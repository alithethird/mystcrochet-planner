class AppConfig {
  /// Standard resolution for regular users (512x512)
  static const int standardPhotoResolution = 512;

  /// High resolution tier for premium accounts (1024x1024)
  static const int premiumPhotoResolution = 1024;

  /// Ultra-high resolution tier (2048x2048)
  static const int ultraPhotoResolution = 2048;

  /// Whether current user session has premium tier enabled
  static bool isPremiumUser = false;

  /// Active target resolution for granny square photo export/compression
  static int get targetPhotoResolution {
    return isPremiumUser ? premiumPhotoResolution : standardPhotoResolution;
  }

  /// Custom override if desired
  static int? _customPhotoResolution;

  static int get activePhotoResolution =>
      _customPhotoResolution ?? targetPhotoResolution;

  static void setCustomResolution(int? resolution) {
    _customPhotoResolution = resolution;
  }
}
