import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import 'common.dart';
import 'memory_shared_preferences.dart';

void main() {
  group('NotifiedPreferences', () {
    late SharedPreferences prefs;
    late NotifiedSettings settings;
    late PreferenceNotifier<String> string;
    late PreferenceNotifier<TestObject> object;
    late PreferenceNotifier<TestEnum> testEnum;

    setUp(() async {
      prefs = MemorySharedPreferences({'abc': 'xyz'});
      settings = NotifiedSettings(prefs);
      string = settings.createSetting(
        key: 'string',
        initialValue: 'abc',
      );

      object = settings.createJsonSetting<TestObject>(
        key: 'object',
        initialValue: TestObject(someInt: 5, someString: 'abc'),
        fromJson: (json) => TestObject.fromJson(json),
      );

      testEnum = settings.createEnumSetting(
        key: 'testEnum',
        initialValue: TestEnum.a,
        values: TestEnum.values,
      );
    });

    test('is initialized properly', () async {
      await settings.initialize();
    });

    test('creates settings correctly', () async {
      await settings.initialize();
      expect(string.value, 'abc');
      expect(object.value, TestObject(someInt: 5, someString: 'abc'));
      expect(testEnum.value, TestEnum.a);
    });

    test('creates enum setting correctly', () async {
      await settings.initialize();
      expect(testEnum.value, TestEnum.a);
      testEnum.value = TestEnum.c;
      expect(testEnum.value, TestEnum.c);
      expect(prefs.getString('testEnum'), 'c');
    });

    test('can reload settings', () async {
      await settings.initialize(prefs);
      prefs.setString('string', 'xyz');
      await settings.reload();
      expect(string.value, 'xyz');
    });

    test('can clear settings', () async {
      await settings.initialize(prefs);
      string.value = 'xyz';
      await settings.clear();
      expect(string.value, 'abc');
    });
  });

  group('NotifiedSettings', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'abc': 'xyz'});
      prefs = await SharedPreferences.getInstance();
    });

    test('is initialized properly', () async {
      final natural = await NotifiedSettings.getInstance();
      natural.reload();
      final artificial = NotifiedSettings(prefs);
      artificial.reload();
    });

    test('can create settings', () {
      NotifiedSettings settings = NotifiedSettings(prefs);
      final string = settings.createSetting<String>(
        key: 'string',
        initialValue: 'abc',
      );
      expect(string.value, 'abc');
      final json = settings.createJsonSetting<TestObject>(
        key: 'json',
        initialValue: TestObject(someInt: 5, someString: 'abc'),
        fromJson: (json) => TestObject.fromJson(json),
      );
      expect(json.value, TestObject(someInt: 5, someString: 'abc'));
      final testEnum = settings.createEnumSetting<TestEnum>(
        key: 'testEnum',
        initialValue: TestEnum.a,
        values: TestEnum.values,
      );
      expect(testEnum.value, TestEnum.a);
    });
  });
}
