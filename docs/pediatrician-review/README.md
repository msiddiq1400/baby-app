# Pediatrician review pack

To-dos 21–23 and 49 (`todos.txt`). This is a document for a pediatrician to
mark up, so that every medical item in Palna can be confirmed or corrected.

| File | What it is |
|---|---|
| `palna-medical-review.docx` | The pack to send (A4, Word tables with a "Reviewer ✓ / ✗ / ?" and a "Change to / comment" column, page numbers). Print it or send it as is. |
| `palna-medical-review.md` | The same content as Markdown (easy to diff and read on GitHub). |
| `make_review_docx.py` | Builds both files from the app's sources. |
| `review_content.py` | The hand-written text: letter, each country's sources and open questions, explanations, where each string appears. |

Don't edit the `.md` or `.docx` by hand: both are regenerated.

## What's in the pack

Cover, a one-page letter, "Questions we most need answered", then:

1. Vaccine schedules for the 23 countries (405 doses), each with sources and open questions.
2. Optional RSV and flu reminders: wording, rules per country, a 23-country overview.
3. Medical wording parents see (fever, medicines, growth check thresholds and the
   WHO weight-gain table, symptoms, emergency signs, heat and dehydration,
   feeds / diapers / sleep ranges, breast milk storage, vaccine screen notes).
4. Emergency numbers per country.
5. Solids guide: guides, 36 foods, 15 recipes.
6. Milestones (86) and "ways to help" (28).

Then "General comments" and a sign-off. On 28 Oct 2026: 62 pages, 49 tables,
91 open questions.

## Regenerate

```
pip install --user python-docx
python docs/pediatrician-review/make_review_docx.py
```

Run it after any change to the medical content, and change `VERSION_DATE` in
`review_content.py` before sending a new version.

What the script reads directly (so the pack stays current):

| Content | Source |
|---|---|
| Vaccine rows and their `verified` flag | every `supabase/migrations/*.sql`, in order (inserts into `vaccine_schedule`, plus simple `update` / `delete` on it with `country_code` / `code` conditions) |
| RSV / flu rules and their "re-check" notes | `app/lib/core/optional_vaccines.dart` |
| Emergency numbers, the Pakistan "call now" number, hot-weather countries | `app/lib/core/emergency.dart` |
| Every string shown | `app/lib/l10n/app_en.arb` |
| Symptom list | `symptomCodes` in `app/lib/data/models.dart` |
| Fever rule | `app/lib/features/health/symptom_sheet.dart` |
| Growth check thresholds | `app/lib/features/growth/growth_check.dart`, `app/lib/core/who_growth.dart`, `app/lib/core/weight_velocity.dart`, `app/assets/who_weight_velocity.json` |
| Sleep ranges and awake windows | `app/lib/features/reports/report_stats.dart`, `app/lib/features/home/sleep_predictions.dart` |
| Foods, guides, recipes | `app/assets/foods.json` (from `app/tool/content/make_foods.py` + `recipes.py`) |
| Milestones | `app/assets/milestones.json` (from `app/tool/content/make_milestones.py`) |

Where the pack explains a rule in words (growth-check levels, RSV / flu logic,
weight-gain bands, PDF footer), the script checks the rule still looks the
same in the source. If not, it stops with `STOPPED: ...` naming what changed:
update the explanation in `make_review_docx.py` / `review_content.py`, then
re-run. It also stops when a country is added or removed, or a string it
quotes disappears.

`review_content.py` is NOT generated: per-country sources and open questions
(from `docs/vaccine-research-2026-10/`), the RSV / flu programme overview, the
letter and the "where it appears" notes are written by hand. Update them when
the research or the app changes. Rules for that file: plain clinical English,
no code / file / database words in anything the doctor reads.

## Feeding the doctor's answers back

Every item has an ID the doctor can refer to:

- vaccine rows `PK-1`, `GB-12` …; RSV / flu wording `O1` …; wording `W1` …;
  growth rules `G1` …; solids `S1` …, foods `F1` …, recipes `R1` …;
  milestones `M1` …, tips `T1` …
- open questions `PK-Q1`, `RSV-Q3`, `W-Q1` … (these are `PK-1`, `RSV-3`,
  `W-1` in `review_content.py`; the pack adds the `Q`).

1. Transcribe the marked pack into a list, one line per item that isn't a
   plain ✓, e.g. `BD-Q1: 18 weeks (DGHS 2026 card)`, `IT-4 ✗ 3 months`,
   `W1 ? add 3–6 months`. Note who reviewed it and the date. Keep the scanned
   or returned pack (outside git if it has personal details).
2. Give the list to Claude. Each kind of answer goes to its source:
   - vaccine rows: a NEW migration (never edit applied ones) with the
     corrected rows, then `update public.vaccine_schedule set verified = true`
     for every row the doctor confirmed. **After the review Claude marks the
     schedules as verified (to-do 21),** and this pack then shows "Yes" in the
     Verified column. (The app itself doesn't read the flag yet: it shows the
     same "always confirm with your doctor" note for every schedule.);
   - RSV / flu rules: `app/lib/core/optional_vaccines.dart`;
   - wording: `app/lib/l10n/app_en.arb`, and the same change in the Urdu and
     Roman Urdu files (to-do 24);
   - growth thresholds: `growth_check.dart` / `weight_velocity.dart`;
   - emergency numbers: `emergency.dart`;
   - foods, recipes: `app/tool/content/make_foods.py` / `recipes.py`, then
     regenerate `app/assets/foods.json`; milestones: `make_milestones.py`,
     then regenerate `app/assets/milestones.json`.
3. Answered open questions: remove or rewrite them in `review_content.py`
   (and note the answer in `docs/vaccine-research-2026-10/` where it's a
   vaccine source). Re-run the script so the next version of the pack shows
   the corrected content.
4. Close to-dos 21–23 and 49 once the corrections are released.
