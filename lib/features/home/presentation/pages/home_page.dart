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
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingL),
            const CounterDisplay(),
            const SizedBox(height: UIConstants.spacingXL),
            const _ActionButtons(),
            const SizedBox(height: UIConstants.spacingL),
            const _NavigationButtons(),
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

class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: UIConstants.spacingM),
        const Text(
          'API Demo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UIConstants.spacingM),
        ElevatedButton.icon(
          onPressed: () {
            context.push(AppRoutes.apiDemo);
          },
          icon: const Icon(Icons.api),
          label: const Text('Test API Service'),
        ),
        const SizedBox(height: UIConstants.spacingS),
        const Text(
          'Comprehensive API testing with all HTTP methods,\nfile uploads, and form data',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
