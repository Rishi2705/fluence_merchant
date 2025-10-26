import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/analytics_api_service.dart';
import '../../utils/logger.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AnalyticsApiService _analyticsApiService;

  DashboardCubit(this._analyticsApiService) : super(const DashboardInitial());

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    AppLogger.step(1, 'DashboardCubit: Loading dashboard data');
    emit(const DashboardLoading());

    try {
      // Add timeout to prevent infinite loading
      final data = await _analyticsApiService.getDashboardData().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          AppLogger.warning('DashboardCubit: Dashboard data fetch timed out, using fallback');
          throw Exception('Dashboard data fetch timed out');
        },
      );
      
      AppLogger.success('DashboardCubit: Dashboard data loaded successfully', data: {
        'todayTransactions': data.stats.todayTransactions,
        'totalRevenue': data.stats.totalRevenue,
        'availableBalance': data.balanceSummary.availableBalance,
        'recentActivitiesCount': data.recentActivities.length,
      });

      emit(DashboardLoaded(data: data));
    } catch (e, stackTrace) {
      AppLogger.error('DashboardCubit: Failed to load dashboard data, emitting error state', error: e, stackTrace: stackTrace);
      emit(DashboardError(message: 'Failed to load dashboard data: ${e.toString()}'));
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    AppLogger.step(1, 'DashboardCubit: Refreshing dashboard data');
    await loadDashboardData();
  }
}
