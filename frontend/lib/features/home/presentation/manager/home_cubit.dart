import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/features/home/presentation/manager/home_state.dart';

class HomeCubit extends Cubit<HomeState>{
  HomeCubit():super(const HomeState(mealTime:1,activity:1, weight: 1, age: 1));

  void updateMealTime(int mealTime){
    emit(state.copyWith(mealTime: mealTime));
  }

  void updateActivity(int activity){
    emit(state.copyWith(activity: activity));
  }
  void updateAge(int value) {
    emit(state.copyWith(age: value));
  }

  void updateWeight(int value) {
    emit(state.copyWith(weight: value));
  }
  void updateGender(Gender gender){
    emit(state.copyWith(
        gender: gender,
    maritalStatus: null,
    pregnancyCount: 0));
  }
  void updateMaterialStatus(MaritalStatus material){
    emit(state.copyWith(maritalStatus: material,
    pregnancyCount: 0));
  }
  void updatePregnancyCount(int count){
    emit(state.copyWith(pregnancyCount: count));
  }
}