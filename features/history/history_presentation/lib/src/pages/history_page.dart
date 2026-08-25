import 'package:app_localization/app_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/src/cubit/history_cubit.dart';
import 'package:history_presentation/src/cubit/history_state.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template history_page}
/// Shows a line chart of room vs. outside daily average temperatures over
/// time, followed by a scrollable list of per-day averages.
///
/// Requires a [HistoryCubit] to be provided above it in the widget tree
/// (see `HistoryModule`).
/// {@endtemplate}
class HistoryPage extends StatelessWidget {
  /// {@macro history_page}
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<HistoryCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.history)),
      body: _HistoryBody(state: state),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.status == HistoryStatus.loading && state.items.isEmpty) {
      return const LoadingView();
    }

    if (state.status == HistoryStatus.error && state.items.isEmpty) {
      return ErrorRetryView(
        message: state.errorMessage ?? l10n.errorGeneric,
        retryLabel: l10n.retry,
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Text(
          l10n.noHistoryYet,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // The repository returns items most-recent-first; the chart reads
    // left-to-right chronologically, so it needs the reverse order.
    final chronological = state.items.reversed.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: _HistoryChart(items: chronological),
        ),
        if (state.status == HistoryStatus.error)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              state.errorMessage ?? l10n.errorGeneric,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _HistoryListTile(item: state.items[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.items});

  final List<DailyAverage> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final roomColor = colorScheme.primary;
    final outsideColor = colorScheme.secondary;

    final roomSpots = <FlSpot>[
      for (var i = 0; i < items.length; i++)
        FlSpot(i.toDouble(), items[i].averageRoomTemperatureCelsius),
    ];
    final outsideSpots = <FlSpot>[
      for (var i = 0; i < items.length; i++)
        FlSpot(i.toDouble(), items[i].averageOutsideTemperatureCelsius),
    ];
    final bottomInterval = items.length <= 1
        ? 1.0
        : (items.length / 4).ceil().toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dailyAverage, style: textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toStringAsFixed(0)}°',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: bottomInterval,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= items.length) {
                        return const SizedBox.shrink();
                      }
                      final day = items[index].day;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${day.month}/${day.day}',
                          style: textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: roomSpots,
                  isCurved: true,
                  color: roomColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: outsideSpots,
                  isCurved: true,
                  color: outsideColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LegendEntry(color: roomColor, label: l10n.roomTemperature),
            const SizedBox(width: 16),
            _LegendEntry(color: outsideColor, label: l10n.outsideTemperature),
          ],
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({required this.item});

  final DailyAverage item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(item.isoDateKey),
      subtitle: Text(
        '${l10n.roomTemperature}: '
        '${item.averageRoomTemperatureCelsius.toStringAsFixed(1)}°C  •  '
        '${l10n.outsideTemperature}: '
        '${item.averageOutsideTemperatureCelsius.toStringAsFixed(1)}°C',
      ),
      trailing: Text(
        '${item.sampleCount}',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
