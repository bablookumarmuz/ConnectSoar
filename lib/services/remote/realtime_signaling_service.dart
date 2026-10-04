import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../core/config/api_config.dart';
import '../../core/config/app_config.dart';

class RealtimeParticipant {
  final String userId;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isMuted;
  final bool isVideoOff;

  const RealtimeParticipant({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.isMuted = false,
    this.isVideoOff = false,
  });

  RealtimeParticipant copyWith({bool? isMuted, bool? isVideoOff}) {
    return RealtimeParticipant(
      userId: userId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isMuted: isMuted ?? this.isMuted,
      isVideoOff: isVideoOff ?? this.isVideoOff,
    );
  }
}

class RealtimeSignalingService {
  final AppConfig _config;
  AppConfig get config => _config;
  WebSocket? _socket;
  StreamSubscription? _subscription;

  final StreamController<List<RealtimeParticipant>> _participantsController =
      StreamController<List<RealtimeParticipant>>.broadcast();
  final StreamController<Map<String, dynamic>> _signalController =
      StreamController<Map<String, dynamic>>.broadcast();

  final List<RealtimeParticipant> _activeParticipants = [];

  Stream<List<RealtimeParticipant>> get participantsStream =>
      _participantsController.stream;
  Stream<Map<String, dynamic>> get signalStream => _signalController.stream;
  List<RealtimeParticipant> get currentParticipants =>
      List.unmodifiable(_activeParticipants);

  RealtimeSignalingService(this._config);

  Future<bool> connectAndJoin({
    required String meetingId,
    required String authToken,
  }) async {
    try {
      await disconnect();

      final uri = Uri.parse(
        ApiConfig.meetingSignalingWsUrl(meetingId, authToken),
      );

      _socket = await WebSocket.connect(uri.toString());

      _subscription = _socket?.listen(
        (data) {
          try {
            final json = jsonDecode(data.toString()) as Map<String, dynamic>;
            _handleIncomingEvent(json);
          } catch (e) {
            // Error parsing message
          }
        },
        onError: (err) {
          // Socket error
        },
        onDone: () {
          // Socket done
        },
      );

      // Send join event
      _sendJson({
        'type': 'meeting:join',
        'token': authToken,
        'meetingId': meetingId,
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  void _handleIncomingEvent(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    if (type == 'meeting:joined') {
      _activeParticipants.clear();
      final participantsJson = json['participants'] as List? ?? [];
      for (final p in participantsJson) {
        final pMap = p as Map<String, dynamic>;
        _activeParticipants.add(
          RealtimeParticipant(
            userId: (pMap['userId'] as String?) ?? '',
            name: (pMap['name'] as String?) ?? 'Participant',
            email: (pMap['email'] as String?) ?? '',
            avatarUrl: (pMap['avatarUrl'] as String?) ?? '',
          ),
        );
      }
      _participantsController.add(List.unmodifiable(_activeParticipants));
    } else if (type == 'participant:joined') {
      final pMap = json['participant'] as Map<String, dynamic>? ?? {};
      final userId = (pMap['userId'] as String?) ?? '';
      if (userId.isNotEmpty &&
          !_activeParticipants.any((p) => p.userId == userId)) {
        _activeParticipants.add(
          RealtimeParticipant(
            userId: userId,
            name: (pMap['name'] as String?) ?? 'Participant',
            email: (pMap['email'] as String?) ?? '',
            avatarUrl: (pMap['avatarUrl'] as String?) ?? '',
          ),
        );
        _participantsController.add(List.unmodifiable(_activeParticipants));
      }
    } else if (type == 'participant:left') {
      final userId = json['userId'] as String?;
      if (userId != null) {
        _activeParticipants.removeWhere((p) => p.userId == userId);
        _participantsController.add(List.unmodifiable(_activeParticipants));
      }
    } else if (type == 'participant:media-changed') {
      final userId = json['userId'] as String?;
      final isMuted = json['isMuted'] as bool? ?? false;
      final isVideoOff = json['isVideoOff'] as bool? ?? false;

      final index = _activeParticipants.indexWhere((p) => p.userId == userId);
      if (index != -1) {
        _activeParticipants[index] = _activeParticipants[index].copyWith(
          isMuted: isMuted,
          isVideoOff: isVideoOff,
        );
        _participantsController.add(List.unmodifiable(_activeParticipants));
      }
    } else if (type != null && type.startsWith('webrtc:')) {
      _signalController.add(json);
    }
  }

  void toggleMedia({
    required String meetingId,
    required bool isMuted,
    required bool isVideoOff,
  }) {
    _sendJson({
      'type': 'media:toggle',
      'meetingId': meetingId,
      'isMuted': isMuted,
      'isVideoOff': isVideoOff,
    });
  }

  void sendOffer({
    required String meetingId,
    required String targetUserId,
    required dynamic offer,
  }) {
    _sendJson({
      'type': 'webrtc:offer',
      'meetingId': meetingId,
      'targetUserId': targetUserId,
      'offer': offer,
    });
  }

  void sendAnswer({
    required String meetingId,
    required String targetUserId,
    required dynamic answer,
  }) {
    _sendJson({
      'type': 'webrtc:answer',
      'meetingId': meetingId,
      'targetUserId': targetUserId,
      'answer': answer,
    });
  }

  void sendIceCandidate({
    required String meetingId,
    required String targetUserId,
    required dynamic candidate,
  }) {
    _sendJson({
      'type': 'webrtc:ice-candidate',
      'meetingId': meetingId,
      'targetUserId': targetUserId,
      'candidate': candidate,
    });
  }

  void leaveMeeting(String meetingId) {
    _sendJson({'type': 'meeting:leave', 'meetingId': meetingId});
  }

  void _sendJson(Map<String, dynamic> data) {
    try {
      if (_socket != null && _socket!.readyState == WebSocket.open) {
        _socket!.add(jsonEncode(data));
      }
    } catch (_) {}
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _socket?.close();
    } catch (_) {}
    _socket = null;
    _activeParticipants.clear();
  }

  void dispose() {
    disconnect();
    _participantsController.close();
    _signalController.close();
  }
}
