import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/api/api_error.dart';
import 'package:untitled10/features/auth/presentaion/manager/auth_state.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepository authRepository;
  AuthCubit(this.authRepository):super(AuthInitial());
  Future<void>login({required String email,required String password})async{
    emit(AuthLoading());
    try{
      final user = await authRepository.login(email, password);
      if(user !=null){

        emit(AuthSuccess("Login successful"));
    }
    }catch(e){
      String errMsg = "Error in Login";
      if(e is ApiError){
        errMsg = e.message;
      }
      emit(AuthError(errMsg));
    }
  }
  Future<void>logout()async{
    emit(AuthLoading());
    try{
      final user = await authRepository.logout();
      emit(AuthSuccess("Logout Successfully"));
    }catch(e){
      String errMsg = "Error in Logout";
      if(e is ApiError){
        errMsg = e.message;
      }
      emit(AuthError(errMsg));
    }
  }
}