import 'package:equatable/equatable.dart';
import 'package:seamlesscall/features/operations/domain/job.dart';

class DispatchItem extends Equatable {
  final Job job;
  final int score;
  final String scoreReason;

  const DispatchItem({
    required this.job,
    required this.score,
    required this.scoreReason,
  });

  @override
  List<Object?> get props => [job, score, scoreReason];
}
