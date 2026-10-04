import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_meeting_repository.dart';
import '../../../services/mock/mock_participant_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_meeting_repository.dart';
import '../../../services/remote/remote_participant_repository.dart';
import '../domain/models/meeting_model.dart';
import '../domain/repositories/meeting_repository.dart';
import '../domain/repositories/participant_repository.dart';

export '../../../services/mock/mock_meeting_repository.dart'
    show MeetingsNotifier;

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockMeetingRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteMeetingRepository(client);
});

final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockParticipantRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteParticipantRepository(client);
});

final meetingsNotifierProvider =
    StateNotifierProvider<MeetingsNotifier, AsyncValue<List<MeetingModel>>>((
      ref,
    ) {
      final repo = ref.watch(meetingRepositoryProvider);
      return MeetingsNotifier(repo);
    });

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
