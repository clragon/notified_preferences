import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notified_preferences/notified_preferences.dart';

/// Your custom Settings class which extends [NotifiedPreferences].
/// It provides helper methods like [createSetting] with which you can quickly set up your preferences.
class Settings with NotifiedPreferences {
  /// Simple values, `String, int, double, bool, List<String>` and nullable versions, are stored and retrieved effortlessly:
  late final PreferenceNotifier<int> clicked = createSetting(
    key: 'clicked',
    initialValue: 0,
  );

  /// It can also store complex objects if you tell it how:
  late final PreferenceNotifier<ComplexObject> complexObject = createSetting(
    key: 'complexObject',
    initialValue: ComplexObject(
      someInt: 0,
      someString: 'a',
    ),

    /// If read returns null, initalValue will be used instead.
    read: (prefs, key) {
      String? value = prefs.getString(key);
      ComplexObject? result;
      if (value != null) {
        return ComplexObject.fromJson(jsonDecode(value));
      }
      return result;
    },
    write: (prefs, key, value) => prefs.setStringOrNull(
      key,
      json.encode(value.toJson()),
    ),
  );

  /// It provides convenience methods for storing enums:
  late final PreferenceNotifier<SomeEnum> someEnum = createEnumSetting(
    key: 'someEnum',
    initialValue: SomeEnum.a,
    values: SomeEnum.values,
  );
}

/// An example complex object with multiple properties.
class ComplexObject {
  ComplexObject({
    required this.someInt,
    required this.someString,
  });

  factory ComplexObject.fromJson(Map<String, dynamic> json) {
    return ComplexObject(
      someInt: json['someInt'],
      someString: json['someString'],
    );
  }

  Map<String, dynamic> toJson() => {
        'someInt': someInt,
        'someString': someString,
      };

  final int someInt;
  final String someString;
}

/// An example enum
enum SomeEnum {
  a,
  b,
  c;
}

Future<void> main() async {
  /// Instantiate your custom Settings class in main.
  Settings settings = Settings();

  /// [NotifiedPreferences] needs to be initialized.
  await settings.initialize();

  /// Provide your Settings class in any way you like, e.g. with InheritedWidget.
  runApp(
    SettingsProvider(
      settings: settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notified Preferences Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),

            /// You can listen to your preferences with [ValueListenableBuilder]
            /// or by using addListener on them, just like any [ValueNotifier].
            ValueListenableBuilder<int>(
              /// Access your custom Settings object and use your preferences.
              valueListenable: SettingsProvider.of(context).clicked,
              builder: (context, value, child) => Text(
                '$value',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        /// When setting a new value to your preference, all listeners are notified.
        onPressed: () => SettingsProvider.of(context).clicked.value++,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
