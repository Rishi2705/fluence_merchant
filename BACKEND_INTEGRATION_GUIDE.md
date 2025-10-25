# Backend Integration Setup Guide

## ✅ Completed Tasks

### 1. API Service Configuration
- Created `api_constants.dart` with all microservice endpoints
- Created enhanced `api_service_new.dart` with multi-service support
- Implemented token management with SharedPreferences
- Added auth interceptors and error handling

### 2. Data Models
- `user_model.dart` - MerchantUser and AuthResponse
- `merchant_model.dart` - MerchantApplication, MerchantProfile, BusinessAddress, BankingInfo
- `wallet_model.dart` - WalletBalance, WalletTransaction, CashbackTransaction
- `notification_model.dart` - AppNotification, NotificationPreferences

### 3. API Services
- `auth_api_service.dart` - Firebase auth, profile completion, status updates
- `merchant_api_service.dart` - Application submission, profile management
- `wallet_api_service.dart` - Balance, transactions, transfers, withdrawals
- `notification_api_service.dart` - Notifications CRUD, preferences

### 4. Repositories
- `auth_repository_impl.dart` - Auth operations wrapper
- `merchant_repository.dart` - Merchant operations wrapper
- `wallet_repository.dart` - Wallet operations wrapper
- `notification_repository.dart` - Notification operations wrapper

### 5. Dependency Injection
- Created `service_locator.dart` with GetIt setup

## 📋 Remaining Tasks

### Create BLoCs/Cubits

You need to create the following state management files:

#### 1. Auth BLoC (`lib/blocs/auth/auth_bloc.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository_impl.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithFirebase extends AuthEvent {
  final String idToken;
  final String? referralCode;
  
  AuthSignInWithFirebase(this.idToken, {this.referralCode});
  
  @override
  List<Object?> get props => [idToken, referralCode];
}

class AuthCompleteProfile extends AuthEvent {
  final String name;
  final String phone;
  final String dateOfBirth;
  
  AuthCompleteProfile({
    required this.name,
    required this.phone,
    required this.dateOfBirth,
  });
  
  @override
  List<Object?> get props => [name, phone, dateOfBirth];
}

