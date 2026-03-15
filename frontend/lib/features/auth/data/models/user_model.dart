class UserModel {
  final String name;
  final String email;
  final String? password;
  final String? token;
  final int? id;

  // Reminder settings fields
  final String? glucoTime;
  final String? medicineTime;
  final bool? sugarReminder;
  final bool? medicineReminder;
  final String? timezone;

  UserModel({
    required this.name,
    required this.email,
    this.password,
    this.token,
    this.id,
    this.glucoTime,
    this.medicineTime,
    this.sugarReminder,
    this.medicineReminder,
    this.timezone,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      token: map['token'],
      id: map['id'],
      glucoTime: map['gluco_time'],
      medicineTime: map['medicine_time'],
      sugarReminder: map['sugar_reminder'],
      medicineReminder: map['medicine_reminder'],
      timezone: map['timezone'],
    );
  }
}
