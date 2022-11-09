import 'dart:convert';

import 'package:notified_preferences/notified_preferences.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('PreferenceAdapter', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'abc': 'xyz'});
      prefs = await SharedPreferences.getInstance();
    });

    test('should use the correct writer', () async {
      await prefs.clear();
      PreferenceAdapter.writeSetting<String>(
        prefs: prefs,
        key: 'string',
        value: 'abc',
      );
      expect(prefs.getString('string'), 'abc');
      PreferenceAdapter.writeSetting<int>(
        prefs: prefs,
        key: 'int',
        value: 5,
      );
      expect(prefs.getInt('int'), 5);
      PreferenceAdapter.writeSetting<double>(
        prefs: prefs,
        key: 'double',
        value: 5.5,
      );
      expect(prefs.getDouble('double'), 5.5);
      PreferenceAdapter.writeSetting<bool>(
        prefs: prefs,
        key: 'bool',
        value: true,
      );
      expect(prefs.getBool('bool'), true);
      PreferenceAdapter.writeSetting<List<String>>(
        prefs: prefs,
        key: 'stringlist',
        value: ['abc'],
      );
      expect(prefs.getStringList('stringlist'), equals(['abc']));
    });

    test('should use the writer when specified', () {
      bool called = false;
      PreferenceAdapter.writeSetting<String>(
        prefs: prefs,
        key: 'abc',
        value: 'def',
        write: (prefs, key, value) => called = true,
      );
      expect(called, true);
    });

    test('should correctly write json objects', () {
      PreferenceAdapter.writeSetting<TestObject>(
        prefs: prefs,
        key: 'json',
        value: TestObject(someInt: 5, someString: 'abc'),
        write: PreferenceAdapter.jsonWriter,
      );
      expect(
        TestObject.fromJson(json.decode(prefs.getString('json')!)),
        TestObject(someInt: 5, someString: 'abc'),
      );
    });

    test('should throw when no writer for custom object', () {
      expect(
        () => PreferenceAdapter.getWriter<Object>(prefs)
            is PreferenceWriter<Object>,
        throwsA(const TypeMatcher<PreferenceWriteError<Object>>()),
      );
    });

    test('should use the correct reader', () async {
      await prefs.clear();
      prefs.setString('string', 'abc');
      PreferenceAdapter.readSetting<String?>(
        prefs: prefs,
        key: 'string',
        initialValue: null,
      );
      expect(prefs.getString('string'), 'abc');
      prefs.setInt('int', 5);
      PreferenceAdapter.readSetting<int?>(
        prefs: prefs,
        key: 'int',
        initialValue: null,
      );
      expect(prefs.getInt('int'), 5);
      prefs.setDouble('double', 5.5);
      PreferenceAdapter.readSetting<double?>(
        prefs: prefs,
        key: 'double',
        initialValue: null,
      );
      expect(prefs.getDouble('double'), 5.5);
      prefs.setBool('bool', true);
      PreferenceAdapter.readSetting<bool?>(
        prefs: prefs,
        key: 'bool',
        initialValue: null,
      );
      expect(prefs.getBool('bool'), true);
      prefs.setStringList('stringlist', ['abc']);
      PreferenceAdapter.readSetting<List<String>?>(
        prefs: prefs,
        key: 'stringlist',
        initialValue: null,
      );
      expect(prefs.getStringList('stringlist'), equals(['abc']));
    });

    test('should use the reader when specified', () {
      bool called = false;
      PreferenceAdapter.readSetting<String?>(
        prefs: prefs,
        key: 'abc',
        initialValue: null,
        read: (prefs, key) {
          called = true;
          return '';
        },
      );
      expect(called, true);
    });

    test('should correctly read json objects', () async {
      await prefs.setString(
        'json',
        json.encode(TestObject(someInt: 5, someString: 'abc')),
      );
      final result = PreferenceAdapter.readSetting<TestObject?>(
        prefs: prefs,
        key: 'json',
        initialValue: null,
        read: PreferenceAdapter.jsonReader((json) => TestObject.fromJson(json)),
      );
      expect(
        result,
        TestObject(someInt: 5, someString: 'abc'),
      );
    });

    test('should throw when no reader for custom object', () {
      expect(
        () => PreferenceAdapter.getReader<Object>(prefs)
            is PreferenceReader<Object>,
        throwsA(const TypeMatcher<PreferenceReadError<Object>>()),
      );
    });

    test('provides satisfactory error messages', () {
      expect(PreferenceReadError<Object?>().toString(), contains('Object?'));
      expect(PreferenceWriteError<Object?>().toString(), contains('Object?'));
    });
  });
}
