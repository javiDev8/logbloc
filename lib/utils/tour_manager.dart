import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:logbloc/config/locales.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logbloc/pools/tour_step_pool.dart';
import 'package:logbloc/utils/tour_keys.dart';

class TourManager {
  static const String _tourCompletedKey = 'tour_completed';

  static Future<bool> isTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tourCompletedKey) ?? false;
  }

  static Future<void> markTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourCompletedKey, true);
  }

  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tourCompletedKey);
  }

  static void startTourForStep(BuildContext context, int step) {
    TargetFocus target;
    Function(TargetFocus)? onClickTarget;
    switch (step) {
      case 1:
        target = TargetFocus(
          identify: "tap_add_item",
          keyTarget: addItemButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  Tr.tourTapAddEntry.getString(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
        onClickTarget = (target) {
          markTourCompleted();
          tourStepPool.endTour();
        };
        break;

      default:
        return;
    }

    TutorialCoachMark(
      targets: [target],
      colorShadow: Colors.black,
      textSkip: "",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onClickTarget: onClickTarget,
      onClickOverlay: step == 1
          ? (target) {
              markTourCompleted();
              tourStepPool.endTour();
            }
          : null,
      onFinish: () {
        _onTourStepFinished(step);
        return true;
      },
      onSkip: () {
        // No skip
        return true;
      },
    ).show(context: context);
  }

  static void _onTourStepFinished(int step) {
    if (step == 1) {
      markTourCompleted();
      tourStepPool.endTour();
    }
  }

  static void startTour(BuildContext context, List<TargetFocus> targets) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        markTourCompleted();
        return true;
      },
      onSkip: () {
        markTourCompleted();
        return true;
      },
    ).show(context: context);
  }
}
