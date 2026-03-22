import 'package:intl/intl.dart';

class UserModel {
  final String name;
  final String email;
  final String? password;
  final String? token;
  final int? id;
  final String? gender;

  // Reminder settings fields
  final String? glucoTime;
  final String? medicineTime;
  final bool sugarReminder;
  final bool medicineReminder;
  final String? timezone;

  UserModel({
    required this.name,
    required this.email,
    this.password,
    this.token,
    this.id,
    this.gender,
    this.glucoTime,
    this.medicineTime,
    this.sugarReminder = false,
    this.medicineReminder = false,
    this.timezone,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    // Parse gluco_reminder (DateTime) to extract time string
    String? parsedGlucoTime;
    bool parsedSugarReminder = false;
    if (map['gluco_reminder'] != null) {
      try {
        final glucoReminder = DateTime.parse(map['gluco_reminder']);
        parsedGlucoTime = DateFormat('HH:mm').format(glucoReminder);
        parsedSugarReminder = true;
      } catch (e) {
        // If parsing fails, check if gluco_time string exists
        parsedGlucoTime = null;
        parsedSugarReminder = true;
      }
    }

    // Parse medicine_reminder (DateTime) to extract time string
    String? parsedMedicineTime;
    bool parsedMedicineReminder = false;
    if (map['medicine_reminder'] != null) {
      try {
        final medicineReminder = DateTime.parse(map['medicine_reminder']);
        parsedMedicineTime = DateFormat('HH:mm').format(medicineReminder);
        parsedMedicineReminder = true;
      } catch (e) {
        // If parsing fails, check if medicine_time string exists
        parsedMedicineTime = null;
        parsedMedicineReminder = true;
      }
    }

    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      token: map['token'],
      gender: map['gender'],
      glucoTime: parsedGlucoTime,
      medicineTime: parsedMedicineTime,
      sugarReminder: parsedSugarReminder,
      medicineReminder: parsedMedicineReminder,
      timezone: map['timezone'],
    );
  }
}
