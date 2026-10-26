// Uploading local changes (SupabaseConnector) to a fake Supabase: what each
// kind of change sends (new row = upsert with its id, edit = PATCH of the
// changed columns, removal = DELETE), the 0/1 and JSON columns converted to
// the server's booleans and arrays, the queue emptied after success, kept
// after a temporary failure, and a change the server can never accept
// (bad data, constraint, permission) dropped so later uploads still go.

import 'dart:convert';

import 'package:baby_app/core/config/env.dart';
import 'package:baby_app/data/local_db.dart';
import 'package:baby_app/data/local_schema.dart';
import 'package:baby_app/data/medication_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/supabase_connector.dart';
import 'package:baby_app/data/tracking_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:powersync/powersync.dart';

import 'harness.dart';
import 'schema_guard_migrations.dart';

/// Marks every queued change as uploaded, so a test starts from an empty queue.
Future<void> drainQueue(PowerSyncDatabase db) async {
  while (true) {
    final t = await db.getNextCrudTransaction();
    if (t == null) return;
    await t.complete();
  }
}

/// A reply that carries its request, as a real HTTP client's does (the
/// database client reads the request's method from the response).
http.Response reply(SentRequest r, int status, [Object? json]) => http.Response(
      json == null ? '' : jsonEncode(json),
      status,
      request: http.Request(r.method, r.url),
      headers: {'content-type': 'application/json'},
    );

/// The fake server accepts every write.
void acceptWrites(FakeServer server) {
  server.on('POST', '/rest/v1/', (r) => reply(r, 201));
  server.on('PATCH', '/rest/v1/', (r) => reply(r, 204));
  server.on('DELETE', '/rest/v1/', (r) => reply(r, 204));
}

/// The fake server answers writes to [table] with a Postgres error [code].
void rejectWrites(FakeServer server, String table, String code, {int status = 400}) {
  for (final method in ['POST', 'PATCH', 'DELETE']) {
    server.on(
      method,
      '/rest/v1/$table',
      (r) => reply(r, status, {'code': code, 'message': 'rejected ($code)', 'details': null, 'hint': null}),
    );
  }
}

/// Runs uploads until the queue is empty (one transaction per call, as
/// PowerSync does), at most [max] times.
Future<void> uploadAll(SupabaseConnector connector, PowerSyncDatabase db, {int max = 50}) async {
  for (var i = 0; i < max && await db.getNextCrudTransaction() != null; i++) {
    await connector.uploadData(db);
  }
}

Map<String, Object?> bodyOf(SentRequest r) => (r.json! as Map).cast<String, Object?>();

