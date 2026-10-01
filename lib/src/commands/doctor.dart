import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../api.dart';
import '../config.dart';

class DoctorCommand {
  DoctorCommand(this.cfg);
  final CascadeConfig cfg;

  static const baselineSecrets = [
    'CASCADE_NOTIFY_EMAILS',
    'ANDROID_KEYSTORE',
    'KEYSTORE_PASSWORD',
    'KEY_PASSWORD',
    'KEYSTORE_ALIAS',
  ];

  Future<void> run() async {
    final cwd = Directory.current.path;
    final projectPath = p.join(cwd, 'cascade.project.yaml');
    final workflowPath = p.join(cwd, '.github/workflows/cascade.yml');

    stdout.writeln('Cascade doctor\n');

    if (cfg.token == null || cfg.token!.isEmpty) {
      stdout.writeln('⚠️  CLI login: missing (run cascade login)');
    } else {
      stdout.writeln('✅ CLI login: ${cfg.email ?? 'token present'}');
    }

    if (!File(p.join(cwd, 'pubspec.yaml')).existsSync()) {
      stdout.writeln('❌ pubspec.yaml: not found (wrong directory?)');
    } else {
      stdout.writeln('✅ pubspec.yaml: found');
    }

    String? projectKey;
    final projectFile = File(projectPath);
    if (!projectFile.existsSync()) {
      stdout.writeln(
        '❌ cascade.project.yaml: missing — run cascade login && cascade init',
      );
    } else {
      final body = projectFile.readAsStringSync();
      projectKey =
          RegExp(r'project_key:\s*(\S+)').firstMatch(body)?.group(1);
      projectKey = projectKey?.replaceAll('"', '');
      stdout.writeln('✅ cascade.project.yaml: found');
      if (projectKey == null || !projectKey.startsWith('cas_proj_')) {
        stdout.writeln('❌ project_key: invalid — re-run cascade init');
        projectKey = null;
      } else {
        stdout.writeln('✅ project_key: present');
      }
    }

    final workflowFile = File(workflowPath);
    if (!workflowFile.existsSync()) {
      stdout.writeln('❌ sealed workflow: missing — run cascade init');
    } else {
      final wf = workflowFile.readAsStringSync();
      if (!wf.contains('DO NOT EDIT')) {
        stdout.writeln(
          '⚠️  workflow: missing seal banner — restore with cascade init',
        );
      } else {
        stdout.writeln('✅ sealed workflow: present');
      }
    }

    await _checkSecrets(cwd, projectKey);

    stdout.writeln(
      '\nReminder: enable lanes in the Cascade dashboard. Email is sent by Cascade servers.',
    );
    stdout.writeln(
      'Secrets guide: cascade.secrets.md  (or ${cfg.apiUrl}/docs#secrets)',
    );
  }

  Future<void> _checkSecrets(String cwd, String? projectKey) async {
    stdout.writeln('\nSecrets (local file vs GitHub)');

    var required = List<String>.from(baselineSecrets);
    var source = 'baseline';

    if (cfg.token != null &&
        cfg.token!.isNotEmpty &&
        projectKey != null) {
      try {
        final api = CascadeApi(cfg);
        final data = await api.getJson(
          '/api/cli/apps/secrets-status?project_key=${Uri.encodeQueryComponent(projectKey)}',
        );
        final list = (data['requiredSecrets'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            required;
        if (list.isNotEmpty) required = list;
        source = (data['source'] as String?) ?? source;
      } catch (_) {
        stdout.writeln(
          '⚠️  Could not load lane requirements from Cascade — using baseline list',
        );
      }
    }

    stdout.writeln('   (required from: $source)');

    final local = _readLocalSecretsEnv(cwd);
    final localPath = p.join(cwd, 'cascade.secrets.env');
    if (!File(localPath).existsSync()) {
      stdout.writeln(
        '⚠️  cascade.secrets.env missing — run cascade init',
      );
    }

    final gh = await _listGhSecrets();
    if (gh == null) {
      stdout.writeln(
        '⚠️  gh CLI missing or not authenticated — checking local file only',
      );
      stdout.writeln(
        '   Install: https://cli.github.com/  then: gh auth login',
      );
    }

    var missingLocal = 0;
    var missingGh = 0;
    var pendingPush = 0;

    for (final name in required) {
      final inLocal = local.containsKey(name) && local[name]!.isNotEmpty;
      final inGh = gh != null && gh.contains(name);

      if (inGh) {
        stdout.writeln('✅ $name  (on GitHub)');
      } else if (inLocal) {
        stdout.writeln(
          '⚠️  $name  (filled in cascade.secrets.env — not pushed to GitHub yet)',
        );
        pendingPush++;
        missingGh++;
      } else {
        stdout.writeln('❌ $name  (empty locally and missing on GitHub)');
        missingLocal++;
        missingGh++;
      }
    }

    if (pendingPush > 0) {
      stdout.writeln(
        '\n   Push filled values with:  see cascade.secrets.md',
      );
      stdout.writeln(
        '   Example:  gh secret set CASCADE_NOTIFY_EMAILS --body "you@example.com"',
      );
    }
    if (missingLocal == 0 && missingGh == 0) {
      stdout.writeln('✅ All required secrets are on GitHub');
    } else if (missingLocal == 0 && pendingPush == missingGh) {
      stdout.writeln(
        '⚠️  All required values are filled locally — push them to GitHub with gh',
      );
    } else {
      stdout.writeln(
        '⚠️  $missingLocal empty locally, $missingGh not on GitHub — see cascade.secrets.md',
      );
    }
  }

  /// Non-empty NAME=value pairs from cascade.secrets.env.
  Map<String, String> _readLocalSecretsEnv(String cwd) {
    final file = File(p.join(cwd, 'cascade.secrets.env'));
    if (!file.existsSync()) return {};
    final out = <String, String>{};
    for (final raw in file.readAsStringSync().split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final eq = line.indexOf('=');
      if (eq <= 0) continue;
      final name = line.substring(0, eq).trim();
      var value = line.substring(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      if (name.isNotEmpty && value.isNotEmpty) out[name] = value;
    }
    return out;
  }

  /// Returns secret names from `gh secret list`, or null if gh unavailable.
  Future<Set<String>?> _listGhSecrets() async {
    try {
      final result = await Process.run(
        'gh',
        ['secret', 'list', '--json', 'name'],
        workingDirectory: Directory.current.path,
      );
      if (result.exitCode != 0) {
        final plain = await Process.run(
          'gh',
          ['secret', 'list'],
          workingDirectory: Directory.current.path,
        );
        if (plain.exitCode != 0) return null;
        final names = <String>{};
        for (final line in (plain.stdout as String).split('\n')) {
          final name = line.trim().split(RegExp(r'\s+')).first;
          if (name.isNotEmpty && name != 'NAME') names.add(name);
        }
        return names;
      }
      final decoded = jsonDecode(result.stdout as String);
      if (decoded is! List) return {};
      return {
        for (final row in decoded)
          if (row is Map && row['name'] is String) row['name'] as String,
      };
    } catch (_) {
      return null;
    }
  }
}
