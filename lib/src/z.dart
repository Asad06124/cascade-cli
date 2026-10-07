import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as h;
import 'package:path/path.dart' as q;

part '_v.dart';

const cliVersion = '0.1.18';
const supportedWorkflowVersion = '2.2.0';
String workflowChecksum(String contents) {
  final normalized = contents
      .replaceAll('\r\n', '\n')
      .replaceFirst(RegExp(r'_Σ:\s*".*"'), '_Σ: "__SEAL__"')
      .trim();
  return sha256.convert(utf8.encode('$normalized\n')).toString();
}

String $(int i) => _V
    ._(i)
    .replaceAll('✅', 'OK')
    .replaceAll('⚠️', 'WARN')
    .replaceAll('❌', 'ERROR')
    .replaceAll('→', '->')
    .replaceAll('←', '<-')
    .replaceAll('…', '...');

class Z {
  static Future<void> go(List<String> a0) async {
    final a1 = ArgParser()
      ..addFlag($(76), abbr: $(229), negatable: false)
      ..addOption($(77))
      ..addFlag($(78), negatable: false)
      ..addFlag($(79), negatable: false)
      ..addOption($(28))
      ..addFlag("version", negatable: false)
      ..addFlag("ios", negatable: false)
      ..addOption("file")
      ..addOption("app")
      ..addOption("to");
    late ArgResults a2;
    try {
      a2 = a1.parse(a0);
    } on FormatException catch (a3) {
      stderr.writeln(a3.message);
      _u(a1);
      exitCode = 64;
      return;
    }
    if (a2['version'] == true ||
        (a2.rest.isNotEmpty && a2.rest.first == 'version')) {
      stdout
          .writeln('cascade $cliVersion (workflow $supportedWorkflowVersion)');
      return;
    }
    if (a2[$(76)] == true || a2.rest.isEmpty) {
      _u(a1);
      return;
    }
    final a4 = a2.rest.first;
    final a5 = a2.rest.skip(1).toList();
    late _A a6;
    final a7 = <String>[
      if (a2[$(78)] == true) $(73),
      if (a2[$(79)] == true) $(74),
      if (a2[$(28)] != null) ...[$(75), a2[$(28)] as String],
      ...a5,
    ];
    try {
      a6 = await _A.x(y: a2[$(77)] as String?);
      if (a4 == $(70)) {
        await _B(a6).x();
      } else if (a4 == $(230)) {
        _H.x();
      } else if (a4 == $(234) || a4 == $(235) || a4 == $(253)) {
        await _I.x([...a5, if (a2["ios"] == true) "--ios"], a6);
      } else if (a4 == "send") {
        await _sendLocalApk(a6, a2);
      } else if (a4 == $(71)) {
        await _C(a6).x(a7);
      } else if (a4 == $(72)) {
        await _D(a6).x();
      } else {
        stderr.writeln('${$(116)}$a4\n');
        _u(a1);
        exitCode = 64;
      }
    } on _E catch (a8) {
      stderr.writeln('${$(216)}${a8.a}');
      if (a8.b == $(82)) stderr.writeln($(217));
      exitCode = 1;
    } on _F catch (a9) {
      stderr.writeln('${$(216)}${a9.a}');
      exitCode = 1;
    } on TimeoutException {
      stderr.writeln(
          'ERROR Server timed out. Check your connection and --api endpoint, then retry.');
      exitCode = 1;
    } on SocketException {
      stderr.writeln(
          'ERROR Server unavailable. Check your connection and --api endpoint, then retry.');
      exitCode = 1;
    } on h.ClientException {
      stderr.writeln(
          'ERROR Server unavailable. Check your connection and --api endpoint, then retry.');
      exitCode = 1;
    } catch (_) {
      stderr.writeln(
          'ERROR Operation failed. Check login, project setup and server compatibility; run cascade doctor.');
      exitCode = 1;
    }
  }

  static void _u(ArgParser a0) {
    stdout.writeln(
        "cascade match: configure release credentials and available automatic status access; --ios explicitly provisions Apple signing.\ncascade send --app APP_ID --file app-release.apk --to you@example.com: email a local APK link.");
    stdout.writeln(
        'cascade --version: show package and supported workflow versions.');
    stdout.write($(115));
    stdout.writeln(a0.usage);
    stdout.write($(200));
  }
}

class _F implements Exception {
  _F(this.a);
  final String a;
  @override
  String toString() => a;
}

class _E implements Exception {
  _E(this.a, {this.b});
  final String a;
  final String? b;
  @override
  String toString() => a;
}

class _A {
  _A({required this.a, this.b, this.c, this.d});
  String a;
  String? b;
  String? c;
  String? d;

  static String get e {
    final a0 = Platform.environment[$(3)] ?? Platform.environment[$(4)] ?? '.';
    return q.join(a0, $(7));
  }

  static String get f => q.join(e, $(8));

  static Future<_A> x({String? y}) async {
    String? a0, a1, a2, a3;
    final a4 = File(f);
    if (a4.existsSync()) {
      final a5 = jsonDecode(a4.readAsStringSync()) as Map<String, dynamic>;
      a3 = (a5[$(9)] as String?)?.trim();
      if (a3 != null && a3.isEmpty) a3 = null;
      a0 = a5[$(10)] as String?;
      a1 = a5[$(11)] as String?;
      a2 = a5[$(12)] as String?;
    }
    final a6 = await _r(y: y, z: Platform.environment[$(2)], w: a3);
    return _A(a: _s(a6), b: a0, c: a1, d: a2);
  }

  static Future<String> _r({String? y, String? z, String? w}) async {
    if (y != null && y.trim().isNotEmpty) return y.trim();
    if (z != null && z.trim().isNotEmpty) return z.trim();
    if (w != null && w.trim().isNotEmpty) {
      final a0 = w.trim();
      if (!_lb(a0)) return a0;
      // Local endpoints require an explicit --api or CASCADE_API_URL override.
    }
    return $(0);
  }

  static bool _lb(String a0) {
    final a1 = a0.toLowerCase();
    return a1.contains($(103)) ||
        a1.contains($(104)) ||
        a1.contains($(105)) ||
        a1.contains($(106));
  }

  void y() {
    Directory(e).createSync(recursive: true);
    File(f).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({
            $(9): a,
            if (b != null) $(10): b,
            if (c != null) $(11): c,
            if (d != null) $(12): d,
          })}\n',
    );
  }

  /// Clears saved CLI credentials (logout / switch account).
  static bool z() {
    final a0 = File(f);
    if (!a0.existsSync()) return false;
    a0.deleteSync();
    return true;
  }

  static String _s(String a0) =>
      a0.endsWith('/') ? a0.substring(0, a0.length - 1) : a0;
}

class _G {
  _G(this.a);
  final _A a;

