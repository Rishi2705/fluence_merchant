# 🚀 Quick Setup Guide - Backend Integration

## Files Created ✅

### Core Services
- `lib/core/constants/api_constants.dart` - All API endpoints
- `lib/services/api_service_new.dart` - Multi-service API client
- `lib/core/di/service_locator.dart` - Dependency injection

### Models
- `lib/models/user_model.dart` - User & Auth models
- `lib/models/merchant_model.dart` - Merchant models
- `lib/models/wallet_model.dart` - Wallet & Transaction models
- `lib/models/notification_model.dart` - Notification models

### API Services
- `lib/services/auth_api_service.dart` - Auth API calls
- `lib/services/merchant_api_service.dart` - Merchant API calls
- `lib/services/wallet_api_service.dart` - Wallet API calls
- `lib/services/notification_api_service.dart` - Notification API calls

### Repositories
- `lib/repositories/auth_repository_impl.dart` - Auth repository
- `lib/repositories/merchant_repository.dart` - Merchant repository
- `lib/repositories/wallet_repository.dart` - Wallet repository
- `lib/repositories/notification_repository.dart` - Notification repository

### Documentation
- `BACKEND_INTEGRATION_GUIDE.md` - Complete BLoC/Cubit code
- `UI_INTEGRATION_EXAMPLES.md` - UI integration examples
- `BACKEND_INTEGRATION_README.md` - Full setup instructions

## What You Need to Do 📝

### 1. Create BLoC/Cubit Files (Copy from BACKEND_INTEGRATION_GUIDE.md)
```
lib/blocs/auth/auth_bloc.dart
lib/cubits/merchant/merchant_cubit.dart
lib/cubits/wallet/wallet_cubit.dart
lib/cubits/notification/notification_cubit.dart
```

### 2. Update service_locator.dart
Add BLoC registrations after creating the files above.

### 3. Configure Backend URLs
Edit `lib/core/constants/api_constants.dart`:
```dart
static const String authBaseUrl = 'YOUR_AUTH_URL';
static const String merchantBaseUrl = 'YOUR_MERCHANT_URL';
// etc...
```

### 4. Add Firebase
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and configure
firebase login
flutterfire configure
```

Add to pubspec.yaml:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
```

### 5. Update main.dart
See BACKEND_INTEGRATION_GUIDE.md for complete main.dart code.

### 6. Update UI Pages
Follow examples in UI_INTEGRATION_EXAMPLES.md for each page.

## Testing Steps 🧪

1. Start all backend services (ports 4001-4007)
2. Update API URLs in api_constants.dart
3. Run `flutter pub get`
4. Run `flutter run`
5. Test login flow
6. Test merchant application submission
7. Test wallet operations
8. Test profile viewing

## Architecture 🏗️

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│      (UI Pages + Widgets)           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      State Management Layer         │
│      (BLoCs + Cubits)               │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Repository Layer              │
│    (Business Logic)                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Service Layer               │
│      (API Services)                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Backend Services             │
│  Auth | Merchant | Wallet | etc.   │
└─────────────────────────────────────┘
```

## Key Features Implemented ⭐

✅ Token-based authentication with auto-refresh
✅ Multi-microservice architecture support
✅ Comprehensive error handling
✅ Type-safe data models
✅ Clean architecture with BLoC pattern
✅ Dependency injection with GetIt
✅ Persistent token storage
✅ API request/response logging

## Quick Commands 💻

```bash
# Get dependencies
flutter pub get

# Clean and rebuild
flutter clean && flutter pub get

# Run app
flutter run

# Run with verbose
flutter run -v

# Build release APK
flutter build apk --release

# Check for errors
flutter analyze
```

## Important URLs 🔗

Backend Services:
- Auth: http://localhost:4001
- Cashback: http://localhost:4002
- Merchant: http://localhost:4003
- Notification: http://localhost:4004
- Wallet: http://localhost:4005
- Referral: http://localhost:4006
- Social: http://localhost:4007

## Need Help? 🆘

1. Check `BACKEND_INTEGRATION_GUIDE.md` for complete code
2. Check `UI_INTEGRATION_EXAMPLES.md` for UI examples
3. Check `BACKEND_INTEGRATION_README.md` for detailed setup
4. Verify backend services are running
5. Check API URLs configuration
6. Review Flutter DevTools for BLoC states
7. Check console for error messages

## Common Issues & Fixes 🔧

**Can't connect to localhost**
→ Use computer IP address (e.g., 192.168.1.100:4001)

**Token not persisting**
→ Ensure SharedPreferences is initialized in main()

**BLoC not updating UI**
→ Wrap widgets with BlocBuilder/BlocListener

**Firebase errors**
→ Run `flutterfire configure` and add google-services.json

## Status: Ready for Implementation! ✨

All infrastructure code is complete. Just follow the steps above to:
1. Create the 4 BLoC/Cubit files
2. Update service locator
3. Configure backend URLs
4. Add Firebase
5. Update main.dart
6. Update UI pages

Then test and deploy! 🚀
