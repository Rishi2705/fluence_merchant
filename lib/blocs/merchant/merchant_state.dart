import 'package:equatable/equatable.dart';
import '../../models/merchant_model.dart';

/// Base class for all merchant states
abstract class MerchantState extends Equatable {
  const MerchantState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MerchantInitial extends MerchantState {
  const MerchantInitial();
}

/// Loading state
class MerchantLoading extends MerchantState {
  const MerchantLoading();
}

/// Application submitted successfully
class MerchantApplicationSubmitted extends MerchantState {
  final MerchantApplication application;

  const MerchantApplicationSubmitted({required this.application});

  @override
  List<Object?> get props => [application];
}

/// Profile loaded successfully
class MerchantProfileLoaded extends MerchantState {
  final MerchantProfile profile;

  const MerchantProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Applications list loaded
class MerchantApplicationsLoaded extends MerchantState {
  final List<MerchantApplication> applications;

  const MerchantApplicationsLoaded({required this.applications});

  @override
  List<Object?> get props => [applications];
}

/// Profile updated successfully
class MerchantProfileUpdated extends MerchantState {
  final MerchantProfile profile;

  const MerchantProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Error state
class MerchantError extends MerchantState {
  final String message;

  const MerchantError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile not found state (user needs to complete onboarding)
class MerchantProfileNotFound extends MerchantState {
  const MerchantProfileNotFound();

  @override
  List<Object?> get props => [];
}

/// Analytics loaded state
class MerchantAnalyticsLoaded extends MerchantState {
  final MerchantAnalytics analytics;

  const MerchantAnalyticsLoaded({required this.analytics});

  @override
  List<Object?> get props => [analytics];
}

/// Profile with analytics loaded state
class MerchantProfileWithAnalytics extends MerchantState {
  final MerchantProfile profile;
  final MerchantAnalytics analytics;

  const MerchantProfileWithAnalytics({
    required this.profile,
    required this.analytics,
  });

  @override
  List<Object?> get props => [profile, analytics];
}
