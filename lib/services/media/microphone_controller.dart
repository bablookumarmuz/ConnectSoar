import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MicrophoneController {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  final StreamController<double> _audioLevelController =
      StreamController<double>.broadcast();

  bool _isMicActive = false;
  bool get isMicActive => _isMicActive;
  Stream<double> get audioLevelStream => _audioLevelController.stream;

  Future<bool> startMicrophone() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _isMicActive = false;
        return false;
      }

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _isMicActive = false;
        return false;
      }

      _isMicActive = true;

      // Start listening to real audio amplitude changes from hardware mic
      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amp) {
            // Convert dB amplitude (-160 to 0) to normalized 0.0 - 1.0 factor
            final currentDb = amp.current;
            final normalized = ((currentDb + 60) / 60).clamp(0.0, 1.0);
            _audioLevelController.add(normalized);
          });

      return true;
    } catch (_) {
      _isMicActive = false;
      return false;
    }
  }

  Future<void> stopMicrophone() async {
    _isMicActive = false;
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _audioLevelController.add(0.0);
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
  }

  void dispose() {
    stopMicrophone();
    _audioLevelController.close();
    _recorder.dispose();
  }
}
