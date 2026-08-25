import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/cubit/temperature_cubit.dart';
import 'package:temperature_presentation/src/cubit/temperature_state.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template dashboard_page}
/// Shows the current estimated room temperature alongside the real outside
/// temperature, with pull-to-refresh.
///
/// Requires a [TemperatureCubit] to be provided above it in the widget
/// tree (see `TemperatureModule`).
/// {@endtemplate}
class DashboardPage extends StatelessWidget {
  /// {@macro dashboard_page}
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<TemperatureCubit>();
    if (cubit.state.reading == null) {
      unawaited(cubit.refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<TemperatureCubit>().state;
    final reading = state.reading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboard)),
      body: RefreshIndicator(
        onRefresh: context.read<TemperatureCubit>().refresh,
        child: _buildBody(context, state, reading),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TemperatureState state,
    Reading? reading,
  ) {
    final l10n = context.l10n;

    if (reading == null && state.status == TemperatureStatus.loading) {
      return const LoadingView();
    }

    if (reading == null && state.status == TemperatureStatus.error) {
      return ErrorRetryView(
        message: state.errorMessage ?? l10n.errorGeneric,
        onRetry: context.read<TemperatureCubit>().refresh,
      );
    }

    if (reading == null) {
      return const LoadingView();
    }

    return ListView(
      padding: const EdgeInsetsDirectional.all(20),
      children: [
        TemperatureReadingCard(
          label: l10n.roomTemperature,
          temperatureCelsius: reading.roomTemperatureCelsius,
          isEstimated: reading.isEstimated,
          icon: Icons.home_outlined,
          accentColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        TemperatureReadingCard(
          label: l10n.outsideTemperature,
          temperatureCelsius: reading.outsideTemperatureCelsius,
          icon: Icons.wb_sunny_outlined,
          accentColor: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${l10n.lastUpdated}: ${_formatTime(reading.timestamp)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (state.status == TemperatureStatus.error) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              state.errorMessage ?? l10n.errorGeneric,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
