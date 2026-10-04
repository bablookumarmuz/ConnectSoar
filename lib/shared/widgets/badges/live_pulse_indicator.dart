import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LivePulseIndicator extends StatefulWidget {
  final double size;

  const LivePulseIndicator({super.key, this.size = 10.0});

  @override
  State<LivePulseIndicator> createState() => _LivePulseIndicatorState();
}

class _LivePulseIndicatorState extends State<LivePulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: AppColors.liveIndicator,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
