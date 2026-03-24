```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/core/widgets/states/empty_state.dart';
import 'package:glucotrack/core/widgets/states/loading_state.dart';
import '../manager/measurement_cubit.md';
import '../manager/measurement_state.md';
import '../widgets/measurement_list.dart';

class MeasurementPage extends StatelessWidget {
  const MeasurementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<MeasurementCubit>()..load(),
      child: const MeasurementView(),
    );
  }
}

class MeasurementView extends StatefulWidget {
  const MeasurementView({super.key});

  @override
  State<MeasurementView> createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  late final GlobalRefresher _refresher;
  late final MeasurementCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MeasurementCubit>();
    _refresher = GetIt.I<GlobalRefresher>();
    _refresher.refreshStream.listen((_) {
      _cubit.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measurements')),
      body: RefreshIndicator(
        onRefresh: () => _cubit.refresh(),
        child: BlocConsumer<MeasurementCubit, MeasurementState>(
          listener: (context, state) {
            // Add any state change listeners here
          },
          builder: (context, state) {
            return state.when(
              initial: () => const LoadingState(),
              loading: () => const LoadingState(),
              loaded: (measurements, lastRefreshed) {
                return MeasurementList(measurements: measurements);
              },
              error: (message, error) {
                return ErrorState(
                  message: message,
                  onRetry: () => _cubit.load(),
                );
              },
              empty: () {
                return EmptyState(
                  title: 'No Measurements',
                  message: 'Add your first measurement to get started',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```
