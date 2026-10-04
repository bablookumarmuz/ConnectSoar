enum MeetingStatus {
  scheduled,
  live,
  ended,
  cancelled;

  String get displayName => switch (this) {
    MeetingStatus.scheduled => 'Scheduled',
    MeetingStatus.live => 'Live',
    MeetingStatus.ended => 'Ended',
    MeetingStatus.cancelled => 'Cancelled',
  };

  String get name => switch (this) {
    MeetingStatus.scheduled => 'scheduled',
    MeetingStatus.live => 'live',
    MeetingStatus.ended => 'ended',
    MeetingStatus.cancelled => 'cancelled',
  };

  String get label => displayName;
}

enum MeetingType { instant, scheduled, recurring, webinar, teamSync, oneOnOne }

enum RepeatOption { never, daily, weekly, monthly }

class MeetingModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final MeetingStatus status;
  final MeetingType type;
  final RepeatOption repeatOption;
  final String joinCode;
  final String hostId;
  final String hostName;
  final String? hostAvatarUrl;
  final List<String> participantIds;
  final int participantCount;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final String timezone;
  final int reminderMinutes;
  final String? password;
  final bool isChatAllowed;
  final bool isScreenShareAllowed;
  final bool isMuteOnEntry;
  final bool isCameraAllowed;
  final String? meetingUrl;

  const MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.type = MeetingType.scheduled,
    this.repeatOption = RepeatOption.never,
    required this.joinCode,
    required this.hostId,
    required this.hostName,
    this.hostAvatarUrl,
    required this.participantIds,
    this.participantCount = 0,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
    this.timezone = 'UTC+05:30 (IST)',
    this.reminderMinutes = 15,
    this.password,
    this.isChatAllowed = true,
    this.isScreenShareAllowed = true,
    this.isMuteOnEntry = false,
    this.isCameraAllowed = true,
    this.meetingUrl,
  });

  bool get isLive => status == MeetingStatus.live;
  String get statusDisplayName => status.displayName;
  String get statusName => status.name;

  int get durationMinutes {
    final diff = endTime.difference(startTime).inMinutes;
    return diff > 0 ? diff : 45;
  }

  String get meetingLink => meetingUrl != null && meetingUrl!.isNotEmpty
      ? meetingUrl!
      : 'https://connectsoar.com/meeting/$joinCode';

  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    MeetingStatus? status,
    MeetingType? type,
    RepeatOption? repeatOption,
    String? joinCode,
    String? hostId,
    String? hostName,
    String? hostAvatarUrl,
    List<String>? participantIds,
    int? participantCount,
    bool? isVideoEnabled,
    bool? isAudioEnabled,
    String? timezone,
    int? reminderMinutes,
    String? password,
    bool? isChatAllowed,
    bool? isScreenShareAllowed,
    bool? isMuteOnEntry,
    bool? isCameraAllowed,
    String? meetingUrl,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      type: type ?? this.type,
      repeatOption: repeatOption ?? this.repeatOption,
      joinCode: joinCode ?? this.joinCode,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      participantIds: participantIds ?? this.participantIds,
      participantCount: participantCount ?? this.participantCount,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      timezone: timezone ?? this.timezone,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      password: password ?? this.password,
      isChatAllowed: isChatAllowed ?? this.isChatAllowed,
      isScreenShareAllowed: isScreenShareAllowed ?? this.isScreenShareAllowed,
      isMuteOnEntry: isMuteOnEntry ?? this.isMuteOnEntry,
      isCameraAllowed: isCameraAllowed ?? this.isCameraAllowed,
      meetingUrl: meetingUrl ?? this.meetingUrl,
    );
  }

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString().toUpperCase();
    final status = switch (rawStatus) {
      'LIVE' => MeetingStatus.live,
      'SCHEDULED' => MeetingStatus.scheduled,
      'COMPLETED' || 'ENDED' => MeetingStatus.ended,
      'CANCELLED' || 'CANCELED' => MeetingStatus.cancelled,
      _ => MeetingStatus.scheduled,
    };

    final rawType =
        (json['meetingType'] ?? json['meeting_type'] ?? json['type'] ?? '')
            .toString()
            .toUpperCase();
    final type = switch (rawType) {
      'INSTANT_ROOM' || 'INSTANT' => MeetingType.instant,
      'SCHEDULED_MEETING' || 'SCHEDULED' => MeetingType.scheduled,
      'RECURRING' => MeetingType.recurring,
      'WEBINAR' => MeetingType.webinar,
      'TEAM_SYNC' => MeetingType.teamSync,
      'ONE_ON_ONE' => MeetingType.oneOnOne,
      _ => MeetingType.scheduled,
    };

    final rawRepeat =
        (json['recurrenceType'] ??
                json['recurrence_type'] ??
                json['repeatOption'] ??
                '')
            .toString()
            .toUpperCase();
    final repeatOption = switch (rawRepeat) {
      'DAILY' => RepeatOption.daily,
      'WEEKLY' => RepeatOption.weekly,
      'MONTHLY' => RepeatOption.monthly,
      _ => RepeatOption.never,
    };

    final hostMap = json['host'] is Map<String, dynamic>
        ? json['host'] as Map<String, dynamic>
        : null;

    final hostId =
        (json['hostId'] ??
                json['host_id'] ??
                hostMap?['id'] ??
                hostMap?['userId'] ??
                '')
            .toString();

    final hostName =
        (json['hostName'] ??
                json['host_name'] ??
                hostMap?['name'] ??
                hostMap?['fullName'] ??
                'Host')
            .toString();

    final hostAvatarUrl =
        (json['hostAvatarUrl'] ??
                json['host_avatar_url'] ??
                hostMap?['avatarUrl'] ??
                hostMap?['avatar_url'] ??
                hostMap?['image_url'])
            as String?;

    final permissions = json['permissions'] is Map<String, dynamic>
        ? json['permissions'] as Map<String, dynamic>
        : null;

    final isChatAllowed =
        (permissions?['allowParticipantChat'] ??
                json['allow_participant_chat'] ??
                json['isChatAllowed'] ??
                true)
            as bool;

    final isScreenShareAllowed =
        (permissions?['allowScreenSharing'] ??
                json['allow_screen_sharing'] ??
                json['isScreenShareAllowed'] ??
                true)
            as bool;

    final isMuteOnEntry =
        (permissions?['muteParticipantsOnEntry'] ??
                json['mute_participants_on_entry'] ??
                json['isMuteOnEntry'] ??
                false)
            as bool;

    final isCameraAllowed =
        (permissions?['allowParticipantVideo'] ??
                json['allow_participant_video'] ??
                json['isCameraAllowed'] ??
                true)
            as bool;

    final isAudioAllowed =
        (permissions?['allowParticipantAudio'] ??
                json['allow_participant_audio'] ??
                json['isAudioEnabled'] ??
                true)
            as bool;

    // Participant IDs parsing
    final List<String> pIds = [];
    if (json['participants'] is List) {
      for (final p in json['participants'] as List) {
        if (p is Map<String, dynamic>) {
          final pid = (p['userId'] ?? p['id'] ?? '').toString();
          if (pid.isNotEmpty) pIds.add(pid);
        }
      }
    } else if (json['participantIds'] is List) {
      pIds.addAll((json['participantIds'] as List).map((e) => e.toString()));
    }

    final int pCount = json['participantCount'] is int
        ? json['participantCount'] as int
        : json['participantsCount'] is int
        ? json['participantsCount'] as int
        : pIds.length;

    // Parse start time
    DateTime startTime = DateTime.now();
    final rawStart =
        json['scheduledStartTime'] ??
        json['scheduled_start_time'] ??
        json['startTime'] ??
        json['startedAt'] ??
        json['started_at'] ??
        json['createdAt'] ??
        json['created_at'];

    if (rawStart != null) {
      try {
        startTime = DateTime.parse(rawStart.toString());
      } catch (_) {}
    }

    // Parse end time
    DateTime endTime = startTime.add(const Duration(minutes: 45));
    final rawEnd =
        json['scheduledEndTime'] ??
        json['scheduled_end_time'] ??
        json['endTime'] ??
        json['endedAt'] ??
        json['ended_at'];

    if (rawEnd != null) {
      try {
        endTime = DateTime.parse(rawEnd.toString());
      } catch (_) {}
    } else if (json['durationMinutes'] is int ||
        json['duration_minutes'] is int) {
      final dur = (json['durationMinutes'] ?? json['duration_minutes']) as int;
      endTime = startTime.add(Duration(minutes: dur));
    }

    final joinCode =
        (json['meetingCode'] ??
                json['meeting_code'] ??
                json['joinCode'] ??
                json['join_code'] ??
                '')
            .toString();

    final meetingUrl =
        (json['meetingUrl'] ??
                json['meeting_url'] ??
                json['meetingLink'] ??
                json['meeting_link'])
            as String?;

    return MeetingModel(
      id: (json['id'] ?? json['meetingId'] ?? json['meeting_id'] ?? '')
          .toString(),
      title: (json['title'] ?? 'ConnectSoar Meeting').toString(),
      description: (json['description'] ?? '').toString(),
      startTime: startTime,
      endTime: endTime,
      status: status,
      type: type,
      repeatOption: repeatOption,
      joinCode: joinCode,
      hostId: hostId,
      hostName: hostName,
      hostAvatarUrl: hostAvatarUrl,
      participantIds: pIds,
      participantCount: pCount,
      isVideoEnabled: isCameraAllowed,
      isAudioEnabled: isAudioAllowed,
      timezone: (json['timezone'] ?? 'UTC+05:30 (IST)').toString(),
      reminderMinutes:
          (json['reminderMinutes'] ?? json['reminder_minutes'] ?? 15) as int,
      password: json['password'] as String?,
      isChatAllowed: isChatAllowed,
      isScreenShareAllowed: isScreenShareAllowed,
      isMuteOnEntry: isMuteOnEntry,
      isCameraAllowed: isCameraAllowed,
      meetingUrl: meetingUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.name.toUpperCase(),
      'type': type == MeetingType.instant
          ? 'INSTANT_ROOM'
          : 'SCHEDULED_MEETING',
      'repeatOption': repeatOption.name.toUpperCase(),
      'joinCode': joinCode,
      'meetingCode': joinCode,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatarUrl': hostAvatarUrl,
      'participantIds': participantIds,
      'participantCount': participantCount,
      'isVideoEnabled': isVideoEnabled,
      'isAudioEnabled': isAudioEnabled,
      'timezone': timezone,
      'reminderMinutes': reminderMinutes,
      'password': password,
      'isChatAllowed': isChatAllowed,
      'isScreenShareAllowed': isScreenShareAllowed,
      'isMuteOnEntry': isMuteOnEntry,
      'isCameraAllowed': isCameraAllowed,
      'meetingUrl': meetingUrl,
    };
  }
}

