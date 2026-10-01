import 'dart:io';

import 'package:path/path.dart' as p;

import '../api.dart';
import '../config.dart';
import '../errors.dart';
import '../project.dart';

class InitCommand {
  InitCommand(this.cfg);
  final CascadeConfig cfg;

  Future<void> run(List<String> args) async {
    if (cfg.token == null || cfg.token!.isEmpty) {
      throw CascadeCliException('Not logged in. Run: cascade login');
    }

    final cwd = Directory.current.path;
    final meta = readPubspecMeta(cwd);
    if (meta == null) {
      throw CascadeCliException(
        'No pubspec.yaml in this directory. Run cascade init inside your Flutter app root.',
      );
    }

    final forceNew = args.contains('--new');
    final pick = args.contains('--pick');
    String? nameOverride;
    final nameIdx = args.indexOf('--name');
    if (nameIdx >= 0 && nameIdx + 1 < args.length) {
      nameOverride = args[nameIdx + 1];
    }

    final api = CascadeApi(cfg);
    String? appId;
    String? projectKey;
    if (pick) {
      appId = await _pickApp(api);
    } else if (!forceNew) {
      projectKey = readExistingProjectKey(cwd);
      // Older cascade.project.yaml files had app_id; still honor for re-link.
      appId = projectKey == null ? readExistingProjectAppId(cwd) : null;
    }

    final name = (nameOverride ?? meta.name ?? 'flutter_app').trim();
    final androidPackage = readAndroidPackage(cwd);
    final iosBundleId = readIosBundleId(cwd);

    if (appId != null || projectKey != null) {
      stdout.writeln('\nRefreshing link for existing Cascade app…');
    } else {
      stdout.writeln('\nCreating Cascade app “$name” from this folder…');
      if (androidPackage != null) stdout.writeln('  Android: $androidPackage');
      if (iosBundleId != null) stdout.writeln('  iOS:     $iosBundleId');
    }

    final data = await api.postJson('/api/cli/apps/init', {
      if (appId != null)
        'appId': appId
      else if (projectKey != null)
        'projectKey': projectKey
      else ...{
        'name': name,
        if (androidPackage != null) 'androidPackage': androidPackage,
        if (iosBundleId != null) 'iosBundleId': iosBundleId,
      },
    });

    final projectFile = data['projectFile'] as Map<String, dynamic>;
    final workflowFile = data['workflowFile'] as Map<String, dynamic>;
    final projectPath = p.join(cwd, projectFile['path'] as String);
    final workflowPath = p.join(cwd, workflowFile['path'] as String);

    await Directory(p.dirname(workflowPath)).create(recursive: true);
    await File(projectPath).writeAsString(projectFile['contents'] as String);
    await File(workflowPath).writeAsString(workflowFile['contents'] as String);

    final secretsEnv = data['secretsEnvFile'] as Map<String, dynamic>?;
    final secretsEnvExample =
        data['secretsEnvExampleFile'] as Map<String, dynamic>?;
    final secretsGuide = data['secretsGuideFile'] as Map<String, dynamic>?;

    // Fillable secrets file: create once; never overwrite filled values.
    // Auto-fill Android signing (+ email hint) from the local project when present.
    var wroteSecretsEnv = false;
    final detected = detectLocalSecrets(cwd);
    if (secretsEnv != null) {
      final filled = fillSecretsEnv(
        secretsEnv['contents'] as String,
        detected.values,
      );
      wroteSecretsEnv = writeFileIfNeeded(
        p.join(cwd, secretsEnv['path'] as String),
        filled,
        overwrite: false,
      );
    }
    if (secretsEnvExample != null) {
      await File(p.join(cwd, secretsEnvExample['path'] as String))
          .writeAsString(secretsEnvExample['contents'] as String);
    }
    if (secretsGuide != null) {
      await File(p.join(cwd, secretsGuide['path'] as String))
          .writeAsString(secretsGuide['contents'] as String);
    }
    ensureSecretsEnvGitignored(cwd);

    final created = data['created'] == true;
    final linkedId = data['appId'];
    if (created) {
      stdout.writeln('\n✅ Created app in Cascade ($linkedId)');
    } else {
      stdout.writeln('\n✅ Linked existing app ($linkedId)');
    }
    stdout.writeln(
      '✅ Wrote ${projectFile['path']}  ← project key (required for CI)',
    );
    stdout.writeln(
      '✅ Wrote ${workflowFile['path']}  ← sealed workflow (do not edit)',
    );
    if (secretsEnv != null) {
      if (wroteSecretsEnv) {
        stdout.writeln(
          '✅ Wrote ${secretsEnv['path']}  ← fill this (gitignored)',
        );
        if (detected.values.isNotEmpty) {
          stdout.writeln(
            '   Auto-filled from project: ${detected.values.keys.join(', ')}',
          );
          for (final src in detected.sources) {
            stdout.writeln('     · $src');
          }
        } else {
          stdout.writeln(
            '   No local key.properties / .jks found — fill Android signing by hand if needed',
          );
        }
        stdout.writeln(
          '   Not everything is required — only secrets for lanes you enable',
        );
      } else {
        stdout.writeln(
          '⏭️  Left ${secretsEnv['path']} unchanged (already exists)',
        );
      }
    }
    if (secretsEnvExample != null) {
      stdout.writeln(
        '✅ Wrote ${secretsEnvExample['path']}  ← safe template to commit',
      );
    }
    if (secretsGuide != null) {
      stdout.writeln(
        '✅ Wrote ${secretsGuide['path']}  ← how to push secrets with gh',
      );
    }
    stdout.writeln('✅ Ensured cascade.secrets.env is in .gitignore');
    stdout.writeln('\nNext:');
    stdout.writeln(
      '  1) Check cascade.secrets.env — Android signing may already be filled',
    );
    stdout.writeln(
      '  2) Add only what your lanes need (Play / Apple are optional)',
    );
    stdout.writeln('  3) Push with gh (see cascade.secrets.md)');
    stdout.writeln('  4) Enable lanes in the Cascade dashboard');
    stdout.writeln(
      '  5) Commit cascade.project.yaml + .github/workflows/cascade.yml',
    );
    stdout.writeln('  6) cascade doctor');
    stdout.writeln('  7) Push a tagged commit, e.g. [test-android-internal] …');
  }

  Future<String> _pickApp(CascadeApi api) async {
    final data = await api.getJson('/api/cli/apps');
    final apps = (data['apps'] as List?) ?? const [];
    if (apps.isEmpty) {
      throw CascadeCliException(
        'No apps on your account yet. Run cascade init without --pick to auto-create one.',
      );
    }

    stdout.writeln('\nYour Cascade apps:');
    for (var i = 0; i < apps.length; i++) {
      final app = apps[i] as Map<String, dynamic>;
      stdout.writeln(
        '  [${i + 1}] ${app['name']}  (${app['id']})  [${app['keyStatus']}]',
      );
    }

    stdout.write('\nSelect app [1-${apps.length}]: ');
    final answer = stdin.readLineSync()?.trim() ?? '';
    final index = int.tryParse(answer);
    if (index == null || index < 1 || index > apps.length) {
      throw CascadeCliException('Invalid selection');
    }
    return (apps[index - 1] as Map<String, dynamic>)['id'] as String;
  }
}
