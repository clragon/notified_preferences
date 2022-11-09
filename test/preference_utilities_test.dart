import 'package:notified_preferences/notified_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('PreferenceUtilities', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'abc': 'xyz'});
      prefs = await SharedPreferences.getInstance();
    });

    test('should use the correct writer', () async {
      await prefs.clear();
      PreferenceUtilities.writeSetting<String>(
        prefs: prefs,
        key: 'string',
        value: 'abc',
      );
      expect(prefs.getString('string'), 'abc');
      PreferenceUtilities.writeSetting<int>(
        prefs: prefs,
        key: 'int',
        value: 5,
      );
      expect(prefs.getInt('int'), 5);
      PreferenceUtilities.writeSetting<double>(
        prefs: prefs,
        key: 'double',
        value: 5.5,
      );
      expect(prefs.getDouble('double'), 5.5);
      PreferenceUtilities.writeSetting<bool>(
        prefs: prefs,
        key: 'bool',
        value: true,
      );
      expect(prefs.getBool('bool'), true);
      PreferenceUtilities.writeSetting<List<String>>(
        prefs: prefs,
        key: 'stringlist',
        value: ['abc'],
      );
      expect(prefs.getStringList('stringlist'), equals(['abc']));
    });

    test('should use the writer when specified', () {
      bool called = false;
      PreferenceUtilities.writeSetting<String>(
        prefs: prefs,
        key: 'abc',
        value: 'def',
        write: (prefs, key, value) => called = true,
      );
      expect(called, true);
    });

    test('should throw when no writer for custom object', () {
      expect(
        () => PreferenceUtilities.getWriter<Object>(prefs)
            is PreferenceWriter<Object>,
        throwsA(const TypeMatcher<PreferenceWriteError<Object>>()),
      );
    });

    test('should use the correct reader', () async {
      await prefs.clear();
      prefs.setString('string', 'abc');
      PreferenceUtilities.readSetting<String?>(
        prefs: prefs,
        key: 'string',
        initialValue: null,
      );
      expect(prefs.getString('string'), 'abc');
      prefs.setInt('int', 5);
      PreferenceUtilities.readSetting<int?>(
        prefs: prefs,
        key: 'int',
        initialValue: null,
      );
      expect(prefs.getInt('int'), 5);
      prefs.setDouble('double', 5.5);
      PreferenceUtilities.readSetting<double?>(
        prefs: prefs,
        key: 'double',
        initialValue: null,
      );
      expect(prefs.getDouble('double'), 5.5);
      prefs.setBool('bool', true);
      PreferenceUtilities.readSetting<bool?>(
        prefs: prefs,
        key: 'bool',
        initialValue: null,
      );
      expect(prefs.getBool('bool'), true);
      prefs.setStringList('stringlist', ['abc']);
      PreferenceUtilities.readSetting<List<String>?>(
        prefs: prefs,
        key: 'stringlist',
        initialValue: null,
      );
      expect(prefs.getStringList('stringlist'), equals(['abc']));
    });

    test('should use the reader when specified', () {
      bool called = false;
      PreferenceUtilities.readSetting<String?>(
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

    test('should throw when no reader for custom object', () {
      expect(
        () => PreferenceUtilities.getReader<Object>(prefs)
            is PreferenceReader<Object>,
        throwsA(const TypeMatcher<PreferenceReadError<Object>>()),
      );
    });
  });
}
