class UserModel{
  final String name;
  final String email;
  final String password;
  final String? token;
  UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.token
});
  factory UserModel.fromJson(Map<String,dynamic> map){
    return UserModel(
        name: map['name'],
        email: map['email'],
        password: map['password'],
        token:map['token']
    );
  }
}