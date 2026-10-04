import 'package:flutter_test/flutter_test.dart';
import 'package:connectsoar/core/config/api_config.dart';
import 'package:connectsoar/features/chat/domain/models/chat_message_model.dart';
import 'package:connectsoar/features/meetings/domain/models/meeting_model.dart';
import 'package:connectsoar/features/meetings/domain/models/participant_model.dart';
import 'package:connectsoar/services/mock/mock_meeting_repository.dart';

void main() {
  group('Meeting Module Unit Tests — Real API Contract & Endpoints', () {
    test(
      'ApiConfig strictly contains /api/meetings and NOT /api/v1/meetings',
      () {
        expect(
          ApiConfig.baseUrl,
          equals('https://connectsoar-backend.onrender.com'),
        );
        expect(ApiConfig.meetingsEndpoint, equals('/api/meetings'));
        expect(ApiConfig.createInstantMeetingEndpoint, equals('/api/meetings'));
        expect(ApiConfig.scheduleMeetingEndpoint, equals('/api/meetings'));
        expect(
          ApiConfig.joinMeetingCodeEndpoint,
          equals('/api/meetings/join-code'),
        );
        expect(
          ApiConfig.meetingDetailsEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101'),
        );
        expect(
          ApiConfig.meetingStartEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101/start'),
        );
        expect(
          ApiConfig.meetingJoinEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101/join'),
        );
        expect(
          ApiConfig.meetingLeaveEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101/leave'),
        );
        expect(
          ApiConfig.meetingEndEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101/end'),
        );
        expect(
          ApiConfig.meetingParticipantsEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101/participants'),
        );
        expect(
          ApiConfig.meetingMessagesEndpoint('mtg-101'),
          equals('/api/meetings/mtg-101/messages'),
        );

        // WebSocket Signaling URL verification
        final wsUrl = ApiConfig.meetingSignalingWsUrl(
          'mtg-101',
          'sample_token_xyz',
        );
        expect(
          wsUrl,
          equals(
            'wss://connectsoar-backend.onrender.com/ws/meetings/mtg-101?token=sample_token_xyz',
          ),
        );
      },
    );

    test('MeetingModel.fromJson parses real production backend structure', () {
      final json = {
        "id": "e3048ec1-c2e3-460d-9b19-48245582f347",
        "title": "Production Sprint Planning",
        "description": "Bi-weekly sprint kick-off with engineering",
        "meeting_type": "SCHEDULED_MEETING",
        "scheduled_start_time": "2026-09-08T10:00:00Z",
        "scheduled_end_time": "2026-09-08T11:00:00Z",
        "duration_minutes": 60,
        "meeting_code": "847291054",
        "meeting_link":
            "https://connectsoar-backend.onrender.com/meeting/847291054",
        "status": "SCHEDULED",
        "host": {
          "id": "usr_emp_123",
          "name": "Alex Vance",
          "avatar_url": "https://example.com/avatar.jpg",
        },
        "permissions": {
          "allow_participant_chat": true,
          "allow_screen_sharing": true,
          "mute_participants_on_entry": false,
          "allow_participant_video": true,
        },
        "created_at": "2026-09-08T08:00:00Z",
        "updated_at": "2026-09-08T08:00:00Z",
      };

      final meeting = MeetingModel.fromJson(json);

      expect(meeting.id, equals("e3048ec1-c2e3-460d-9b19-48245582f347"));
      expect(meeting.title, equals("Production Sprint Planning"));
      expect(
        meeting.description,
        equals("Bi-weekly sprint kick-off with engineering"),
      );
      expect(meeting.joinCode, equals("847291054"));
      expect(
        meeting.meetingLink,
        equals("https://connectsoar-backend.onrender.com/meeting/847291054"),
      );
      expect(meeting.status, equals(MeetingStatus.scheduled));
      expect(meeting.hostId, equals("usr_emp_123"));
      expect(meeting.hostName, equals("Alex Vance"));
      expect(meeting.hostAvatarUrl, equals("https://example.com/avatar.jpg"));
      expect(meeting.isChatAllowed, isTrue);
      expect(meeting.isScreenShareAllowed, isTrue);
      expect(meeting.isMuteOnEntry, isFalse);
      expect(meeting.isCameraAllowed, isTrue);
      expect(meeting.durationMinutes, equals(60));
    });

    test('PaginatedMeetings.fromJson handles paginated API response', () {
      final paginatedJson = {
        "content": [
          {
            "id": "mtg-1",
            "title": "Design Sync",
            "meeting_type": "INSTANT_MEETING",
            "status": "LIVE",
            "meeting_code": "123456789",
            "scheduled_start_time": "2026-09-08T12:00:00Z",
            "scheduled_end_time": "2026-09-08T13:00:00Z",
            "host_id": "usr_admin_1",
            "host_name": "Admin User",
          },
        ],
        "page": 0,
        "size": 20,
        "totalElements": 1,
        "totalPages": 1,
      };

      final paginated = PaginatedMeetings.fromJson(paginatedJson);

      expect(paginated.content.length, equals(1));
      expect(paginated.content.first.id, equals("mtg-1"));
      expect(paginated.content.first.isLive, isTrue);
      expect(paginated.page, equals(0));
      expect(paginated.size, equals(20));
      expect(paginated.totalElements, equals(1));
      expect(paginated.totalPages, equals(1));
    });

    test(
      'ParticipantModel.fromJson and toJson maps role, email, status correctly',
      () {
        final json = {
          "id": "part-99",
          "user_id": "usr_mgr_1",
          "name": "Sophia Chen",
          "email": "sophia@example.com",
          "avatar_url": "https://example.com/sophia.jpg",
          "role": "HOST",
          "status": "JOINED",
          "is_muted": true,
          "is_video_off": false,
          "is_hand_raised": true,
          "joined_at": "2026-09-08T10:05:00Z",
        };

        final participant = ParticipantModel.fromJson(json);

        expect(participant.id, equals("part-99"));
        expect(participant.userId, equals("usr_mgr_1"));
        expect(participant.name, equals("Sophia Chen"));
        expect(participant.email, equals("sophia@example.com"));
        expect(participant.role, equals(ParticipantRole.host));
        expect(participant.status, equals("JOINED"));
        expect(participant.isMuted, isTrue);
        expect(participant.isVideoOff, isFalse);
        expect(participant.isHandRaised, isTrue);

        final outMap = participant.toJson();
        expect(outMap['userId'], equals("usr_mgr_1"));
        expect(outMap['role'], equals('host'));
        expect(outMap['email'], equals('sophia@example.com'));
      },
    );

    test('ChatMessageModel.fromJson maps in-meeting message correctly', () {
      final json = {
        "id": "msg-001",
        "thread_id": "mtg-101",
        "meeting_id": "mtg-101",
        "sender_id": "usr_emp_2",
        "sender_name": "Elena Rostova",
        "sender_avatar": "https://example.com/elena.jpg",
        "message": "Here is the shared Figma link!",
        "created_at": "2026-09-08T10:15:00Z",
      };

      final chatMsg = ChatMessageModel.fromJson(json);

      expect(chatMsg.id, equals("msg-001"));
      expect(chatMsg.threadId, equals("mtg-101"));
      expect(chatMsg.meetingId, equals("mtg-101"));
      expect(chatMsg.senderId, equals("usr_emp_2"));
      expect(chatMsg.senderName, equals("Elena Rostova"));
      expect(chatMsg.message, equals("Here is the shared Figma link!"));
    });

    test('CreateScheduledMeetingRequest.toJson generates required payload', () {
      final startTime = DateTime.utc(2026, 9, 8, 14, 0);
      final req = CreateScheduledMeetingRequest(
        title: "Architecture Review",
        description: "Reviewing microservice architecture",
        scheduledStartTime: startTime,
        scheduledEndTime: startTime.add(const Duration(minutes: 45)),
        durationMinutes: 45,
        invitedEmails: const ["dev1@example.com", "dev2@example.com"],
        allowParticipantChat: true,
        allowScreenSharing: true,
        muteParticipantsOnEntry: true,
        allowParticipantVideo: true,
      );

      final map = req.toJson();

      expect(map['title'], equals("Architecture Review"));
      expect(map['description'], equals("Reviewing microservice architecture"));
      expect(map['scheduled_start_time'], equals(startTime.toIso8601String()));
      expect(map['duration_minutes'], equals(45));
      expect(map['invited_emails'], contains("dev1@example.com"));
      expect(map['allow_participant_chat'], isTrue);
      expect(map['mute_participants_on_entry'], isTrue);
    });

    test(
      'MockMeetingRepository performs all meeting lifecycle operations',
      () async {
        final repo = MockMeetingRepository();

        // 1. Get Meetings
        final initialMeetings = await repo.getMeetings();
        expect(initialMeetings.isNotEmpty, isTrue);

        // 2. Create Instant Meeting
        final instant = await repo.createMeeting(
          title: "Test Instant Call",
          description: "Ad-hoc sync",
          type: MeetingType.instant,
        );
        expect(instant.status, equals(MeetingStatus.live));
        expect(instant.title, equals("Test Instant Call"));

        // 3. Start Meeting
        final started = await repo.startMeeting(instant.id);
        expect(started.isLive, isTrue);

        // 4. Join Meeting
        final joinResult = await repo.joinMeeting(instant.id);
        expect(joinResult['status'], equals('LIVE'));

        // 5. Leave Meeting
        final left = await repo.leaveMeeting(instant.id);
        expect(left, isTrue);

        // 6. End Meeting
        final ended = await repo.endMeeting(instant.id);
        expect(ended?.status, equals(MeetingStatus.ended));

        // 7. Delete Meeting
        final deleted = await repo.deleteMeeting(instant.id);
        expect(deleted, isTrue);
      },
    );

    test(
      'MeetingStatus enum has valid name, displayName, and label getters',
      () {
        expect(MeetingStatus.scheduled.name, equals('scheduled'));
        expect(MeetingStatus.scheduled.displayName, equals('Scheduled'));
        expect(MeetingStatus.scheduled.label, equals('Scheduled'));

        expect(MeetingStatus.live.name, equals('live'));
        expect(MeetingStatus.live.displayName, equals('Live'));
        expect(MeetingStatus.live.label, equals('Live'));

        expect(MeetingStatus.ended.name, equals('ended'));
        expect(MeetingStatus.ended.displayName, equals('Ended'));
        expect(MeetingStatus.ended.label, equals('Ended'));

        expect(MeetingStatus.cancelled.name, equals('cancelled'));
        expect(MeetingStatus.cancelled.displayName, equals('Cancelled'));
        expect(MeetingStatus.cancelled.label, equals('Cancelled'));
      },
    );

    test('Meeting filter tab logic matches correctly', () {
      bool matchesTab(int tabIndex, MeetingStatus status) {
        switch (tabIndex) {
          case 0: // Upcoming
            return status == MeetingStatus.scheduled;
          case 1: // Live Now
            return status == MeetingStatus.live;
          case 2: // Completed
            return status == MeetingStatus.ended ||
                status == MeetingStatus.cancelled;
          default:
            return false;
        }
      }

      expect(matchesTab(0, MeetingStatus.scheduled), isTrue);
      expect(matchesTab(0, MeetingStatus.live), isFalse);

      expect(matchesTab(1, MeetingStatus.live), isTrue);
      expect(matchesTab(1, MeetingStatus.scheduled), isFalse);

      expect(matchesTab(2, MeetingStatus.ended), isTrue);
      expect(matchesTab(2, MeetingStatus.cancelled), isTrue);
      expect(matchesTab(2, MeetingStatus.scheduled), isFalse);
    });
  });
}
