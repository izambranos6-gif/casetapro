import 'package:flutter/material.dart';
import 'feed_controller.dart';

class AppScope extends InheritedNotifier<FeedController> {
  const AppScope({super.key, required FeedController controller, required super.child})
      : super(notifier: controller);

  static FeedController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(result != null, 'Falta AppScope');
    return result!.notifier!;
  }
}
