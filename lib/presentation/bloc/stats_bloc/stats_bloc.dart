import 'package:flutter_bloc/flutter_bloc.dart';
import 'stats_event.dart';
import 'stats_state.dart';
import '../../../data/datasources/firebase_datasource.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final FirebaseDataSource firebaseDataSource;

  StatsBloc({required this.firebaseDataSource}) : super(const StatsInitial()) {
    on<GetUserStatsEvent>(_onGetUserStats);
    on<GetEarningsHistoryEvent>(_onGetEarningsHistory);
  }

  Future<void> _onGetUserStats(
    GetUserStatsEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoading());
    try {
      final user = await firebaseDataSource.getUserById(event.userId);
      final referralTree = await firebaseDataSource.getReferralTree(
        event.userId,
      );
      emit(
        StatsLoaded(
          totalEarnings: user.totalEarnings,
          availableBalance: user.availableBalance,
          withdrawnAmount: user.withdrawnAmount,
          totalReferrals: referralTree.length,
          activeReferrals: referralTree.length,
        ),
      );
    } catch (e) {
      emit(StatsError(message: e.toString()));
    }
  }

  Future<void> _onGetEarningsHistory(
    GetEarningsHistoryEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoading());
    try {
      // TODO: Implement earnings history fetching
      emit(
        const StatsLoaded(
          totalEarnings: 0,
          availableBalance: 0,
          withdrawnAmount: 0,
          totalReferrals: 0,
          activeReferrals: 0,
        ),
      );
    } catch (e) {
      emit(StatsError(message: e.toString()));
    }
  }
}
