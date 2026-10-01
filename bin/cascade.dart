#!/usr/bin/env dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:cascade_cli/cascade_cli.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage')
    ..addOption(
      'api',
      help: 'Cascade control-plane URL (overrides config / CASCADE_API_URL)',
    )
    ..addFlag(
      'new',
      negatable: false,
      help: 'Always create a new Cascade app (ignore local cascade.project.yaml)',
    )
    ..addFlag(
      'pick',
      negatable: false,
      help: 'Pick an existing dashboard app instead of auto-create',
    )
    ..addOption(
      'name',
      help: 'Override the app name (default: pubspec.yaml name)',
    );

  ArgResults root;
  try {
    root = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  if (root['help'] == true || root.rest.isEmpty) {
    _printUsage(parser);
    return;
  }

  final command = root.rest.first;
  final rest = root.rest.skip(1).toList();
  final cfg = await CascadeConfig.load(apiOverride: root['api'] as String?);

  // Rebuild init argv from parsed flags so position does not matter:
  // `cascade init --new` and `cascade --new init` both work.
  final initArgs = <String>[
    if (root['new'] == true) '--new',
    if (root['pick'] == true) '--pick',
    if (root['name'] != null) ...['--name', root['name'] as String],
    ...rest,
  ];

  try {
    switch (command) {
      case 'login':
        await LoginCommand(cfg).run();
      case 'init':
        await InitCommand(cfg).run(initArgs);
      case 'doctor':
        await DoctorCommand(cfg).run();
      default:
        stderr.writeln('Unknown command: $command\n');
        _printUsage(parser);
        exitCode = 64;
    }
  } on CascadeApiException catch (e) {
    stderr.writeln('\n❌ ${e.message}');
    if (e.code == 'CLI_AUTH') {
      stderr.writeln('   Run: cascade login');
    }
    exitCode = 1;
  } on CascadeCliException catch (e) {
    stderr.writeln('\n❌ ${e.message}');
    exitCode = 1;
  }
}

void _printUsage(ArgParser parser) {
  stdout.writeln('''
Cascade CLI

Commands:
  cascade login     Open browser to sign in (required before init)
  cascade init      Auto-create the app (from pubspec) + write project key + sealed workflow
  cascade doctor    Check local project wiring and GitHub secrets

${parser.usage}

Environment:
  CASCADE_API_URL   Control-plane URL (auto: local panel if up, else ${CascadeConfig.defaultApiUrl})
''');
}
