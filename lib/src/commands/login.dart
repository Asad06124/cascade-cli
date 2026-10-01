import 'dart:convert';
import 'dart:io';

import '../api.dart';
import '../config.dart';
import '../errors.dart';
import '../project.dart';

class LoginCommand {
  LoginCommand(this.cfg);
  final CascadeConfig cfg;

  Future<void> run() async {
    final api = CascadeApi(cfg);
    final email = Platform.environment['CASCADE_EMAIL'];
    final password = Platform.environment['CASCADE_PASSWORD'];

    // Automation escape hatch only — never document as the normal path.
    if (email != null &&
        email.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      final data = await api.postJson('/api/cli/login', {
        'email': email,
        'password': password,
      });
      final user = data['user'] as Map<String, dynamic>? ?? {};
      cfg
        ..token = data['token'] as String?
        ..email = user['email'] as String?
        ..expiresAt = data['expiresAt'] as String?;
      cfg.save();
      stdout.writeln('\n✅ Logged in as ${cfg.email} (env credentials)');
      stdout.writeln('   Next: cascade init');
      return;
    }

    stdout.writeln('\nOpening browser to finish Cascade login…\n');
    final start = await api.postJson('/api/cli/device/start', {
      'apiUrl': cfg.apiUrl,
    });

    final userCode = start['userCode'] as String? ?? '';
    final verificationUriComplete =
        start['verificationUriComplete'] as String? ?? '';
    final deviceCode = start['deviceCode'] as String? ?? '';
    final expiresIn = (start['expiresIn'] as num?)?.toInt() ?? 900;
    final intervalSec = (start['interval'] as num?)?.toInt() ?? 2;

    stdout.writeln('  Code:  $userCode');
    stdout.writeln('  URL:   $verificationUriComplete\n');
    if (verificationUriComplete.isNotEmpty) {
      openBrowser(verificationUriComplete);
    }

    final deadline = DateTime.now().add(Duration(seconds: expiresIn));
    final interval = Duration(seconds: intervalSec < 2 ? 2 : intervalSec);
    final client = HttpClient();

    try {
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(interval);
        final uri = Uri.parse(
          '${cfg.apiUrl}/api/cli/device/poll?device_code=${Uri.encodeQueryComponent(deviceCode)}',
        );
        final req = await client.getUrl(uri);
        final res = await req.close();
        final body = await res.transform(utf8.decoder).join();
        final poll = jsonDecode(body) as Map<String, dynamic>;

        final status = poll['status'] as String?;
        if (status == 'pending') {
          stdout.write('.');
          continue;
        }
        if (status == 'approved' && poll['token'] != null) {
          stdout.writeln();
          final user = poll['user'] as Map<String, dynamic>? ?? {};
          cfg
            ..token = poll['token'] as String?
            ..email = user['email'] as String?
            ..expiresAt = poll['expiresAt'] as String?;
          cfg.save();
          stdout.writeln(
            '\n✅ Logged in as ${cfg.email ?? 'your account'}',
          );
          stdout.writeln('   Credentials stored in ${CascadeConfig.configPath}');
          stdout.writeln('   Next: cascade init');
          return;
        }
        if (status == 'expired') {
          throw CascadeCliException('Login expired. Run cascade login again.');
        }
      }
    } finally {
      client.close(force: true);
    }

    throw CascadeCliException('Timed out waiting for browser authorization.');
  }
}