class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final MerchantUser user;
  final bool needsProfileCompletion;
  
  AuthAuthenticated(this.user, {this.needsProfileCompletion = false});
  
  @override
  List<Object?> get props => [user, needsProfileCompletion];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;
  
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithFirebase>(_onAuthSignInWithFirebase);
    on<AuthCompleteProfile>(_onAuthCompleteProfile);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }
  
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_authRepository.isAuthenticated) {
      // Load user data if authenticated
      emit(AuthAuthenticated(MerchantUser(
        id: 'temp',
        name: 'User',
        email: 'user@example.com',
        status: 'active',
        createdAt: DateTime.now(),
      )));
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  Future<void> _onAuthSignInWithFirebase(
    AuthSignInWithFirebase event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithFirebase(
        idToken: event.idToken,
        referralCode: event.referralCode,
      );
      emit(AuthAuthenticated(
        response.user,
        needsProfileCompletion: response.needsProfileCompletion,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onAuthCompleteProfile(
    AuthCompleteProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.completeProfile(
        name: event.name,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
```

#### 2. Merchant Cubit (`lib/cubits/merchant/merchant_cubit.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/merchant_model.dart';
import '../../repositories/merchant_repository.dart';

// States
abstract class MerchantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MerchantInitial extends MerchantState {}

class MerchantLoading extends MerchantState {}

class MerchantApplicationSubmitted extends MerchantState {
  final MerchantApplication application;
  
  MerchantApplicationSubmitted(this.application);
  
  @override
  List<Object?> get props => [application];
}

class MerchantProfileLoaded extends MerchantState {
  final MerchantProfile profile;
  
  MerchantProfileLoaded(this.profile);
  
  @override
  List<Object?> get props => [profile];
}

class MerchantApplicationsLoaded extends MerchantState {
  final List<MerchantApplication> applications;
  
  MerchantApplicationsLoaded(this.applications);
  
  @override
  List<Object?> get props => [applications];
}

class MerchantError extends MerchantState {
  final String message;
  
  MerchantError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class MerchantCubit extends Cubit<MerchantState> {
  final MerchantRepository _merchantRepository;
  
  MerchantCubit(this._merchantRepository) : super(MerchantInitial());
  
  Future<void> submitApplication({
    required String businessName,
    required String businessType,
    required String contactEmail,
    required String contactPhone,
    required BusinessAddress businessAddress,
    required String businessDescription,
    double? expectedMonthlyVolume,
    BankingInfo? bankingInfo,
  }) async {
    emit(MerchantLoading());
    try {
      final application = await _merchantRepository.submitApplication(
        businessName: businessName,
        businessType: businessType,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        businessAddress: businessAddress,
        businessDescription: businessDescription,
        expectedMonthlyVolume: expectedMonthlyVolume,
        bankingInfo: bankingInfo,
      );
      emit(MerchantApplicationSubmitted(application));
    } catch (e) {
      emit(MerchantError(e.toString()));
    }
  }
  
  Future<void> loadProfile() async {
    emit(MerchantLoading());
    try {
      final profile = await _merchantRepository.getProfile();
      emit(MerchantProfileLoaded(profile));
    } catch (e) {
      emit(MerchantError(e.toString()));
    }
  }
  
  Future<void> loadApplications() async {
    emit(MerchantLoading());
    try {
      final applications = await _merchantRepository.getApplications();
      emit(MerchantApplicationsLoaded(applications));
    } catch (e) {
      emit(MerchantError(e.toString()));
    }
  }
  
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    emit(MerchantLoading());
    try {
      final profile = await _merchantRepository.updateProfile(updates);
      emit(MerchantProfileLoaded(profile));
    } catch (e) {
      emit(MerchantError(e.toString()));
    }
  }
}
```

#### 3. Wallet Cubit (`lib/cubits/wallet/wallet_cubit.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/wallet_model.dart';
import '../../repositories/wallet_repository.dart';

// States
abstract class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final List<CashbackTransaction> cashbackTransactions;
  
  WalletLoaded({
    required this.balance,
    required this.transactions,
    required this.cashbackTransactions,
  });
  
  @override
  List<Object?> get props => [balance, transactions, cashbackTransactions];
}

class WalletTransactionSuccess extends WalletState {
  final WalletTransaction transaction;
  
  WalletTransactionSuccess(this.transaction);
  
  @override
  List<Object?> get props => [transaction];
}

class WalletError extends WalletState {
  final String message;
  
  WalletError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _walletRepository;
  
  WalletCubit(this._walletRepository) : super(WalletInitial());
  
  Future<void> loadWalletData() async {
    emit(WalletLoading());
    try {
      final balance = await _walletRepository.getBalance();
      final transactions = await _walletRepository.getTransactions();
      final cashbackTransactions = await _walletRepository.getCashbackTransactions();
      
      emit(WalletLoaded(
        balance: balance,
        transactions: transactions,
        cashbackTransactions: cashbackTransactions,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
  
  Future<void> transfer({
    required String recipientId,
    required double amount,
    String? description,
  }) async {
    emit(WalletLoading());
    try {
      final transaction = await _walletRepository.transfer(
        recipientId: recipientId,
        amount: amount,
        description: description,
      );
      emit(WalletTransactionSuccess(transaction));
      // Reload wallet data
      await loadWalletData();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
  
  Future<void> withdraw({
    required double amount,
    required String bankAccountId,
    String? description,
  }) async {
    emit(WalletLoading());
    try {
      final transaction = await _walletRepository.withdraw(
        amount: amount,
        bankAccountId: bankAccountId,
        description: description,
      );
      emit(WalletTransactionSuccess(transaction));
      // Reload wallet data
      await loadWalletData();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
```

#### 4. Notification Cubit (`lib/cubits/notification/notification_cubit.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';

// States
abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  
  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });
  
  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  
  NotificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationRepository;
  
  NotificationCubit(this._notificationRepository) : super(NotificationInitial());
  
  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationRepository.getNotifications();
      final unreadCount = await _notificationRepository.getUnreadCount();
      
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRepository.deleteNotification(notificationId);
      await loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
```

## 🔧 Integration Steps

### 1. Update main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'blocs/auth/auth_bloc.dart';
import 'cubits/merchant/merchant_cubit.dart';
import 'cubits/wallet/wallet_cubit.dart';
import 'cubits/notification/notification_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => getIt<MerchantCubit>()),
        BlocProvider(create: (_) => getIt<WalletCubit>()),
        BlocProvider(create: (_) => getIt<NotificationCubit>()),
      ],
      child: MaterialApp(
        title: 'Fluence Merchant',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainContainerPage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
```

### 2. Update API Constants with your backend URLs
Edit `lib/core/constants/api_constants.dart` and replace localhost URLs with your actual backend URLs.

### 3. Update Onboarding Page to connect with API
The onboarding page should call `MerchantCubit.submitApplication()` when the form is submitted.

### 4. Update Wallet Page to display real data
Use `WalletCubit` to load and display balance and transactions.

### 5. Update Profile Page to display real data
Use `MerchantCubit.loadProfile()` to load merchant profile data.

### 6. Add Firebase Authentication
You'll need to integrate Firebase for authentication and get the idToken to pass to the auth API.

## 📦 Required Dependencies (add to pubspec.yaml)
```yaml
dependencies:
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7
  dio: ^5.9.0
  shared_preferences: ^2.5.3
  get_it: ^7.7.0
  firebase_core: latest
  firebase_auth: latest
```

## 🚀 Next Steps
1. Create the BLoC/Cubit files as shown above
2. Update main.dart with BLoC providers
3. Configure backend URLs in api_constants.dart
4. Integrate Firebase Authentication
5. Update UI pages to use BLoCs/Cubits
6. Test all functionality

This architecture follows clean code principles and BLoC pattern for scalable and maintainable code.
