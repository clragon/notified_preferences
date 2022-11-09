import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/src/retype.dart';

void main() {
  group('ReType', () {
    test('recognizes supertypes', () async {
      expect(const ReType<A>().isSuperTypeOf(const ReType<B>()), true);
    });

    test('recognizes subtypes', () async {
      expect(const ReType<B>().isSubTypeOf(const ReType<A>()), true);
    });

    test('recognizes sub-objects', () async {
      expect(const ReType<A>().isSuperClassOfObject(B()), true);
    });

    test('compares to others', () async {
      expect(
        const ReType<A>() == const ReType<A>(),
        true,
      );
      expect(
        const ReType<A>() == const ReType<B>(),
        false,
      );
    });

    test('provides information', () {
      expect(
          const ReType<A>().toString(), contains((<T>() => T)<A>().toString()));
    });
  });
}

class A {}

class B extends A {}
