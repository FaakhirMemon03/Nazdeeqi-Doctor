import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'colors.dart';

/// Premium animated medical-themed loader for Nazdeeqi Doctor app.
/// Features heartbeat pulse animation with rotating ring and brand text.
class NazdeeqiLoader extends StatefulWidget {
  final String? message;
  final String? subMessage;
  final double size;

  const NazdeeqiLoader({
    super.key,
    this.message,
    this.subMessage,
    this.size = 72,
  });

  @override
  State<NazdeeqiLoader> createState() => _NazdeeqiLoaderState();
}

class _NazdeeqiLoaderState extends State<NazdeeqiLoader>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Outer ring spin
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Heart pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sub-text fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated ring + heart icon
            SizedBox(
              width: widget.size + 20,
              height: widget.size + 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring (reverse spin, subtle)
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -_spinController.value * 2 * math.pi,
                        child: Container(
                          width: widget.size + 16,
                          height: widget.size + 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _ArcPainter(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              strokeWidth: 2,
                              sweepAngle: math.pi * 0.7,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Main spinning ring
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinController.value * 2 * math.pi,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 3,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _ArcPainter(
                              color: AppColors.primary,
                              strokeWidth: 3,
                              sweepAngle: math.pi * 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Pulsing heart icon
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Icon(
                      Icons.favorite_rounded,
                      size: widget.size * 0.38,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main message
            if (widget.message != null)
              Text(
                widget.message!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

            // Sub message with fade animation
            if (widget.subMessage != null) ...[
              const SizedBox(height: 6),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.subMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Paints a partial arc on a circle (used for spinning ring effect)
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepAngle;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      sweepAngle != oldDelegate.sweepAngle;
}

/// Workaround: AnimatedBuilder is the same as AnimatedWidget builder.
/// Flutter uses AnimatedBuilder, let's ensure we have a proper builder alias.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
