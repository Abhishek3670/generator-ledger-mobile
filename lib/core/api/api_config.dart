import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// The base URL for the FastAPI backend.
  ///
  /// For Android emulators, '10.0.2.2' is the magic address to access the host machine's localhost.
  /// For iOS and other platforms, 'localhost' works if the server is on the same machine.
  ///
  /// In a production environment, this would be replaced with the actual server URL.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }
}
