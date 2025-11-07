import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/stats_bloc/stats_bloc.dart';
import '../bloc/stats_bloc/stats_event.dart';
import '../bloc/stats_bloc/stats_state.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    loadUserStats();
  }

  void loadUserStats() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<StatsBloc>().add(
        GetUserStatsEvent(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StatsLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  buildHeader(context),
                  buildEarningsCard(context, state),
                  buildReferralCard(context, state),
                  buildActionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else if (state is StatsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          Text(
            'Earn while sharing WiFi',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget buildEarningsCard(BuildContext context, StatsLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            state.totalEarnings.toStringAsFixed(2),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildEarningsMetric(
                'Available',
                state.availableBalance.toStringAsFixed(2),
                Colors.white,
              ),
              buildEarningsMetric(
                'Withdrawn',
                state.withdrawnAmount.toStringAsFixed(2),
                Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEarningsMetric(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildReferralCard(BuildContext context, StatsLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral Network',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildReferralMetric(
                'Total Referrals',
                state.totalReferrals.toString(),
              ),
              buildReferralMetric('Active', state.activeReferrals.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildReferralMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, 'withdraw'),
              child: const Text('Withdraw'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
              ),
              onPressed: () => Navigator.pushNamed(context, 'referral'),
              child: const Text('Refer'),
            ),
          ),
        ],
      ),
    );
  }
}