  Future<Map<String, dynamic>> x(
    String a0,
    String a1, {
    Map<String, dynamic>? a2,
  }) async {
    final a3 = Uri.parse('${a.a}$a1');
    final a4 = <String, String>{
      $(14): $(15),
      $(16): a.a,
      if (a.b != null) $(17): '${$(18)}${a.b}',
    };
    late h.Response a5;
    final a6 = a0.toUpperCase();
    if (a6 == $(80)) {
      a5 = await h.get(a3, headers: a4).timeout(const Duration(seconds: 30));
    } else if (a6 == $(81)) {
      a5 = await h
          .post(a3, headers: a4, body: a2 == null ? null : jsonEncode(a2))
          .timeout(const Duration(seconds: 30));
    } else {
      throw _F('${$(198)}$a0');
    }
    Map<String, dynamic> a7;
    try {
      final a8 = jsonDecode(a5.body);
      a7 = a8 is Map<String, dynamic> ? a8 : <String, dynamic>{};
    } catch (_) {
      a7 = <String, dynamic>{};
    }
    if (a5.statusCode < 200 || a5.statusCode >= 300) {
      throw _E(
        a5.statusCode == 401 || a5.statusCode == 403
            ? 'Login expired or account access unavailable. Run cascade login and check your dashboard.'
            : a5.statusCode == 404
                ? 'App/project not found. Run cascade init --pick with the correct account.'
                : a5.statusCode >= 500
                    ? 'Server unavailable. Check connectivity and retry.'
                    : 'Request rejected. Check App/project identity, repository access and CLI/server compatibility; run cascade doctor.',
        b: a7[$(40)] as String?,
      );
    }
    return a7;
  }

  Future<Map<String, dynamic>> y(String a0) => x($(80), a0);
  Future<Map<String, dynamic>> z(String a0, [Map<String, dynamic>? a1]) =>
      x($(81), a0, a2: a1);
}

class _H {
  static void x() {
    if (_A.z()) {
      stdout.writeln('${$(231)}${_A.f}');
      stdout.writeln($(232));
    } else {
      stdout.writeln($(233));
    }
  }
}

/// Push filled release secrets to GitHub; Apple signing requires explicit --ios.
class _I {
  static Future<void> x(List<String> a0, _A config) async {
    stdout.writeln($(242));
    final a1 = Directory.current.path;
    final a2 = File(q.join(a1, $(60)));
    if (!a2.existsSync()) throw _F($(243));

    var a3 = _parseEnvMultiline(a2.readAsStringSync());
    final a4 = a3[$(236)]?.trim() ?? '';
    final a5 = a3[$(237)]?.trim() ?? '';
    var a6 = a3[$(238)]?.trim() ?? '';
    final bAll = a4.isNotEmpty && a5.isNotEmpty && a6.isNotEmpty;
    final setupIos = a0.contains("--ios");
    // Push existing credentials before optional Apple provisioning, so it cannot block Android setup.
    final setupErrors = <String>[];
    try {
      if (!_hasGh()) throw _F($(249));
      await _pushSecrets(a1, a3);
    } catch (_) {
      stdout.writeln(
          'ERROR GitHub release configuration. Check gh access and rerun cascade match.');
      setupErrors.add('GitHub release configuration');
    }
    setupErrors.addAll(await _configureStatus(a1, a3, config));
    if (setupErrors.isNotEmpty) {
      throw _F(
          'Setup incomplete: ${setupErrors.join(', ')}. Fix the reported configuration and run cascade match again.');
    }
    if (setupIos && !bAll) {
      final a7 = <String>[
        if (a4.isEmpty) $(236),
        if (a5.isEmpty) $(237),
        if (a6.isEmpty) $(238),
      ];
      throw _F('${$(244)}${a7.join(', ')}${$(245)}');
    }

    if (setupIos && bAll) {
      a6 = _keyBody(a1, a6);
      if (!a6.contains('BEGIN PRIVATE KEY') ||
          !a6.contains('END PRIVATE KEY')) {
        throw _F($(304));
      }
      if (a6.contains('…') || a6.contains('...')) {
        throw _F($(304));
      }

      final a8 = q.join(a1, $(240));
      if (!Directory(a8).existsSync()) throw _F($(246));
      if (!_hasFastlane()) throw _F($(247));

      final a9 = _i(a1);
      if (a9 == null || a9.isEmpty) throw _F($(288));

      final b0 = await _certsUrl(a1);
      a3['MATCH_GIT_URL'] = b0;
      stdout.writeln('${$(264)}$b0');
      _writeMatchfile(a8, b0, a9);
      stdout.write($(265));

      final b1 = _ensurePassword(a2, a3);
      stdout.write($(266));
      final b2 = await _ensureGitAuth(a2, a3);
      stdout.write($(267));

      final b6 = q.join(Directory.systemTemp.path, $(302));
      File(b6).writeAsStringSync(a6.endsWith('\n') ? a6 : '$a6\n');
      final bOk = _pemOk(b6);
      if (bOk == false) {
        try {
          File(b6).deleteSync();
        } catch (_) {}
        throw _F($(304));
      }
      stdout.writeln($(309));

      stdout.writeln($(248));
      final b3 = Map<String, String>.from(Platform.environment)
        ..remove($(238))
        ..remove($(239))
        ..[$(236)] = a4
        ..[$(237)] = a5
        ..[$(254)] = b1
        ..[$(255)] = b2
        ..[$(256)] = b2
        ..[$(285)] = $(287)
        ..[$(286)] = $(287)
        ..[$(301)] = b6;

      final b7 = q.join(a8, $(298));
      Directory(b7).createSync(recursive: true);
      final b8 = File(q.join(b7, $(299)));
      final b9 = b8.existsSync() ? b8.readAsStringSync() : '';
      if (!b9.contains($(300))) {
        b8.writeAsStringSync(
          '$b9${b9.isEmpty || b9.endsWith('\n') ? '' : '\n'}${$(303)}',
        );
      }

      final b4 = await Process.run(
        $(235),
        [$(300)],
        workingDirectory: a8,
        environment: b3,
      );
      try {
        File(b6).deleteSync();
      } catch (_) {}
      if (b4.exitCode != 0) {
        final out = '${b4.stdout}\n${b4.stderr}'.toLowerCase();
        if (out.contains('invalid curve') ||
            out.contains('openssl::pkey') ||
            out.contains('pkeyerror') ||
            out.contains('could not parse') ||
            out.contains('private key')) {
          throw _F($(310));
        }
        throw _F($(311));
      }
      stdout.writeln($(252));
    } else {
      stdout.write($(318));
    }

    final matchUrl = a3["MATCH_GIT_URL"];
    a3 = _parseEnvMultiline(a2.readAsStringSync());
    if (matchUrl != null) a3["MATCH_GIT_URL"] = matchUrl;
    if (setupIos) await _pushSecrets(a1, a3);
  }

