import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class RpgPerformanceTrace {
  const RpgPerformanceTrace._();

  static T sync<T>(String name, T Function() action) {
    if (kReleaseMode) return action();
    return developer.Timeline.timeSync('rpg.$name', action);
  }

  static Future<T> async<T>(String name, Future<T> Function() action) async {
    if (kReleaseMode) return action();
    final task = developer.TimelineTask()..start('rpg.$name');
    try {
      return await action();
    } finally {
      task.finish();
    }
  }

  static void mark(String name, [Map<String, Object?> arguments = const {}]) {
    if (kReleaseMode) return;
    developer.Timeline.instantSync('rpg.$name', arguments: arguments);
  }
}
