import 'dart:async';
import 'dart:convert';
import 'package:logize/main.dart';
import 'package:logize/pools/items/items_by_day_pool.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:logize/pools/tags/tags_pool.dart';

class Event {
  String? id;
  String entity;
  String type;
  List<String> entityIds;
  DateTime timestamp;

  Event({
    this.id,
    required this.entity,
    required this.type,
    required this.entityIds,
    required this.timestamp,
  });

  Map<String, dynamic> serialize() => {
    'entity': entity,
    'type': type,
    'entityIds': entityIds,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}

class EventProcessor {
  List<String>? lastBurntEvents;
  StreamController<Event> controller = StreamController.broadcast();

  EventProcessor();

  init() async {
    lastBurntEvents = jsonDecode(
      await sharedPrefs.getString('events') ?? '[]',
    ).map<String>((e) => e.toString()).toList();
  }

  processEvent(Event event) {
    switch (event.entity) {
      case 'model':
        switch (event.type) {
          case 'add':
            modelsPool.clean();
            itemsByDayPool.clean();
            break;
          case 'update':
            modelsPool.clean();
            itemsByDayPool.clean();
            break;
          case 'delete':
            modelsPool.clean();
            itemsByDayPool.clean();
            recordsPool.clean();
            break;
        }
      case 'record':
        switch (event.type) {
          case 'add':
            recordsPool.clean();
            modelsPool.clean();
            itemsByDayPool.clean();
            break;
          case 'update':
            recordsPool.clean();
            itemsByDayPool.clean();
            break;
          case 'delete':
            recordsPool.clean();
            modelsPool.clean();
            itemsByDayPool.clean();
        }
        break;

      case 'tag':
        switch (event.type) {
          case 'save':
            tagsPool.clean();
            break;
          case 'delete':
            tagsPool.clean();
            modelsPool.clean();
            break;
        }
        break;
    }
  }

  listen() {
    controller.stream.listen((event) {
      processEvent(event);
    });
  }

  emitEvent(Event event) => controller.sink.add(event);
}

final eventProcessor = EventProcessor();