  static Future<List<String>> _configureStatus(
      String root, Map<String, String> values, _A config) async {
    final errors = <String>[];
    final candidates = <String, Object>{};
    try {
      final google = values['PLAY_SERVICE_ACCOUNT_JSON']?.trim() ?? '';
      if (google.isNotEmpty) candidates['google_play'] = jsonDecode(google);
    } catch (_) {
      stdout.writeln(
          'ERROR Automatic Android status updates: invalid Google Play configuration.');
      errors.add('Android status updates');
    }
    final appleKey = values['APP_STORE_CONNECT_API_KEY']?.trim() ?? '';
    if (appleKey.isNotEmpty) {
      candidates['app_store_connect'] = {
        'mode': 'team',
        'keyId': values['APP_STORE_CONNECT_API_KEY_ID'] ?? '',
        'issuerId': values['APP_STORE_CONNECT_API_ISSUER_ID'] ?? '',
        'privateKey': _keyBody(root, appleKey),
      };
    }
    if (candidates.isEmpty) return errors;
    try {
      if (config.b == null) throw _F('Run cascade login.');
      final project = File(q.join(root, 'cascade.project.yaml'));
      final binding = project.existsSync()
          ? RegExp(r'^(?:cx|project_key):\s*(\S+)', multiLine: true)
              .firstMatch(project.readAsStringSync())
              ?.group(1)
          : null;
      if (binding == null) throw _F('Run cascade init.');
      final api = _G(config);
      final setup =
          await api.z('/api/cli/apps/status-access', {'projectKey': binding});
      if (setup['available'] != true) {
        stdout.writeln(
            'WARN Automatic status updates are unavailable on this deployment. Release setup is retained.');
        return errors;
      }
      for (final entry in candidates.entries) {
        final label = entry.key == 'google_play' ? 'Android' : 'iOS';
        try {
          for (final operation in ['configure', 'test']) {
            final ticket = await api.z('/api/cli/apps/status-access', {
              'projectKey': binding,
              'provider': entry.key,
              'operation': operation
            });
            final upload = Uri.parse(ticket['uploadUrl'] as String);
            final local = _A._lb(config.a) &&
                ['127.0.0.1', 'localhost', '::1'].contains(upload.host);
            if ((upload.scheme != 'https' &&
                    !(local && upload.scheme == 'http')) ||
                upload.userInfo.isNotEmpty ||
                upload.hasQuery ||
                upload.hasFragment) {
              throw _F('Invalid setup destination.');
            }
            final response = await h
                .post(upload,
                    headers: {
                      'Content-Type': 'application/json',
                      'Origin': Uri.parse(config.a).origin,
                      'Authorization': 'Bearer ${ticket['authorization']}',
                    },
                    body: jsonEncode({
                      'appId': ticket['appId'],
                      'provider': entry.key,
                      if (operation == 'configure') 'credential': entry.value
                    }))
                .timeout(const Duration(seconds: 30));
            if (response.statusCode < 200 ||
                response.statusCode >= 300 ||
                response.bodyBytes.length > 8192) {
              throw _F('Status setup failed.');
            }
            final result = jsonDecode(response.body) as Map<String, dynamic>;
            if (operation == 'test' &&
                !['accepted', 'limited'].contains(result['outcome'])) {
              stdout.writeln(
                  'WARN $label automatic status updates: saved, awaiting validation.');
            } else if (operation == 'test') {
              final checked = await api
                  .z('/api/cli/apps/status-access', {'projectKey': binding});
              final configured = (checked['providers'] as List? ?? []).any(
                  (p) =>
                      p is Map &&
                      p['provider'] == entry.key &&
                      p['configured'] == true);
              stdout.writeln(configured
                  ? 'OK $label automatic status updates'
                  : 'WARN $label automatic status updates: saved, awaiting validation.');
            }
          }
        } catch (_) {
          stdout.writeln(
              'ERROR Automatic $label status updates. Check the configuration, sign in again and rerun cascade match.');
          errors.add('$label status updates');
        }
      }
    } catch (_) {
      stdout.writeln(
          'ERROR Automatic status setup. Check Cascade login and project binding, then rerun cascade match.');
      errors.add('Automatic status updates');
    } finally {
      candidates.clear();
    }
    return errors;
  }

  static Future<void> _pushSecrets(String a0, Map<String, String> a1) async {
    final a2 = File(q.join(a0, $(314)));
    if (!a2.existsSync()) throw _F($(319));
    stdout.write($(315));
    final a3 = RegExp(r'gh secret set (\S+) --body "\$([A-Z0-9_]+)"');
    var a4 = 0;
    final failed = <String>[];
    for (final a5 in a3.allMatches(a2.readAsStringSync())) {
      final a6 = a5.group(1)!;
      final a7 = a5.group(2)!;
      var a8 = a1[a7]?.trim() ?? '';
      if (a8.isEmpty) continue;
      if (a7 == $(238)) a8 = _keyBody(a0, a8);
      final process = await Process.start('gh', ['secret', 'set', a6],
          workingDirectory: a0);
      final output = process.stdout.drain<void>();
      final errors = process.stderr.drain<void>();
      process.stdin.write(a8);
      await process.stdin.close();
      final status = await process.exitCode;
      await Future.wait([output, errors]);
      if (status != 0) {
        failed.add(a7);
        continue;
      }
      stdout.writeln('${$(316)}$a7');
      a4++;
    }
    if (failed.isNotEmpty) {
      throw _F(
          "Some secrets failed to upload: ${failed.join(', ')}. Other uploads were attempted; fix gh authentication/permissions and rerun.");
    }
    if (a4 == 0) {
      stdout.write($(321));
    }
    stdout.writeln($(317));
  }

