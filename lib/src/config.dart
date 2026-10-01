import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class CascadeConfig {
  /// Production control plane. Local panel is auto-detected when running.
  static const defaultApiUrl = 'https://cascade.dev';
  static const localApiUrl = 'http://127.0.0.1:43127';

  CascadeConfig({
    required this.apiUrl,
    this.token,
    this.email,
    this.expiresAt,
  });

  String apiUrl;
  String? token;
  String? email;
  String? expiresAt;

  static String get configDir {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return p.join(home, '.cascade');
  }

  static String get configPath => p.join(configDir, 'config.json');

  /// Resolve control-plane URL:
  /// `--api` / CASCADE_API_URL → saved config → localhost probe → production.
  static Future<CascadeConfig> load({String? apiOverride}) async {
    final envApi = Platform.environment['CASCADE_API_URL'];
    String? token;
    String? email;
    String? expiresAt;
    String? savedApi;

    final file = File(configPath);
    if (file.existsSync()) {
      final map = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      savedApi = (map['apiUrl'] as String?)?.trim();
      if (savedApi != null && savedApi.isEmpty) savedApi = null;
      token = map['token'] as String?;
      email = map['email'] as String?;
      expiresAt = map['expiresAt'] as String?;
    }

    final apiUrl = await resolveApiUrl(
      apiOverride: apiOverride,
      envApi: envApi,
      savedApi: savedApi,
    );

    return CascadeConfig(
      apiUrl: _stripTrailingSlash(apiUrl),
      token: token,
      email: email,
      expiresAt: expiresAt,
    );
  }

  static Future<String> resolveApiUrl({
    String? apiOverride,
    String? envApi,
    String? savedApi,
  }) async {
    if (apiOverride != null && apiOverride.trim().isNotEmpty) {
      return apiOverride.trim();
    }
    if (envApi != null && envApi.trim().isNotEmpty) {
      return envApi.trim();
    }
    if (savedApi != null && savedApi.trim().isNotEmpty) {
      return savedApi.trim();
    }
    if (await probeLocalApi()) {
      return localApiUrl;
    }
    return defaultApiUrl;
  }

  /// Quick probe — local panel up? Prefer it over production for login.
  static Future<bool> probeLocalApi() async {
    try {
      final client = http.Client();
      try {
        final res = await client
            .get(Uri.parse(localApiUrl))
            .timeout(const Duration(milliseconds: 400));
        return res.statusCode > 0 && res.statusCode < 600;
      } finally {
        client.close();
      }
    } catch (_) {
      return false;
    }
  }

  void save() {
    Directory(configDir).createSync(recursive: true);
    File(configPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({
            'apiUrl': apiUrl,
            if (token != null) 'token': token,
            if (email != null) 'email': email,
            if (expiresAt != null) 'expiresAt': expiresAt,
          })}\n',
    );
  }

  static String _stripTrailingSlash(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }
}
