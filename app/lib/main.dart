import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'data/local_db.dart';
import 'data/local_schema.dart';
import 'data/supabase_connector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Started without --dart-define-from-file: say so on screen instead of
  // hanging on the splash logo.
  try {
    Env.assertConfigured();
  } on StateError catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.message),
            ),
          ),
        ),
      ),
    );
    return;
  }
  // Date formats for every language, also outside widgets (reminder texts).
  await initializeDateFormatting();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );

  final db = await _openDatabase();
  runApp(
    ProviderScope(
      overrides: [powerSyncProvider.overrideWithValue(db)],
      child: const BabyApp(),
    ),
  );
}

/// Opens the database on the phone and keeps it syncing while signed in.
Future<PowerSyncDatabase> _openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final db = PowerSyncDatabase(
    schema: localSchema,
    path: '${dir.path}/baby_app.db',
  );
  await db.initialize();

  final auth = Supabase.instance.client.auth;
  final connector = SupabaseConnector(Supabase.instance.client);
  if (auth.currentSession != null) db.connect(connector: connector).ignore();

  auth.onAuthStateChange.listen((change) async {
    switch (change.event) {
      case AuthChangeEvent.signedIn:
        await db.connect(connector: connector);
      case AuthChangeEvent.signedOut:
        // Remove this family's data, so the next person signing in on this
        // phone doesn't see it.
        await db.disconnectAndClear();
      default:
        break;
    }
  });
  return db;
}
