import 'package:shared_preferences/shared_preferences.dart';

import 'nullable_preferences.dart';
import 'preference_read_write.dart';

/// Provides utility functions for interacting with [SharedPreferences].
/// Cannot be instantiated. Please use the static methods which are provided.
abstract class PreferenceUtilities {
  /// Finds a matching writer for a Preference in [SharedPreferences].
  /// Known types are `String, int, double, bool, List<String>` and their nullable versions.
  static PreferenceWriter<T>? getWriter<T>(SharedPreferences prefs) {
    if (_typeMatch<String, T>()) {
      return prefs.setStringOrNull as PreferenceWriter<T>;
    }
    if (_typeMatch<int, T>()) {
      return prefs.setIntOrNull as PreferenceWriter<T>;
    }
    if (_typeMatch<bool, T>()) {
      return prefs.setBoolOrNull as PreferenceWriter<T>;
    }
    if (T == _typeify<List<String>>() || T == _typeify<List<String>?>()) {
      return prefs.setStringListOrNull as PreferenceWriter<T>;
    }
    throw PreferenceWriteError<T>();
  }

  /// Writes a Preference to [SharedPreferences].
  static void writeSetting<T>({
    required SharedPreferences prefs,
    required String key,
    required T value,
    WritePreference<T>? write,
  }) async {
    if (write != null) {
      write(prefs, key, value);
    } else {
      PreferenceWriter<T>? serialize = getWriter<T>(prefs);
      await serialize?.call(key, value);
    }
  }

  /// Finds a matching reader for a Preference in [SharedPreferences].
  /// Known types are `String, int, double, bool, List<String>` and their nullable versions.
  static PreferenceReader<T>? getReader<T>(SharedPreferences prefs) {
    if (_typeMatch<String, T>()) {
      return prefs.getString as PreferenceReader<T>;
    }
    if (_typeMatch<int, T>()) {
      return prefs.getInt as PreferenceReader<T>;
    }
    if (_typeMatch<bool, T>()) {
      return prefs.getBool as PreferenceReader<T>;
    }
    if (T == _typeify<List<String>>() || T == _typeify<List<String>?>()) {
      return prefs.getStringList as PreferenceReader<T>;
    }
    throw PreferenceReadError<T>();
  }

  /// Reads a Preference from [SharedPreferences].
  static T readSetting<T>({
    required SharedPreferences prefs,
    required String key,
    required T initialValue,
    ReadPreference<T>? read,
  }) {
    T? value;
    if (read != null) {
      value = read(prefs, key);
    } else {
      PreferenceReader<T>? deserialize = getReader<T>(prefs);
      value = deserialize?.call(key);
    }
    return value ?? initialValue;
  }

  /// Turns a generic into a Type.
  static Type _typeify<T>() => T;

  /// Compares a generic [T] and [T]? to another generic [E].
  static bool _typeMatch<T, E>() => T == E || _typeify<T?>() == E;
}

/// An error that is thrown when [PreferenceUtilities] cannot find a matching Reader for the given Preference Type.
/// Supported Preference types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Reader with the [ReadPreference] parameter.
class PreferenceReadError<T> extends Error {
  @override
  String toString() {
    return "Error: PreferenceUtilities failed to read $T because it wasn't String, int, double, bool or List<String>."
        "\nPlease provide a reader callback.";
  }
}

/// An error that is thrown when [PreferenceUtilities] cannot find a matching Writer for the given Preference Type.
/// Supported Preference types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Writer with the [WritePreference] parameter.
class PreferenceWriteError<T> extends Error {
  @override
  String toString() {
    return "Error: PreferenceUtilities failed to write $T because it wasn't String, int, double, bool or List<String>."
        "\nPlease provide a writer callback.";
  }
}
