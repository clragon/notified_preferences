# notified_preferences

[![pub package](https://img.shields.io/pub/v/notified_preferences.svg)](https://pub.dartlang.org/packages/notified_preferences)
[![Build Status](https://github.com/clragon/notified_preferences/actions/workflows/test.yml/badge.svg)](https://github.com/clragon/notified_preferences/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/clragon/notified_preferences/badge.svg)](https://coveralls.io/github/clragon/notified_preferences)

Flutter plugin for reading and writing key-value pairs.

notified_preferences is a wrapper around shared_preferences.
It provides you with an easy way of listening to changes in your preference values.

If you're already using `shared_preferences`, you can replace it.

### Index

- [Index](#index)
- [Usage](#usage)
  - [Getting started](#getting-started)
  - [Widgets](#widgets)
  - [Listeners](#listeners)
  - [Json](#json)
  - [Enums](#enums)
- [Advanced usage](#advanced-usage)
  - [Custom shared prefs](#custom-shared-prefs)
  - [Manual notifiers](#manual-notifiers)
  - [Custom Read/Write](#custom-readwrite)
  - [Decentralised settings](#decentralised-settings)

## Usage

### Getting started

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

### Widgets

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

### Listeners

You can also listen to your preferences with `addListener`:

```dart
void _onClicked() {
  print('The user has clicked ${settings.clicked.value} times!');
}

settings.clicked.addListener(_onClicked);
```

Remember to remove the listener again, to avoid memory leaks:

```dart
@override
void dispose() {
  settings.clicked.removeListener(_onClicked);
  super.dispose();
}
```

! Using anonymous functions with `addListener` results in them being unable to be removed !

### Json

If you want to store preferences which aren't contained in the base types,
`String, int, double, bool, List<String>` and their nullable counterparts,
you can store them as json:

```dart
late final PreferenceNotifier<ComplexObject> complexObject = createJsonSetting(
  key: 'complexObject',
  initialValue: ComplexObject(
    someInt: 0,
    someString: 'a',
  ),
  fromJson: (json) => ComplexObject.fromJson(json),
);
```

### Enums

If you want to store enums, a convenience method is provided:

```dart
late final PreferenceNotifier<SomeEnum> someEnum = createEnumSetting(
  key: 'someEnum',
  initialValue: SomeEnum.a,
  values: SomeEnum.values,
);
```

## Advanced usage

### Custom shared prefs

If you are already using a different `SharedPreferences` wrapper like [`encrypted_shared_preferences`](https://pub.dev/packages/encrypted_shared_preferences),
or if you want to mock the implementation for testing, you can pass it during initialisation:

```dart
await settings.initialize(otherSharedPrefs);
```

### Manual notifiers

If you do not want to use `NotifiedPreferences`, you can instantiate your `PreferenceNotifier`s manually:

```dart
final myNotifier = PreferenceNotifier<T>(
  preferences: preferences,
  key: key,
  initialValue: initialValue,
  read: read,
  write: write,
);
```

Note that you lose functionality to clear all your settings.

### Custom Read/Write

If you somehow want to implement custom logic inside read or write of your Preferences, you can do so:

```dart
late final PreferenceNotifier<ComplexObject> complexObject = createSetting(
  key: 'complexObject',
  initialValue: ComplexObject(
    someInt: 0,
    someString: 'a',
  ),
  read: (prefs, key) {
    String? value = prefs.getString(key);
    ComplexObject? result;
    if (value != null) {
      result = ComplexObject.fromJson(jsonDecode(value));
    }
    return result;
  },
  write: (prefs, key, value) => prefs.setStringOrNull(
    key,
    json.encode(value.toJson()),
  ),
);
```

Note that read cannot be async.

### Decentralised settings

If you would like to store your Preferences on multiple classes instead of a single one,
you can use `NotifiedSettings`, which is not abstract:

```dart
NotifiedSettings settings = await NotifiedSettings.getInstance();

class SomeController {
    final ValueNotifier<String?> someValue = settings.createSettings(
        key: 'someString',
        initialValue: null,
    );
}
```

This way you can retain your ability to clear all settings.
