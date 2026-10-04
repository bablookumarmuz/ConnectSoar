import '../../features/auth/domain/models/user_model.dart';
import '../../features/meetings/domain/models/meeting_model.dart';
import '../../features/meetings/domain/models/participant_model.dart';
import '../../features/chat/domain/models/chat_message_model.dart';
import '../../features/chat/domain/models/chat_thread_model.dart';
import '../../features/notifications/domain/models/notification_model.dart';
import '../../features/history/domain/models/meeting_event_model.dart';
import '../../features/analytics/domain/models/analytics_summary_model.dart';

abstract class MockDataGenerator {
  static const List<UserModel> sampleUsers = [
    UserModel(
      id: 'usr_admin_1',
      name: 'Alex Vance',
      email: 'alex.vance@connectsoar.io',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      role: UserRole.admin,
      status: UserStatus.online,
      department: 'Engineering',
      title: 'VP of Platform Architecture',
    ),
    UserModel(
      id: 'usr_mgr_1',
      name: 'Sophia Chen',
      email: 'sophia.chen@connectsoar.io',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      role: UserRole.manager,
      status: UserStatus.busy,
      department: 'Product Design',
      title: 'Head of Product Design',
    ),
    UserModel(
      id: 'usr_emp_1',
      name: 'Marcus Brody',
      email: 'marcus.brody@connectsoar.io',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      role: UserRole.employee,
      status: UserStatus.online,
      department: 'Frontend Engineering',
      title: 'Senior Flutter Engineer',
    ),
    UserModel(
      id: 'usr_emp_2',
      name: 'Elena Rostova',
      email: 'elena.r@connectsoar.io',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      role: UserRole.employee,
      status: UserStatus.away,
      department: 'AI & Data Science',
      title: 'Lead ML Engineer',
    ),
    UserModel(
      id: 'usr_emp_3',
      name: 'David Kim',
      email: 'david.k@connectsoar.io',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      role: UserRole.employee,
      status: UserStatus.offline,
      department: 'DevOps & Cloud',
      title: 'Site Reliability Engineer',
    ),
  ];

