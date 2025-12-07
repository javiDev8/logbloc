import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReviewManager {
  static const String _firstLaunchDateKey = 'first_launch_date';
  static const String _userRankedAppKey = 'user_ranked_app';
  static const String _lastPromptDateKey = 'last_prompt_date';

  // Minimum days after first launch before showing review
  static const int _minimumDaysBeforeFirstPrompt = 7;

  // Minimum hours between prompts
  static const int _minimumHoursBetweenPrompts = 24;

  static bool _isShowingDialog = false;

  /// Check if review dialog should be shown and request it if conditions are met
  static Future<void> checkAndRequestReview(BuildContext context) async {
    // Prevent multiple dialogs
    if (_isShowingDialog || !context.mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // Check if user has already ranked app
    final userRankedApp = prefs.getBool(_userRankedAppKey) ?? false;
    if (userRankedApp) return;

    // Get current date and stored dates
    final now = DateTime.now();
    final firstLaunchDateStr = prefs.getString(_firstLaunchDateKey);
    final lastPromptDateStr = prefs.getString(_lastPromptDateKey);

    // Set first launch date if not exists
    if (firstLaunchDateStr == null) {
      await prefs.setString(_firstLaunchDateKey, now.toIso8601String());
      return; // Don't show on first install
    }

    final firstLaunchDate = DateTime.parse(firstLaunchDateStr);

    // Check if minimum days have passed since first launch
    final daysSinceFirstLaunch = now.difference(firstLaunchDate).inDays;
    if (daysSinceFirstLaunch < _minimumDaysBeforeFirstPrompt) return;

    // Check if enough time has passed since last prompt
    DateTime? lastPromptDate;
    if (lastPromptDateStr != null) {
      lastPromptDate = DateTime.parse(lastPromptDateStr);
      final hoursSinceLastPrompt = now.difference(lastPromptDate).inHours;
      if (hoursSinceLastPrompt < _minimumHoursBetweenPrompts) return;
    }

    // All conditions met, show review dialog
    if (context.mounted) {
      await _showReviewDialog(context, prefs);
    }
  }

  /// Get the correct store URL based on platform
  static String _getStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=dev.sweetfeatures.logbloc';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/es/app/logbloc/id6751601425';
    } else {
      // Default to Android for other platforms
      return 'https://play.google.com/store/apps/details?id=dev.sweetfeatures.logbloc';
    }
  }

  /// Open app store page for review
  static Future<void> _openStoreReview() async {
    final url = _getStoreUrl();
    final uri = Uri.parse(url);

    try {
      debugPrint('Attempting to open store: $url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('Store opened successfully');
      } else {
        debugPrint('Could not launch store URL');
      }
    } catch (e) {
      debugPrint('Could not open store for review: $e');
    }
  }

  /// Request review with fallback to store
  static Future<void> _requestReviewWithFallback() async {
    try {
      final inAppReview = InAppReview.instance;
      final isAvailable = await inAppReview.isAvailable();

      debugPrint('In-app review available: $isAvailable');

      if (isAvailable) {
        debugPrint('Attempting to show native in-app review...');
        await inAppReview.requestReview();
        debugPrint('Native in-app review requested successfully');

        // Wait a bit to see if native dialog appears
        await Future.delayed(const Duration(seconds: 2));

        // If we get here without user interaction, fallback to store
        debugPrint(
          'Native dialog may not have appeared, falling back to store...',
        );
        await _openStoreReview();
      } else {
        debugPrint('In-app review not available, opening store directly');
        // Fallback to store directly
        await _openStoreReview();
      }
    } catch (e) {
      debugPrint('In-app review failed, falling back to store: $e');
      await _openStoreReview();
    }
  }

  /// Show custom review dialog before calling native review
  static Future<void> _showReviewDialog(
    BuildContext context,
    SharedPreferences prefs,
  ) async {
    if (!context.mounted) return;

    _isShowingDialog = true;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(
          'Is Logbloc a good app?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Let us know what do you think about Logbloc, your feedback helps us improve!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await prefs.setBool(_userRankedAppKey, true);
                    await prefs.setString(
                      _lastPromptDateKey,
                      DateTime.now().toIso8601String(),
                    );
                    _isShowingDialog = false;

                    // Call native review dialog after dialog closes
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () async {
                        await _requestReviewWithFallback();
                      },
                    );
                  },
                  child: const Text(
                    'Never',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await prefs.setString(
                      _lastPromptDateKey,
                      DateTime.now().toIso8601String(),
                    );
                    _isShowingDialog = false;
                  },
                  child: const Text(
                    'Later',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await prefs.setBool(_userRankedAppKey, true);
                    await prefs.setString(
                      _lastPromptDateKey,
                      DateTime.now().toIso8601String(),
                    );
                    _isShowingDialog = false;

                    // Call native review dialog after dialog closes
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () async {
                        await _requestReviewWithFallback();
                      },
                    );
                  },
                  child: const Text(
                    'Rate',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    _isShowingDialog = false;
  }

  /// Force show review dialog (for testing purposes)
  static Future<void> forceShowReviewDialog(BuildContext context) async {
    if (!context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (context.mounted) {
      await _showReviewDialog(context, prefs);
    }
  }

  /// Reset all review tracking (for testing purposes)
  static Future<void> resetReviewTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchDateKey);
    await prefs.remove(_userRankedAppKey);
    await prefs.remove(_lastPromptDateKey);
  }
}
