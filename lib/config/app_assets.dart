/// Asset path constants.
class AppAssets {
  AppAssets._();

  // ── Base Paths ────────────────────────────────────────────────
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // ── Images ────────────────────────────────────────────────────
  // Add actual asset paths as you create them.
  // Example: static const String logo = '$_images/logo.png';
  // Example: static const String onboarding1 = '$_images/onboarding_1.png';

  // ── Icons ─────────────────────────────────────────────────────
  // For custom SVG icons not available in Material Icons.
  // Example: static const String documentIcon = '$_icons/document.svg';

  // ── Animations ────────────────────────────────────────────────
  // For Lottie or Rive animations.
  // Example: static const String loadingAnimation = '$_animations/loading.json';

  // ── Placeholder getter (prevents unused import warnings) ──────
  /// Returns the images base path. Used for development.
  static String get imagesPath => _images;
  static String get iconsPath => _icons;
  static String get animationsPath => _animations;
}
