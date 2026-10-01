import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class PubspecMeta {
  PubspecMeta({required this.name, required this.path});
  final String? name;
  final String path;
}

PubspecMeta? readPubspecMeta(String cwd) {
  final path = p.join(cwd, 'pubspec.yaml');
  final file = File(path);
  if (!file.existsSync()) return null;
  final text = file.readAsStringSync();
  final match = RegExp(r'''^\s*name:\s*["']?([A-Za-z0-9_]+)["']?\s*$''', multiLine: true)
      .firstMatch(text);
  return PubspecMeta(name: match?.group(1), path: path);
}

String? readAndroidPackage(String cwd) {
  final candidates = [
    p.join(cwd, 'android/app/build.gradle.kts'),
    p.join(cwd, 'android/app/build.gradle'),
  ];
  for (final filePath in candidates) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    final text = file.readAsStringSync();
    final match = RegExp(r'''applicationId\s*=\s*["']([^"']+)["']''').firstMatch(text) ??
        RegExp(r'''applicationId\s+["']([^"']+)["']''').firstMatch(text);
    if (match != null) return match.group(1);
  }
  return null;
}

String? readIosBundleId(String cwd) {
  final path = p.join(cwd, 'ios/Runner.xcodeproj/project.pbxproj');
  final file = File(path);
  if (!file.existsSync()) return null;
  final text = file.readAsStringSync();
  final match =
      RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;\s]+)\s*;').firstMatch(text);
  if (match == null) return null;
  final value = match.group(1)!.replaceAll('"', '');
  if (value.contains(r'$(') || value.contains(r'${')) return null;
  return value;
}

String? readExistingProjectKey(String cwd) {
  final path = p.join(cwd, 'cascade.project.yaml');
  final file = File(path);
  if (!file.existsSync()) return null;
  final body = file.readAsStringSync();
  final match = RegExp(r'^\s*project_key:\s*(\S+)\s*$', multiLine: true)
      .firstMatch(body);
  final key = match?.group(1)?.replaceAll('"', '');
  if (key == null || !key.startsWith('cas_proj_')) return null;
  // Placeholder / sample keys from package docs — treat as missing.
  if (key.contains('REPLACE') || key.endsWith('_ME')) return null;
  return key;
}

/// @Deprecated — use [readExistingProjectKey]. Kept for older project files.
String? readExistingProjectAppId(String cwd) {
  final path = p.join(cwd, 'cascade.project.yaml');
  final file = File(path);
  if (!file.existsSync()) return null;
  final body = file.readAsStringSync();
  return RegExp(r'^\s*app_id:\s*(\S+)\s*$', multiLine: true)
      .firstMatch(body)
      ?.group(1);
}

void openBrowser(String url) {
  if (Platform.isMacOS) {
    Process.run('open', [url]);
  } else if (Platform.isWindows) {
    Process.run('cmd', ['/c', 'start', '', url]);
  } else {
    Process.run('xdg-open', [url]);
  }
}

/// Ensure cascade.secrets.env is listed in .gitignore (never commit / publish).
void ensureSecretsEnvGitignored(String cwd) {
  final gi = File(p.join(cwd, '.gitignore'));
  const entry = 'cascade.secrets.env';
  if (!gi.existsSync()) {
    gi.writeAsStringSync(
      '# Cascade local secrets (never commit)\n$entry\n',
    );
    return;
  }
  final text = gi.readAsStringSync();
  if (RegExp(r'^cascade\.secrets\.env\s*$', multiLine: true).hasMatch(text)) {
    return;
  }
  final suffix = text.endsWith('\n') ? '' : '\n';
  gi.writeAsStringSync(
    '$text$suffix\n# Cascade local secrets (never commit)\n$entry\n',
  );
}

/// Write [path] from [contents]. If [overwrite] is false and file exists, skip.
bool writeFileIfNeeded(
  String path,
  String contents, {
  bool overwrite = true,
}) {
  final file = File(path);
  if (!overwrite && file.existsSync()) return false;
  file.writeAsStringSync(contents);
  return true;
}

