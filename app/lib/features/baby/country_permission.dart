import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/family_repository.dart';
import '../../data/models.dart';

/// Whether the signed-in person may set [baby]'s country (todos.txt Q1).
///
/// The person who added the baby always may. If they have left the family or
/// deleted their account, a family owner may (that needs the member list, so
/// it's only known online). Everyone else, or while that's unknown: no. The
/// server enforces the same rule.
bool canChangeBabyCountry(Baby baby, {required String? me, List<FamilyMember>? members}) {
  if (me == null) return false;
  if (baby.createdBy == me) return true;
  if (members == null) return false;
  final creatorGone = baby.createdBy == null || !members.any((m) => m.userId == baby.createdBy);
  final iAmOwner = members.any((m) => m.isMe && m.isOwner);
  return creatorGone && iAmOwner;
}

/// `ref.watch(canChangeBabyCountryProvider(baby))`.
final canChangeBabyCountryProvider = Provider.autoDispose.family<bool, Baby>((ref, baby) {
  final me = ref.watch(currentUserIdProvider);
  if (me != null && baby.createdBy == me) return true;
  final members = ref.watch(familyMembersProvider(baby.familyId)).value;
  return canChangeBabyCountry(baby, me: me, members: members);
});
