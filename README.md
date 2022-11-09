# notified_preferences

[![pub package](https://img.shields.io/pub/v/notified_preferences.svg)](https://pub.dartlang.org/packages/notified_preferences)

Flutter plugin for reading and writing simple key-value pairs.

notified_preferences is a wrapper around shared_preferences.
It provides you with an easy way of listening to changes in your preference values.

## Getting started

First, add notified_preferences into your pubspec.yaml.

```yaml
dependencies:
  notified_preferences: ^0.0.1
```

If you're already using `shared_preferences`, you can replace it:

```diff
dependencies:
-   shared_preferences: ^2.0.15
+   notified_preferences: ^0.0.1
```

## Usage

A helper mixin class, `NotifiedPreferences` is provided with which you can create your own Settings object:

```dart
class Settings with NotifiedPreferences {
  late final PreferenceNotifier<bool> hasSeenTutorial =
    createSetting(key: 'hasSeenTutorial', initial: false);

  late final PreferenceNotifier<bool> clicked =
    createSetting(key: 'buttonClicks', initial: 0);
}
```

`NotifiedPreferences` has to be initialized once, when you create your Settings object:

```dart
Future<void> main() async {
  await settings.initialize();
  runApp(MyApp());
}
```

This has the benefit that all other operations are completely synchronous.

You can listen to your preferences by using `ValueListenableBuilder` just like with normal `ValueNotifier`:

```dart
ValueListenableBuilder<int>(
  valueListenable: settings.clicked,
  builder: (context, value, child) => Text('You have clicked the button $value times!'),
)
```

And when you change your value, listeners will be notified / rebuilt:

```dart
FloatingActionButton(
  onPressed: () => settings.clicked.value++,
  tooltip: 'Increment',
  child: const Icon(Icons.add),
),
```

If you want to store preferences which aren't contained in the base types,
`String, int, double, bool, List<String>` and their nullable counterparts,
you can specify custom read and write functions:

```dart
late final PreferenceNotifier<ComplexObject> complexObject = createSetting(
  key: 'complexObject',
  initialValue: ComplexObject(
    someInt: 0,
    someString: 'a',
  ),
  // If read returns null, initalValue will be used instead.
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
```

If you want to store enums, convenience methods are provided:

```dart
late final PreferenceNotifier<SomeEnum> someEnum = createEnumSetting(
  key: 'someEnum',
  initialValue: SomeEnum.a,
  values: SomeEnum.values,
);
```

## Advanced usage

If you are already using a different `SharedPreferences` wrapper like encrypted_shared_preferences,
or if you wanna mock the implementation for testing, you can pass it during itialization:

```dart
await settings.initialize(otherSharedPrefs);
```

If you do not want to use the `NotifiedPreferences`, you can manually instantiate your `PreferenceNotifier`s manually:

```dart
final myNotifier = PreferenceNotifier<T>(
  preferences: preferences,
  key: key,
  initialValue: initialValue,
  read: read,
  write: write,
);
```

If you would like to store your Preferences on multiple classes instead of a single one,
you can use `NotifiedSettings`, which is not abstract:

```dart
NotifiedSettings settings = NotifiedSettings.getInstance();

class SomeController {
    final ValueNotifier<String?> someValue = settings.createSettings(
        key: 'someString',
        initialValue: null,
    );
}
```
