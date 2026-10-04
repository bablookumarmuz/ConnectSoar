import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';

class FloatingPipTile extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isVideoOff;
  final bool isMicMuted;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onClose;

  const FloatingPipTile({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isVideoOff,
    required this.isMicMuted,
    required this.onToggleVideo,
    required this.onToggleMic,
    required this.onClose,
  });

  @override
  State<FloatingPipTile> createState() => _FloatingPipTileState();
}

class _FloatingPipTileState extends State<FloatingPipTile> {
  Offset _offset = const Offset(20, 80);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      right: _offset.dx,
      bottom: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final double newDx = _offset.dx - details.delta.dx;
            final double newDy = _offset.dy - details.delta.dy;
            _offset = Offset(
              newDx.clamp(10.0, size.width - 160),
              newDy.clamp(80.0, size.height - 240),
            );
          });
        },
        child: Material(
          elevation: 12,
          borderRadius: AppRadius.borderRadiusLg,
          color: Colors.transparent,
          child: Container(
            width: 150,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFF161922),
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (widget.isVideoOff)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAvatar(
                          name: widget.name,
                          imageUrl: widget.avatarUrl,
                          size: 48,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You (Video Off)',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusLg,
                    child: Image.network(
                      widget.avatarUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Center(child: AppAvatar(name: widget.name, size: 48)),
                    ),
                  ),

                // Top Header Overlay (PiP Tag + Close)
                Positioned(
                  top: 6,
                  left: 6,
                  right: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.picture_in_picture_alt_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'You (PiP)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Floating Controls Overlay
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: widget.onToggleMic,
                          child: Icon(
                            widget.isMicMuted
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            size: 16,
                            color: widget.isMicMuted
                                ? AppColors.danger
                                : Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onToggleVideo,
                          child: Icon(
                            widget.isVideoOff
                                ? Icons.videocam_off_rounded
                                : Icons.videocam_rounded,
                            size: 16,
                            color: widget.isVideoOff
                                ? AppColors.danger
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
