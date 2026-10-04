import 'package:flutter_test/flutter_test.dart';
import 'package:connectsoar/features/auth/domain/models/user_model.dart';
import 'package:connectsoar/features/meetings/domain/models/meeting_model.dart';
import 'package:connectsoar/services/mock/mock_auth_repository.dart';
import 'package:connectsoar/services/mock/mock_meeting_repository.dart';

void main() {
  group('ConnectSoar Unit & Mock Integration Tests', () {
    test('MockAuthRepository returns sample user session', () async {
      final repo = MockAuthRepository();
      final user = await repo.login(
        email: 'alex.vance@connectsoar.io',
        password: 'password123',
      );

      expect(user.name, equals('Alex Vance'));
      expect(user.role, equals(UserRole.admin));
      expect(user.email, equals('alex.vance@connectsoar.io'));

      final token = await repo.getAuthToken();
      expect(token, contains('mock_jwt_token'));
    });

    test('MockMeetingRepository returns live and scheduled meetings', () async {
      final repo = MockMeetingRepository();
      final meetings = await repo.getMeetings();

      expect(meetings.isNotEmpty, isTrue);
      final liveMeetings = meetings
          .where((m) => m.status == MeetingStatus.live)
          .toList();
      expect(liveMeetings.length, equals(1));
      expect(liveMeetings.first.title, contains('Architecture Sync'));
    });
  });
}
