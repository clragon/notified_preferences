import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import 'common.dart';

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
      expect(settings.object.value, TestObject(someInt: 5, someString: 'abc'));
      expect(settings.testEnum.value, TestEnum.a);
    });

    test('creates enum setting correctly', () async {
      _TestSettings settings = _TestSettings();
      await settings.initialize();
      expect(settings.testEnum.value, TestEnum.a);
      settings.testEnum.value = TestEnum.c;
      expect(settings.testEnum.value, TestEnum.c);
      expect(prefs.getString('testEnum'), 'c');
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
      await settings.clear();
      expect(settings.string.value, 'abc');
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

class _TestSettings with NotifiedPreferences {
  late final PreferenceNotifier<String> string = createSetting(
    key: 'string',
    initialValue: 'abc',
  );

  late final PreferenceNotifier<TestObject> object =
      createJsonSetting<TestObject>(
    key: 'object',
    initialValue: TestObject(someInt: 5, someString: 'abc'),
    fromJson: (json) => TestObject.fromJson(json),
  );

  late final PreferenceNotifier<TestEnum> testEnum = createEnumSetting(
    key: 'testEnum',
    initialValue: TestEnum.a,
    values: TestEnum.values,
  );
}
