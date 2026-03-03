
import 'package:untitled10/features/auth/data/models/user_model.dart';
abstract class UserRepository {
Future<UserModel?>createUser(String name,String email,String password);
  Future<UserModel?> getUser();
  Future<UserModel?> updateUser(String name,String email,String password);

}