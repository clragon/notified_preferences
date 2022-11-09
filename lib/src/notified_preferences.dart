import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nullable_preferences.dart';
import 'preference_notifier.dart';
import 'preference_read_write.dart';

/// Provides easily creating listenable preferences with [SharedPreferences].
///
/// This class is supposed be used as a Mixin.
/// A basic example of this is provided here:
///
/// ```dart
/// class Settings with NotifiedPreferences {
///   late final PreferenceNotifier<bool> hasSeenTutorial =
///   createSetting(key: 'hasSeenTutorial', initial: false);
///
///   late final PreferenceNotifier<bool> buttonClicks =
///   createSetting(key: 'buttonClicks', initial: 0);
/// }
/// ```
///
/// There can only ever be one [SharedPreferences] and therefore [NotifiedPreferences].
/// It therefore makes sense to treat it as a quasi-global variable in your state management,
/// for example by using an [InheritedWidget] above [MaterialApp].
///
/// The [SharedPreferences] have to be read from disk, so you have to initialize Settings in your main method:
/// ```dart
/// Future<void> main() async {
///   await settings.initialize();
///   runApp(MyApp());
/// }
/// ```
///
/// The settings object can then be used in combination with [ValueListenableBuilder] to provide and listen to your settings:
///
/// ```dart
/// ValueListenableBuilder<int>(
///   valueListenable: settings.buttonClicks,
///   builder: (context, value, child) => Text('You have clicked the button $value times!'),
/// )
/// ```
///
/// And it can be used to set the value and update all listening widgets:
/// ```dart
/// FloatingActionButton(
///   child: Icon(Icons.add),
///   onPressed: () {
///     settings.buttonClicks.value++;
///   },
/// )
/// ```
///
/// If your Settings type does not match any of the predefined types,
/// which are `String, int, double, bool, List<String>` and their nullable counterparts,
/// you can provide custom methods to read and write it, like shown in the following example:
///
/// ```dart
/// late final PreferenceNotifier<ComplexObject> complexObject = createSetting(
///   key: 'complexObject',
///   initialValue: ComplexObject(
///     someInt: 0,
///     someString: 'a',
///   ),
///   read: (prefs, key) {
///     String? value = prefs.getString(key);
///     ComplexObject? result;
///     if (value != null) {
///       result = ComplexObject.fromJson(jsonDecode(value));
///     }
///     return result;
///   },
///   write: (prefs, key, value) => prefs.setStringOrNull(
///     key,
///     json.encode(value.toJson()),
///   ),
/// );
/// ```
///
/// In this example we also use nullable extensions that the package provides
/// to write a String? to SharedPreferences.
/// This means, in case our String is null, we will instead delete the key.
abstract class NotifiedPreferences {
  /// Initializes the [NotifiedPreferences].
  /// This method should be called in your main method, before runApp.
  ///
  /// You can pass a custom [SharedPreferences] instance, in case you are using another library that wraps it.
  Future<void> initialize([FutureOr<SharedPreferences>? preferences]) async =>
      _prefs = await (preferences ?? SharedPreferences.getInstance());

  SharedPreferences? _prefs;
  final List<PreferenceNotifier> _notifiers = [];

  /// Creates a new Preference of type [T].
  /// A key and an initial value have to be provided.
  ///
  /// The following types have default values for [read] and [write] :
  /// `String, int, double, bool, List<String>` and their nullable versions.
  ///
  /// - If you do not provide [read] and [write] methods and your type is not supported, an error will be thrown.
  ///
  /// - If your type is nullable and initially null, provide null for [initialValue].
  ///
  /// - It is possible to not use the [SharedPreferences] object passed to [read] and [write] and instead write your own logic for storing a Preference.
  @protected
  PreferenceNotifier<T> createSetting<T>({
    required String key,
    required T initialValue,
    ReadPreference<T>? read,
    WritePreference<T>? write,
  }) {
    _assertInitialized();
    final notifier = PreferenceNotifier<T>(
      preferences: _prefs!,
      key: key,
      initialValue: initialValue,
      read: read,
      write: write,
    );
    _notifiers.add(notifier);
    return notifier;
  }

  /// Creates an Enum Setting.
  /// The enum value is stored and read as by its `name` property.
  @protected
  PreferenceNotifier<T> createEnumSetting<T extends Enum>({
    required String key,
    required T initialValue,
    required List<T> values,
  }) {
    _assertInitialized();
    return createSetting(
      key: key,
      initialValue: initialValue,
      read: (prefs, key) {
        String? value = prefs.getString(key);
        return values.asNameMap()[value];
      },
      write: (prefs, key, value) => prefs.setStringOrNull(key, value.name),
    );
  }

  /// Reloads the values of all Preferences.
  void _reload() {
    _assertInitialized();
    for (PreferenceNotifier setting in _notifiers) {
      setting.reload();
    }
  }

  /// Completes with true once the settings for the app have been cleared.
  Future<bool> clear() async {
    _assertInitialized();
    bool result = await _prefs!.clear();
    if (result) {
      _reload();
    }
    return result;
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    _assertInitialized();
    await _prefs!.reload();
    _reload();
  }

  /// Ensures that the [NotifiedPreferences] object has been properly initialized.
  void _assertInitialized() {
    if (_prefs == null) {
      throw StateError(
        '$runtimeType was not initialized!\n\n'
        'You must call the initialize() function on your NotifiedSharedPreferences extension before using it,'
        'to ensure that a SharedPreferences instance has been obtained!\n'
        'A good place to do so is in the main function:\n\n'
        'void main() {'
        '  $runtimeType settings = $runtimeType;'
        '  await settings.initialize();'
        '  runApp();'
        '}',
      );
    }
  }
}

/// Provides Preferences for immediate usage, without having to create a new class.
///
/// Can be used to create Preferences across multiple classes.
class NotifiedSettings with NotifiedPreferences {
  NotifiedSettings(SharedPreferences preferences) {
    initialize(preferences);
  }

  static Future<NotifiedSettings> getInstance() async =>
      NotifiedSettings(await SharedPreferences.getInstance());

  @override
  PreferenceNotifier<T> createSetting<T>({
    required String key,
    required T initialValue,
    ReadPreference<T>? read,
    WritePreference<T>? write,
  }) =>
      super.createSetting(
        key: key,
        initialValue: initialValue,
        read: read,
        write: write,
      );

  @override
  PreferenceNotifier<T> createEnumSetting<T extends Enum>({
    required String key,
    required T initialValue,
    required List<T> values,
  }) =>
      super.createEnumSetting(
        key: key,
        initialValue: initialValue,
        values: values,
      );
}
