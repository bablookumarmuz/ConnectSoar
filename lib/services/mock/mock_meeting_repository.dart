import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/meetings/domain/models/meeting_model.dart';
import '../../features/meetings/domain/models/participant_model.dart';
import '../../features/meetings/domain/repositories/meeting_repository.dart';
import 'mock_data_generator.dart';

class MockMeetingRepository implements MeetingRepository {
  final List<MeetingModel> _meetings = List.from(
    MockDataGenerator.sampleMeetings,
  );
  final List<ParticipantModel> _participants = List.from(
    MockDataGenerator.sampleParticipants,
  );

  @override
  Future<List<MeetingModel>> getMeetings({
    String tab = 'all',
    int page = 0,
    int size = 20,
    String search = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var result = List<MeetingModel>.from(_meetings);
    if (tab == 'live') {
      result = result.where((m) => m.status == MeetingStatus.live).toList();
    } else if (tab == 'upcoming') {
      result = result
          .where((m) => m.status == MeetingStatus.scheduled)
          .toList();
    } else if (tab == 'past') {
      result = result
          .where(
            (m) =>
                m.status == MeetingStatus.ended ||
                m.status == MeetingStatus.cancelled,
          )
          .toList();
    }
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result
          .where(
            (m) =>
                m.title.toLowerCase().contains(q) ||
                m.hostName.toLowerCase().contains(q) ||
                m.joinCode.toLowerCase().contains(q),
          )
          .toList();
    }
    return List.unmodifiable(result);
  }

  @override
  Future<MeetingModel?> getMeetingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _meetings.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MeetingModel?> getMeetingByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final normalized = code.trim().replaceAll(' ', '').toUpperCase();
    try {
      return _meetings.firstWhere(
        (m) =>
            m.joinCode.replaceAll('-', '').toUpperCase() == normalized ||
            m.joinCode.toUpperCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ParticipantModel>> getMeetingParticipants(
    String meetingId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_participants);
  }

  @override
  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required MeetingType type,
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final newMeeting = MeetingModel(
      id: 'mtg_${now.millisecondsSinceEpoch}',
      title: title,
      description: description,
      startTime: now,
      endTime: now.add(const Duration(minutes: 45)),
      status: MeetingStatus.live,
      type: type,
      joinCode:
          'SOAR-${(100 + _meetings.length * 13)}-${(300 + _meetings.length * 7)}',
      hostId: 'usr_admin_1',
      hostName: 'Alex Vance (You)',
      hostAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      participantIds: ['usr_admin_1'],
      password: password,
      isChatAllowed: isChatAllowed,
      isScreenShareAllowed: isScreenShareAllowed,
      isMuteOnEntry: isMuteOnEntry,
      isCameraAllowed: isCameraAllowed,
    );
    _meetings.insert(0, newMeeting);
    return newMeeting;
  }

  @override
  Future<MeetingModel> scheduleMeeting({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    required MeetingType type,
    required RepeatOption repeatOption,
    required String timezone,
    required int reminderMinutes,
    List<String> participantEmails = const [],
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newMeeting = MeetingModel(
      id: 'mtg_sched_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      startTime: startTime,
      endTime: startTime.add(Duration(minutes: durationMinutes)),
      status: MeetingStatus.scheduled,
      type: type,
      repeatOption: repeatOption,
      joinCode:
          'SOAR-${(200 + _meetings.length * 9)}-${(400 + _meetings.length * 3)}',
      hostId: 'usr_admin_1',
      hostName: 'Alex Vance (You)',
      hostAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      participantIds: ['usr_admin_1', ...participantEmails],
      timezone: timezone,
      reminderMinutes: reminderMinutes,
      password: password,
      isChatAllowed: isChatAllowed,
      isScreenShareAllowed: isScreenShareAllowed,
      isMuteOnEntry: isMuteOnEntry,
    );
    _meetings.insert(0, newMeeting);
    return newMeeting;
  }

  @override
  Future<MeetingModel> updateMeeting(
    String meetingId,
    UpdateMeetingRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final old = _meetings[index];
      final updated = old.copyWith(
        title: request.title ?? old.title,
        description: request.description ?? old.description,
        startTime: request.scheduledStartTime ?? old.startTime,
        endTime: request.scheduledEndTime ?? old.endTime,
        isChatAllowed: request.allowParticipantChat ?? old.isChatAllowed,
        isScreenShareAllowed:
            request.allowScreenSharing ?? old.isScreenShareAllowed,
        isMuteOnEntry: request.muteParticipantsOnEntry ?? old.isMuteOnEntry,
        isCameraAllowed: request.allowParticipantVideo ?? old.isCameraAllowed,
      );
      _meetings[index] = updated;
      return updated;
    }
    throw Exception('Meeting not found');
  }

