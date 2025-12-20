import 'package:logbloc/pools/pools.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TourStepPool extends Pool<int> {
  static const String _tourStepKey = 'tour_step';

  TourStepPool() : super(-1); // -1 means no tour

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStep = prefs.getInt(_tourStepKey) ?? -1;
    if (savedStep != -1) {
      set((_) => savedStep);
    }
  }

  void _saveStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tourStepKey, step);
  }

  void startTour() {
    set((_) => 0);
  }

  void nextStep() {
    set((current) => current + 1);
  }

  void endTour() {
    set((_) => -1);
  }

  @override
  dynamic set(Function(int) change) {
    final result = super.set(change);
    _saveStep(data);
    return result;
  }

  bool get isActive => data >= 0;
  int get currentStep => data;
}

final tourStepPool = TourStepPool();
