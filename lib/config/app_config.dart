import 'package:flutter/material.dart';

/// White-label application configuration.
/// Modify these values to rebrand the entire application.
class AppConfig {
  AppConfig._();

  // ── Branding ──
  static const String appName = 'Luxe';
  static const String appTagline = 'Premium Shopping Experience';
  static const String appVersion = '1.0.0';

  // ── Currency ──
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const String locale = 'en_IN';

  // ── Feature Flags ──
  static const bool enableWishlist = true;
  static const bool enableReviews = true;
  static const bool enableSearch = true;
  static const bool enableSocialAuth = false;

  // ── Layout ──
  static const int productsPerRow = 2;
  static const int productsPerPage = 20;
  static const double maxContentWidth = 1200;

  // ── Assets ──
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  /// Format price with currency symbol
  static String formatPrice(double price) {
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }
}