  @override
  Future<MeetingModel> startMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final updated = _meetings[index].copyWith(status: MeetingStatus.live);
      _meetings[index] = updated;
      return updated;
    }
    throw Exception('Meeting not found');
  }

  @override
  Future<Map<String, dynamic>> joinMeeting(
    String meetingId, {
    String? password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'status': 'LIVE', 'meetingId': meetingId};
  }

  @override
  Future<Map<String, dynamic>> joinMeetingByCode(
    String code, {
    String? password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final m = await getMeetingByCode(code);
    if (m != null) {
      return {'status': 'LIVE', 'meetingId': m.id, 'meetingCode': m.joinCode};
    }
    throw Exception('Invalid meeting code');
  }

  @override
  Future<bool> leaveMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return true;
  }

  @override
  Future<MeetingModel?> endMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final updated = _meetings[index].copyWith(status: MeetingStatus.ended);
      _meetings[index] = updated;
      return updated;
    }
    return null;
  }

  @override
  Future<bool> deleteMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      _meetings.removeAt(index);
      return true;
    }
    return false;
  }

  @override
  Future<bool> cancelMeeting(String meetingId) async {
    return deleteMeeting(meetingId);
  }

  @override
  Future<List<MeetingModel>> getRecentMeetings() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_meetings.take(3).toList());
  }
}

// --- Riverpod StateNotifier for Reactive Meetings List ---
class MeetingsNotifier extends StateNotifier<AsyncValue<List<MeetingModel>>> {
  final MeetingRepository _repo;

  MeetingsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadMeetings();
  }

  String _currentTab = 'all';
  String _currentSearch = '';

  Future<void> loadMeetings({
    String? tab,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    if (tab != null) _currentTab = tab;
    if (search != null) _currentSearch = search;

    state = const AsyncValue.loading();
    try {
      final list = await _repo.getMeetings(
        tab: _currentTab,
        search: _currentSearch,
        page: page,
        size: size,
      );
      state = AsyncValue.data(list);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required MeetingType type,
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  }) async {
    final meeting = await _repo.createMeeting(
      title: title,
      description: description,
      type: type,
      password: password,
      isChatAllowed: isChatAllowed,
      isScreenShareAllowed: isScreenShareAllowed,
      isMuteOnEntry: isMuteOnEntry,
      isCameraAllowed: isCameraAllowed,
    );
    await loadMeetings();
    return meeting;
  }

  Future<MeetingModel> scheduleMeeting({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    required MeetingType type,
    required RepeatOption repeatOption,
    required String timezone,
    required int reminderMinutes,
    List<String> participantEmails = const [],
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  }) async {
    final meeting = await _repo.scheduleMeeting(
      title: title,
      description: description,
      startTime: startTime,
      durationMinutes: durationMinutes,
      type: type,
      repeatOption: repeatOption,
      timezone: timezone,
      reminderMinutes: reminderMinutes,
      participantEmails: participantEmails,
      password: password,
      isChatAllowed: isChatAllowed,
      isScreenShareAllowed: isScreenShareAllowed,
      isMuteOnEntry: isMuteOnEntry,
      isCameraAllowed: isCameraAllowed,
    );
    await loadMeetings();
    return meeting;
  }

  Future<MeetingModel> startMeeting(String id) async {
    final meeting = await _repo.startMeeting(id);
    await loadMeetings();
    return meeting;
  }

  Future<MeetingModel?> endMeeting(String id) async {
    final meeting = await _repo.endMeeting(id);
    await loadMeetings();
    return meeting;
  }

  Future<bool> deleteMeeting(String id) async {
    final success = await _repo.deleteMeeting(id);
    if (success) {
      await loadMeetings();
    }
    return success;
  }

  Future<MeetingModel> updateMeeting(
    String id,
    UpdateMeetingRequest request,
  ) async {
    final meeting = await _repo.updateMeeting(id, request);
    await loadMeetings();
    return meeting;
  }

  Future<Map<String, dynamic>> joinMeeting(
    String id, {
    String? password,
  }) async {
    return _repo.joinMeeting(id, password: password);
  }

  Future<Map<String, dynamic>> joinMeetingByCode(
    String code, {
    String? password,
  }) async {
    return _repo.joinMeetingByCode(code, password: password);
  }

  Future<bool> leaveMeeting(String id) async {
    final success = await _repo.leaveMeeting(id);
    await loadMeetings();
    return success;
  }

  Future<bool> cancelMeeting(String id) async {
    final success = await _repo.cancelMeeting(id);
    if (success) {
      await loadMeetings();
    }
    return success;
  }
}

// --- Riverpod Providers ---
final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MockMeetingRepository();
});

final meetingsNotifierProvider =
    StateNotifierProvider<MeetingsNotifier, AsyncValue<List<MeetingModel>>>((
      ref,
    ) {
      final repo = ref.watch(meetingRepositoryProvider);
      return MeetingsNotifier(repo);
    });

// Backward compatible provider
final meetingsListProvider = FutureProvider<List<MeetingModel>>((ref) async {
  final asyncValue = ref.watch(meetingsNotifierProvider);
  return asyncValue.value ?? [];
});

final liveMeetingProvider = FutureProvider<MeetingModel?>((ref) async {
  final asyncValue = ref.watch(meetingsNotifierProvider);
  final meetings = asyncValue.value ?? [];
  try {
    return meetings.firstWhere((m) => m.status == MeetingStatus.live);
  } catch (_) {
    return meetings.isNotEmpty ? meetings.first : null;
  }
});
