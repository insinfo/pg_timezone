// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

/// TimeZone initialization for standalone environments.
///
/// ```dart
/// import 'package:pg_timezone/standalone.dart';
///
/// initializeTimeZone().then((_) {
///  final detroit = getLocation('America/Detroit');
///  final now = TZDateTime.now(detroit);
/// });
/// ```
library timezone.standalone;

import 'dart:io' hide BytesBuilder;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:pg_timezone/timezone.dart';

export 'package:pg_timezone/timezone.dart'
    show
        getLocation,
        setLocalLocation,
        TZDateTime,
        Location,
        TimeZone,
        timeZoneDatabase;

final String tzDataDefaultPath = p.join('data', tzDataDefaultFilename);

// Load file
Future<List<int>> _loadAsBytes(String path) async {
  final script = Platform.script;
  final scheme = Platform.script.scheme;

  if (scheme.startsWith('http')) {
    // TODO: This path is not tested. How would one get to this situation?
    return HttpClient()
        .getUrl(Uri(
            scheme: script.scheme,
            host: script.host,
            port: script.port,
            path: path))
        .then((req) {
      return req.close();
    }).then((response) {
      // join byte buffers
      return response
          .fold(BytesBuilder(), (BytesBuilder b, d) => b..add(d))
          .then((builder) {
        return builder.takeBytes();
      });
    });
  } else {
    var uri = await Isolate.resolvePackageUri(
        Uri(scheme: 'package', path: 'timezone/$path'));
    return File(p.fromUri(uri)).readAsBytes();
  }
}

/// Initialize Time Zone database.
///
/// Throws [TimeZoneInitException] when something is worng.
///
/// ```dart
/// import 'package:pg_timezone/standalone.dart';
///
/// initializeTimeZone().then(() {
///   final detroit = getLocation('America/Detroit');
///   final detroitNow = TZDateTime.now(detroit);
/// });
/// ```
Future<void> initializeTimeZone([String? path]) {
  path ??= tzDataDefaultPath;
  return _loadAsBytes(path).then((rawData) {
    initializeDatabase(rawData);
  }).catchError((dynamic e) {
    throw TimeZoneInitException(e.toString());
  });
}
