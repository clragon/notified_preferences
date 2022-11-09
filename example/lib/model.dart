/// An example complex object with multiple properties.
class ComplexObject {
  ComplexObject({
    required this.someInt,
    required this.someString,
  });

  factory ComplexObject.fromJson(Map<String, dynamic> json) {
    return ComplexObject(
      someInt: json['someInt'],
      someString: json['someString'],
    );
  }

  Map<String, dynamic> toJson() => {
        'someInt': someInt,
        'someString': someString,
      };

  final int someInt;
  final String someString;

  @override
  operator ==(Object other) {
    if (other is ComplexObject) {
      return someInt == other.someInt && someString == other.someString;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(someInt, someString);
}

/// An example enum
enum SomeEnum {
  a,
  b,
  c;
}
