import 'package:logbloc/pools/pools.dart';

class TourStepPool extends Pool<int> {
  TourStepPool() : super(-1); // -1 means no tour

  void startTour() {
    set((_) => 0);
  }

  void nextStep() {
    set((current) => current + 1);
  }

  void endTour() {
    set((_) => -1);
  }

  bool get isActive => data >= 0;
  int get currentStep => data;
}

final tourStepPool = TourStepPool();
