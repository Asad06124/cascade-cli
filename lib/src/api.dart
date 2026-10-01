import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'errors.dart';

class CascadeApi {
  CascadeApi(this.cfg);

  final CascadeConfig cfg;

  Future<Map<String, dynamic>> request(
    String method,
    String pathname, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${cfg.apiUrl}$pathname');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Cascade-Api-Url': cfg.apiUrl,
      if (cfg.token != null) 'Authorization': 'Bearer ${cfg.token}',
    };

    late http.Response res;
    switch (method.toUpperCase()) {
      case 'GET':
        res = await http.get(uri, headers: headers);
      case 'POST':
        res = await http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      default:
        throw CascadeCliException('Unsupported HTTP method: $method');
    }

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(res.body);
      data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      data = <String, dynamic>{};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw CascadeApiException(
        (data['error'] as String?) ?? 'HTTP ${res.statusCode}',
        code: data['code'] as String?,
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> getJson(String pathname) =>
      request('GET', pathname);

  Future<Map<String, dynamic>> postJson(
    String pathname, [
    Map<String, dynamic>? body,
  ]) =>
      request('POST', pathname, body: body);
}
