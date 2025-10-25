import 'package:get_it/get_it.dart';
import '../../services/api_service_new.dart';
import '../../services/auth_api_service.dart';
import '../../services/merchant_api_service.dart';
import '../../services/wallet_api_service.dart';
import '../../services/notification_api_service.dart';
import '../../repositories/auth_repository_impl.dart';
import '../../repositories/merchant_repository.dart';
import '../../repositories/wallet_repository.dart';
import '../../repositories/notification_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // API Services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<MerchantApiService>(
    () => MerchantApiService(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<WalletApiService>(
    () => WalletApiService(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(getIt<ApiService>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(getIt<AuthApiService>()),
  );
  getIt.registerLazySingleton<MerchantRepository>(
    () => MerchantRepository(getIt<MerchantApiService>()),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepository(getIt<WalletApiService>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<NotificationApiService>()),
  );

  // BLoCs and Cubits will be registered after they are created
  // See BACKEND_INTEGRATION_GUIDE.md for BLoC/Cubit implementations
}
