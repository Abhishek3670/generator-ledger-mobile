
class ApiConfig {
  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const String primaryBaseUrl = 'http://192.168.29.71:8000';
  static const String fallbackBaseUrl = 'http://192.168.29.60:8001';

  /// The base URL for the API backend.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_configuredBaseUrl);
    }
    return primaryBaseUrl;
  }

  static String _normalizeBaseUrl(String baseUrl) {
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }
}
