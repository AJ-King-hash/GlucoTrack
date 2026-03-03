import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/api/api_error.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';

class UserCubit extends Cubit<UserState>{
  final UserRepository userRepository;
  UserCubit(this.userRepository):super(UserInitial());

  //function for create user
Future<void>createUser({required String name,required String email,required String password})async{
  emit(UserLoading());
  try{
final user = await userRepository.createUser(name, email, password);
if(user!=null){
  emit(UserSuccess("Register successful"));
}
  } catch(e){
    String errMsg = "Error in Register";
    if(e is ApiError){
      errMsg = e.message;
    }
emit(UserError(errMsg));
  }
}
//function for get user data
Future<void>getUser()async{
  emit(UserLoading());
  try{
    final user =await userRepository.getUser();
    if(user!=null){
      emit(UserLoaded(user));
    }else{
      emit(UserError("User not found"));
    }
  }catch(e){
    String errorMsg ="Error in Profile";
    if(e is ApiError){
      errorMsg = e.message;
    }
    emit(UserError(errorMsg));
  }
}

  //function for update user data
Future<void>updateUser({required String name,required String email,required String password})async{
  emit(UserLoading());
  try{
    final user = await userRepository.updateUser(name, email, password);
    if(user!=null){
      emit(UserLoaded(user));
    }else{
      emit(UserError("Faild to update profile"));
    }
    await getUser();
    emit(UserSuccess("Profile updated successfully"));
  }catch(e){
    String errorMsg ="Error in Update Profile";
    if(e is ApiError){
      errorMsg = e.message;
    }
    emit(UserError(errorMsg));
  }
}
}