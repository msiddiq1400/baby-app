import 'dart:convert';
import 'dart:io';

import 'package:baby_app/data/content.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> load(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// Every {en, ur, ur_Latn} map anywhere in [json] must have all three, non-empty.
void expectAllTranslated(Object? json, String path) {
  if (json is Map) {
    if (json.containsKey('en')) {
      for (final lang in const ['en', 'ur', 'ur_Latn']) {
        expect(
          (json[lang] as String?)?.trim(),
          isNotEmpty,
          reason: '$path is missing "$lang"',
        );
      }
      return;
    }
    json.forEach((k, v) => expectAllTranslated(v, '$path.$k'));
  } else if (json is List) {
    for (var i = 0; i < json.length; i++) {
      expectAllTranslated(json[i], '$path[$i]');
    }
  }
}

void main() {
  test('food guide parses, ids are unique, allergens are known', () {
    final json = load('assets/foods.json');
    final guide = FoodGuide.fromJson(json);
    expect(guide.foods.length, greaterThan(30));
    expect(guide.foods.map((f) => f.id).toSet().length, guide.foods.length);
    for (final f in guide.foods) {
      if (f.allergen != null) {
        expect(guide.allergens, contains(f.allergen), reason: f.id);
      }
    }
    // Every allergen in the tracker has at least one food to try it with.
    for (final a in guide.allergens.keys) {
      expect(guide.foods.any((f) => f.allergen == a), isTrue, reason: a);
    }
    expect(guide.food('honey')!.fromMonths, 12);
    expectAllTranslated(json, 'foods');

    // Recipes: each age stage covered, and every food and allergen exists.
    expect(guide.recipes.length, greaterThanOrEqualTo(15));
    expect({for (final r in guide.recipes) r.fromMonths}, containsAll([6, 7, 10]));
    expect(guide.recipes.map((r) => r.id).toSet().length, guide.recipes.length);
    for (final r in guide.recipes) {
      for (final f in r.foods) {
        expect(guide.food(f), isNotNull, reason: '${r.id}: $f');
        // A recipe never uses a food before the age it's allowed.
        expect(guide.food(f)!.fromMonths, lessThanOrEqualTo(r.fromMonths), reason: '${r.id}: $f');
      }
      for (final a in r.allergens) {
        expect(guide.allergens, contains(a), reason: '${r.id}: $a');
      }
      expect(r.steps, isNotEmpty);
    }
    expect(guide.vegFirst, isNotNull);
  });

  test('milestone guide parses, ids are unique, ages ascend', () {
    final json = load('assets/milestones.json');
    final guide = MilestoneGuide.fromJson(json);
    final ids = [for (final a in guide.ages) ...a.milestones.map((m) => m.id)];
    expect(ids.toSet().length, ids.length);
    final months = guide.ages.map((a) => a.months).toList();
    expect(months, [...months]..sort());
    for (final a in guide.ages) {
      for (final m in a.milestones) {
        expect(
          const ['social', 'language', 'cognitive', 'movement'],
          contains(m.area),
          reason: m.id,
        );
      }
    }
    expectAllTranslated(json, 'milestones');
  });
}
