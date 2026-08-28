import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_temperature_app/places/place_models.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// Details for one locally stored place and its visits.
class PlaceDetailsPage extends StatelessWidget {
  /// Creates a place details page.
  const PlaceDetailsPage({
    required this.place,
    required this.units,
    required this.loadVisits,
    required this.onDelete,
    super.key,
  });

  /// Aggregated place stats.
  final PlaceSummary place;

  /// Display units.
  final Units units;

  /// Loads closed visits.
  final Future<List<PlaceVisitSummary>> Function() loadVisits;

  /// Deletes this place.
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FutureBuilder<List<PlaceVisitSummary>>(
          future: loadVisits(),
          builder: (context, snapshot) {
            final visits = snapshot.data ?? const <PlaceVisitSummary>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: GlassTokens.onGlass,
                      ),
                    ),
                    Expanded(child: GlassPageHeader(title: place.name)),
                  ],
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(
                        label: l10n.placeAverage,
                        value: _temp(place.averageIndoorCelsius),
                      ),
                      _Stat(
                        label: l10n.placeMin,
                        value: _temp(place.minIndoorCelsius),
                      ),
                      _Stat(
                        label: l10n.placeMax,
                        value: _temp(place.maxIndoorCelsius),
                      ),
                      _Stat(
                        label: l10n.placeVisits,
                        value: '${place.visitCount}',
                      ),
                      _Stat(
                        label: l10n.placeTotalTime,
                        value: formatPlaceDuration(place.totalDuration),
                      ),
                      _Stat(
                        label: l10n.placeLastVisit,
                        value: place.lastVisitAt == null
                            ? '—'
                            : DateFormat.yMMMd().add_jm().format(
                                place.lastVisitAt!,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final visit in visits) ...[
                  GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat.yMMMd().add_jm().format(visit.startedAt),
                            style: const TextStyle(
                              color: GlassTokens.onGlass,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          _temp(visit.averageIndoorCelsius),
                          style: const TextStyle(
                            color: GlassTokens.onGlass,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await onDelete();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(l10n.deletePlace),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _temp(double? celsius) {
    if (celsius == null) {
      return '—';
    }
    return '${units.fromCelsius(celsius).toStringAsFixed(1)}${units.symbol}';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: GlassTokens.onGlassMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: GlassTokens.onGlass, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Formats a dwell duration as `6h 42m`.
String formatPlaceDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours <= 0) {
    return '${minutes}m';
  }
  return '${hours}h ${minutes}m';
}
