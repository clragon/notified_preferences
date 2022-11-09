import 'package:flutter/material.dart';

import 'provider.dart';
import 'settings.dart';

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Close the app and reopen it to see your state persist.',
            ),
            TextButton(
              onPressed: SettingsProvider.of(context).clicked.reset,
              child: const Text('RESET'),
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
