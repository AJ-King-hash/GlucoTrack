import 'package:flutter/material.dart';
import 'package:glucotrack/core/widgets/states/empty_state.dart'
    as core_empty_state;

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return core_empty_state.EmptyState(
      lottieAsset: 'assets/lottie/empty ghost.json',
    );
  }
}
