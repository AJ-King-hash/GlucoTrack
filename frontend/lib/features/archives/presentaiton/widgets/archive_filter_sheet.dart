import 'package:flutter/material.dart';

void showArchiveFilter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تصفية حسب', style: TextStyle(fontSize: 18)),
            ListTile(
              title: const Text('قياسات السكر'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('الأدوية'),
              onTap: () {},
            ),
          ],
        ),
      );
    },
  );
}
