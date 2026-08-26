import 'package:flutter/material.dart';

/// Design tokens for the app's glassmorphism surfaces.
///
/// Every translucent surface in the app derives its blur, tint, border, and
/// radius from here, so the whole UI reads as one material rather than a
/// collection of separately-tuned containers.
abstract final class GlassTokens {
  /// Backdrop blur sigma for a large primary surface (the inside/outside
  /// temperature cards).
  static const double blurLarge = 24;

  /// Backdrop blur sigma for a small secondary surface (stat tiles, the
  /// unit toggle, nav bar).
  static const double blurSmall = 18;

  /// Corner radius for a large primary surface.
  static const double radiusLarge = 28;

  /// Corner radius for a small secondary surface.
  static const double radiusSmall = 20;

  /// Corner radius for a pill — the unit toggle and nav highlight.
  static const double radiusPill = 999;

  /// Tint painted over the blurred backdrop for a primary surface.
  static const Color tint = Color(0x40202428);

  /// A slightly stronger tint, for surfaces that sit over busy imagery and
  /// need more separation (stat tiles inside an already-tinted card).
  static const Color tintStrong = Color(0x59171B1F);

  /// Tint for the selected segment of the unit toggle — near-opaque white,
  /// matching the reference design's bright active pill.
  static const Color tintSelected = Color(0xF2FFFFFF);

  /// Hairline border that catches the light along a glass edge.
  static const Color border = Color(0x2EFFFFFF);

  /// Primary text/icon color on glass.
  static const Color onGlass = Color(0xFFFFFFFF);

  /// Secondary text color on glass — labels, captions, units.
  static const Color onGlassMuted = Color(0xCCFFFFFF);

  /// Text color for the selected unit-toggle segment, which sits on a
  /// near-white surface rather than on glass.
  static const Color onSelected = Color(0xFF12181C);

  /// A soft drop shadow that lifts a glass surface off the background
  /// without reading as a Material elevation.
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
