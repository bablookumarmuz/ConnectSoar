import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingReactionItem {
  final String id;
  final String emoji;
  final String senderName;
  final double startXPercent;

  FloatingReactionItem({
    required this.id,
    required this.emoji,
    required this.senderName,
    required this.startXPercent,
  });
}

class FloatingEmojiOverlay extends StatefulWidget {
  final List<FloatingReactionItem> reactions;
  final VoidCallback? onAnimationComplete;

  const FloatingEmojiOverlay({
    super.key,
    required this.reactions,
    this.onAnimationComplete,
  });

  @override
  State<FloatingEmojiOverlay> createState() => _FloatingEmojiOverlayState();
}

class _FloatingEmojiOverlayState extends State<FloatingEmojiOverlay> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: widget.reactions.map((item) {
          return _SingleFloatingEmoji(key: ValueKey(item.id), reaction: item);
        }).toList(),
      ),
    );
  }
}

class _SingleFloatingEmoji extends StatefulWidget {
  final FloatingReactionItem reaction;

  const _SingleFloatingEmoji({super.key, required this.reaction});

  @override
  State<_SingleFloatingEmoji> createState() => _SingleFloatingEmojiState();
}

class _SingleFloatingEmojiState extends State<_SingleFloatingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late double _randomXShift;

  @override
  void initState() {
    super.initState();
    _randomXShift = (math.Random().nextDouble() - 0.5) * 60;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _yAnimation = Tween<double>(
      begin: 0,
      end: -350,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.3, end: 1.3), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 60),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final startX = (widget.reaction.startXPercent * (size.width - 100)) + 20;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: startX + (_randomXShift * _controller.value),
          bottom: 100 - _yAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.reaction.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.reaction.senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
