import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as h;
import 'package:path/path.dart' as q;

part '_v.dart';

String $(int i) => _V._(i);

class Z {
  static Future<void> go(List<String> a0) async {
    final a1 = ArgParser()
      ..addFlag($(76), abbr: $(229), negatable: false)
      ..addOption($(77))
      ..addFlag($(78), negatable: false)
      ..addFlag($(79), negatable: false)
      ..addOption($(28));
    late ArgResults a2;
    try {
      a2 = a1.parse(a0);
    } on FormatException catch (a3) {
      stderr.writeln(a3.message);
      _u(a1);
      exitCode = 64;
      return;
    }
    if (a2[$(76)] == true || a2.rest.isEmpty) {
      _u(a1);
      return;
    }
    final a4 = a2.rest.first;
    final a5 = a2.rest.skip(1).toList();
    final a6 = await _A.x(y: a2[$(77)] as String?);
    final a7 = <String>[
      if (a2[$(78)] == true) $(73),
      if (a2[$(79)] == true) $(74),
      if (a2[$(28)] != null) ...[$(75), a2[$(28)] as String],
      ...a5,
    ];
    try {
      if (a4 == $(70)) {
        await _B(a6).x();
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
    }
  }

  static void _u(ArgParser a0) {
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
      if (await _p()) return a0;
    }
    if (await _p()) return $(1);
    return $(0);
  }

  static bool _lb(String a0) {
    final a1 = a0.toLowerCase();
    return a1.contains($(103)) ||
        a1.contains($(104)) ||
        a1.contains($(105)) ||
        a1.contains($(106));
  }

  static Future<bool> _p() async {
    try {
      final a0 = h.Client();
      try {
        final a1 = await a0
            .get(Uri.parse($(1)))
            .timeout(const Duration(milliseconds: 400));
        return a1.statusCode > 0 && a1.statusCode < 600;
      } finally {
        a0.close();
      }
    } catch (_) {
      return false;
    }
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
      a5 = await h.get(a3, headers: a4);
    } else if (a6 == $(81)) {
      a5 = await h.post(a3, headers: a4, body: a2 == null ? null : jsonEncode(a2));
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
        (a7[$(39)] as String?) ?? '${$(199)}${a5.statusCode}',
        b: a7[$(40)] as String?,
      );
    }
    return a7;
  }

  Future<Map<String, dynamic>> y(String a0) => x($(80), a0);
  Future<Map<String, dynamic>> z(String a0, [Map<String, dynamic>? a1]) =>
      x($(81), a0, a2: a1);
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
    final b3 = await a7.z($(22), {
      if (a8 != null)
        $(49): a8
      else if (a9 != null)
        $(50): a9
      else ...{
        $(28): b0,
        if (b1 != null) $(51): b1,
        if (b2 != null) $(52): b2,
      },
    });
    final b4 = b3[$(41)] as Map<String, dynamic>;
    final b5 = b3[$(42)] as Map<String, dynamic>;
    final b6 = q.join(a1, b4[$(46)] as String);
    final b7 = q.join(a1, b5[$(46)] as String);
    await Directory(q.dirname(b7)).create(recursive: true);
    await File(b6).writeAsString(b4[$(47)] as String);
    await File(b7).writeAsString(b5[$(47)] as String);
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
      final c3 = _f(b8[$(47)] as String, c2.$1);
      c1 = _g(q.join(a1, b8[$(46)] as String), c3, false);
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
    if (a.b == null || a.b!.isEmpty) {
      stdout.writeln($(157));
    } else {
      stdout.writeln('${$(158)}${a.c ?? $(159)}');
    }
    if (!File(q.join(a0, $(57))).existsSync()) {
      stdout.writeln($(160));
    } else {
      stdout.writeln($(161));
    }
    String? a3;
    final a4 = File(a1);
    if (!a4.existsSync()) {
      stdout.writeln($(162));
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
        a3 = null;
      } else if (a3.startsWith($(83))) {
        stdout.writeln($(165));
      } else {
        stdout.writeln($(166));
      }
    }
    final a6 = File(a2);
    if (!a6.existsSync()) {
      stdout.writeln($(167));
    } else {
      final a7 = a6.readAsStringSync();
      if (!a7.contains($(209)) || !a7.contains($(208)) || !a7.contains($(210))) {
        stdout.writeln($(168));
      } else {
        stdout.writeln($(169));
      }
    }
    await _c(a0, a3);
    stdout.writeln($(170));
    stdout.writeln('${$(171)}${a.a}${$(172)}');
  }

  Future<void> _c(String a0, String? a1) async {
    stdout.writeln($(173));
    final a2 = <(String, String)>[];
    var a3 = $(218);
    if (a.b != null && a.b!.isNotEmpty && a1 != null) {
      try {
        final a4 = _G(a);
        final a5 = await a4.y('${$(24)}${Uri.encodeQueryComponent(a1)}');
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
      } catch (_) {
        stdout.writeln($(174));
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
    if (!File(q.join(a0, $(60))).existsSync()) stdout.writeln($(178));
    final b1 = await _a();
    if (b1 == null) {
      stdout.writeln($(179));
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
        b3++;
      }
    }
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
    final a1 = File(q.join(a0, $(60)));
    if (!a1.existsSync()) return {};
    final a2 = <String, String>{};
    for (final a3 in a1.readAsStringSync().split('\n')) {
      final a4 = a3.trim();
      if (a4.isEmpty || a4.startsWith('#')) continue;
      final a5 = a4.indexOf('=');
      if (a5 <= 0) continue;
      final a6 = a4.substring(0, a5).trim();
      var a7 = a4.substring(a5 + 1).trim();
      if ((a7.startsWith('"') && a7.endsWith('"')) ||
          (a7.startsWith("'") && a7.endsWith("'"))) {
        a7 = a7.substring(1, a7.length - 1);
      }
      if (a6.isNotEmpty && a7.isNotEmpty) a2[a6] = a7;
    }
    return a2;
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
    final a4 =
        RegExp($(66)).firstMatch(a3) ?? RegExp($(67)).firstMatch(a3);
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

void _d(String a0) {
  final a1 = File(q.join(a0, $(61)));
  final a2 = $(60);
  if (!a1.existsSync()) {
    a1.writeAsStringSync('${$(114)}$a2\n');
    return;
  }
  final a3 = a1.readAsStringSync();
  if (RegExp('^${RegExp.escape(a2)}\\s*\$', multiLine: true).hasMatch(a3)) {
    return;
  }
  final a4 = a3.endsWith('\n') ? '' : '\n';
  a1.writeAsStringSync('$a3$a4\n${$(114)}$a2\n');
}

bool _g(String a0, String a1, bool a2) {
  final a3 = File(a0);
  if (!a2 && a3.existsSync()) return false;
  a3.writeAsStringSync(a1);
  return true;
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

String _f(String a0, Map<String, String> a1) {
  var a2 = a0;
  for (final a3 in a1.entries) {
    a2 = a2.replaceFirstMapped(
      RegExp('^${RegExp.escape(a3.key)}=\\s*\$', multiLine: true),
      (_) => '${a3.key}=${a3.value}',
    );
  }
  return a2;
}
