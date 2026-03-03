import 'package:equatable/equatable.dart';
import '../../data/model/archives_model.dart';


enum ArchiveStatus { initial, loading, success, error }

class ArchiveState extends Equatable {
  final ArchiveStatus status;
  final List<ArchiveModel> archives;
  final String? errorMessage;

  const ArchiveState({
    this.status = ArchiveStatus.initial,
    this.archives = const [],
    this.errorMessage,
  });

  ArchiveState copyWith({
    ArchiveStatus? status,
    List<ArchiveModel>? archives,
    String? errorMessage,
  }) {
    return ArchiveState(
      status: status ?? this.status,
      archives: archives ?? this.archives,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, archives, errorMessage];
}