bool _isPlaceholder(String? value) {
  if (value == null) return true;
  final v = value.trim();
  if (v.isEmpty) return true;
  final upper = v.toUpperCase();
  return upper.contains('YOUR_') ||
      upper.contains('REPLACE') ||
      upper == 'CHANGEME' ||
      upper == 'TODO';
}

Map<String, String> _parseProperties(String text) {
  final out = <String, String>{};
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    out[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
  }
  return out;
}

File? _resolveKeystoreFile(String cwd, String? storeFile, String propsDir) {
  final candidates = <String>[];
  if (storeFile != null && storeFile.isNotEmpty) {
    if (p.isAbsolute(storeFile)) {
      candidates.add(storeFile);
    } else {
      candidates.addAll([
        p.normalize(p.join(propsDir, storeFile)),
        p.normalize(p.join(cwd, 'android', storeFile)),
        p.normalize(p.join(cwd, 'android', 'app', storeFile)),
        p.normalize(p.join(cwd, storeFile)),
      ]);
    }
  }
  candidates.addAll([
    p.join(cwd, 'android', 'app', 'upload-keystore.jks'),
    p.join(cwd, 'android', 'upload-keystore.jks'),
    p.join(cwd, 'upload-keystore.jks'),
  ]);
  for (final path in candidates) {
    final f = File(path);
    if (f.existsSync()) return f;
  }
  return null;
}

/// Pull Android signing (and optional email hint) from the local Flutter project.
///
/// Reads `android/key.properties` (or nearby) + base64-encodes the `.jks`.
/// Only returns real values — placeholders like `YOUR_KEY_ALIAS` are skipped.
class DetectedSecrets {
  DetectedSecrets({required this.values, required this.sources});
  final Map<String, String> values;
  final List<String> sources;
}

DetectedSecrets detectLocalSecrets(String cwd) {
  final values = <String, String>{};
  final sources = <String>[];

  final propsCandidates = [
    p.join(cwd, 'android', 'key.properties'),
    p.join(cwd, 'android', 'app', 'key.properties'),
    p.join(cwd, 'key.properties'),
  ];

  Map<String, String> props = {};
  String? propsPath;
  for (final path in propsCandidates) {
    final file = File(path);
    if (!file.existsSync()) continue;
    props = _parseProperties(file.readAsStringSync());
    propsPath = path;
    break;
  }

  if (propsPath != null) {
    sources.add(propsPath);
    final alias = props['keyAlias'];
    final storePassword = props['storePassword'];
    final keyPassword = props['keyPassword'] ?? storePassword;
    if (!_isPlaceholder(alias)) values['KEYSTORE_ALIAS'] = alias!;
    if (!_isPlaceholder(storePassword)) {
      values['KEYSTORE_PASSWORD'] = storePassword!;
    }
    if (!_isPlaceholder(keyPassword)) values['KEY_PASSWORD'] = keyPassword!;
  }

  final keystore = _resolveKeystoreFile(
    cwd,
    props['storeFile'],
    propsPath != null ? p.dirname(propsPath) : p.join(cwd, 'android'),
  );
  if (keystore != null) {
    values['ANDROID_KEYSTORE'] = base64Encode(keystore.readAsBytesSync());
    sources.add(keystore.path);
  }

  // Soft hint only — user can change who gets build emails.
  try {
    final result = Process.runSync('git', ['config', 'user.email'], workingDirectory: cwd);
    if (result.exitCode == 0) {
      final email = (result.stdout as String).trim();
      if (email.contains('@') && !_isPlaceholder(email)) {
        values['CASCADE_NOTIFY_EMAILS'] = email;
        sources.add('git config user.email');
      }
    }
  } catch (_) {}

  return DetectedSecrets(values: values, sources: sources);
}

/// Fill empty `NAME=` lines in a secrets env file from [values].
String fillSecretsEnv(String template, Map<String, String> values) {
  var out = template;
  for (final entry in values.entries) {
    final name = entry.key;
    final value = entry.value;
    // Only fill blank assignments (do not clobber non-empty).
    out = out.replaceFirstMapped(
      RegExp('^${RegExp.escape(name)}=\\s*\$', multiLine: true),
      (_) => '$name=$value',
    );
  }
  return out;
}
