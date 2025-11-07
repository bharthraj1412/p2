import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();
  @override
  List<Object> get props => [];
}

class GetUserStatsEvent extends StatsEvent {
  final String userId;
  const GetUserStatsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetEarningsHistoryEvent extends StatsEvent {
  final String userId;
  final int days;
  const GetEarningsHistoryEvent({required this.userId, required this.days});

  @override
  List<Object> get props => [userId, days];
}
