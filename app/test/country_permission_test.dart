import 'package:flutter_test/flutter_test.dart';
import 'package:baby_app/data/family_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/baby/country_permission.dart';

Baby _baby(String? createdBy) =>
    Baby(id: 'b', familyId: 'f', name: 'Aisha', birthDate: DateTime(2026, 6, 1), createdBy: createdBy);

FamilyMember _m(String id, {bool owner = false, bool me = false}) =>
    FamilyMember(userId: id, name: id, isOwner: owner, isMe: me);

void main() {
  test('the person who added the baby may, even offline', () {
    expect(canChangeBabyCountry(_baby('me'), me: 'me'), isTrue);
  });

  test('another member may not', () {
    final members = [_m('me', me: true), _m('mum', owner: true)];
    expect(canChangeBabyCountry(_baby('mum'), me: 'me', members: members), isFalse);
  });

  test('an owner may not while the creator is still in the family', () {
    final members = [_m('me', owner: true, me: true), _m('dad')];
    expect(canChangeBabyCountry(_baby('dad'), me: 'me', members: members), isFalse);
  });

  test('creator left or deleted their account: the owner may, others may not', () {
    final owner = [_m('me', owner: true, me: true), _m('nani')];
    final caregiver = [_m('me', me: true), _m('mum', owner: true)];
    expect(canChangeBabyCountry(_baby('gone'), me: 'me', members: owner), isTrue);
    expect(canChangeBabyCountry(_baby(null), me: 'me', members: owner), isTrue);
    expect(canChangeBabyCountry(_baby('gone'), me: 'me', members: caregiver), isFalse);
  });

  test('unknown members (offline) or signed out: no', () {
    expect(canChangeBabyCountry(_baby('gone'), me: 'me'), isFalse);
    expect(canChangeBabyCountry(_baby('me'), me: null), isFalse);
  });
}
