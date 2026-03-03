import 'package:hive/hive.dart';

class HiveService {
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }
}