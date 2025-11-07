import 'package:flutter_bloc/flutter_bloc.dart';
import 'referral_event.dart';
import 'referral_state.dart';
import '../../../domain/usecases/get_referral_tree_usecase.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final GetReferralTreeUseCase getReferralTreeUseCase;

  ReferralBloc({required this.getReferralTreeUseCase})
    : super(const ReferralInitial()) {
    on<GetReferralTreeEvent>(_onGetReferralTree);
  }

  Future<void> _onGetReferralTree(
    GetReferralTreeEvent event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    try {
      final referrals = await getReferralTreeUseCase.call(event.userId);
      emit(ReferralTreeLoaded(referrals: referrals));
    } catch (e) {
      emit(ReferralError(message: e.toString()));
    }
  }
}
