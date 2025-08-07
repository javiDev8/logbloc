import 'dart:async';
import 'package:flutter/widgets.dart';

class Pool<T> {
  StreamController controller = StreamController.broadcast();
  T data;
  Pool(T def) : data = def;

  emit() => controller.sink.add(true);
  set(Function(T) change) {
    final newData = change(data);
    if (data == newData) return;
    data = newData;
    emit();
  }
}

class Swimmer<T> extends StatelessWidget {
  final Pool pool;
  final Widget Function(BuildContext, T) builder;

  const Swimmer({super.key, required this.pool, required this.builder});
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: pool.controller.stream,
    builder: (context, snap) {
      return builder(context, pool.data);
    },
  );
}

class LazySwimmer<T> extends Swimmer<T> {
  final List<String>? listenedEvents;
  final bool Function(T? prev, T data, dynamic event)? deal;

  const LazySwimmer({
    super.key,
    required super.pool,
    required super.builder,
    this.listenedEvents,
    this.deal,
  });

  @override
  Widget build(BuildContext context) {
    final midController = StreamController.broadcast();
    emit() => midController.sink.add(true);
    T? prev;
    T next = pool.data;
    pool.controller.stream.listen((event) {
      if (prev == null) return emit();
      if (listenedEvents != null && !listenedEvents!.contains(event)) {
        // discard rebuild if event not "listened"
        return;
      }

      if (deal == null) return emit();
      if (deal!(prev, next, event)) emit();
    });
    return StreamBuilder(
      stream: midController.stream,
      builder: (context, snap) {
        prev = next;
        return builder(context, next);
      },
    );
  }
}
