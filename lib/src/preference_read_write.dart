import 'package:shared_preferences/shared_preferences.dart';

/// Reads [value] from [key].
typedef PreferenceReader<T> = T? Function(String key);

/// Writes [value] to [key].
typedef PreferenceWriter<T> = Future<bool> Function(String key, T value);

/// Reads a Preference from [SharedPreferences].
typedef ReadPreference<T> = T? Function(SharedPreferences prefs, String key);

/// Writes a Preference to [SharedPreferences].
typedef WritePreference<T> = void Function(
    SharedPreferences prefs, String key, T value);
