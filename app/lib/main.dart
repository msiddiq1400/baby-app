// PowerSync's attachment queue (photos) is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/attachments/attachments.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'data/local_db.dart';
import 'data/local_schema.dart';
import 'data/photo_repository.dart';
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

  final (db, photoQueue, photoFolder) = await _openDatabase();
  runApp(
    ProviderScope(
      overrides: [
        powerSyncProvider.overrideWithValue(db),
        photoQueueProvider.overrideWithValue(photoQueue),
        photoFolderProvider.overrideWithValue(photoFolder),
      ],
      child: const BabyApp(),
    ),
  );
}

/// Opens the database on the phone and keeps it, and the photo files,
/// syncing while signed in.
Future<(PowerSyncDatabase, AttachmentQueue, String)> _openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final db = PowerSyncDatabase(
    schema: localSchema,
    path: '${dir.path}/baby_app.db',
  );
  await db.initialize();

  final photoFolder = '${dir.path}/photos';
  final photoQueue = createPhotoQueue(db, Supabase.instance.client, photoFolder);

  final auth = Supabase.instance.client.auth;
  final connector = SupabaseConnector(Supabase.instance.client);
  if (auth.currentSession != null) {
    db.connect(connector: connector).ignore();
    photoQueue.startSync().ignore();
  }

  auth.onAuthStateChange.listen((change) async {
    switch (change.event) {
      case AuthChangeEvent.signedIn:
        await db.connect(connector: connector);
        await photoQueue.startSync();
      case AuthChangeEvent.signedOut:
        // Remove this family's data and photos, so the next person signing
        // in on this phone doesn't see them.
        await photoQueue.stopSyncing();
        await photoQueue.clearQueue();
        await db.disconnectAndClear();
      default:
        break;
    }
  });
  return (db, photoQueue, photoFolder);
}
