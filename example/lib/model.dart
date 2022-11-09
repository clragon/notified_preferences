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
}

/// An example enum
enum SomeEnum {
  a,
  b,
  c;
}
