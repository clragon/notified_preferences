import 'package:notified_preferences/notified_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('PreferenceNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'abc': 'xyz'});
      prefs = await SharedPreferences.getInstance();
    });

    test('should use initialValue when read returns null', () {
      expect(
        PreferenceNotifier<String>(
          preferences: prefs,
          key: 'def',
          initialValue: 'hij',
        ).value,
        'hij',
      );
    });

    test('should read its value when initializing', () {
      expect(
        PreferenceNotifier<String?>(
          preferences: prefs,
          key: 'abc',
          initialValue: null,
        ).value,
        'xyz',
      );
    });

    test('should write its value when its changed', () {
      final notifier = PreferenceNotifier<String?>(
        preferences: prefs,
        key: 'abc',
        initialValue: null,
      );

      notifier.value = 'def';

      expect(notifier.value, 'def');
    });

    test('should allow reloading its value from disk', () {
      final notifier = PreferenceNotifier<String?>(
        preferences: prefs,
        key: 'abc',
        initialValue: null,
      );

      prefs.setString('abc', 'def');

      notifier.reload();

      expect(notifier.value, 'def');
    });
  });
}
