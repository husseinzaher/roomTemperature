import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:room_temperature_app/places/place_models.dart';
import 'package:room_temperature_app/places/places_details_page.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// Local places list. Coordinates never leave the device.
class PlacesPage extends StatelessWidget {
  /// Creates a places page.
  const PlacesPage({
    required this.places,
    required this.units,
    required this.loadVisits,
    required this.onDeletePlace,
    super.key,
  });

  /// Aggregated places, most recent first.
  final List<PlaceSummary> places;

  /// Display units.
  final Units units;

  /// Loads closed visits for a place.
  final Future<List<PlaceVisitSummary>> Function(int placeId) loadVisits;

  /// Deletes one place after confirmation on the details screen.
  final Future<void> Function(int placeId) onDeletePlace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
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
                Expanded(child: GlassPageHeader(title: l10n.places)),
              ],
            ),
            const SizedBox(height: 16),
            if (places.isEmpty)
              GlassCard(
                child: Text(
                  l10n.noPlacesYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GlassTokens.onGlassMuted,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              )
            else
              for (final place in places) ...[
                GlassCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => PlaceDetailsPage(
                          place: place,
                          units: units,
                          loadVisits: () => loadVisits(place.id),
                          onDelete: () => onDeletePlace(place.id),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(
                                color: GlassTokens.onGlass,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.placeVisitCount(place.visitCount),
                              style: const TextStyle(
                                color: GlassTokens.onGlassMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _placeAverageLabel(place, units),
                        style: const TextStyle(
                          color: GlassTokens.onGlass,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

String _placeAverageLabel(PlaceSummary place, Units units) {
  final celsius = place.averageIndoorCelsius;
  if (celsius == null) {
    return '—';
  }
  return '${units.fromCelsius(celsius).toStringAsFixed(1)}${units.symbol}';
}
