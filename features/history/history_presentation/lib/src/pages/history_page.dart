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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _HistoryBody(state: state, title: l10n.history),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.state, required this.title});

  final HistoryState state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.status == HistoryStatus.loading && state.items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          GlassPageHeader(title: title),
          const SizedBox(height: 80),
          const Center(
            child: CircularProgressIndicator(color: GlassTokens.onGlass),
          ),
        ],
      );
    }

    if (state.status == HistoryStatus.error && state.items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          GlassPageHeader(title: title),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 44,
                  color: GlassTokens.onGlassMuted,
                ),
                const SizedBox(height: 14),
                Text(
                  state.errorMessage ?? l10n.errorGeneric,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GlassTokens.onGlassMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          GlassPageHeader(title: title),
          const SizedBox(height: 16),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.noHistoryYet,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GlassTokens.onGlassMuted,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // The repository returns items most-recent-first; the chart reads
    // left-to-right chronologically, so it needs the reverse order.
    final chronological = state.items.reversed.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
          child: GlassPageHeader(title: title),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: GlassCard(
            blur: 0,
            child: _HistoryChart(items: chronological),
          ),
        ),
        if (state.status == HistoryStatus.error)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Text(
              state.errorMessage ?? l10n.errorGeneric,
              style: const TextStyle(color: Color(0xFFFFB4A9), fontSize: 13),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
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

  static const _roomColor = Color(0xFFF4FBFF);
  static const _outsideColor = Color(0xFF8EC8E8);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
        Text(
          l10n.dailyAverage.toUpperCase(),
          style: const TextStyle(
            color: GlassTokens.onGlass,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0x22FFFFFF),
                  strokeWidth: 1,
                ),
              ),
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
                      style: const TextStyle(
                        color: GlassTokens.onGlassMuted,
                        fontSize: 11,
                      ),
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
                          style: const TextStyle(
                            color: GlassTokens.onGlassMuted,
                            fontSize: 11,
                          ),
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
                  color: _roomColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0x22FFFFFF),
                  ),
                ),
                LineChartBarData(
                  spots: outsideSpots,
                  isCurved: true,
                  color: _outsideColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
            duration: Duration.zero,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _LegendEntry(color: _roomColor, label: l10n.roomTemperature),
            const SizedBox(width: 16),
            _LegendEntry(color: _outsideColor, label: l10n.outsideTemperature),
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
        Text(
          label,
          style: const TextStyle(
            color: GlassTokens.onGlassMuted,
            fontSize: 12.5,
          ),
        ),
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

    return GlassCard(
      blur: GlassTokens.blurSmall,
      radius: GlassTokens.radiusSmall,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.isoDateKey,
                  style: const TextStyle(
                    color: GlassTokens.onGlass,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.roomTemperature}: '
                  '${item.averageRoomTemperatureCelsius.toStringAsFixed(1)}°C'
                  '  •  '
                  '${l10n.outsideTemperature}: '
                  '${item.averageOutsideTemperatureCelsius.toStringAsFixed(1)}'
                  '°C',
                  style: const TextStyle(
                    color: GlassTokens.onGlassMuted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.sampleCount}',
            style: const TextStyle(
              color: GlassTokens.onGlassMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
