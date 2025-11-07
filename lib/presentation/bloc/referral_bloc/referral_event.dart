import 'package:equatable/equatable.dart';

abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object> get props => [];
}

class GetReferralTreeEvent extends ReferralEvent {
  final String userId;
  const GetReferralTreeEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetReferralCountEvent extends ReferralEvent {
  final String userId;
  final int level;
  const GetReferralCountEvent({required this.userId, required this.level});

  @override
  List<Object> get props => [userId, level];
}
