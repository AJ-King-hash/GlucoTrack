import 'package:flutter/material.dart';

import '../../data/model/archives_model.dart';
import '../widgets/archive_card.dart';
import 'archive_details_page.dart';

class ArchivesPage extends StatelessWidget {
  final List<ArchiveModel> archives;

  const ArchivesPage({super.key, required this.archives});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Analysis Records")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: archives.length,
        itemBuilder: (context, index) {
          final archive = archives[index];
          return ArchiveCard(
            archive: archive,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArchiveDetailsPage(archive: archive),
                ),
              );
            },
          );
        },
      ),
    );
  }
}