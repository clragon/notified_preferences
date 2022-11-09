import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nullable_preferences.dart';
import 'preference_adapter.dart';

/// Stores a Preference in [SharedPreferences].
/// When created, will read its own value from [SharedPreferences].
/// Notifies all its listeners whenever its value is changed.
/// Changes are written into the corresponding [SharedPreferences].
class PreferenceNotifier<T> extends ValueNotifier<T> {
  /// Creates a PreferenceNotifier.
  PreferenceNotifier({
    required SharedPreferences preferences,
    required this.key,
    required this.initialValue,
    this.read,
    this.write,
  })  : _prefs = preferences,
        super(
          PreferenceAdapter.readSetting<T>(
            prefs: preferences,
            key: key,
            initialValue: initialValue,
            read: read,
          ),
        );

  /// Creates a PreferenceNotifier that is stored as json string.
  static PreferenceNotifier<T> json<T>({
    required SharedPreferences preferences,
    required String key,
    required T initialValue,
    required T Function(dynamic json) fromJson,
  }) =>
      _JsonPreferenceNotifier(
        preferences: preferences,
        key: key,
        initialValue: initialValue,
        fromJson: fromJson,
      );

  /// Creates a PreferenceNotifier that stores an Enum by its name.
  static PreferenceNotifier<T> enums<T extends Enum>({
    required SharedPreferences preferences,
    required String key,
    required T initialValue,
    required List<T> values,
  }) =>
      _EnumPreferenceNotifier(
        preferences: preferences,
        key: key,
        initialValue: initialValue,
        values: values,
      );

  @override
  set value(T value) {
    if (this.value != value) {
      PreferenceAdapter.writeSetting<T>(
        prefs: _prefs,
        key: key,
        value: value,
        write: write,
      );
    }
    super.value = value;
  }

  /// Reads this setting from disk again.
  void reload() {
    value = PreferenceAdapter.readSetting<T>(
      prefs: _prefs,
      key: key,
      initialValue: initialValue,
      read: read,
    );
  }

  /// The [SharedPreferences] in which this Preference is saved in.
  final SharedPreferences _prefs;

  /// The key for this Preference.
  final String key;

  /// The initial value of this Preference. Used when reading it would return null.
  final T initialValue;

  /// The method to read this Preference. This is required for special Types.
  final ReadPreference<T>? read;

  /// The method to write this Preference. This is required for special Types.
  final WritePreference<T>? write;

  /// Resets this Preference to its initial value.
  void reset() => value = initialValue;
}

/// Creates a PreferenceNotifier that stores an Enum by its name.
class _EnumPreferenceNotifier<T extends Enum> extends PreferenceNotifier<T> {
  _EnumPreferenceNotifier({
    required super.preferences,
    required super.key,
    required super.initialValue,
    required List<T> values,
  }) : super(
          read: (prefs, key) => values.asNameMap()[prefs.getString(key)],
          write: (prefs, key, value) => prefs.setStringOrNull(key, value.name),
        );
}

/// Creates a PreferenceNotifier that is stored as json string.
class _JsonPreferenceNotifier<T> extends PreferenceNotifier<T> {
  _JsonPreferenceNotifier({
    required super.preferences,
    required super.key,
    required super.initialValue,
    required T Function(dynamic json) fromJson,
  }) : super(
          read: PreferenceAdapter.jsonReader(fromJson),
          write: PreferenceAdapter.jsonWriter,
        );
}
