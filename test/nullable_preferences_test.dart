import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  group('NullablePreferences', () {
    test('allows deleting keys', () async {
      SharedPreferences.setMockInitialValues({
        'string': 'abc',
        'int': 5,
        'double': 5.5,
        'bool': true,
        'stringlist': ['abc'],
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringOrNull('string', null);
      expect(prefs.getString('string'), null);
      prefs.setIntOrNull('int', null);
      expect(prefs.getInt('int'), null);
      prefs.setDoubleOrNull('double', null);
      expect(prefs.getDouble('double'), null);
      prefs.setBoolOrNull('bool', null);
      expect(prefs.getBool('bool'), null);
      prefs.setStringListOrNull('stringlist', null);
      expect(prefs.getStringList('stringlist'), null);
    });
  });
}
