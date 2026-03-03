import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../localization/locale_cubit.dart';

void showLanguageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text("🇸🇦", style: TextStyle(fontSize: 22)),
              title: const Text("العربية"),
              onTap: () {
                context.read<LocaleCubit>().changeLanguage('ar');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text("🇺🇸", style: TextStyle(fontSize: 22)),
              title: const Text("English"),
              onTap: () {
                context.read<LocaleCubit>().changeLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