  static List<MeetingModel> get sampleMeetings {
    final now = DateTime.now();
    return [
      MeetingModel(
        id: 'mtg_live_1',
        title: 'ConnectSoar Architecture Sync & Q3 Roadmap',
        description:
            'Reviewing real-time video infrastructure, WebRTC gateway and FastAPI backend integration plan.',
        startTime: now.subtract(const Duration(minutes: 25)),
        endTime: now.add(const Duration(minutes: 35)),
        status: MeetingStatus.live,
        type: MeetingType.teamSync,
        repeatOption: RepeatOption.weekly,
        joinCode: 'SOAR-982-314',
        hostId: 'usr_admin_1',
        hostName: 'Alex Vance',
        hostAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        participantIds: ['usr_admin_1', 'usr_mgr_1', 'usr_emp_1', 'usr_emp_2'],
        timezone: 'UTC+05:30 (IST)',
        reminderMinutes: 15,
        password: 'soar2026password',
        isChatAllowed: true,
        isScreenShareAllowed: true,
        isMuteOnEntry: false,
        isCameraAllowed: true,
      ),
      MeetingModel(
        id: 'mtg_sched_1',
        title: 'Design System & Accessibility Review',
        description:
            'Material 3 design language tokens, typography hierarchy, and high contrast dark theme audit.',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        status: MeetingStatus.scheduled,
        type: MeetingType.scheduled,
        repeatOption: RepeatOption.never,
        joinCode: 'SOAR-415-890',
        hostId: 'usr_mgr_1',
        hostName: 'Sophia Chen',
        hostAvatarUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        participantIds: ['usr_mgr_1', 'usr_emp_1'],
        timezone: 'UTC+00:00 (GMT)',
        reminderMinutes: 10,
        isChatAllowed: true,
        isScreenShareAllowed: true,
        isMuteOnEntry: true,
      ),
      MeetingModel(
        id: 'mtg_sched_2',
        title: 'Weekly All-Hands & Product Updates',
        description:
            'Company-wide status sync, engineering team announcements, product launch milestones, and live Q&A session.',
        startTime: now.add(const Duration(days: 1, hours: 4)),
        endTime: now.add(const Duration(days: 1, hours: 5, minutes: 30)),
        status: MeetingStatus.scheduled,
        type: MeetingType.webinar,
        repeatOption: RepeatOption.weekly,
        joinCode: 'SOAR-771-002',
        hostId: 'usr_admin_1',
        hostName: 'Alex Vance',
        hostAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        participantIds: [
          'usr_admin_1',
          'usr_mgr_1',
          'usr_emp_1',
          'usr_emp_2',
          'usr_emp_3',
        ],
        timezone: 'UTC-05:00 (EST)',
        reminderMinutes: 30,
        password: 'allhandspass',
        isChatAllowed: true,
        isScreenShareAllowed: false,
        isMuteOnEntry: true,
      ),
      MeetingModel(
        id: 'mtg_sched_3',
        title: '1-on-1 Engineering Mentorship',
        description:
            'Career growth sync, code review best practices, and architecture deep dive.',
        startTime: now.add(const Duration(days: 2, hours: 1)),
        endTime: now.add(const Duration(days: 2, hours: 1, minutes: 45)),
        status: MeetingStatus.scheduled,
        type: MeetingType.oneOnOne,
        repeatOption: RepeatOption.weekly,
        joinCode: 'SOAR-101-555',
        hostId: 'usr_admin_1',
        hostName: 'Alex Vance',
        hostAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        participantIds: ['usr_admin_1', 'usr_emp_1'],
        timezone: 'UTC+05:30 (IST)',
        reminderMinutes: 15,
      ),
      MeetingModel(
        id: 'mtg_ended_1',
        title: 'Sprint 24 Retrospective & Demo',
        description:
            'Review of sprint goals, completed backlog items, performance metrics, and release notes.',
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        endTime: now.subtract(const Duration(days: 1, hours: 2)),
        status: MeetingStatus.ended,
        type: MeetingType.scheduled,
        repeatOption: RepeatOption.never,
        joinCode: 'SOAR-303-911',
        hostId: 'usr_emp_1',
        hostName: 'Marcus Brody',
        hostAvatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        participantIds: ['usr_emp_1', 'usr_mgr_1', 'usr_emp_2'],
        timezone: 'UTC+00:00 (GMT)',
      ),
      MeetingModel(
        id: 'mtg_ended_2',
        title: 'AI & ML Pipeline Optimization Sync',
        description:
            'Discussion on low-latency transcription models and WebSockets streaming buffers.',
        startTime: now.subtract(const Duration(days: 3, hours: 4)),
        endTime: now.subtract(const Duration(days: 3, hours: 3)),
        status: MeetingStatus.ended,
        type: MeetingType.teamSync,
        repeatOption: RepeatOption.monthly,
        joinCode: 'SOAR-552-819',
        hostId: 'usr_emp_2',
        hostName: 'Elena Rostova',
        hostAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        participantIds: ['usr_emp_2', 'usr_admin_1'],
        timezone: 'UTC+03:00 (MSK)',
      ),
    ];
  }

  static const List<ParticipantModel> sampleParticipants = [
    ParticipantModel(
      id: 'p_1',
      userId: 'usr_admin_1',
      name: 'Alex Vance',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      role: ParticipantRole.host,
      isMuted: false,
      isVideoOff: false,
      isScreenSharing: true,
    ),
    ParticipantModel(
      id: 'p_2',
      userId: 'usr_mgr_1',
      name: 'Sophia Chen',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      role: ParticipantRole.coHost,
      isMuted: true,
      isVideoOff: false,
    ),
    ParticipantModel(
      id: 'p_3',
      userId: 'usr_emp_1',
      name: 'Marcus Brody',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      role: ParticipantRole.attendee,
      isMuted: false,
      isVideoOff: false,
      isHandRaised: true,
    ),
    ParticipantModel(
      id: 'p_4',
      userId: 'usr_emp_2',
      name: 'Elena Rostova',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      role: ParticipantRole.attendee,
      isMuted: true,
      isVideoOff: true,
    ),
  ];

