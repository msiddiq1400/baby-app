// PowerSync marks its attachment API experimental; it's the supported way to
// sync files, so the warnings are silenced here.
// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/attachments/attachments.dart';
import 'package:powersync/attachments/io.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

// Monthly photos. The row (photos table) syncs like everything else; the
// picture is a JPEG file that PowerSync's attachment queue keeps on the
// phone and uploads to / downloads from the private Storage bucket "photos"
// at <family_id>/<photo id>.jpg, retrying while offline.

/// One photo per baby per month of age (the free plan; the server enforces
/// it too). A paid plan will allow more (todos.txt item 38).
class PhotoLimitException implements Exception {
  const PhotoLimitException();
}

class Photo {
  const Photo({required this.id, required this.ageMonth, this.caption, this.localPath});

  final String id;

  /// Completed months of age: 0 = newborn.
  final int ageMonth;
  final String? caption;

  /// The file on this phone; null until it has downloaded.
  final String? localPath;
}

const _bucket = 'photos';

/// Supabase Storage behind the attachment queue. Each attachment's metaData
/// is its family id, the first folder of the path.
class SupabasePhotoStorage implements RemoteStorage {
  SupabasePhotoStorage(this._supabase);

  final SupabaseClient _supabase;

  static String path(String familyId, String photoId) => '$familyId/$photoId.jpg';

  String _path(Attachment a) => '${a.metaData}/${a.filename}';

  @override
  Future<void> uploadFile(Stream<Uint8List> fileData, Attachment attachment) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in fileData) {
      bytes.add(chunk);
    }
    await _supabase.storage
        .from(_bucket)
        .uploadBinary(_path(attachment), bytes.takeBytes(), fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
  }

  @override
  Future<Stream<List<int>>> downloadFile(Attachment attachment) async =>
      Stream.value(await _supabase.storage.from(_bucket).download(_path(attachment)));

  @override
  Future<void> deleteFile(Attachment attachment) => _supabase.storage.from(_bucket).remove([_path(attachment)]);
}

/// The queue, created in main() with the folder the files live in.
AttachmentQueue createPhotoQueue(PowerSyncDatabase db, SupabaseClient supabase, String folder) => AttachmentQueue(
      db: db,
      remoteStorage: SupabasePhotoStorage(supabase),
      localStorage: IOLocalStorage(Directory(folder)),
      watchAttachments: () => db.watch('SELECT id, family_id FROM photos WHERE deleted_at IS NULL').map(
            (rows) => [
              for (final r in rows)
                WatchedAttachmentItem(id: r['id'] as String, fileExtension: 'jpg', metaData: r['family_id'] as String),
            ],
          ),
    );

class PhotoRepository {
  PhotoRepository(this._db, this._queue, this._folder, this._supabase);

  final PowerSyncDatabase _db;
  final AttachmentQueue _queue;
  final String _folder;
  final SupabaseClient _supabase;

  /// The baby's photos by month, with the local file once it's on the phone.
  Stream<List<Photo>> watchPhotos(String babyId) => _db
      .watch(
        'SELECT p.id, p.age_month, p.caption, a.local_uri FROM photos p '
        'LEFT JOIN attachments_queue a ON a.id = p.id '
        'WHERE p.baby_id = ? AND p.deleted_at IS NULL ORDER BY p.age_month',
        parameters: [babyId],
      )
      .map(
        (rows) => [
          for (final r in rows)
            Photo(
              id: r['id'] as String,
              ageMonth: r['age_month'] as int,
              caption: r['caption'] as String?,
              localPath: switch (r['local_uri']) {
                final String uri => '$_folder/$uri',
                _ => null,
              },
            ),
        ],
      );

  /// Saves [jpeg] as the photo for [ageMonth]; throws [PhotoLimitException]
  /// if that month already has one.
  Future<void> add(Baby baby, {required int ageMonth, required Uint8List jpeg, String? caption}) async {
    final taken = await _db.getOptional(
      'SELECT 1 FROM photos WHERE baby_id = ? AND age_month = ? AND deleted_at IS NULL',
      [baby.id, ageMonth],
    );
    if (taken != null) throw const PhotoLimitException();
    await _queue.saveFile(
      data: Stream.value(jpeg),
      mediaType: 'image/jpeg',
      fileExtension: 'jpg',
      metaData: baby.familyId,
      updateHook: (tx, attachment) => insertRow(tx, 'photos', {
        'id': attachment.id,
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'age_month': ageMonth,
        'caption': caption,
        'created_at': utcTimestamp(DateTime.now()),
      }),
    );
  }

  Future<void> updateCaption(String photoId, String? caption) =>
      updateRow(_db, 'photos', photoId, {'caption': caption});

  /// Hides the photo everywhere and deletes the file from the server.
  Future<void> delete(Baby baby, String photoId) async {
    Future<void> markDeleted(SqliteWriteContext tx) =>
        tx.execute('UPDATE photos SET deleted_at = ? WHERE id = ?', [utcTimestamp(DateTime.now()), photoId]);
    try {
      await _queue.deleteFile(attachmentId: photoId, updateHook: (tx, _) => markDeleted(tx));
    } on Exception {
      // Not in this phone's queue yet (never downloaded): mark the row and
      // remove the file directly.
      await _db.writeTransaction(markDeleted);
      await _supabase.storage.from(_bucket).remove([SupabasePhotoStorage.path(baby.familyId, photoId)]);
    }
  }

  /// Deletes every photo of a baby that is being deleted.
  Future<void> deleteAllFor(Baby baby) async {
    final rows = await _db.getAll('SELECT id FROM photos WHERE baby_id = ? AND deleted_at IS NULL', [baby.id]);
    for (final r in rows) {
      await delete(baby, r['id'] as String);
    }
  }
}

/// Overridden in main() with the started queue and its folder.
final photoQueueProvider = Provider<AttachmentQueue>((ref) => throw UnimplementedError('Overridden in main()'));
final photoFolderProvider = Provider<String>((ref) => throw UnimplementedError('Overridden in main()'));

final photoRepositoryProvider = Provider(
  (ref) => PhotoRepository(
    ref.watch(powerSyncProvider),
    ref.watch(photoQueueProvider),
    ref.watch(photoFolderProvider),
    Supabase.instance.client,
  ),
);

final photosProvider = StreamProvider.family<List<Photo>, String>(
  (ref, babyId) => ref.watch(photoRepositoryProvider).watchPhotos(babyId),
);
