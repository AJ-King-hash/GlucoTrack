import 'package:dio/dio.dart';
import 'package:untitled10/core/api/api_error.dart';
import 'package:untitled10/core/api/api_exceptions.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/api/end_point.dart';
import 'package:untitled10/core/utils/pref_helper.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';





class UserRepositoryImpl implements UserRepository {
final ApiService apiService;
UserModel?_currentUser;
UserRepositoryImpl(this.apiService);

//function for create user
  @override
 Future<UserModel?>createUser(String name,String email, String password)async{
    try{
      final response = await apiService.post(ApiEndpoints.user, {
        'name': name,
        'email': email,
        'password': password,
      });
      if(response is ApiError){
        throw response;
      }
      if(response is Map<String,dynamic>){
        final msg = response['message'];
        final code   = response['code'];
        final coder = int.tryParse(code);
        final data = response['data'];
        if(coder!=200&&data==null){
          throw ApiError(message: msg??"Unknown Error");
        }
        final user = UserModel.fromJson(data);
        if(user.token!=null){
          await PrefHelper.saveToken(user.token!);
        }
        _currentUser = user;
        return user;
      }else{
        throw ApiError(message: "Invalid Response");
      }
    }on DioException catch(e){
      throw ApiExceptions.handleError(e);
    }catch(e){
      throw ApiError(message: e.toString());
    }
  }
//function for get user data
  @override
  Future<UserModel?> getUser() async {
  try {
    final token = await PrefHelper.getToken();
    if(token == null) return null;
    final response = await apiService.get("/user");
    if (response is ApiError) {
      throw response;
    }
  final user =  UserModel.fromJson(response['user']);
    _currentUser=user;
    return user;
  }on DioException catch(e){
    throw ApiExceptions.handleError(e);
  }catch(e){
    throw ApiError(message: e.toString());
  }

  }

//function for update user data
  @override
  Future<UserModel?> updateUser(String name,String email,String password) async {
    try {
      final response = await apiService.put("/user/update", {
        "name":name,
        "email":email,
        "password":password,
      });
      if(response is ApiError){
        throw response;
      }
      if(response is Map<String,dynamic>){
        final msg= response['message'];
        final code = response['code'];
        final coder = int.tryParse(code);
        if(coder!=200&&coder!=201){
          throw ApiError(message: msg??"Unknown Error");
        }
       final updateUser= UserModel.fromJson(response['user']);
        _currentUser = updateUser;
        return updateUser;
      }
    } on DioException catch (e) {
        throw ApiExceptions.handleError(e);
    }catch(e){
      throw ApiError(message: e.toString());
    }
  }
}