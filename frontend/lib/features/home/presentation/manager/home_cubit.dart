import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/features/home/presentation/manager/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState(mealTime: 1, activity: 1)) {}

  Future<void> updateMealTime(int mealTime) async {
    emit(state.copyWith(mealTime: mealTime));
  }
}
