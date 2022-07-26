
class User {
  final int id;
  final String name;
  final int age;

  const User(this.id, this.name, this.age);

  Map<String, dynamic> toJson() => {
    UserFields.id: id,
    UserFields.name: name,
    UserFields.age: age,
  };

  static User fromJson(Map<String, dynamic> json) => User(
      json[UserFields.id] ?? 0,
      json[UserFields.name] ?? '',
      json[UserFields.age] ?? 0
  );
}

class UserFields {

  static final List<String> values = [id, name, age];

  static const String id = '_id';
  static const String name = '_name';
  static const String age = '_age';
}