import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  group('NotifiedPreferences', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'abc': 'xyz'});
      prefs = await SharedPreferences.getInstance();
    });

    test('is initialized properly', () async {
      _TestSettings settings = _TestSettings();
      await settings.initialize();
    });

    test('throws when not initialized', () {
      expect(
        () => _TestSettings().string.value,
        throwsA(const TypeMatcher<StateError>()),
      );
    });

    test('creates settings correctly', () async {
      _TestSettings settings = _TestSettings();
      await settings.initialize();
      expect(settings.string.value, 'abc');
      expect(settings.object.value, _TestObject(someInt: 5, someString: 'abc'));
      expect(settings.testEnum.value, _TestEnum.a);
    });

    test('can reload settings', () async {
      _TestSettings settings = _TestSettings();
      await settings.initialize(prefs);
      prefs.setString('string', 'xyz');
      settings.reload();
      expect(settings.string.value, 'xyz');
    });

    test('can clear settings', () async {
      _TestSettings settings = _TestSettings();
      await settings.initialize(prefs);
      settings.string.value = 'xyz';
      settings.reload();
      expect(settings.string.value, 'xyz');
    });
  });

  group('NotifiedSettings', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'abc': 'xyz'});
      prefs = await SharedPreferences.getInstance();
    });

    test('is initialized properly', () async {
      await NotifiedSettings.getInstance();
      NotifiedSettings(prefs);
    });
  });
}

class _TestSettings with NotifiedPreferences {
  late final PreferenceNotifier<String> string = createSetting(
    key: 'string',
    initialValue: 'abc',
  );

  late final PreferenceNotifier<_TestObject> object = createSetting(
    key: 'object',
    initialValue: _TestObject(someInt: 5, someString: 'abc'),
    read: (prefs, key) {
      String? value = prefs.getString(key);
      _TestObject? result;
      if (value != null) {
        return _TestObject.fromJson(json.decode(value));
      }
      return result;
    },
    write: (prefs, key, value) => prefs.setStringOrNull(
      key,
      json.encode(value.toJson()),
    ),
  );

  late final PreferenceNotifier<_TestEnum> testEnum = createEnumSetting(
    key: 'testEnum',
    initialValue: _TestEnum.a,
    values: _TestEnum.values,
  );
}

class _TestObject {
  _TestObject({
    required this.someInt,
    required this.someString,
  });

  factory _TestObject.fromJson(Map<String, dynamic> json) => _TestObject(
        someInt: json['someInt'],
        someString: json['someString'],
      );

  Map<String, dynamic> toJson() => {
        'someInt': someInt,
        'someString': someString,
      };

  final int someInt;
  final String someString;

  @override
  operator ==(Object other) {
    if (other is _TestObject) {
      return someInt == other.someInt && someString == other.someString;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(someInt, someString);
}

enum _TestEnum {
  a,
  b,
  c;
}
