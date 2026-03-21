import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glucotrack/features/archives/data/model/archives_model.dart';

class ArchivesTimelineItem extends StatelessWidget {
  final ArchiveModel archive;
  final VoidCallback onDelete;
  const ArchivesTimelineItem({
    super.key,
    required this.archive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(archive),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        padding: EdgeInsets.only(right: 20.w),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2.w, height: 80.h, color: Colors.grey.shade300),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Hero(
              tag: 'Archive_id',
              child: Material(
                child: ListTile(
                  title: Text('Type archive'),
                  subtitle: Text('archive value'),
                  trailing: Text('archive date'),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
