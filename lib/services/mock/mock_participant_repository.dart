import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/meetings/domain/models/participant_model.dart';
import '../../features/meetings/domain/repositories/participant_repository.dart';
import 'mock_data_generator.dart';

class MockParticipantRepository implements ParticipantRepository {
  final List<ParticipantModel> _participants = List.from(
    MockDataGenerator.sampleParticipants,
  );

  @override
  Future<List<ParticipantModel>> getParticipants(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_participants);
  }

  @override
  Future<ParticipantModel> inviteParticipant(
    String meetingId, {
    required String email,
    String role = 'PARTICIPANT',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newP = ParticipantModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
      avatarUrl: '',
      role: role == 'HOST'
          ? ParticipantRole.host
          : role == 'CO_HOST'
          ? ParticipantRole.coHost
          : ParticipantRole.attendee,
      status: 'INVITED',
    );
    _participants.add(newP);
    return newP;
  }

  @override
  Future<ParticipantModel> addParticipant(
    String meetingId,
    String userId,
    String name,
    String avatarUrl,
    ParticipantRole role,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newP = ParticipantModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: name,
      email: '$userId@connectsoar.com',
      avatarUrl: avatarUrl,
      role: role,
    );
    _participants.add(newP);
    return newP;
  }

  @override
  Future<bool> removeParticipant(String meetingId, String participantId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _participants.indexWhere((p) => p.id == participantId);
    if (idx != -1) {
      _participants.removeAt(idx);
      return true;
    }
    return false;
  }

  @override
  Future<void> updateAudioStatus(
    String meetingId,
    String participantId,
    bool isMuted,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _participants.indexWhere((p) => p.id == participantId);
    if (idx != -1) {
      _participants[idx] = _participants[idx].copyWith(isMuted: isMuted);
    }
  }

  @override
  Future<void> updateVideoStatus(
    String meetingId,
    String participantId,
    bool isVideoOff,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _participants.indexWhere((p) => p.id == participantId);
    if (idx != -1) {
      _participants[idx] = _participants[idx].copyWith(isVideoOff: isVideoOff);
    }
  }

  @override
  Future<void> updateHandRaisedStatus(
    String meetingId,
    String participantId,
    bool isHandRaised,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _participants.indexWhere((p) => p.id == participantId);
    if (idx != -1) {
      _participants[idx] = _participants[idx].copyWith(
        isHandRaised: isHandRaised,
      );
    }
  }

  @override
  Future<void> updateParticipantRole(
    String meetingId,
    String participantId,
    ParticipantRole newRole, {
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _participants.indexWhere(
      (p) => p.id == participantId || p.userId == participantId,
    );
    if (idx != -1) {
      _participants[idx] = _participants[idx].copyWith(
        role: newRole,
        status: status ?? _participants[idx].status,
      );
    }
  }
}

final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
  return MockParticipantRepository();
});
