import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preference_read_write.dart';
import 'preference_utilities.dart';

/// Stores a Preference in [SharedPreferences].
/// When created, will read its own value from [SharedPreferences].
/// Notifies all its listeners whenever its value is changed.
/// Changes are written into the corresponding [SharedPreferences].
class PreferenceNotifier<T> extends ValueNotifier<T> {
  PreferenceNotifier({
    required SharedPreferences preferences,
    required this.key,
    required this.initialValue,
    this.read,
    this.write,
  })  : _prefs = preferences,
        super(
          PreferenceUtilities.readSetting<T>(
            prefs: preferences,
            key: key,
            initialValue: initialValue,
            read: read,
          ),
        );

  @override
  set value(T value) {
    if (this.value != value) {
      PreferenceUtilities.writeSetting<T>(
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
    value = PreferenceUtilities.readSetting<T>(
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

  /// Resets this Preference to its inital value.
  void reset() => value = initialValue;
}
