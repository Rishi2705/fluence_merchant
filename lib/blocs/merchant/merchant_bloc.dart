import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/merchant_repository.dart';
import '../../utils/logger.dart';
import 'merchant_event.dart';
import 'merchant_state.dart';

/// BLoC that manages merchant-related state and operations
class MerchantBloc extends Bloc<MerchantEvent, MerchantState> {
  final MerchantRepository _merchantRepository;

  MerchantBloc(this._merchantRepository) : super(const MerchantInitial()) {
    on<SubmitMerchantApplication>(_onSubmitApplication);
    on<FetchMerchantProfile>(_onFetchProfile);
    on<UpdateMerchantProfile>(_onUpdateProfile);
    on<FetchMerchantApplications>(_onFetchApplications);
  }

  /// Handles merchant application submission
  Future<void> _onSubmitApplication(
    SubmitMerchantApplication event,
    Emitter<MerchantState> emit,
  ) async {
    AppLogger.auth('BLoC: Merchant application submission requested', data: {
      'businessName': event.businessName,
      'businessType': event.businessType,
      'contactEmail': event.contactEmail,
      'contactPhone': event.contactPhone,
    });
    emit(const MerchantLoading());

    try {
      final application = await _merchantRepository.submitApplication(
        businessName: event.businessName,
        businessType: event.businessType,
        contactEmail: event.contactEmail,
        contactPhone: event.contactPhone,
        businessAddress: event.businessAddress,
        businessDescription: event.businessDescription,
        expectedMonthlyVolume: event.expectedMonthlyVolume,
        bankingInfo: event.bankingInfo,
      );

      AppLogger.success('BLoC: Merchant application submission successful', data: {
        'applicationId': application.id,
        'businessName': application.businessName,
        'status': application.status,
      });
      emit(MerchantApplicationSubmitted(application: application));
    } catch (e, stackTrace) {
      AppLogger.error('BLoC: Merchant application submission failed', error: e, stackTrace: stackTrace);
      emit(MerchantError(message: e.toString()));
    }
  }

  /// Handles fetching merchant profile
  Future<void> _onFetchProfile(
    FetchMerchantProfile event,
    Emitter<MerchantState> emit,
  ) async {
    emit(const MerchantLoading());

    try {
      final profile = await _merchantRepository.getProfile();
      emit(MerchantProfileLoaded(profile: profile));
    } catch (e) {
      emit(MerchantError(message: e.toString()));
    }
  }

  /// Handles updating merchant profile
  Future<void> _onUpdateProfile(
    UpdateMerchantProfile event,
    Emitter<MerchantState> emit,
  ) async {
    emit(const MerchantLoading());

    try {
      final profile = await _merchantRepository.updateProfile(event.updates);
      emit(MerchantProfileUpdated(profile: profile));
    } catch (e) {
      emit(MerchantError(message: e.toString()));
    }
  }

  /// Handles fetching merchant applications
  Future<void> _onFetchApplications(
    FetchMerchantApplications event,
    Emitter<MerchantState> emit,
  ) async {
    emit(const MerchantLoading());

    try {
      final applications = await _merchantRepository.getApplications();
      emit(MerchantApplicationsLoaded(applications: applications));
    } catch (e) {
      emit(MerchantError(message: e.toString()));
    }
  }
}
