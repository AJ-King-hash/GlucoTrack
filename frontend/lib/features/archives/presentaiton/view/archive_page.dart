import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

import '../manager/archives_cubit.dart';
import '../manager/archives_state.dart';
import '../widgets/archive_card.dart';
import 'archive_details_page.dart';

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return BlocProvider(
      create: (context) => sl<ArchiveCubit>()..fetchArchives(),
      child: BlocBuilder<ArchiveCubit, ArchiveState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(locale.translate('archives_page_title')),
            ),
            body: _buildBody(state, locale),
          );
        },
      ),
    );
  }

  Widget _buildBody(ArchiveState state, LocaleCubit locale) {
    switch (state.status) {
      case ArchiveStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ArchiveStatus.error:
        return Center(
          child: Text(
            state.errorMessage ?? locale.translate('archives_error_message'),
          ),
        );
      case ArchiveStatus.success:
        if (state.archives.isEmpty) {
          return Center(
            child: Text(locale.translate('archives_empty_message')),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.archives.length,
          itemBuilder: (context, index) {
            final archive = state.archives[index];
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
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
