class TestObject {
  TestObject({
    required this.someInt,
    required this.someString,
  });

  factory TestObject.fromJson(Map<String, dynamic> json) => TestObject(
        someInt: json['someInt'],
        someString: json['someString'],
      );

  Map<String, dynamic> toJson() => {
        'someInt': someInt,
        'someString': someString,
      };

  final int someInt;
  final String someString;

  @override
  operator ==(Object other) {
    if (other is TestObject) {
      return someInt == other.someInt && someString == other.someString;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(someInt, someString);
}

enum TestEnum {
  a,
  b,
  c;
}
