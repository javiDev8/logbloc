import 'package:flutter/material.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/widgets/navbar.dart';
import 'package:logbloc/screens/models/models_screen.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:flutter_localization/flutter_localization.dart';

enum TourStep { swipe, tapLogbooks, tapAddModel }

class TourOverlay extends StatefulWidget {
  final TourStep step;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const TourOverlay({
    super.key,
    required this.step,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay> {
  @override
  Widget build(BuildContext context) {
    String title;
    Widget? icon;
    Alignment alignment;
    EdgeInsets padding;

    switch (widget.step) {
      case TourStep.swipe:
        title = Tr.tourSwipeInstruction.getString(context);
        alignment = Alignment.center;
        padding = const EdgeInsets.all(32);
        icon = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 30),
            const SizedBox(width: 20),
            Icon(Icons.arrow_forward, color: Colors.white, size: 30),
          ],
        );
        break;
      case TourStep.tapLogbooks:
        title = Tr.tourTapLogbooks.getString(context);
        alignment = Alignment.bottomCenter;
        padding = const EdgeInsets.all(16);
        break;
      case TourStep.tapAddModel:
        title = Tr.tourTapAddModel.getString(context);
        alignment = Alignment.bottomCenter;
        padding = const EdgeInsets.all(16);
        break;
    }

    return Stack(
      children: [
        // Semi-transparent overlay that doesn't block touches
        IgnorePointer(
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        // Hole in the overlay if needed
        if (widget.step == TourStep.tapLogbooks ||
            widget.step == TourStep.tapAddModel)
          IgnorePointer(
            child: Positioned.fill(
              child: CustomPaint(
                painter: HolePainter(
                  holeKey: widget.step == TourStep.tapLogbooks
                      ? logbooksNavKey
                      : addModelButtonKey,
                ),
              ),
            ),
          ),
        // The text box that blocks touches for buttons
        Align(
          alignment: alignment,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (icon != null) ...[const SizedBox(height: 16), icon],
                        const SizedBox(height: 16),
                        Button(
                          Tr.tourNext.getString(context),
                          onPressed: widget.onNext,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HolePainter extends CustomPainter {
  final GlobalKey holeKey;

  HolePainter({required this.holeKey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    final RenderBox? renderBox =
        holeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(
        position.dx,
        position.dy,
        renderBox.size.width,
        renderBox.size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