  static List<ChatThreadModel> get sampleChatThreads {
    final now = DateTime.now();
    return [
      ChatThreadModel(
        id: 'th_live_1',
        title: 'ConnectSoar Architecture Sync',
        subtitle: '4 participants active',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        type: ChatThreadType.meeting,
        meetingId: 'mtg_live_1',
        participantIds: ['usr_admin_1', 'usr_mgr_1', 'usr_emp_1', 'usr_emp_2'],
        lastMessage: 'I uploaded the system design slides PDF.',
        lastMessageTime: now.subtract(const Duration(minutes: 2)),
        unreadCount: 2,
        isPinned: true,
        isOnline: true,
      ),
      ChatThreadModel(
        id: 'th_dm_sophia',
        title: 'Sophia Chen',
        subtitle: 'Head of Product Design',
        avatarUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        type: ChatThreadType.direct,
        otherUserId: 'usr_mgr_1',
        participantIds: ['usr_admin_1', 'usr_mgr_1'],
        lastMessage: 'Let us review the audit log UI specs after lunch.',
        lastMessageTime: now.subtract(const Duration(minutes: 18)),
        unreadCount: 1,
        isPinned: true,
        isOnline: true,
      ),
      ChatThreadModel(
        id: 'th_dm_marcus',
        title: 'Marcus Brody',
        subtitle: 'Senior Flutter Engineer',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        type: ChatThreadType.direct,
        otherUserId: 'usr_emp_1',
        participantIds: ['usr_admin_1', 'usr_emp_1'],
        lastMessage: 'PR for the reaction picker is ready for review!',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: 0,
        isPinned: false,
        isOnline: true,
      ),
      ChatThreadModel(
        id: 'th_dm_elena',
        title: 'Elena Rostova',
        subtitle: 'Lead ML Engineer',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        type: ChatThreadType.direct,
        otherUserId: 'usr_emp_2',
        participantIds: ['usr_admin_1', 'usr_emp_2'],
        lastMessage: 'Whisper AI transcription model benchmark: 140ms latency.',
        lastMessageTime: now.subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isPinned: false,
        isOnline: false,
      ),
    ];
  }

