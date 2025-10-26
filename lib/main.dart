import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'core/di/service_locator.dart';
import 'cubits/wallet/wallet_cubit.dart';
import 'cubits/dashboard/dashboard_cubit.dart';
import 'blocs/merchant/merchant_bloc.dart';
import 'presentation/pages/splash_page_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize dependency injection
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletCubit>(
          create: (context) => getIt<WalletCubit>(),
        ),
        BlocProvider<MerchantBloc>(
          create: (context) => getIt<MerchantBloc>(),
        ),
        BlocProvider<DashboardCubit>(
          create: (context) => getIt<DashboardCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Fluence Merchant',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
