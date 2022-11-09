import 'package:notified_preferences/notified_preferences.dart';

import 'model.dart';

/// Your custom Settings class which extends [NotifiedPreferences].
/// It provides helper methods like [createSetting] with which you can quickly set up your preferences.
class Settings with NotifiedPreferences {
  /// Simple values, `String, int, double, bool, List<String>` and nullable versions, are stored and retrieved effortlessly:
  late final PreferenceNotifier<int> clicked = createSetting(
    key: 'clicked',
    initialValue: 0,
  );

  /// It can also store json objects, if they provide toJson and fromJson.
  late final PreferenceNotifier<ComplexObject> complexObject =
      createJsonSetting(
    key: 'complexObject',
    initialValue: ComplexObject(
      someInt: 0,
      someString: 'a',
    ),
    fromJson: (json) => ComplexObject.fromJson(json),
  );

  /// It provides convenience methods for storing enums:
  late final PreferenceNotifier<SomeEnum> someEnum = createEnumSetting(
    key: 'someEnum',
    initialValue: SomeEnum.a,
    values: SomeEnum.values,
  );
}
