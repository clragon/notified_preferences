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

    test('should notify its listeners when its value changes', () {
      final notifier = PreferenceNotifier<String?>(
        preferences: prefs,
        key: 'abc',
        initialValue: null,
      );

      bool called = false;
      notifier.addListener(() => called = true);
      notifier.value = 'def';

      expect(called, true);
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

    test('should allow resetting its value', () {
      final notifier = PreferenceNotifier<String?>(
        preferences: prefs,
        key: 'abc',
        initialValue: 'def',
      );

      expect(notifier.value, 'xyz');

      notifier.reset();

      expect(notifier.value, 'def');
      expect(prefs.getString('abc'), 'def');
    });
  });
}
