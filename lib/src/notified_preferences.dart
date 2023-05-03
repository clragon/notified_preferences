import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preference_adapter.dart';
import 'preference_notifier.dart';

/// Provides easily creating listenable preferences with [SharedPreferences].
///
/// This class is supposed be used as a Mixin.
abstract class NotifiedPreferences {
  /// Initializes the [NotifiedPreferences].
  /// This method should be called in your main method, before runApp.
  ///
  /// You can pass a custom [SharedPreferences] instance, in case you are using another library that wraps it.
  Future<void> initialize([FutureOr<SharedPreferences>? preferences]) async =>
      _prefs = await (preferences ?? SharedPreferences.getInstance());

  /// internal sharedp preference instance.
  SharedPreferences? _prefs;

  /// List of all notifiers created by this controller.
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

  /// Creates a Preference that is encoded and decoded from json.
  ///
  /// Types using this must provide a toJson method.
  /// [fromJson] will be used to instantiate the object.
  @protected
  PreferenceNotifier<T> createJsonSetting<T>({
    required String key,
    required T initialValue,
    required DecodeJsonPreference<T> fromJson,
  }) {
    _assertInitialized();
    final notifier = PreferenceNotifier.json<T>(
      preferences: _prefs!,
      key: key,
      initialValue: initialValue,
      fromJson: fromJson,
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
    final notifier = PreferenceNotifier.enums<T>(
      preferences: _prefs!,
      key: key,
      initialValue: initialValue,
      values: values,
    );
    _notifiers.add(notifier);
    return notifier;
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
        '  $runtimeType settings = $runtimeType();'
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
  /// Creates an instace of [NotifiedSettings] with the specified [SharedPreferences].
  NotifiedSettings(SharedPreferences preferences) {
    _prefs = preferences;
  }

  /// Creates an instace of [NotifiedSettings] with the default [SharedPreferences].
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
  PreferenceNotifier<T> createJsonSetting<T>({
    required String key,
    required T initialValue,
    required DecodeJsonPreference<T> fromJson,
  }) =>
      super.createJsonSetting(
        key: key,
        initialValue: initialValue,
        fromJson: fromJson,
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
