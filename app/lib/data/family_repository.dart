import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers.dart';

class FamilyMember {
  const FamilyMember({required this.userId, required this.name, required this.isOwner, required this.isMe});

  final String userId;
  final String name;
  final bool isOwner;
  final bool isMe;
}

/// Family membership and invites. These go straight to the server (not the
/// phone's database), so they need an internet connection.
class FamilyRepository {
  FamilyRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<FamilyMember>> members(String familyId) async {
    final rows = await _supabase.rpc<List<dynamic>>('family_member_list', params: {'target_family': familyId});
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        FamilyMember(
          userId: r['user_id'] as String,
          name: (r['display_name'] as String?) ?? '',
          isOwner: r['role'] == 'owner',
          isMe: r['is_me'] as bool,
        ),
    ];
  }

  /// A new 6-character code, valid for 7 days. Owners only.
  Future<String> createInvite(String familyId) =>
      _supabase.rpc<String>('create_family_invite', params: {'target_family': familyId});

  /// Joins the family behind [code]. Throws [InvalidInviteException] for a
  /// wrong, used or expired code.
  Future<void> acceptInvite(String code) async {
    try {
      await _supabase.rpc<dynamic>('accept_family_invite', params: {'invite_code': code});
    } on PostgrestException catch (e) {
      if (e.message.contains('invalid_invite')) throw const InvalidInviteException();
      rethrow;
    }
  }

  /// Removes someone (owners), or leaves the family (anyone, themselves).
  Future<void> removeMember(String familyId, String userId) =>
      _supabase.from('family_members').delete().eq('family_id', familyId).eq('user_id', userId);

  /// Deletes the signed-in user's login, and every family only they belong
  /// to. Shared families keep their data (see delete_my_account in the
  /// migrations). The caller must sign out afterwards.
  Future<void> deleteMyAccount() async {
    await _deleteSoloFamilyPhotos();
    await _supabase.rpc<dynamic>('delete_my_account');
  }

  /// Photo files are in Storage, which the database function can't reach:
  /// delete the ones of families that are about to go (only this user in
  /// them) first.
  Future<void> _deleteSoloFamilyPhotos() async {
    final me = _supabase.auth.currentUser?.id;
    if (me == null) return;
    final mine = await _supabase.from('family_members').select('family_id').eq('user_id', me);
    for (final row in mine) {
      final familyId = row['family_id'] as String;
      final members = await _supabase.from('family_members').select('user_id').eq('family_id', familyId);
      if (members.length != 1) continue;
      final photos = await _supabase.from('photos').select('id').eq('family_id', familyId);
      if (photos.isEmpty) continue;
      await _supabase.storage.from('photos').remove([for (final p in photos) '$familyId/${p['id']}.jpg']);
    }
  }
}

class InvalidInviteException implements Exception {
  const InvalidInviteException();
}

final familyRepositoryProvider = Provider((ref) => FamilyRepository(ref.watch(supabaseProvider)));

final familyMembersProvider = FutureProvider.autoDispose.family<List<FamilyMember>, String>(
  (ref, familyId) => ref.watch(familyRepositoryProvider).members(familyId),
);
