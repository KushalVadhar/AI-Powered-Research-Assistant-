/// Centralized dimension constants.
class AppDimensions {
  AppDimensions._();

  // ── Base Unit ─────────────────────────────────────────────────
  static const double base = 4.0;

  // ── Spacing (used for padding, margin, gaps) ──────────────────
  static const double spacingXxs = 2.0; // base * 0.5
  static const double spacingXs = 4.0; // base * 1
  static const double spacingSm = 8.0; // base * 2
  static const double spacingMd = 12.0; // base * 3
  static const double spacingLg = 16.0; // base * 4
  static const double spacingXl = 20.0; // base * 5
  static const double spacingXxl = 24.0; // base * 6
  static const double spacing2Xl = 32.0; // base * 8
  static const double spacing3Xl = 40.0; // base * 10
  static const double spacing4Xl = 48.0; // base * 12
  static const double spacing5Xl = 64.0; // base * 16

  // ── Screen Padding ────────────────────────────────────────────
  /// Standard horizontal padding for screen content.
  static const double screenPaddingH = 20.0;

  /// Standard vertical padding for screen content.
  static const double screenPaddingV = 16.0;

  // ── Border Radius ─────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusFull = 999.0; // Pill shape

  // ── Icon Sizes ────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // ── Button Heights ────────────────────────────────────────────
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // ── Input Field ───────────────────────────────────────────────
  static const double inputHeight = 52.0;
  static const double inputBorderWidth = 1.5;

  // ── Card ──────────────────────────────────────────────────────
  static const double cardElevation = 0.0; // Flat design, use borders instead
  static const double cardRadius = 12.0;

  // ── App Bar ───────────────────────────────────────────────────
  static const double appBarHeight = 56.0;

  // ── Avatar ────────────────────────────────────────────────────
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;

  // ── Chat ──────────────────────────────────────────────────────
  static const double chatBubbleMaxWidth = 0.78; // 78% of screen width
  static const double chatInputMaxHeight = 120.0;
}
