class UserModel {
  final String name;
  final String email;
  final String? password;
  final String? token;
  final int? id;
  UserModel({
    required this.name,
    required this.email,
    this.password,
    this.token,
    this.id,
  });
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'],
      password: map['password'],
      token: map['token'],
      id: map['id'],
    );
  }
}
