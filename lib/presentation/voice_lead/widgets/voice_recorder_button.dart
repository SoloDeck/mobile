import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Nút ghi âm giọng nói lớn với animation pulse và sound-level indicator.
class VoiceRecorderButton extends StatefulWidget {
  const VoiceRecorderButton({
    super.key,
    required this.isListening,
    required this.onTap,
    this.soundLevel = 0,
  });

  final bool isListening;
  final VoidCallback onTap;
  /// 0.0 – 1.0, được cập nhật real-time từ mic.
  final double soundLevel;

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceRecorderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          // Khi đang nghe: scale kết hợp pulse cố định + sound level thực tế
          final scale = widget.isListening
              ? _pulseAnimation.value + widget.soundLevel * 0.15
              : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isListening ? AppColors.error : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isListening
                            ? AppColors.error
                            : AppColors.primary)
                        .withValues(
                          alpha: widget.isListening
                              ? 0.35 + widget.soundLevel * 0.3
                              : 0.35,
                        ),
                    blurRadius: widget.isListening
                        ? 24 + widget.soundLevel * 16
                        : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