  static List<ChatMessageModel> get sampleChatMessages {
    final now = DateTime.now();
    return [
      ChatMessageModel(
        id: 'msg_0',
        meetingId: 'mtg_live_1',
        threadId: 'th_live_1',
        senderId: 'sys',
        senderName: 'System',
        senderAvatar: '',
        message:
            'Alex Vance pinned a message: "Architecture diagram & WebRTC gateway docs updated."',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: MessageType.system,
        isPinned: true,
      ),
      ChatMessageModel(
        id: 'msg_1',
        meetingId: 'mtg_live_1',
        threadId: 'th_live_1',
        senderId: 'usr_admin_1',
        senderName: 'Alex Vance',
        senderAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        message:
            'Welcome everyone! @Sophia Chen @Marcus Brody I am currently sharing the architecture diagram.',
        timestamp: now.subtract(const Duration(minutes: 20)),
        mentions: ['Sophia Chen', 'Marcus Brody'],
        reactions: {
          '👍': ['usr_mgr_1', 'usr_emp_1'],
          '🔥': ['usr_emp_2'],
        },
        isPinned: true,
      ),
      ChatMessageModel(
        id: 'msg_2',
        meetingId: 'mtg_live_1',
        threadId: 'th_live_1',
        senderId: 'usr_mgr_1',
        senderName: 'Sophia Chen',
        senderAvatar:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        message:
            'The new Material 3 dark surface colors look super clean! Great work design system team.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        replyToMessageId: 'msg_1',
        replyToSenderName: 'Alex Vance',
        replyToMessageText:
            'Welcome everyone! @Sophia Chen @Marcus Brody I am currently sharing...',
        reactions: {
          '❤️': ['usr_admin_1'],
          '🚀': ['usr_emp_1'],
        },
      ),
      ChatMessageModel(
        id: 'msg_3',
        meetingId: 'mtg_live_1',
        threadId: 'th_live_1',
        senderId: 'usr_emp_1',
        senderName: 'Marcus Brody',
        senderAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        message:
            'I raised my hand with a quick question regarding Riverpod state management in `@Alex Vance`.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        mentions: ['Alex Vance'],
        reactions: {
          '👍': ['usr_admin_1'],
        },
      ),
      ChatMessageModel(
        id: 'msg_4',
        meetingId: 'mtg_live_1',
        threadId: 'th_live_1',
        senderId: 'usr_emp_2',
        senderName: 'Elena Rostova',
        senderAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        message: 'I uploaded the system design slides PDF for reference.',
        timestamp: now.subtract(const Duration(minutes: 2)),
        type: MessageType.file,
        fileName: 'ConnectSoar_Architecture_v2.pdf',
        fileSize: '4.2 MB',
        fileUrl: 'https://connectsoar.io/docs/architecture_v2.pdf',
        reactions: {
          '🔥': ['usr_admin_1', 'usr_mgr_1'],
        },
      ),
      // Direct message thread sample messages
      ChatMessageModel(
        id: 'msg_dm_1',
        meetingId: '',
        threadId: 'th_dm_sophia',
        senderId: 'usr_mgr_1',
        senderName: 'Sophia Chen',
        senderAvatar:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        message:
            'Hey Alex! Have you had a chance to review the audit log filter mockups?',
        timestamp: now.subtract(const Duration(minutes: 40)),
      ),
      ChatMessageModel(
        id: 'msg_dm_2',
        meetingId: '',
        threadId: 'th_dm_sophia',
        senderId: 'usr_admin_1',
        senderName: 'Alex Vance',
        senderAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        message:
            'Yes! The action chip filters and IP metadata preview look fantastic.',
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
      ChatMessageModel(
        id: 'msg_dm_3',
        meetingId: '',
        threadId: 'th_dm_sophia',
        senderId: 'usr_mgr_1',
        senderName: 'Sophia Chen',
        senderAvatar:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        message: 'Let us review the audit log UI specs after lunch.',
        timestamp: now.subtract(const Duration(minutes: 18)),
      ),
    ];
  }

  static List<NotificationModel> get sampleNotifications {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_rem_1',
        title: 'Meeting Reminder: Architecture Sync',
        message:
            'Your live session "ConnectSoar Architecture Sync" is running now.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        type: NotificationType.meeting,
        meetingId: 'mtg_live_1',
        hostName: 'Alex Vance',
        meetingTime: 'Started 25m ago',
        joinCode: 'SOAR-982-314',
      ),
      NotificationModel(
        id: 'notif_1',
        title: 'Meeting Invite: Design Review',
        message:
            'Sophia Chen invited you to "Design System & Accessibility Review"',
        timestamp: now.subtract(const Duration(minutes: 45)),
        type: NotificationType.invite,
        meetingId: 'mtg_sched_1',
        hostName: 'Sophia Chen',
        meetingTime: 'Today at 5:00 PM',
        joinCode: 'SOAR-415-890',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Upcoming Webinar Reminder',
        message:
            'Weekly All-Hands & Product Updates starts tomorrow at 10:00 AM',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        type: NotificationType.meeting,
        meetingId: 'mtg_sched_2',
        hostName: 'Alex Vance',
        meetingTime: 'Tomorrow at 10:00 AM',
        joinCode: 'SOAR-771-002',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'System Security Update',
        message: 'ConnectSoar v1.0 design system tokens deployed successfully.',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        type: NotificationType.system,
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'Audit Log Alert',
        message: 'Role changed for Marcus Brody by Admin Alex Vance.',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: true,
        type: NotificationType.alert,
      ),
    ];
  }

  static List<MeetingEventModel> get sampleHistory {
    final now = DateTime.now();
    return [
      MeetingEventModel(
        id: 'hist_1',
        meetingId: 'mtg_ended_1',
        title: 'Sprint 24 Retrospective & Demo',
        timestamp: now.subtract(const Duration(days: 1)),
        type: 'Retrospective',
        summary:
            'Completed 18 story points, resolved 4 UI accessibility issues.',
        durationMinutes: 45,
        participantCount: 6,
      ),
      MeetingEventModel(
        id: 'hist_2',
        meetingId: 'mtg_ended_2',
        title: 'FastAPI Backend API Schema Sync',
        timestamp: now.subtract(const Duration(days: 3)),
        type: 'Engineering',
        summary: 'Aligned endpoint contracts for OAuth2 and WebSockets.',
        durationMinutes: 60,
        participantCount: 4,
      ),
    ];
  }

  static const AnalyticsSummaryModel sampleAnalytics = AnalyticsSummaryModel(
    totalMeetings: 148,
    totalHours: 312.5,
    activeUsers: 84,
    peakConcurrentMeetings: 12,
    completionRate: 98.4,
    monthlyGrowthPercent: 18.2,
    weeklyMeetingCounts: [12, 19, 15, 22, 28, 25, 27],
  );
}