void main() {
  late FlowEnv env;
  late SupabaseConnector connector;
  late Baby baby;

  setUp(() async {
    env = await FlowEnv.open();
    connector = SupabaseConnector(env.supabase);
    baby = Baby.fromJson(await env.db.get('SELECT ${Baby.columns} FROM babies WHERE id = ?', [env.babyId]));
  });
  tearDown(() => env.close());

  group('what is sent', () {
    test('a new family and baby go up in one transaction, family first', () async {
      acceptWrites(env.server);
      await connector.uploadData(env.db);
      final writes = env.server.sent('/rest/v1/');
      expect(writes.map((r) => (r.method, r.path)), [
        ('POST', '/rest/v1/families'),
        ('POST', '/rest/v1/babies'),
      ]);
      expect(bodyOf(writes[1]), containsPair('id', env.babyId));
      expect(bodyOf(writes[1]), containsPair('family_id', env.familyId));
      expect(bodyOf(writes[1]), containsPair('country_code', 'PK'));
      expect(await env.db.getNextCrudTransaction(), isNull, reason: 'uploaded, so nothing left');
    });

    test('a new row is upserted with its id', () async {
      await drainQueue(env.db);
      acceptWrites(env.server);
      await TrackingRepository(env.db).saveFeed(baby, type: FeedType.bottleFormula, at: DateTime(2026, 10, 26, 8), amountMl: 120);
      await connector.uploadData(env.db);

      final post = env.server.sent('/rest/v1/feeds').single;
      expect(post.method, 'POST');
      final body = bodyOf(post);
      final id = (await env.db.get('SELECT id FROM feeds'))['id'];
      expect(body, containsPair('id', id));
      expect(body, containsPair('baby_id', baby.id));
      expect(body, containsPair('family_id', baby.familyId));
      expect(body, containsPair('type', 'bottle_formula'));
      expect(body, containsPair('amount_ml', 120));
      expect(await env.db.getNextCrudTransaction(), isNull);
    });

    test('an edit sends only the changed columns, for that row', () async {
      final tracking = TrackingRepository(env.db);
      await tracking.saveDiaper(baby, at: DateTime(2026, 10, 26, 9), wet: true, dirty: false);
      await drainQueue(env.db);
      acceptWrites(env.server);
      final id = (await env.db.get('SELECT id FROM diapers'))['id'] as String;
      await tracking.saveDiaper(baby, existingId: id, at: DateTime(2026, 10, 26, 9), wet: true, dirty: true);
      await connector.uploadData(env.db);

      final patch = env.server.sent('/rest/v1/diapers').single;
      expect(patch.method, 'PATCH');
      expect(patch.url.queryParameters['id'], 'eq.$id');
      expect(bodyOf(patch), {'is_dirty': true}, reason: 'unchanged columns are not sent');
    });

    test('a soft delete is an update of deleted_at (so other phones hide it)', () async {
      final tracking = TrackingRepository(env.db);
      await tracking.saveDiaper(baby, at: DateTime(2026, 10, 26, 9), wet: true, dirty: false);
      await drainQueue(env.db);
      acceptWrites(env.server);
      final id = (await env.db.get('SELECT id FROM diapers'))['id'] as String;
      await tracking.delete(TrackedTable.diapers, id);
      await connector.uploadData(env.db);

      final patch = env.server.sent('/rest/v1/diapers').single;
      expect((patch.method, patch.url.queryParameters['id']), ('PATCH', 'eq.$id'));
      expect(bodyOf(patch).keys, ['deleted_at']);
    });

    test('a row removed from the phone is deleted on the server', () async {
      await insertRow(env.db, 'sleeps', {'id': 'sleep-1', 'family_id': baby.familyId, 'baby_id': baby.id, 'kind': 'nap'});
      await drainQueue(env.db);
      acceptWrites(env.server);
      await env.db.execute('DELETE FROM sleeps WHERE id = ?', ['sleep-1']);
      await connector.uploadData(env.db);

      final delete = env.server.sent('/rest/v1/sleeps').single;
      expect((delete.method, delete.url.queryParameters['id']), ('DELETE', 'eq.sleep-1'));
    });
  });

  group('types the server expects', () {
    test('diaper wet / dirty go up as true / false, not 1 / 0', () async {
      await drainQueue(env.db);
      acceptWrites(env.server);
      await TrackingRepository(env.db).saveDiaper(baby, at: DateTime(2026, 10, 26, 9), wet: true, dirty: false);
      await connector.uploadData(env.db);
      final body = bodyOf(env.server.sent('/rest/v1/diapers').single);
      expect((body['is_wet'], body['is_dirty']), (true, false));
    });

    test('a medicine\'s dose times go up as an array and as_needed as a boolean', () async {
      await drainQueue(env.db);
      acceptWrites(env.server);
      await MedicationRepository(env.db).save(
        baby,
        name: 'Syrup',
        prescribedDose: '2 ml',
        doseTimes: const [DoseTime(8, 0), DoseTime(20, 0)],
        asNeeded: false,
        startDate: DateTime(2026, 10, 26),
      );
      await connector.uploadData(env.db);
      final body = bodyOf(env.server.sent('/rest/v1/medications').single);
      expect(body['dose_times'], ['08:00:00', '20:00:00']);
      expect(body['as_needed'], false);
    });

    test('a skipped dose goes up with skipped = true', () async {
      final meds = MedicationRepository(env.db);
      await meds.save(baby, name: 'Drops', prescribedDose: '1', doseTimes: const [], asNeeded: true, startDate: DateTime(2026, 10, 26));
      await drainQueue(env.db);
      acceptWrites(env.server);
      await meds.recordDose(baby, (await meds.all(baby.id)).single, skipped: true);
      await connector.uploadData(env.db);
      expect(bodyOf(env.server.sent('/rest/v1/medication_doses').single)['skipped'], true);
    });

    // Guards new columns: every boolean or array column on a server table
    // the app writes must be converted, or the server rejects the row (and
    // the change is dropped). Reads the types from supabase/migrations.
    final server = parseServerTables();
    final uploadable = {
      for (final t in localSchema.tables)
        if (!t.localOnly && !downloadOnlyTables.contains(t.name) && server.containsKey(t.name)) t.name: t,
    };
    for (final MapEntry(key: table, value: columns) in server.entries) {
      final local = uploadable[table];
      if (local == null) continue;
      for (final MapEntry(key: column, value: type) in columns.entries) {
        final isBool = type == 'boolean' || type == 'bool';
        final isArray = type.endsWith('[]');
        if (!isBool && !isArray) continue;
        if (!local.columns.any((c) => c.name == column)) continue; // not on the phone: never uploaded
        test('$table.$column ($type) is converted on upload', () async {
          await drainQueue(env.db);
          acceptWrites(env.server);
          await env.db.execute(
            'INSERT INTO $table (id, $column) VALUES (?, ?)',
            ['guard-1', isBool ? 1 : jsonEncode(['08:00:00'])],
          );
          await connector.uploadData(env.db);
          final sent = bodyOf(env.server.sent('/rest/v1/$table').single)[column];
          if (isBool) {
            expect(sent, isA<bool>(), reason: 'add $table.$column to SupabaseConnector._booleanColumns');
          } else {
            expect(sent, isA<List<Object?>>(), reason: 'add $table.$column to SupabaseConnector._arrayColumns');
          }
        });
      }
    }
  });

  group('failures', () {
    test('a temporary server error keeps the change for the next try', () async {
      await drainQueue(env.db);
      env.server.on('POST', '/rest/v1/feeds', (r) => reply(r, 500, {'code': 'XX000', 'message': 'internal'}));
      await TrackingRepository(env.db).saveFeed(baby, type: FeedType.bottleFormula, at: DateTime(2026, 10, 26, 8), amountMl: 60);

      await expectLater(connector.uploadData(env.db), throwsA(anything));
      final pending = await env.db.getNextCrudTransaction();
      expect(pending?.crud.single.table, 'feeds', reason: 'still queued');

      acceptWrites(env.server);
      await connector.uploadData(env.db);
      expect(await env.db.getNextCrudTransaction(), isNull, reason: 'sent once the server is back');
      expect(env.server.sent('/rest/v1/feeds', method: 'POST'), hasLength(2));
    });

    test('no connection keeps the change for the next try', () async {
      await drainQueue(env.db);
      env.server.on('POST', '/rest/v1/feeds', (_) => throw http.ClientException('offline'));
      await TrackingRepository(env.db).saveFeed(baby, type: FeedType.bottleFormula, at: DateTime(2026, 10, 26, 8), amountMl: 60);
      await expectLater(connector.uploadData(env.db), throwsA(anything));
      expect(await env.db.getNextCrudTransaction(), isNotNull);
    });

    test('an expired login (not a data error) keeps the change', () async {
      await drainQueue(env.db);
      rejectWrites(env.server, 'feeds', 'PGRST301', status: 401);
      await TrackingRepository(env.db).saveFeed(baby, type: FeedType.bottleFormula, at: DateTime(2026, 10, 26, 8), amountMl: 60);
      await expectLater(connector.uploadData(env.db), throwsA(anything));
      expect(await env.db.getNextCrudTransaction(), isNotNull);
    });

    for (final (code, what) in [
      ('22P02', 'bad data'),
      ('23503', 'a missing parent row'),
      ('23505', 'a duplicate'),
      ('23514', 'a failed check'),
      ('42501', 'no permission'),
    ]) {
      test('a change rejected for $what ($code) is dropped, and later changes still upload', () async {
        await drainQueue(env.db);
        acceptWrites(env.server);
        rejectWrites(env.server, 'feeds', code);
        final tracking = TrackingRepository(env.db);
        await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: DateTime(2026, 10, 26, 8), amountMl: 60);
        await tracking.saveDiaper(baby, at: DateTime(2026, 10, 26, 9), wet: true, dirty: false);

        await connector.uploadData(env.db); // the feed: rejected, dropped
        await connector.uploadData(env.db); // the diaper: goes through
        expect(await env.db.getNextCrudTransaction(), isNull, reason: 'nothing stuck in the queue');
        expect(env.server.sent('/rest/v1/diapers', method: 'POST'), hasLength(1));
        // The phone still has the feed; only the upload was given up.
        expect(await env.db.getAll('SELECT id FROM feeds'), hasLength(1));
      });
    }

    test('everything queued offline goes up in order once online', () async {
      await drainQueue(env.db);
      acceptWrites(env.server);
      final tracking = TrackingRepository(env.db);
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: DateTime(2026, 10, 26, 8), amountMl: 60);
      await tracking.saveDiaper(baby, at: DateTime(2026, 10, 26, 9), wet: true, dirty: false);
      await tracking.addSleep(baby, kind: SleepKind.nap, startedAt: DateTime(2026, 10, 26, 10));
      await uploadAll(connector, env.db);
      expect(env.server.sent('/rest/v1/').map((r) => r.path), ['/rest/v1/feeds', '/rest/v1/diapers', '/rest/v1/sleeps']);
    });
  });

  group('credentials for PowerSync', () {
    // PowerSync refuses credentials without its URL, which only the real
    // build has (env/*.json). Run with --dart-define=POWERSYNC_URL=https://powersync.test
    // to include this check.
    test('signed in: the login token and user id', skip: Env.powersyncUrl.isEmpty ? 'needs POWERSYNC_URL' : false, () async {
      final credentials = await connector.fetchCredentials();
      expect(credentials, isNotNull);
      expect(credentials!.token, 'test-access-token');
      expect(credentials.userId, testUserId);
    });

    test('signed out: none, so nothing syncs', () async {
      final signedOut = await FlowEnv.open(signedIn: false, baby: false);
      addTearDown(signedOut.close);
      expect(await SupabaseConnector(signedOut.supabase).fetchCredentials(), isNull);
    });
  });
}
