# UI Pages Backend Integration Reference

## Quick Integration Examples

### 1. Onboarding Page - Submit Application

Update `lib/presentation/pages/onboarding_page.dart`:

```dart
// At the top, add BLoC import
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/merchant/merchant_cubit.dart';
import '../../models/merchant_model.dart';

// In the submit button onPressed:
onPressed: () {
  if (_formKey.currentState!.validate()) {
    // Get the cubit
    final merchantCubit = context.read<MerchantCubit>();
    
    // Submit application
    merchantCubit.submitApplication(
      businessName: _businessNameController.text,
      businessType: _businessTypeController.text,
      contactEmail: _emailController.text,
      contactPhone: _phoneController.text,
      businessAddress: BusinessAddress(
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        country: _countryController.text,
      ),
      businessDescription: _descriptionController.text,
      expectedMonthlyVolume: double.tryParse(_volumeController.text),
    );
  }
},

// Wrap the page with BlocListener to handle states
@override
Widget build(BuildContext context) {
  return BlocListener<MerchantCubit, MerchantState>(
    listener: (context, state) {
      if (state is MerchantApplicationSubmitted) {
        // Show success and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainContainerPage()),
        );
      } else if (state is MerchantError) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    },
    child: Scaffold(
      // ... existing UI
    ),
  );
}
```

### 2. Wallet Page - Display Real Data

Update `lib/presentation/pages/wallet_page.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/wallet/wallet_cubit.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    // Load wallet data when page initializes
    context.read<WalletCubit>().loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is WalletLoaded) {
              return _buildWalletContent(state);
            } else if (state is WalletError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Center(child: Text('No data'));
          },
        ),
      ),
    );
  }

  Widget _buildWalletContent(WalletLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBalanceCard(state.balance),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildCashbackBanner(),
            const SizedBox(height: 24),
            _buildTransactionsList(state.transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletBalance balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5A620), Color(0xFFFDB913)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.balance.toStringAsFixed(2)} ${balance.currency}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<WalletTransaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...transactions.map((tx) => _buildTransactionItem(tx)).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(WalletTransaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            tx.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
            color: tx.type == 'credit' ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? tx.type,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  tx.createdAt.toString().split('.')[0],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${tx.type == 'credit' ? '+' : '-'}${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tx.type == 'credit' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Profile Page - Display Real Data

Update `lib/presentation/pages/profile_page.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/merchant/merchant_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<MerchantCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<MerchantCubit, MerchantState>(
          builder: (context, state) {
            if (state is MerchantLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is MerchantProfileLoaded) {
              return _buildProfileContent(state.profile);
            } else if (state is MerchantError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Center(child: Text('No profile data'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(MerchantProfile profile) {
    return Column(
      children: [
        // White background header
        Container(
          width: double.infinity,
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: _buildHeader(),
        ),
        // Blue background content
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F9FC),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 100),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(profile),
                      const SizedBox(height: 24),
                      _buildStatsRow(profile),
                      const SizedBox(height: 24),
                      _buildContactInformation(profile),
                      const SizedBox(height: 24),
                      _buildAccountSection(),
                      const SizedBox(height: 24),
                      _buildSettingsSection(),
                      const SizedBox(height: 24),
                      _buildSignOutButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(MerchantProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5A620), Color(0xFFFDB913)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Profile image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(Icons.business, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.businessName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile.businessType,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    if (profile.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active ✓',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(MerchantProfile profile) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          '${profile.totalSales ?? 0}',
          'Total Sales',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          '${profile.rating?.toStringAsFixed(1) ?? 'N/A'}',
          'Rating ⭐',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('92', 'Score 💯')),
      ],
    );
  }

  Widget _buildContactInformation(MerchantProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            profile.contactEmail,
            const Color(0xFFE8F4FA),
            AppColors.info,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.phone_outlined,
            'Phone',
            profile.contactPhone,
            const Color(0xFFE8F9F0),
            AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.business_outlined,
            'Business',
            profile.businessType,
            const Color(0xFFFFF8E1),
            AppColors.fluenceGold,
          ),
        ],
      ),
    );
  }
}
```

### 4. Home Page - Display Real Stats

Update `lib/presentation/pages/home_page.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/wallet/wallet_cubit.dart';
import '../../cubits/notification/notification_cubit.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    // Load data
    context.read<WalletCubit>().loadWalletData();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // White header
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGreeting(),
                      BlocBuilder<NotificationCubit, NotificationState>(
                        builder: (context, state) {
                          final unreadCount = state is NotificationLoaded
                              ? state.unreadCount
                              : 0;
                          return _buildNotificationIcon(unreadCount);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Blue content area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F9FC),
                ),
                child: BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    if (state is WalletLoaded) {
                      return _buildContent(state);
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(WalletLoaded walletState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 100),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopPerformers(),
              const SizedBox(height: 24),
              _buildStatsRow(walletState),
              const SizedBox(height: 24),
              _buildActiveCampaign(),
              const SizedBox(height: 24),
              _buildLiveActivity(walletState.transactions),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. Login Page - Implement Authentication

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/auth/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    try {
      // Sign in with Firebase
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get ID token
      final idToken = await credential.user?.getIdToken();

      if (idToken != null) {
        // Trigger auth BLoC event
        context.read<AuthBloc>().add(AuthSignInWithFirebase(idToken));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.needsProfileCompletion) {
            // Navigate to profile completion
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CompleteProfilePage()),
            );
          } else {
            // Navigate to main app
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainContainerPage()),
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: _handleLogin,
                      child: Text('Login'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Testing the Integration

1. **Start your backend services** on the ports specified in api_constants.dart
2. **Update API URLs** if using remote servers instead of localhost
3. **Run the app** and test each flow:
   - Login with Firebase
   - Submit merchant application
   - View wallet balance and transactions
   - Check notifications
   - View and update profile

## Common Issues and Solutions

### Issue: Cannot connect to localhost
**Solution**: If testing on physical device, replace localhost with your computer's IP address (e.g., `http://192.168.1.100:4001`)

### Issue: CORS errors
**Solution**: Configure CORS in your backend services to allow requests from mobile apps

### Issue: Token not persisting
**Solution**: Ensure SharedPreferences is properly initialized in main.dart before app starts

### Issue: BLoC not updating UI
**Solution**: Make sure widgets are wrapped with BlocBuilder or BlocListener and emitting states correctly

Remember to handle loading states, error states, and empty states in your UI for better user experience!
