import 'package:dio/dio.dart';
import 'package:untitled10/core/api/api_error.dart';
import 'package:untitled10/core/api/api_exceptions.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/api/end_point.dart';
import 'package:untitled10/core/utils/pref_helper.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';

class AuthRepoImpl extends AuthRepository{
  final ApiService apiService;
   UserModel? _currentUser;
   final UserRepository? userRepository;
  AuthRepoImpl(this.apiService,this._currentUser,this.userRepository);
  //Login method

Future<UserModel?>login(String email,String password)async{
  try{
    final response = await apiService.post(ApiEndpoints.login,{'email':email,'password':password});
    if(response is ApiError ){
      throw response;
    }
    if(response is Map<String,dynamic>){
      final message = response['message'];
      final code = response['code'];
      final data = response['data'];
      if(code!=200||data ==null){
        throw ApiError(message: message);
      }
      final user = UserModel.fromJson(response['data']);
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

//logout methods
Future<void>logout()async{
  final response = await apiService.post("/logout", {});
  if(response is ApiError){
    throw response;
  }
  await PrefHelper.clearToken();
  _currentUser = null;
}

//function for auto login
Future<UserModel?> autoLogin()async{
  final token = await PrefHelper.getToken();
  if(token == null){
    _currentUser = null;
    return null;
  }
  try{
    final user = await userRepository?.getUser();
    _currentUser = user;
    return user;
  }catch(_){
    await PrefHelper.clearToken();
    _currentUser = null;
    return null;

  }
}

//get currentUser;
UserModel?get currentUser =>_currentUser;
//get isLoggedIn
bool get isLoggedIn => _currentUser!=null;
}
