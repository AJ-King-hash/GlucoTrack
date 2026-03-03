import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/empty ghost.json'),
        SizedBox(height: 16.h,),
          Text( context.read<LocaleCubit>().translate('notfound'),style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.bold),),
        ],
      )
    );
  }
}
