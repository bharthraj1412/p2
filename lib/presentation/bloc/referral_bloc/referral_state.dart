import 'package:equatable/equatable.dart';
import '../../../domain/entities/referral_entity.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();

  @override
  List<Object> get props => [];
}

class ReferralInitial extends ReferralState {
  const ReferralInitial();
}

class ReferralLoading extends ReferralState {
  const ReferralLoading();
}

class ReferralTreeLoaded extends ReferralState {
  final List<ReferralEntity> referrals;
  const ReferralTreeLoaded({required this.referrals});

  @override
  List<Object> get props => [referrals];
}

class ReferralError extends ReferralState {
  final String message;
  const ReferralError({required this.message});

  @override
  List<Object> get props => [message];
}