/// Paginated Meeting List Response Model
class PaginatedMeetings {
  final List<MeetingModel> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const PaginatedMeetings({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PaginatedMeetings.fromJson(Map<String, dynamic> json) {
    final List<MeetingModel> items = [];
    final rawContent = json['content'];
    if (rawContent is List) {
      for (final item in rawContent) {
        if (item is Map<String, dynamic>) {
          items.add(MeetingModel.fromJson(item));
        }
      }
    }
    return PaginatedMeetings(
      content: items,
      page: (json['page'] as int?) ?? 0,
      size: (json['size'] as int?) ?? 20,
      totalElements: (json['totalElements'] as int?) ?? items.length,
      totalPages: (json['totalPages'] as int?) ?? 1,
    );
  }
}

/// Typed request for POST /api/meetings (Instant Room)
class CreateInstantMeetingRequest {
  final String title;
  final String description;
  final String? password;
  final bool allowParticipantChat;
  final bool allowScreenSharing;
  final bool muteParticipantsOnEntry;
  final bool allowParticipantVideo;
  final bool allowParticipantAudio;
  final bool isOpenRoom;

  const CreateInstantMeetingRequest({
    required this.title,
    this.description = '',
    this.password,
    this.allowParticipantChat = true,
    this.allowScreenSharing = true,
    this.muteParticipantsOnEntry = false,
    this.allowParticipantVideo = true,
    this.allowParticipantAudio = true,
    this.isOpenRoom = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'meeting_type': 'INSTANT_ROOM',
      'allow_participant_chat': allowParticipantChat,
      'allow_screen_sharing': allowScreenSharing,
      'mute_participants_on_entry': muteParticipantsOnEntry,
      'allow_participant_video': allowParticipantVideo,
      'allow_participant_audio': allowParticipantAudio,
      'is_open_room': isOpenRoom,
    };
    if (password != null && password!.isNotEmpty) {
      map['password'] = password!;
    }
    return map;
  }
}

/// Typed request for POST /api/meetings (Scheduled Meeting)
class CreateScheduledMeetingRequest {
  final String title;
  final String description;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final int durationMinutes;
  final String timezone;
  final int reminderMinutes;
  final String recurrenceType;
  final List<String> invitedEmails;
  final String? password;
  final bool allowParticipantChat;
  final bool allowScreenSharing;
  final bool muteParticipantsOnEntry;
  final bool allowParticipantVideo;
  final bool allowParticipantAudio;

  const CreateScheduledMeetingRequest({
    required this.title,
    this.description = '',
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.durationMinutes = 60,
    this.timezone = 'Asia/Kolkata',
    this.reminderMinutes = 15,
    this.recurrenceType = 'NONE',
    this.invitedEmails = const [],
    this.password,
    this.allowParticipantChat = true,
    this.allowScreenSharing = true,
    this.muteParticipantsOnEntry = false,
    this.allowParticipantVideo = true,
    this.allowParticipantAudio = true,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'meeting_type': 'SCHEDULED_MEETING',
      'scheduled_start_time': scheduledStartTime.toUtc().toIso8601String(),
      'scheduled_end_time': scheduledEndTime.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'timezone': timezone,
      'reminder_minutes': reminderMinutes,
      'recurrence_type': recurrenceType,
      'invited_emails': invitedEmails,
      'allow_participant_chat': allowParticipantChat,
      'allow_screen_sharing': allowScreenSharing,
      'mute_participants_on_entry': muteParticipantsOnEntry,
      'allow_participant_video': allowParticipantVideo,
      'allow_participant_audio': allowParticipantAudio,
    };
    if (password != null && password!.isNotEmpty) {
      map['password'] = password!;
    }
    return map;
  }
}

/// Typed request for PUT /api/meetings/{id}
class UpdateMeetingRequest {
  final String? title;
  final String? description;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final bool? allowParticipantChat;
  final bool? allowScreenSharing;
  final bool? muteParticipantsOnEntry;
  final bool? allowParticipantVideo;
  final bool? allowParticipantAudio;

  const UpdateMeetingRequest({
    this.title,
    this.description,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.allowParticipantChat,
    this.allowScreenSharing,
    this.muteParticipantsOnEntry,
    this.allowParticipantVideo,
    this.allowParticipantAudio,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (scheduledStartTime != null) {
      map['scheduled_start_time'] = scheduledStartTime!
          .toUtc()
          .toIso8601String();
    }
    if (scheduledEndTime != null) {
      map['scheduled_end_time'] = scheduledEndTime!.toUtc().toIso8601String();
    }
    if (allowParticipantChat != null) {
      map['allow_participant_chat'] = allowParticipantChat;
    }
    if (allowScreenSharing != null) {
      map['allow_screen_sharing'] = allowScreenSharing;
    }
    if (muteParticipantsOnEntry != null) {
      map['mute_participants_on_entry'] = muteParticipantsOnEntry;
    }
    if (allowParticipantVideo != null) {
      map['allow_participant_video'] = allowParticipantVideo;
    }
    if (allowParticipantAudio != null) {
      map['allow_participant_audio'] = allowParticipantAudio;
    }
    return map;
  }
}
