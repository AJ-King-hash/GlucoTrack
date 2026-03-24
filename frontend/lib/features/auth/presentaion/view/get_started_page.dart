import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/routes/app_routes.dart';

import '../../../../core/localization/locale_cubit.dart';

import '../../data/models/on_boarding_model.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  var boardController = PageController();

  List<OnBoardingModel> boarding = [
    OnBoardingModel(
      title: 'Welcome to GlucoTrack',
      lottie: 'assets/lottie/Medical app.json',
      body:
          'A smart and easy way to manage your blood sugar readings, medications, and daily activity all in one place.',
    ),
    OnBoardingModel(
      title: 'Track Your Health Daily',
      lottie: 'assets/lottie/Medical App (1).json',
      body:
          'Log your measurements and monitor your sugar levels and activities, while receiving accurate insights to help you make informed health decisions.',
    ),
    OnBoardingModel(
      title: 'Personal Reminders & Tips',
      lottie: 'assets/lottie/Notifications.json',
      body:
          'Get reminders for measurements and medications, along with personalized tips based on your data to stay on track with your health goals.',
    ),
  ];
  bool isLast = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.backgroundNeutral,
        elevation: 0,
        title: TextButton(
          onPressed: () {
            final localeCubit = context.read<LocaleCubit>();
            if (localeCubit.currentLocale.languageCode == 'ar') {
              localeCubit.changeLanguage('en');
            } else {
              localeCubit.changeLanguage('ar');
            }
          },
          child: Text(
            context.read<LocaleCubit>().translate('language'),
            style: TextStyle(color: AppColor.info, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.splashScreen);
            },
            child: Text(
              'SKIP',
              style: TextStyle(
                color: AppColor.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: boardController,
                physics: BouncingScrollPhysics(),
                onPageChanged: (int index) {
                  if (index == boarding.length - 1) {
                    setState(() {
                      isLast = true;
                    });
                  } else {
                    setState(() {
                      isLast = false;
                    });
                  }
                },
                itemBuilder:
                    (context, index) => buildBoardingItem(boarding[index]),
                itemCount: boarding.length,
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              children: [
                SmoothPageIndicator(
                  controller: boardController,
                  count: boarding.length,
                  effect: ExpandingDotsEffect(
                    dotColor: AppColor.textNeutral,
                    activeDotColor: AppColor.positive,
                    dotHeight: 10.h,
                    dotWidth: 10.w,
                    expansionFactor: 4,
                    spacing: 5.w,
                  ),
                ),
                Spacer(),
                FloatingActionButton(
                  backgroundColor: AppColor.positive,
                  onPressed: () {
                    if (isLast) {
                      Navigator.pushNamed(context, AppRoutes.splashScreen);
                    } else {
                      boardController.nextPage(
                        duration: Duration(milliseconds: 750),
                        curve: Curves.easeInBack,
                      );
                    }
                  },

                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBoardingItem(OnBoardingModel model) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(child: Lottie.asset(model.lottie)),
      SizedBox(height: 30.h),
      Text(
        model.title,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.info,
        ),
      ),
      SizedBox(height: 14.h),
      Text(
        model.body,
        style: TextStyle(fontSize: 14.sp, color: AppColor.textNeutral),
      ),
      SizedBox(height: 30.h),
    ],
  );
}
