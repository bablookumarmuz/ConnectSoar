import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/history/domain/models/meeting_event_model.dart';
import '../../features/history/domain/models/meeting_history_detail_model.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/providers/history_providers.dart'
    show MeetingHistoryFilter;
import '../../features/meetings/domain/models/participant_model.dart';
import 'mock_data_generator.dart';

class MockHistoryRepository implements HistoryRepository {
  final List<MeetingEventModel> _baseHistory = List.from(
    MockDataGenerator.sampleHistory,
  );

  @override
  Future<List<MeetingEventModel>> getMeetingHistory({
    String? searchQuery,
    String? dateFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<MeetingEventModel>.from(_baseHistory);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where(
            (h) =>
                h.title.toLowerCase().contains(q) ||
                h.type.toLowerCase().contains(q) ||
                h.summary.toLowerCase().contains(q),
          )
          .toList();
    }

    if (dateFilter != null && dateFilter != 'all') {
      final now = DateTime.now();
      results = results.where((h) {
        final diff = now.difference(h.timestamp);
        if (dateFilter == 'today') {
          return diff.inDays == 0;
        } else if (dateFilter == 'week') {
          return diff.inDays <= 7;
        } else if (dateFilter == 'month') {
          return diff.inDays <= 30;
        }
        return true;
      }).toList();
    }

    return results;
  }

  @override
  Future<MeetingHistoryDetailModel?> getHistoryDetail(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();

    return MeetingHistoryDetailModel(
      id: 'hist_detail_$meetingId',
      meetingId: meetingId,
      title: 'Sprint 24 Retrospective & Demo',
      description:
          'Review of sprint goals, completed backlog items, performance metrics, and release notes.',
      joinCode: 'SOAR-303-911',
      startTime: now.subtract(const Duration(days: 1, hours: 3)),
      endTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 15)),
      hostName: 'Marcus Brody',
      hostAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      type: 'Sprint Retrospective',
      summary:
          'Completed 18 story points, resolved 4 UI accessibility issues, and reviewed performance benchmarks.',
      durationMinutes: 45,
      screenShareDurationMinutes: 24,
      chatMessageCount: 19,
      participants: const [
        ParticipantModel(
          id: 'p_1',
          userId: 'usr_emp_1',
          name: 'Marcus Brody',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          role: ParticipantRole.host,
        ),
        ParticipantModel(
          id: 'p_2',
          userId: 'usr_mgr_1',
          name: 'Sophia Chen',
          avatarUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
          role: ParticipantRole.coHost,
        ),
        ParticipantModel(
          id: 'p_3',
          userId: 'usr_admin_1',
          name: 'Alex Vance',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          role: ParticipantRole.attendee,
        ),
        ParticipantModel(
          id: 'p_4',
          userId: 'usr_emp_2',
          name: 'Elena Rostova',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          role: ParticipantRole.attendee,
        ),
      ],
      timelineEvents: [
        MeetingTimelineEvent(
          id: 't_1',
          title: 'Meeting Created',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 3, minutes: 10),
          ),
          category: 'created',
          participantName: 'Marcus Brody',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          detail: 'Join code generated: SOAR-303-911',
        ),
        MeetingTimelineEvent(
          id: 't_2',
          title: 'Meeting Started',
          timestamp: now.subtract(const Duration(days: 1, hours: 3)),
          category: 'started',
          participantName: 'Marcus Brody',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          detail: 'Host initiated live WebRTC session',
        ),
        MeetingTimelineEvent(
          id: 't_3',
          title: 'User Joined',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 2, minutes: 58),
          ),
          category: 'joined',
          participantName: 'Sophia Chen',
          avatarUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
          detail: 'Joined as Co-Host',
        ),
        MeetingTimelineEvent(
          id: 't_4',
          title: 'User Joined',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 2, minutes: 55),
          ),
          category: 'joined',
          participantName: 'Alex Vance',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          detail: 'Joined via Desktop App',
        ),
        MeetingTimelineEvent(
          id: 't_5',
          title: 'Screen Sharing Started',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 2, minutes: 45),
          ),
          category: 'screenshare_started',
          participantName: 'Marcus Brody',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          detail: 'Shared "Sprint 24 Jira Board & Burndown Chart"',
        ),
        MeetingTimelineEvent(
          id: 't_6',
          title: 'Screen Sharing Stopped',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 2, minutes: 21),
          ),
          category: 'screenshare_stopped',
          participantName: 'Marcus Brody',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          detail: 'Total sharing duration: 24 mins',
        ),
        MeetingTimelineEvent(
          id: 't_7',
          title: 'User Left',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 2, minutes: 16),
          ),
          category: 'left',
          participantName: 'Alex Vance',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          detail: 'Session disconnected normally',
        ),
        MeetingTimelineEvent(
          id: 't_8',
          title: 'Meeting Ended',
          timestamp: now.subtract(
            const Duration(days: 1, hours: 2, minutes: 15),
          ),
          category: 'ended',
          participantName: 'Marcus Brody',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          detail: 'Meeting ended by Host. Transcript saved.',
        ),
      ],
    );
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return MockHistoryRepository();
});

final meetingHistoryListProvider =
    FutureProvider.family<List<MeetingEventModel>, MeetingHistoryFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.watch(historyRepositoryProvider);
      return repo.getMeetingHistory(
        searchQuery: filter.query,
        dateFilter: filter.date,
      );
    });

final meetingHistoryDetailProvider =
    FutureProvider.family<MeetingHistoryDetailModel?, String>((
      ref,
      meetingId,
    ) async {
      final repo = ref.watch(historyRepositoryProvider);
      return repo.getHistoryDetail(meetingId);
    });
