import 'package:flutter/widgets.dart';

import 'settings.dart';

/// An example method of injecting your custom Settings object into your Tree.
/// You can use any state management method you like.
class SettingsProvider extends InheritedWidget {
  const SettingsProvider({
    super.key,
    required this.settings,
    required super.child,
  });

  final Settings settings;

  static Settings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsProvider>()!.settings;

  static Settings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsProvider>()?.settings;

  @override
  bool updateShouldNotify(covariant SettingsProvider oldWidget) =>
      oldWidget.settings != settings;
}
