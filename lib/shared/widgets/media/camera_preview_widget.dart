import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../avatars/app_avatar.dart';

class CameraPreviewWidget extends StatefulWidget {
  final bool isVideoOff;
  final String userName;
  final String? avatarUrl;
  final double borderRadius;
  final BoxFit fit;

  const CameraPreviewWidget({
    super.key,
    required this.isVideoOff,
    required this.userName,
    this.avatarUrl,
    this.borderRadius = 12.0,
    this.fit = BoxFit.cover,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.isVideoOff) {
      _initCamera();
    }
  }

  @override
  void didUpdateWidget(CameraPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVideoOff != widget.isVideoOff) {
      if (widget.isVideoOff) {
        _stopCamera();
      } else {
        _initCamera();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed && !widget.isVideoOff) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing || widget.isVideoOff) return;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _errorMessage = 'Camera permission denied.';
          });
        }
        return;
      }
      if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _errorMessage =
                'Camera permission permanently denied. Enable in Settings.';
          });
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _errorMessage = 'No hardware camera detected on device.';
          });
        }
        return;
      }

      // Select front camera if available, else back camera
      final frontCamera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _controller = controller;
      await controller.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Failed to initialize camera hardware: $e';
        });
      }
    }
  }

  Future<void> _stopCamera() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isVideoOff) {
      return _buildOffFallback(isDark, 'Camera is Turned Off');
    }

    if (_errorMessage != null) {
      return _buildOffFallback(isDark, _errorMessage!);
    }

    if (_isInitializing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Container(
        color: isDark ? const Color(0xFF10131B) : Colors.black87,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Starting Local Camera Hardware...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: CameraPreview(_controller!),
    );
  }

  Widget _buildOffFallback(bool isDark, String message) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(
              name: widget.userName,
              imageUrl: widget.avatarUrl,
              size: 64,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
