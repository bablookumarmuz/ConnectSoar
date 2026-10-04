enum ParticipantRole { host, coHost, attendee }

class ParticipantModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String avatarUrl;
  final ParticipantRole role;
  final String status;
  final bool isMuted;
  final bool isVideoOff;
  final bool isHandRaised;
  final bool isScreenSharing;

  const ParticipantModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email = '',
    required this.avatarUrl,
    required this.role,
    this.status = 'JOINED',
    this.isMuted = false,
    this.isVideoOff = false,
    this.isHandRaised = false,
    this.isScreenSharing = false,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final rawRole =
        (json['participantRole'] ??
                json['participant_role'] ??
                json['role'] ??
                '')
            .toString()
            .toUpperCase();
    final role = switch (rawRole) {
      'HOST' => ParticipantRole.host,
      'CO_HOST' || 'COHOST' => ParticipantRole.coHost,
      _ => ParticipantRole.attendee,
    };

    final rawStatus = (json['status'] ?? 'JOINED').toString().toUpperCase();

    return ParticipantModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? json['id'] ?? '')
          .toString(),
      name: (json['name'] ?? json['fullName'] ?? json['email'] ?? 'Participant')
          .toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl:
          (json['avatarUrl'] ?? json['avatar_url'] ?? json['image_url'] ?? '')
              .toString(),
      role: role,
      status: rawStatus,
      isMuted: (json['isMuted'] ?? json['is_muted'] ?? false) as bool,
      isVideoOff: (json['isVideoOff'] ?? json['is_video_off'] ?? false) as bool,
      isHandRaised:
          (json['isHandRaised'] ?? json['is_hand_raised'] ?? false) as bool,
      isScreenSharing:
          (json['isScreenSharing'] ?? json['is_screen_sharing'] ?? false)
              as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user_id': userId,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'participantRole': role == ParticipantRole.host
          ? 'HOST'
          : role == ParticipantRole.coHost
          ? 'CO_HOST'
          : 'PARTICIPANT',
      'status': status,
      'isMuted': isMuted,
      'isVideoOff': isVideoOff,
      'isHandRaised': isHandRaised,
      'isScreenSharing': isScreenSharing,
    };
  }

  ParticipantModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
    ParticipantRole? role,
    String? status,
    bool? isMuted,
    bool? isVideoOff,
    bool? isHandRaised,
    bool? isScreenSharing,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      isVideoOff: isVideoOff ?? this.isVideoOff,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
    );
  }
}
