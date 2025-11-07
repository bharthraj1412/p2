import 'package:equatable/equatable.dart';

abstract class StatsState extends Equatable {
  const StatsState();
  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  final double totalEarnings;
  final double availableBalance;
  final double withdrawnAmount;
  final int totalReferrals;
  final int activeReferrals;
  const StatsLoaded({
    required this.totalEarnings,
    required this.availableBalance,
    required this.withdrawnAmount,
    required this.totalReferrals,
    required this.activeReferrals,
  });

  @override
  List<Object> get props => [
    totalEarnings,
    availableBalance,
    withdrawnAmount,
    totalReferrals,
    activeReferrals,
  ];
}

class StatsError extends StatsState {
  final String message;
  const StatsError({required this.message});
  @override
  List<Object> get props => [message];
}
