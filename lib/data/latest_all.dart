// This is a generated file. Do not edit.
import 'dart:typed_data';

import 'package:pg_timezone/src/env.dart';
import 'package:pg_timezone/src/exceptions.dart';

/// Initialize Time Zone database from latest_all.
///
/// Throws [TimeZoneInitException] when something is wrong.
void initializeTimeZones() {
  try {
    initializeDatabase(
        Uint16List.fromList(_embeddedData.codeUnits).buffer.asUint8List());
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    throw TimeZoneInitException(e.toString());
  }
}

const _embeddedData =