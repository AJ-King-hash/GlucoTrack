class UserEntity {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? token;
  final String? gender;
  final String? glucoTime;
  final String? medicineTime;
  final bool sugarReminder;
  final bool medicineReminder;
  final String? timezone;

  UserEntity({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.token,
    this.gender,
    this.glucoTime,
    this.medicineTime,
    this.sugarReminder = false,
    this.medicineReminder = false,
    this.timezone,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? token,
    String? gender,
    String? glucoTime,
    String? medicineTime,
    bool? sugarReminder,
    bool? medicineReminder,
    String? timezone,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      gender: gender ?? this.gender,
      glucoTime: glucoTime ?? this.glucoTime,
      medicineTime: medicineTime ?? this.medicineTime,
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
      timezone: timezone ?? this.timezone,
    );
  }
}