  static bool _hasFastlane() {
    try {
      return Process.runSync($(235), ['--version']).exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static bool _hasGh() {
    try {
      return Process.runSync($(211), [$(280), $(281)]).exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<String> _ghLogin() async {
    final a0 = await Process.run($(211), [$(276), $(277), $(278), $(279)]);
    final a1 = (a0.stdout as String).trim();
    if (a0.exitCode != 0 || a1.isEmpty) throw _F($(268));
    return a1;
  }

  static Future<String> _ghToken() async {
    final a0 = await Process.run($(211), [$(280), $(281)]);
    final a1 = (a0.stdout as String).trim();
    if (a0.exitCode != 0 || a1.isEmpty) throw _F($(249));
    return a1;
  }

  static Future<String> _certsUrl(String a0) async {
    final a1 = File(q.join(a0, $(240), $(241)));
    if (a1.existsSync()) {
      final a2 =
          RegExp(r'git_url\("([^"]+)"\)').firstMatch(a1.readAsStringSync());
      if (a2 != null) return a2.group(1)!;
    }
    final a3 = await _ghLogin();
    final a4 =
        (_n(a0) ?? $(69)).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final a5 = '$a3/${$(282)}$a4'.replaceAll(RegExp(r'-+'), '-');
    final a6 = '${$(283)}$a5${$(284)}';
    final a7 = await Process.run($(211), [$(270), $(275), a5]);
    if (a7.exitCode != 0) {
      final a8 = await Process.run($(211), [
        $(270),
        $(271),
        a5,
        $(272),
        $(273),
        $(274),
      ]);
      if (a8.exitCode != 0) {
        throw _F('${$(269)}: ${(a8.stderr as String).trim()}');
      }
    }
    return a6;
  }

  static void _writeMatchfile(String a0, String a1, String a2) {
    File(q.join(a0, $(241)))
        .writeAsStringSync('${$(289)}$a1${$(290)}$a2${$(291)}');
  }

  static String _ensurePassword(File a0, Map<String, String> a1) {
    final a2 = a1[$(254)]?.trim() ?? '';
    if (a2.isNotEmpty) return a2;
    final a3 = Random.secure();
    final a4 = List<int>.generate(24, (_) => a3.nextInt(256));
    final a5 = base64UrlEncode(a4).replaceAll('=', '');
    _upsertEnv(a0, $(254), a5);
    return a5;
  }

  static Future<String> _ensureGitAuth(File a0, Map<String, String> a1) async {
    final a2 = a1[$(255)]?.trim() ?? '';
    if (a2.isNotEmpty) return a2;
    final a3 = await _ghToken();
    final a4 = base64Encode(utf8.encode('${$(292)}$a3'));
    _upsertEnv(a0, $(255), a4);
    return a4;
  }

  static void _upsertEnv(File a0, String a1, String a2) {
    final a3 = a0.readAsStringSync();
    final a4 = RegExp('^${RegExp.escape(a1)}=.*\$', multiLine: true);
    final a5 = '$a1=$a2';
    if (a4.hasMatch(a3)) {
      a0.writeAsStringSync(a3.replaceFirst(a4, a5));
    } else {
      final a6 = a3.endsWith('\n') ? a3 : '$a3\n';
      a0.writeAsStringSync('$a6\n# auto by cascade match\n$a5\n');
    }
  }

  /// `true` valid, `false` invalid, `null` openssl unavailable (skip early check).
  static bool? _pemOk(String a0) {
    try {
      final a1 = Process.runSync($(305), [$(306), $(307), a0, $(308)]);
      return a1.exitCode == 0;
    } catch (_) {
      return null;
    }
  }

  static String _keyBody(String a0, String a1) {
    var a2 = a1.trim();
    while ((a2.startsWith('"') && a2.endsWith('"') && a2.length > 1) ||
        (a2.startsWith("'") && a2.endsWith("'") && a2.length > 1)) {
      a2 = a2.substring(1, a2.length - 1).trim();
    }
    a2 = a2
        .replaceAll(r'\\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
    if (!a2.contains('BEGIN PRIVATE KEY')) {
      final a3 = a2.startsWith('/') || a2.startsWith('~')
          ? a2.replaceFirst('~', Platform.environment[$(3)] ?? '')
          : q.join(a0, a2);
      final a4 = File(a3);
      if (a4.existsSync()) {
        a2 = a4.readAsStringSync().trim();
      }
    }
    if (a2.contains('BEGIN PRIVATE KEY') && !a2.contains('\n')) {
      a2 = a2
          .replaceFirst(
              '-----BEGIN PRIVATE KEY-----', '-----BEGIN PRIVATE KEY-----\n')
          .replaceFirst(
              '-----END PRIVATE KEY-----', '\n-----END PRIVATE KEY-----');
    }
    if (!a2.endsWith('\n')) a2 = '$a2\n';
    return a2;
  }
}

class _B {
  _B(this.a);
  final _A a;

  Future<void> x() async {
    final a0 = _G(a);
    final a1 = Platform.environment[$(5)];
    final a2 = Platform.environment[$(6)];
    if (a1 != null && a1.isNotEmpty && a2 != null && a2.isNotEmpty) {
      final a3 = await a0.z($(19), {$(11): a1, $(13): a2});
      final a4 = a3[$(25)] as Map<String, dynamic>? ?? {};
      a
        ..b = a3[$(10)] as String?
        ..c = a4[$(11)] as String?
        ..d = a3[$(12)] as String?;
      a.y();
      stdout.writeln('${$(145)}${a.c}${$(150)}');
      stdout.writeln($(147));
      return;
    }
    stdout.writeln($(142));
    final a5 = await a0.z($(20), {$(9): a.a});
    final a6 = a5[$(30)] as String? ?? '';
    final a7 = a5[$(31)] as String? ?? '';
    final a8 = a5[$(32)] as String? ?? '';
    final a9 = (a5[$(33)] as num?)?.toInt() ?? 900;
    final b0 = (a5[$(34)] as num?)?.toInt() ?? 2;
    stdout.writeln('${$(143)}$a6');
    stdout.writeln('${$(144)}$a7\n');
    if (a7.isNotEmpty) _o(a7);
    final b1 = DateTime.now().add(Duration(seconds: a9));
    final b2 = Duration(seconds: b0 < 2 ? 2 : b0);
    final b3 = HttpClient();
    try {
      while (DateTime.now().isBefore(b1)) {
        await Future<void>.delayed(b2);
        final b4 = Uri.parse('${a.a}${$(21)}${Uri.encodeQueryComponent(a8)}');
        final b5 = await b3.getUrl(b4);
        final b6 = await b5.close();
        final b7 = await b6.transform(utf8.decoder).join();
        final b8 = jsonDecode(b7) as Map<String, dynamic>;
        final b9 = b8[$(35)] as String?;
        if (b9 == $(36)) {
          stdout.write($(201));
          continue;
        }
        if (b9 == $(37) && b8[$(10)] != null) {
          stdout.writeln();
          final c0 = b8[$(25)] as Map<String, dynamic>? ?? {};
          a
            ..b = b8[$(10)] as String?
            ..c = c0[$(11)] as String?
            ..d = b8[$(12)] as String?;
          a.y();
          stdout.writeln('${$(145)}${a.c ?? $(159)}');
          stdout.writeln('${$(146)}${_A.f}');
          stdout.writeln($(147));
          return;
        }
        if (b9 == $(38)) throw _F($(148));
      }
    } finally {
      b3.close(force: true);
    }
    throw _F($(149));
  }
}

class _C {
  _C(this.a);
  final _A a;

  Future<void> x(List<String> a0) async {
    if (a.b == null || a.b!.isEmpty) throw _F($(117));
    final a1 = Directory.current.path;
    final a2 = _n(a1);
    if (a2 == null) throw _F($(118));
    final a3 = a0.contains($(73));
    final a4 = a0.contains($(74));
    String? a5;
    final a6 = a0.indexOf($(75));
    if (a6 >= 0 && a6 + 1 < a0.length) a5 = a0[a6 + 1];
    final a7 = _G(a);
    String? a8;
    String? a9;
    if (a4) {
      a8 = await _k(a7);
    } else if (!a3) {
      a9 = _m(a1);
      a8 = a9 == null ? _l(a1) : null;
    }
    final b0 = (a5 ?? a2).trim();
    final b1 = _j(a1);
    final b2 = _i(a1);
    if (a8 != null || a9 != null) {
      stdout.writeln($(119));
    } else {
      stdout.writeln('${$(120)}$b0${$(121)}');
      if (b1 != null) stdout.writeln('${$(122)}$b1');
      if (b2 != null) stdout.writeln('${$(123)}$b2');
    }
    final binding = await _repositoryBinding();
    final b3 = await a7.z($(22), {
      "repositoryTrust": binding,
      "refreshWorkflowSupported": true,
      if (a8 != null) $(49): a8,
      if (a9 != null) $(50): a9,
      $(28): b0,
      if (b1 != null) $(51): b1,
      if (b2 != null) $(52): b2,
    });
    final b4 = b3[$(41)] as Map<String, dynamic>;
    final b5 = b3[$(42)] as Map<String, dynamic>;
    final refresh = b3['refreshWorkflowFile'];
    if (b4['path'] != 'cascade.project.yaml' ||
        b5['path'] != '.github/workflows/cascade.yml' ||
        b5['version'] != supportedWorkflowVersion ||
        b5['checksum'] != workflowChecksum((b5['contents'] as String?) ?? '') ||
        refresh is! Map ||
        refresh['path'] != '.github/workflows/cascade-refresh.yml' ||
        refresh['contents'] is! String ||
        b4['contents'] is! String ||
        !((b5['contents'] as String?) ?? '')
            .contains('_Σ: "${b5['checksum']}"') ||
        !((b5['contents'] as String?) ?? '')
            .contains('_λ: "$supportedWorkflowVersion"') ||
        !((b5['contents'] as String?) ?? '').contains('_Σ:') ||
        !((b5['contents'] as String?) ?? '').contains('_μ:')) {
      throw _F(
          'Unsupported server workflow contract. Upgrade cascade_cli and the server together; no project files were written.');
    }
    for (final entry in {
      'secretsEnvFile': 'cascade.secrets.env',
      'secretsEnvExampleFile': 'cascade.secrets.env.example',
      'secretsGuideFile': 'cascade.secrets.md'
    }.entries) {
      if (b3[entry.key] is! Map ||
          b3[entry.key]['path'] != entry.value ||
          b3[entry.key]['contents'] is! String) {
        throw _F(
            'Invalid server setup response. Upgrade CLI/server together; no files were written.');
      }
    }
    final b6 = q.join(a1, b4[$(46)] as String);
    final b7 = q.join(a1, b5[$(46)] as String);
    await Directory(q.dirname(b7)).create(recursive: true);
    await File(b6).writeAsString(b4[$(47)] as String);
    final previous = File(b7);
    if (previous.existsSync()) {
      await previous.copy('$b7.pre-cascade-init.bak');
      stdout.writeln(
          'Saved previous Cascade-owned workflow to $b7.pre-cascade-init.bak.');
    }
    await previous.writeAsString(b5[$(47)] as String);
    final refreshWorkflow = b3['refreshWorkflowFile'] as Map<String, dynamic>?;
    if (refreshWorkflow != null) {
      final refreshPath = refreshWorkflow['path'] as String;
      if (refreshPath != '.github/workflows/cascade-refresh.yml') {
        throw _F('Unexpected lifecycle workflow path.');
      }
      final companion = File(q.join(a1, refreshPath));
      if (companion.existsSync()) {
        await companion.copy('${companion.path}.pre-cascade-init.bak');
      }
      await companion.writeAsString(refreshWorkflow['contents'] as String);
      stdout.writeln('Wrote $refreshPath — scoped lifecycle reader.');
      stdout.writeln('Commit both generated files in .github/workflows/.');
    }
    if (_h(a.a)) {
      stdout.writeln('');
      stdout.writeln('${$(191)}${a.a}${$(192)}');
      stdout.writeln($(193));
      stdout.writeln($(194));
    }
    final b8 = b3[$(43)] as Map<String, dynamic>?;
    final b9 = b3[$(44)] as Map<String, dynamic>?;
    final c0 = b3[$(45)] as Map<String, dynamic>?;
    var c1 = false;
    final c2 = _e(a1);
    if (b8 != null) {
      final c7 = q.join(a1, b8[$(46)] as String);
      final c8 = File(c7).existsSync();
      final c3 = _mergeSecretsEnv(
        c8 ? File(c7).readAsStringSync() : null,
        b8[$(47)] as String,
        c2.$1,
      );
      File(c7).writeAsStringSync(c3);
      c1 = !c8;
    }
    if (b9 != null) {
      await File(q.join(a1, b9[$(46)] as String))
          .writeAsString(b9[$(47)] as String);
    }
    if (c0 != null) {
      await File(q.join(a1, c0[$(46)] as String))
          .writeAsString(c0[$(47)] as String);
    }
    _d(a1);
    final c4 = b3[$(48)] == true;
    final c5 = b3[$(49)];
    stdout.writeln(c4 ? '${$(124)}$c5${$(203)}' : '${$(125)}$c5${$(203)}');
    stdout.writeln('${$(126)}${b4[$(46)]}${$(127)}');
    stdout.writeln('${$(126)}${b5[$(46)]}${$(128)}');
    if (b8 != null) {
      if (c1) {
        stdout.writeln('${$(126)}${b8[$(46)]}${$(129)}');
        if (c2.$1.isNotEmpty) {
          stdout.writeln('${$(195)}${c2.$1.keys.join(', ')}');
          for (final c6 in c2.$2) {
            stdout.writeln('${$(207)}${$(228)} $c6');
          }
        } else {
          stdout.writeln($(196));
        }
        stdout.writeln($(197));
      } else {
        stdout.writeln('${$(132)}${b8[$(46)]}${$(133)}');
      }
    }
    if (b9 != null) stdout.writeln('${$(126)}${b9[$(46)]}${$(130)}');
    if (c0 != null) stdout.writeln('${$(126)}${c0[$(46)]}${$(131)}');
    stdout.writeln($(134));
    stdout.writeln($(135));
    stdout.writeln($(136));
    stdout.writeln($(137));
    stdout.writeln($(138));
    stdout.writeln($(139));
    stdout.writeln($(140));
    stdout.writeln($(141));
  }

  Future<String> _k(_G a0) async {
    final a1 = await a0.y($(23));
    final a2 = (a1[$(26)] as List?) ?? const [];
    if (a2.isEmpty) throw _F($(151));
    stdout.writeln($(152));
    for (var a3 = 0; a3 < a2.length; a3++) {
      final a4 = a2[a3] as Map<String, dynamic>;
      stdout.writeln(
        '${$(205)}${a3 + 1}${$(206)}${a4[$(28)]}  (${a4[$(27)]})  [${a4[$(29)]}]',
      );
    }
    stdout.write('${$(153)}${a2.length}${$(154)}');
    final a5 = stdin.readLineSync()?.trim() ?? '';
    final a6 = int.tryParse(a5);
    if (a6 == null || a6 < 1 || a6 > a2.length) throw _F($(155));
    return (a2[a6 - 1] as Map<String, dynamic>)[$(27)] as String;
  }

  bool _h(String a0) {
    final a1 = a0.toLowerCase();
    return a1.contains($(103)) ||
        a1.contains($(104)) ||
        a1.contains($(105)) ||
        a1.contains($(106));
  }
}

class _D {
  _D(this.a);
  final _A a;

  Future<void> x() async {
    final a0 = Directory.current.path;
    final a1 = q.join(a0, $(58));
    final a2 = q.join(a0, $(59));
    stdout.writeln($(156));
    if (a.d != null &&
        (DateTime.tryParse(a.d!)?.isBefore(DateTime.now()) ?? true)) {
      stdout.writeln('ERROR CLI login expired - run: cascade login');
      exitCode = 1;
    }
    if (a.b == null || a.b!.isEmpty) {
      stdout.writeln($(157));
      exitCode = 1;
    } else {
      stdout.writeln('${$(158)}${a.c ?? $(159)}');
    }
    if (!File(q.join(a0, $(57))).existsSync()) {
      stdout.writeln($(160));
      exitCode = 1;
    } else {
      stdout.writeln($(161));
    }
    String? a3;
    final a4 = File(a1);
    if (!a4.existsSync()) {
      stdout.writeln($(162));
      exitCode = 1;
    } else {
      final a5 = a4.readAsStringSync();
      a3 = RegExp($(63), multiLine: true)
              .firstMatch(a5)
              ?.group(1)
              ?.replaceAll('"', '') ??
          RegExp($(64), multiLine: true)
              .firstMatch(a5)
              ?.group(1)
              ?.replaceAll('"', '');
      stdout.writeln($(163));
      if (a3 == null || !(a3.startsWith($(83)) || a3.startsWith($(84)))) {
        stdout.writeln($(164));
        exitCode = 1;
        a3 = null;
      } else if (a3.startsWith($(83))) {
        stdout.writeln($(165));
      } else {
        stdout.writeln($(166));
        exitCode = 1;
      }
    }
    final a6 = File(a2);
    if (!a6.existsSync()) {
      stdout.writeln($(167));
      exitCode = 1;
    } else {
      final a7 = a6.readAsStringSync();
      if (!a7.contains($(209)) ||
          !a7.contains($(208)) ||
          !a7.contains($(210))) {
        stdout.writeln($(168));
        exitCode = 1;
      } else {
        final version = RegExp(r'_λ:\s*"([^"\r\n]+)"').firstMatch(a7)?.group(1);
        if (version != supportedWorkflowVersion) {
          stdout.writeln(
              'ERROR workflow contract unsupported (expected $supportedWorkflowVersion) - run: dart pub global activate cascade_cli; cascade init');
          exitCode = 1;
        } else {
          stdout.writeln('OK workflow contract: $supportedWorkflowVersion');
          stdout.writeln($(169));
        }
      }
    }
    await _c(a0, a3);
    final refreshFile =
        File(q.join(a0, '.github/workflows/cascade-refresh.yml'));
    if (!refreshFile.existsSync() ||
        !refreshFile.readAsStringSync().contains('workflow_call:')) {
      stdout.writeln(
          'ERROR lifecycle workflow missing or invalid - run: cascade init');
      exitCode = 1;
    } else {
      stdout.writeln('OK lifecycle workflow: present');
    }
    stdout.writeln($(170));
    stdout.writeln('${$(171)}${a.a}${$(172)}');
  }

  Future<void> _c(String a0, String? a1) async {
    stdout.writeln($(173));
    if (!File(q.join(a0, 'cascade.secrets.env')).existsSync()) {
      stdout.writeln('ERROR cascade.secrets.env missing - run: cascade init');
      exitCode = 1;
    }
    final a2 = <(String, String)>[];
    var a3 = $(218);
    if (a.b != null && a.b!.isNotEmpty && a1 != null) {
      try {
        final a4 = _G(a);
        final a5 = await a4.y('${$(24)}${Uri.encodeQueryComponent(a1)}');
        if (a5['source'] == 'baseline') {
          stdout
              .writeln('ERROR App/project mismatch - run: cascade init --pick');
          exitCode = 1;
        }
        if (a5['workflowVersion'] != supportedWorkflowVersion) {
          stdout.writeln(
              'ERROR server workflow contract differs - upgrade CLI/server together, then run: cascade init');
          exitCode = 1;
        }
        final workflow = File(q.join(a0, '.github/workflows/cascade.yml'));
        if (a5['issuedWorkflowVersion'] != supportedWorkflowVersion ||
            !workflow.existsSync() ||
            a5['issuedWorkflowChecksum'] !=
                workflowChecksum(workflow.readAsStringSync())) {
          stdout.writeln(
              'ERROR workflow does not match the server-issued seal - run: cascade init');
          exitCode = 1;
        } else {
          stdout.writeln('OK server-issued workflow seal verified');
        }
        final a6 = a5[$(53)] as List?;
        if (a6 != null) {
          for (final a7 in a6) {
            if (a7 is Map) {
              final a8 = '${a7[$(54)] ?? ''}';
              final a9 = '${a7[$(55)] ?? ''}';
              if (a8.isNotEmpty && a9.isNotEmpty) a2.add((a8, a9));
            }
          }
        }
        a3 = (a5[$(56)] as String?) ?? a3;
        final status =
            await a4.z('/api/cli/apps/status-access', {'projectKey': a1});
        for (final item in (status['providers'] as List? ?? [])) {
          if (item is Map) {
            final label = item['provider'] == 'google_play' ? 'Android' : 'iOS';
            stdout.writeln(item['configured'] == true
                ? 'OK $label automatic status updates'
                : status['available'] != true
                    ? 'WARN $label automatic status updates unavailable on this deployment'
                    : 'WARN $label automatic status updates not configured. Run: cascade match');
          }
        }
      } catch (_) {
        stdout.writeln($(174));
        exitCode = 1;
      }
    } else {
      stdout.writeln($(175));
    }
    if (a2.isEmpty) {
      stdout.writeln($(176));
      return;
    }
    stdout.writeln('${$(177)}$a3${$(203)}');
    final b0 = _b(a0);
    final names = a2.map((p) => p.$1).toSet();
    stdout.writeln(
        'Android readiness: ${names.contains('ANDROID_KEYSTORE') ? 'signing required by enabled lanes' : 'no Android signing lane enabled'}');
    stdout.writeln(
        'iOS readiness: ${names.contains('MATCH_PASSWORD') ? 'signing required - setup: cascade match --ios' : 'no iOS lane enabled'}');
    stdout.writeln("Lane requirements: ${a2.map((p) => p.$1).join(', ')}");
    if (!File(q.join(a0, $(60))).existsSync()) stdout.writeln($(178));
    final b1 = await _a();
    if (b1 == null) {
      stdout.writeln($(179));
      exitCode = 1;
      stdout.writeln($(180));
    }
    var b2 = 0, b3 = 0, b4 = 0;
    for (final b5 in a2) {
      final b6 = b0.containsKey(b5.$1) && b0[b5.$1]!.isNotEmpty;
      final b7 = b1 != null && b1.contains(b5.$2);
      if (b7) {
        stdout.writeln('${$(225)}${b5.$1}${$(202)}${b5.$2}${$(181)}');
      } else if (b6) {
        stdout.writeln('${$(226)}${b5.$1}${$(202)}${b5.$2}${$(182)}');
        b4++;
        b3++;
      } else {
        stdout.writeln('${$(227)}${b5.$1}${$(202)}${b5.$2}${$(183)}');
        b2++;
        exitCode = 1;
        b3++;
      }
    }
    if (b3 > 0) exitCode = 1;
    if (b4 > 0) {
      stdout.writeln($(184));
      stdout.writeln($(185));
    }
    if (b2 == 0 && b3 == 0) {
      stdout.writeln($(186));
    } else if (b2 == 0 && b4 == b3) {
      stdout.writeln($(187));
    } else {
      stdout.writeln('${$(188)}$b2${$(189)}$b3${$(190)}');
    }
  }

  Map<String, String> _b(String a0) {
    final file = File(q.join(a0, 'cascade.secrets.env'));
    return file.existsSync() ? _parseEnvMultiline(file.readAsStringSync()) : {};
  }

  Future<Set<String>?> _a() async {
    try {
      final a0 = await Process.run(
        $(211),
        [$(212), $(213), $(214), $(28)],
        workingDirectory: Directory.current.path,
      );
      if (a0.exitCode != 0) {
        final a1 = await Process.run(
          $(211),
          [$(212), $(213)],
          workingDirectory: Directory.current.path,
        );
        if (a1.exitCode != 0) return null;
        final a2 = <String>{};
        for (final a3 in (a1.stdout as String).split('\n')) {
          final a4 = a3.trim().split(RegExp(r'\s+')).first;
          if (a4.isNotEmpty && a4 != $(215)) a2.add(a4);
        }
        return a2;
      }
      final a5 = jsonDecode(a0.stdout as String);
      if (a5 is! List) return {};
      return {
        for (final a6 in a5)
          if (a6 is Map && a6[$(28)] is String) a6[$(28)] as String,
      };
    } catch (_) {
      return null;
    }
  }
}

String? _n(String a0) {
  final a1 = File(q.join(a0, $(57)));
  if (!a1.existsSync()) return null;
  return RegExp($(62), multiLine: true)
      .firstMatch(a1.readAsStringSync())
      ?.group(1);
}

String? _j(String a0) {
  for (final a1 in [q.join(a0, $(90)), q.join(a0, $(91))]) {
    final a2 = File(a1);
    if (!a2.existsSync()) continue;
    final a3 = a2.readAsStringSync();
    final a4 = RegExp($(66)).firstMatch(a3) ?? RegExp($(67)).firstMatch(a3);
    if (a4 != null) return a4.group(1);
  }
  return null;
}

String? _i(String a0) {
  final a1 = File(q.join(a0, $(92)));
  if (!a1.existsSync()) return null;
  final a2 = RegExp($(68)).firstMatch(a1.readAsStringSync());
  if (a2 == null) return null;
  final a3 = a2.group(1)!.replaceAll('"', '');
  if (a3.contains(r'$(') || a3.contains(r'${')) return null;
  return a3;
}

String? _m(String a0) {
  final a1 = File(q.join(a0, $(58)));
  if (!a1.existsSync()) return null;
  final a2 = a1.readAsStringSync();
  final a3 = RegExp($(63), multiLine: true)
      .firstMatch(a2)
      ?.group(1)
      ?.replaceAll('"', '');
  if (a3 != null && (a3.startsWith($(83)) || a3.startsWith($(84)))) return a3;
  final a4 = RegExp($(64), multiLine: true).firstMatch(a2);
  final a5 = a4?.group(1)?.replaceAll('"', '');
  if (a5 == null || !a5.startsWith($(84))) return null;
  if (a5.contains($(85)) || a5.endsWith($(86))) return null;
  return a5;
}

String? _l(String a0) {
  final a1 = File(q.join(a0, $(58)));
  if (!a1.existsSync()) return null;
  return RegExp($(65), multiLine: true)
      .firstMatch(a1.readAsStringSync())
      ?.group(1);
}

void _o(String a0) {
  if (Platform.isMacOS) {
    Process.run($(107), [a0]);
  } else if (Platform.isWindows) {
    Process.run($(109), [$(110), $(111), '', a0]);
  } else {
    Process.run($(108), [a0]);
  }
}

void _d(String root) {
  final file = File(q.join(root, '.gitignore'));
  var contents = file.existsSync() ? file.readAsStringSync() : '';
  for (final pattern in [
    'cascade.secrets.env',
    '.github/workflows/*.pre-cascade-init.bak'
  ]) {
    if (!contents.split('\n').contains(pattern)) {
      contents =
          '$contents${contents.isEmpty || contents.endsWith('\n') ? '' : '\n'}$pattern\n';
    }
  }
  file.writeAsStringSync(contents);
}

/// Merge server template + autofill into existing secrets.env (preserve filled values).
String _mergeSecretsEnv(
  String? existing,
  String template,
  Map<String, String> autofill,
) {
  final a0 =
      existing == null ? <String, String>{} : _parseEnvMultiline(existing);
  final a1 = <String, String>{
    for (final a2 in autofill.entries)
      if ((a0[a2.key] ?? '').trim().isEmpty) a2.key: a2.value,
  };
  final a3 = <String, String>{
    ...a1,
    for (final a4 in a0.entries)
      if (a4.value.trim().isNotEmpty) a4.key: a4.value,
  };

  final a5 = StringBuffer();
  final a6 = template.replaceAll('\r\n', '\n').split('\n');
  final a7 = <String>{};
  for (var a8 = 0; a8 < a6.length; a8++) {
    final a9 = a6[a8];
    final b0 = a9.trim();
    if (b0.isEmpty || b0.startsWith('#')) {
      a5.writeln(a9);
      continue;
    }
    final b1 = b0.indexOf('=');
    if (b1 <= 0) {
      a5.writeln(a9);
      continue;
    }
    final b2 = b0.substring(0, b1).trim();
    a7.add(b2);
    final b3 = a3[b2];
    if (b3 == null || b3.isEmpty) {
      a5.writeln('$b2=');
    } else if (b3.contains('\n') || b3.contains('"') || b3.contains("'")) {
      a5.writeln(
          '$b2="${b3.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"');
    } else {
      a5.writeln('$b2=$b3');
    }
  }
  final b4 = a3.keys.where((k) => !a7.contains(k)).toList();
  if (b4.isNotEmpty) {
    a5.writeln('');
    a5.writeln('# preserved from previous cascade.secrets.env');
    for (final b5 in b4) {
      final b6 = a3[b5]!;
      if (b6.contains('\n') || b6.contains('"')) {
        a5.writeln(
            '$b5="${b6.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"');
      } else {
        a5.writeln('$b5=$b6');
      }
    }
  }
  return a5.toString();
}

Map<String, String> _parseEnvMultiline(String a0) {
  final a1 = <String, String>{};
  final a2 = a0.replaceAll('\r\n', '\n').split('\n');
  String? a3;
  final a4 = StringBuffer();
  for (final a5 in a2) {
    if (a3 != null) {
      a4.writeln(a5);
      final a6 = a5.trim();
      if (a6.endsWith('"') || a6.endsWith("'")) {
        var a7 = a4.toString().trim();
        if ((a7.startsWith('"') && a7.endsWith('"')) ||
            (a7.startsWith("'") && a7.endsWith("'"))) {
          a7 = a7.substring(1, a7.length - 1);
        }
        a1[a3] = a7.replaceAll(r'\\n', '\n').replaceAll(r'\n', '\n');
        a3 = null;
        a4.clear();
      }
      continue;
    }
    final a8 = a5.trim();
    if (a8.isEmpty || a8.startsWith('#')) continue;
    final a9 = a8.indexOf('=');
    if (a9 <= 0) continue;
    final b0 = a8.substring(0, a9).trim();
    var b1 = a8.substring(a9 + 1).trim();
    if ((b1.startsWith('"') && !b1.endsWith('"')) ||
        (b1.startsWith("'") && !b1.endsWith("'"))) {
      a3 = b0;
      a4.write(b1);
      a4.writeln();
      continue;
    }
    if ((b1.startsWith('"') && b1.endsWith('"')) ||
        (b1.startsWith("'") && b1.endsWith("'"))) {
      b1 = b1.substring(1, b1.length - 1);
    }
    b1 = b1.replaceAll(r'\\n', '\n').replaceAll(r'\n', '\n');
    if (b0.isNotEmpty) a1[b0] = b1;
  }
  return a1;
}

bool _w(String? a0) {
  if (a0 == null) return true;
  final a1 = a0.trim();
  if (a1.isEmpty) return true;
  final a2 = a1.toUpperCase();
  return a2.contains($(219)) ||
      a2.contains($(85)) ||
      a2 == $(220) ||
      a2 == $(221);
}

Map<String, String> _v(String a0) {
  final a1 = <String, String>{};
  for (final a2 in a0.split('\n')) {
    final a3 = a2.trim();
    if (a3.isEmpty || a3.startsWith('#')) continue;
    final a4 = a3.indexOf('=');
    if (a4 <= 0) continue;
    a1[a3.substring(0, a4).trim()] = a3.substring(a4 + 1).trim();
  }
  return a1;
}

File? _u2(String a0, String? a1, String a2) {
  final a3 = <String>[];
  if (a1 != null && a1.isNotEmpty) {
    if (q.isAbsolute(a1)) {
      a3.add(a1);
    } else {
      a3.addAll([
        q.normalize(q.join(a2, a1)),
        q.normalize(q.join(a0, $(222), a1)),
        q.normalize(q.join(a0, $(222), $(223), a1)),
        q.normalize(q.join(a0, a1)),
      ]);
    }
  }
  a3.addAll([
    q.join(a0, $(222), $(223), $(224)),
    q.join(a0, $(222), $(224)),
    q.join(a0, $(224)),
  ]);
  for (final a4 in a3) {
    final a5 = File(a4);
    if (a5.existsSync()) return a5;
  }
  return null;
}

(Map<String, String>, List<String>) _e(String a0) {
  final a1 = <String, String>{};
  final a2 = <String>[];
  final a3 = [q.join(a0, $(87)), q.join(a0, $(88)), q.join(a0, $(89))];
  Map<String, String> a4 = {};
  String? a5;
  for (final a6 in a3) {
    final a7 = File(a6);
    if (!a7.existsSync()) continue;
    a4 = _v(a7.readAsStringSync());
    a5 = a6;
    break;
  }
  if (a5 != null) {
    a2.add(a5);
    final a8 = a4[$(93)];
    final a9 = a4[$(94)];
    final b0 = a4[$(95)] ?? a9;
    if (!_w(a8)) a1[$(97)] = a8!;
    if (!_w(a9)) a1[$(98)] = a9!;
    if (!_w(b0)) a1[$(99)] = b0!;
  }
  final b1 = _u2(
    a0,
    a4[$(96)],
    a5 != null ? q.dirname(a5) : q.join(a0, $(222)),
  );
  if (b1 != null) {
    a1[$(100)] = base64Encode(b1.readAsBytesSync());
    a2.add(b1.path);
  }
  try {
    final b2 = Process.runSync($(112), [$(113), $(102)], workingDirectory: a0);
    if (b2.exitCode == 0) {
      final b3 = (b2.stdout as String).trim();
      if (b3.contains('@') && !_w(b3)) {
        a1[$(101)] = b3;
        a2.add('${$(112)} ${$(113)} ${$(102)}');
      }
    }
  } catch (_) {}
  return (a1, a2);
}

// Owner-authenticated initialization establishes trust before any CI credential is accepted.
Future<Map<String, String>> _repositoryBinding() async {
  if (!_I._hasGh()) {
    throw _F(
        'GitHub CLI missing. Install https://cli.github.com/, run gh auth login, then cascade init.');
  }
  final view =
      await Process.run('gh', ['repo', 'view', '--json', 'nameWithOwner']);
  if (view.exitCode != 0) {
    throw _F(
        'Sign in with gh auth login and initialize inside a GitHub repository.');
  }
  final name =
      (jsonDecode(view.stdout as String) as Map)['nameWithOwner'] as String;
  final response = await Process.run('gh', ['api', 'repos/$name']);
  if (response.exitCode != 0) {
    throw _F('Cannot inspect the GitHub repository. Check gh authentication.');
  }
  final repo = jsonDecode(response.stdout as String) as Map;
  if ((repo['permissions'] as Map?)?['push'] != true) {
    throw _F('Repository write access is required to bind Cascade.');
  }
  final ref = 'refs/heads/${repo['default_branch']}';
  stdout.writeln(
      'Binding Cascade releases to $name at $ref. PRs run validation only.');
  return {
    'repository': repo['full_name'] as String,
    'repositoryId': repo['id'].toString(),
    'ref': ref
  };
}

Future<void> _sendLocalApk(_A config, ArgResults args) async {
  if (config.b == null) throw _F('Run cascade login first.');
  final file = args['file'] as String?;
  final app = args['app'] as String?;
  final to = args['to'] as String?;
  if (file == null || app == null || to == null) {
    throw _F(
        'Use cascade send --app APP_ID --file app.apk --to you@example.com');
  }
  final artifact = File(file);
  if (!artifact.existsSync() || artifact.lengthSync() > 200 * 1024 * 1024) {
    throw _F('APK missing or larger than 200MB.');
  }
  final request = h.MultipartRequest(
      'POST', Uri.parse('${config.a}/api/cli/apps/$app/artifacts'))
    ..headers['Authorization'] = 'Bearer ${config.b}'
    ..fields['notifyEmails'] = to
    ..files.add(await h.MultipartFile.fromPath('file', file));
  final response = await h.Response.fromStream(await request.send());
  if (response.statusCode != 200) {
    throw _F(
        'Local delivery failed (${response.statusCode}). Check login, Email lane and APK file, then retry.');
  }
  stdout.writeln('APK delivered: ${jsonDecode(response.body)['downloadUrl']}');
}
