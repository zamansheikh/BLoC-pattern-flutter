import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routing/app_router.dart';
import '../bloc/counter_bloc.dart';
import '../widgets/counter_display.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the already provided CounterBloc and start it
    context.read<CounterBloc>().add(CounterStarted());
    return const HomeView();
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.spacingL),
            CounterDisplay(),
            SizedBox(height: AppConstants.spacingXL),
            _ActionButtons(),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilledButton.icon(
          onPressed: () {
            context.read<CounterBloc>().add(CounterIncremented());
          },
          icon: const Icon(Icons.add),
          label: const Text('Increment'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            // You can add decrement functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Decrement feature coming soon!')),
            );
          },
          icon: const Icon(Icons.remove),
          label: const Text('Decrement'),
        ),
      ],
    );
  }
}
