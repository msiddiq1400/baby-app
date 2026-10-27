# Vaccine schedules: Australia (AU), Ireland (IE), Netherlands (NL)

Researched 27 Oct 2026 for Palna. Everything here still needs the pediatrician's review.
Codes follow one style across all three countries (`6IN1-n`, `PCV-n`, `PCV-B`, `ROTA-n`, `MENB-n`, `MMR-n`, ...).

---

## Australia (AU)

### 1. Routine schedule (National Immunisation Program, all children)

```sql
  ('AU', 'HEPB-0',    'Hepatitis B',                                         'Birth dose', 0,  'day',   10, 'Australia NIP 2026'),
  ('AU', '6IN1-1',    '6-in-1 (DTPa-HepB-IPV-Hib)',                          'Dose 1',     6,  'week',  20, 'Australia NIP 2026'),
  ('AU', 'PCV-1',     'Pneumococcal (PCV20, Prevenar 20)',                   'Dose 1',     6,  'week',  21, 'Australia NIP 2026'),
  ('AU', 'ROTA-1',    'Rotavirus (oral drops)',                              'Dose 1',     6,  'week',  22, 'Australia NIP 2026'),
  ('AU', '6IN1-2',    '6-in-1 (DTPa-HepB-IPV-Hib)',                          'Dose 2',     4,  'month', 30, 'Australia NIP 2026'),
  ('AU', 'PCV-2',     'Pneumococcal (PCV20, Prevenar 20)',                   'Dose 2',     4,  'month', 31, 'Australia NIP 2026'),
  ('AU', 'ROTA-2',    'Rotavirus (oral drops)',                              'Dose 2',     4,  'month', 32, 'Australia NIP 2026'),
  ('AU', '6IN1-3',    '6-in-1 (DTPa-HepB-IPV-Hib)',                          'Dose 3',     6,  'month', 40, 'Australia NIP 2026'),
  ('AU', 'MENACWY-1', 'Meningococcal ACWY (MenACWY)',                        null,         12, 'month', 50, 'Australia NIP 2026'),
  ('AU', 'PCV-B',     'Pneumococcal (PCV20, Prevenar 20)',                   'Booster',    12, 'month', 51, 'Australia NIP 2026'),
  ('AU', 'MMR-1',     'MMR (measles, mumps, rubella)',                       'Dose 1',     12, 'month', 52, 'Australia NIP 2026'),
  ('AU', 'DTAP-B',    'Whooping cough booster (DTPa: diphtheria, tetanus, pertussis)', 'Booster', 18, 'month', 60, 'Australia NIP 2026'),
  ('AU', 'MMRV-1',    'MMRV (measles, mumps, rubella, chickenpox; 2nd MMR + 1st chickenpox)', null, 18, 'month', 61, 'Australia NIP 2026'),
  ('AU', 'HIB-B',     'Hib (Haemophilus influenzae type b)',                 'Booster',    18, 'month', 62, 'Australia NIP 2026'),
  ('AU', 'DTAP-IPV',  '4-in-1 (DTPa-IPV: diphtheria, tetanus, pertussis, polio)', 'Booster', 48, 'month', 70, 'Australia NIP 2026'),
```

14 doses in total.

### 2. Sources and notes

- **NIP schedule**, Dept of Health, Disability and Ageing, "current from 9 October 2026", published 14 Oct 2026:
  https://www.health.gov.au/sites/default/files/2026-10/national-immunisation-program-schedule_0.pdf
  and https://www.health.gov.au/topics/immunisation/when-to-get-vaccinated/national-immunisation-program-schedule
  **I could not open health.gov.au from here** (every request timed out). I took the doses from two copies of the same NIP schedule that I could open:
  - **NSW Health schedule "Updated October 2026"**, which lists only NIP-funded vaccines: https://www.health.nsw.gov.au/schedule (page "current as at 1 Oct 2026") and https://www.health.nsw.gov.au/immunisation/Publications/nsw-immunisation-schedule.pdf
  - **NCIRS "Recommended sites for childhood vaccination"**, last updated 5 Aug 2026: https://ncirs.org.au/media/1181
  - Both match each other and match the search-result text of the federal PDF (e.g. "2 months (can be given from 6 weeks of age)").
- **First visit age.** The national schedule labels the first visit "2 months (can be given from 6 weeks)". NSW labels it "6 weeks". Following the earliest-age rule, I used **6 weeks**. If the reviewer prefers the national label, change it to `2, 'month'`.
- **Rotavirus (Rotarix) age limits.** Dose 1 must be given at 6–14 weeks and dose 2 at 10–24 weeks. Late doses are not given, so the app could warn about this.
- **Recent change.** From 1 Sep 2025, Prevenar 20 replaced Prevenar 13. Non-Indigenous children get 2 doses plus a booster (2, 4 and 12 months). Aboriginal and Torres Strait Islander children get 4 doses (2, 4, 6 and 12 months), and Pneumovax 23 was dropped. Earlier 2026 changes I found were adult-only (Arexvy RSV for 75+ from May 2026, Capvaxive for adults from Jul 2026). I could not see what the 9 Oct 2026 revision changed. The NSW October 2026 schedule shows no childhood change.
- **Left out because they are risk-group or Indigenous-only on the NIP:**
  - MenB (Bexsero) at 6 weeks, 4 months and 12 months for Aboriginal and Torres Strait Islander children, plus an extra 6-month dose for some medical risk conditions
  - PCV at 6 months for Aboriginal and Torres Strait Islander children and for medical risk conditions
  - Hepatitis A for Aboriginal and Torres Strait Islander children in NT, Qld, SA and WA (18 months and 4 years)
  - Extra hepatitis B dose for preterm or low-birth-weight babies (ACT, NT, Qld, WA)
- **State-funded MenB for all infants (not NIP, so not in the rows):**
  - **SA** since 2018 (6 weeks, 4 months, 12 months)
  - **Qld** since 2024
  - **NT** since 2025 (6 weeks to 12 months; catch-up to age 2 until end of 2026)
  - **Tasmania** from 1 Jul 2026 (6 weeks, 4 months, 12 months; catch-up for children under 2): https://www.premier.tas.gov.au/latest-news/2026/july/free-meningococcal-b-vaccines-now-available-for-tasmanian-infants
  - NCIRS confirms "all children (NT, Qld, SA, Tas)".
  - The app could offer optional MenB rows per state later. Same dose ages as the Indigenous NIP MenB: 6 weeks, 4 months, 12 months.
- **Paracetamol.** Prophylactic paracetamol is recommended with Bexsero for children under 2. This only matters if MenB is added.
- **Catch-up.** All people under 20 get free catch-up of missed NIP vaccines. This is useful for families arriving from Pakistan.

### 3. RSV for infants — not universal; maternal vaccine is national, infant antibody is state-run

- **National (NIP): maternal Abrysvo.** Offered to all pregnant women, year-round, since 3 Feb 2025. The NSW schedule says "from 28 weeks of gestation for each pregnancy"; the recommended window is 28–36 weeks.
- **Infant nirsevimab (Beyfortus): state and territory funded, no national programme.** The NCIRS summary (last updated 17 Apr 2026) calls it a state- and territory-funded programme:
  https://ncirs.org.au/respiratory-syntactical-virus-rsv-immunisation/state-and-territory-nirsevimab-beyfortus-infant
  - **Who gets it (most states):** infants whose mother did not get the RSV vaccine in pregnancy, or got it less than 2 weeks before birth, and infants with risk conditions. Ideally given before leaving hospital. Babies of vaccinated mothers are not routinely included.
  - **Year-round programmes:** ACT, NSW, NT, Qld.
  - **Seasonal programmes:** SA 1 Apr–30 Sep 2026; Tas 1 Apr–31 Oct 2026; Vic mid-Mar–30 Sep 2026; WA 1 Apr–30 Sep 2026 (Kimberley and Pilbara year-round).
  - **WA is closest to universal:** babies born 1 Oct 2025–31 Mar 2026 got a pre-season catch-up dose 1 Apr–30 Jun, regardless of maternal vaccination.
  - **Second season (up to 24 months):** for some risk-condition children. In ACT and Vic, Aboriginal and Torres Strait Islander children aged 8 to under 24 months are also covered.
- **Suggestion for the app:**
  - Add an AU pregnancy reminder for Abrysvo at 28 weeks.
  - Add an infant prompt only when the mother was not vaccinated (or less than 2 weeks before birth): "ask about nirsevimab; the rules depend on your state".
  - The southern-hemisphere season is roughly April/May to September/October.
- **Also on the national schedule for pregnancy:** pertussis (Boostrix or Adacel) at 20–32 weeks in each pregnancy, and flu in any trimester.

### 4. Flu for young children — yes

- **Who:** free on the NIP for **all children aged 6 months to under 5 years**, every year (NSW Oct 2026 schedule; NCIRS). Also free for Aboriginal and Torres Strait Islander people from 6 months and for children with risk conditions from 6 months.
- **When:** each year when the season's vaccine arrives, usually from March/April, ideally before the June–September peak.
- **First time:** children aged 6 months to under 9 years who have never had a flu vaccine need **2 doses at least 4 weeks apart**, then 1 dose a year after that.
- **Not free for all children:** the nasal spray (FluMist) is registered for ages 2 and up, but it is not funded for everyone.

### 5. Emergency numbers

| Number | Service type | Notes |
|---|---|---|
| **000** | `all` | Ambulance, police, fire. Confirmed. |
| 112 | `all` | Also works from mobile phones. Optional: 000 is the number to teach. |
| 106 | `all` | Text-based relay for deaf or speech-impaired callers. Optional. |
| **13 11 26** | `poison` | Poisons Information Centre. 24/7, national. |
| **1800 022 222** | `nurseLine` | healthdirect, 24/7 registered nurse line. Vic uses the same number (Nurse-On-Call). |
| **1800 882 436** | `nurseLine` | Pregnancy, Birth and Baby helpline (maternal child health nurses), 7am–midnight every day. Parent-relevant; please verify the hours. |

No new service type is needed.

**Confidence for AU: medium-high.** The doses agree across NSW Health (Oct 2026) and NCIRS (Aug 2026), but I could not open the federal PDF itself. The 6-week vs 2-month first visit is a judgement call.

---

## Ireland (IE)

### 1. Routine schedule (HSE Primary Childhood Immunisation Programme, babies born on or after 1 Oct 2024)

```sql
  ('IE', '6IN1-1',   '6-in-1 (DTaP-IPV-Hib-HepB)',                          'Dose 1',  2,  'month', 10, 'HSE Ireland 2026'),
  ('IE', 'PCV-1',    'Pneumococcal (PCV)',                                  'Dose 1',  2,  'month', 11, 'HSE Ireland 2026'),
  ('IE', 'MENB-1',   'MenB (meningococcal B)',                              'Dose 1',  2,  'month', 12, 'HSE Ireland 2026'),
  ('IE', 'ROTA-1',   'Rotavirus (oral drops)',                              'Dose 1',  2,  'month', 13, 'HSE Ireland 2026'),
  ('IE', '6IN1-2',   '6-in-1 (DTaP-IPV-Hib-HepB)',                          'Dose 2',  4,  'month', 20, 'HSE Ireland 2026'),
  ('IE', 'MENB-2',   'MenB (meningococcal B)',                              'Dose 2',  4,  'month', 21, 'HSE Ireland 2026'),
  ('IE', 'ROTA-2',   'Rotavirus (oral drops)',                              'Dose 2',  4,  'month', 22, 'HSE Ireland 2026'),
  ('IE', '6IN1-3',   '6-in-1 (DTaP-IPV-Hib-HepB)',                          'Dose 3',  6,  'month', 30, 'HSE Ireland 2026'),
  ('IE', 'PCV-2',    'Pneumococcal (PCV)',                                  'Dose 2',  6,  'month', 31, 'HSE Ireland 2026'),
  ('IE', 'MMR-1',    'MMR (measles, mumps, rubella)',                       'Dose 1',  12, 'month', 40, 'HSE Ireland 2026'),
  ('IE', 'MENB-B',   'MenB (meningococcal B)',                              'Booster', 12, 'month', 41, 'HSE Ireland 2026'),
  ('IE', 'VAR-1',    'Chickenpox (varicella)',                              'Dose 1',  12, 'month', 42, 'HSE Ireland 2026'),
  ('IE', '6IN1-B',   '6-in-1 (DTaP-IPV-Hib-HepB)',                          'Booster', 13, 'month', 50, 'HSE Ireland 2026'),
  ('IE', 'MENC-1',   'MenC (meningococcal C)',                              null,      13, 'month', 51, 'HSE Ireland 2026'),
  ('IE', 'PCV-B',    'Pneumococcal (PCV)',                                  'Booster', 13, 'month', 52, 'HSE Ireland 2026'),
  ('IE', 'DTAP-IPV', '4-in-1 (DTaP-IPV: diphtheria, tetanus, whooping cough, polio)', 'Booster', 48, 'month', 60, 'HSE Ireland 2026'),
  ('IE', 'MMRV-2',   'MMRV (measles, mumps, rubella, chickenpox)',          'Dose 2',  48, 'month', 61, 'HSE Ireland 2026'),
```

17 doses in total.

### 2. Sources and notes

- **HSE "Vaccines for your child"** (page last reviewed 28 Aug 2024, next review Aug 2027; its table already shows the post-Oct-2024 schedule): https://www2.hse.ie/babies-children/vaccines-your-child/
  - 2 months: 6-in-1, PCV, MenB, rotavirus
  - 4 months: 6-in-1, MenB, rotavirus
  - 6 months: 6-in-1, PCV
  - 12 months: MMR, MenB, chickenpox
  - 13 months: 6-in-1, MenC, PCV
  - 4–5 years (junior infants): 4-in-1, MMRV
- **HSE NIO "Supporting Information for Vaccinations in General Practice"**, v13, applicable from Aug 2025: https://assets.hse.ie/media/documents/PCI_Supporting_Information_for_Vaccinations_in_General_Practice.pdf
  It confirms that the 4th 6-in-1 at 13 months replaces Hib/MenC and that the 6-month MenC is removed.
- **Chickenpox:** "Free chickenpox vaccination recommended for babies born on or after 1 October 2024" (HSE news): https://www.hse.ie/eng/health/immunisation/news/free-chickenpox-vaccination-recommended-for-babies-born-on-or-after-1-october-2024.html
  HSE news also says "available for babies turning 12 months on or after 1 October 2025".
- **Older schedule:** babies born before 1 Oct 2024 had MenC at 6 months, Hib/MenC + PCV at 13 months, and no varicella: https://www.hse.ie/eng/health/immunisation/pubinfo/pcischedule/babypre011024/
  If the app has babies born before Oct 2024 (now older than 2), they are on that schedule. For app purposes they are past the infant doses; only the 4–5-year doses differ (4-in-1 + MMR instead of MMRV).
- **Junior infants (4–5 years) doses:**
  - These are given **in school** in junior infants (first school year, age 4–5), or by the GP in Sligo, Leitrim and Donegal.
  - I included them at 48 months as the pre-school-booster equivalent. In practice the parent may get them only once the child is in school (age 4–5). A reviewer could set 54 or 60 months instead.
  - The MMRV at 4–5 years for the post-Oct-2024 cohort comes from the HSE parent page. That cohort only reaches junior infants around 2028–29, so this is **planned, not yet delivered**. Please re-check closer to then.
- **Not in the programme:** no hepatitis B birth dose for all babies (only babies of HBsAg-positive mothers), and no BCG (stopped 2015).
- **Ages are given as months** (2, 4, 6, 12, 13 months), not weeks.

### 3. RSV for infants — yes, universal seasonal nirsevimab programme (3rd season, 2026/27)

Source: HSE "RSV immunisation for babies", last reviewed 14 Aug 2026: https://www2.hse.ie/conditions/rsv/immunisation/ (also https://nmh.ie/newborn-care/rsv-immunisation/)

- **Product:** nirsevimab (Beyfortus), one injection in the thigh. It protects for about 5 months.
- **Babies born during the season (1 Sep 2026 – 28 Feb 2027):** offered free in the maternity hospital soon after birth, before discharge. Babies born at home also get it via the maternity hospital (ask the midwife).
- **Babies born before the season (1 Mar 2026 – 31 Aug 2026):** catch-up **at the GP** from 1 Sep 2026, "as early in the season as possible". It can be given with routine vaccines. In effect this covers babies under about 6 months at the season start.
- **High-risk babies under 24 months** (e.g. born before 30 weeks, heart or lung disease, weak immune system) are referred by a paediatrician to the HSE team for a second-season dose.
- **Season:** September to February.
- **Maternal RSV vaccine (Abrysvo):** the HSE does **not** offer it in pregnancy. The infant antibody is the HSE's approach.
- **App rule:** a newborn born Sep–Feb gets "RSV antibody at birth (hospital)". A baby born Mar–Aug gets "RSV antibody at GP from 1 September".

### 4. Flu for young children — yes, from age 2

Sources:
- HSE children's flu vaccine page: https://www2.hse.ie/conditions/flu/childrens-flu-vaccine/
- HSE LAIV toolkit 2026/27: https://assets.hse.ie/media/documents/Toolkit_LAIV_Primary_Care_2026_2027.pdf
- HSE flu FAQ 2026/27: https://assets.hse.ie/media/documents/Influenza_FAQ_2026_2027.pdf

Details:
- **Who:** free **nasal spray (LAIV) for all children aged 2–17**, at the GP, pharmacy or (for school children) in school.
- **When:** the 2026/27 programme started 8 Oct 2026. The season runs October to end of April.
- **Doses:**
  - Healthy children: **1 dose**, even the first time.
  - At-risk children aged 2–8 having flu vaccine for the first time (or with unknown history): 2 doses at least 4 weeks apart.
- **Under 2:** only babies aged 6 months and over in risk groups, by injection. Not universal.

### 5. Emergency numbers

| Number | Service type | Notes |
|---|---|---|
| **112** | `all` | Confirmed. |
| **999** | `all` | Works identically to 112. Irish people mostly say 999, so worth adding. |
| **01 809 2166** | `poison` | National Poisons Information Centre, public line, **8am–10pm daily**, aimed at parents of young children. Outside those hours: GP out-of-hours service or emergency department. The 24/7 lines 01 837 9964 / 01 809 2566 are for healthcare professionals only. |

- **No national nurse line.** HSE Live (1800 700 700) gives health service information, not clinical triage, so it is not a `nurseLine`.
- **Out-of-hours GP co-ops** (e.g. SouthDoc, Caredoc, D-Doc) are regional, with no single number.

**Confidence for IE: high** for the infant schedule up to 13 months (HSE parent page and NIO GP document agree). **Medium** for the 4–5-year rows (MMRV is planned for a future cohort, given in school, and the age is approximate).

---

## Netherlands (NL)

### 1. Routine schedule (Rijksvaccinatieprogramma, default = mother had the 22-week whooping-cough shot)

```sql
  ('NL', 'ROTA-1',    'Rotavirus (oral drops)',                             'Dose 1',  6,  'week',  10, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', '6IN1-1',    '6-in-1 (DKTP-Hib-HepB: DTaP-IPV-Hib-HepB)',          'Dose 1',  3,  'month', 20, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'PCV-1',     'Pneumococcal (PCV)',                                 'Dose 1',  3,  'month', 21, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'ROTA-2',    'Rotavirus (oral drops)',                             'Dose 2',  3,  'month', 22, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', '6IN1-2',    '6-in-1 (DKTP-Hib-HepB: DTaP-IPV-Hib-HepB)',          'Dose 2',  5,  'month', 30, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'PCV-2',     'Pneumococcal (PCV)',                                 'Dose 2',  5,  'month', 31, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', '6IN1-B',    '6-in-1 (DKTP-Hib-HepB: DTaP-IPV-Hib-HepB)',          'Booster', 12, 'month', 40, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'PCV-B',     'Pneumococcal (PCV)',                                 'Booster', 12, 'month', 41, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'MMR-1',     'MMR (BMR: measles, mumps, rubella)',                 'Dose 1',  14, 'month', 50, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'MENACWY-1', 'MenACWY (meningococcal ACWY)',                       null,      14, 'month', 51, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'MMR-2',     'MMR (BMR: measles, mumps, rubella)',                 'Dose 2',  36, 'month', 60, 'RIVM Rijksvaccinatieprogramma 2026'),
  ('NL', 'DTAP-B',    '3-in-1 booster (DKT: diphtheria, whooping cough, tetanus)', 'Booster', 60, 'month', 70, 'RIVM Rijksvaccinatieprogramma 2026'),
```

12 doses in total (default schedule).

**Babies whose mother did NOT get the 22-week shot**, or was vaccinated less than 2 weeks before birth, or in other special situations decided by the youth doctor, get **one extra 6-in-1 dose at 6–9 weeks**. The schedule is then 6 weeks, 3, 5 and 12 months. Add this row only for them, for example via a "mother had 22-week shot? yes/no/unknown" flag:

```sql
  ('NL', '6IN1-0',    '6-in-1 (DKTP-Hib-HepB), extra dose if mother not vaccinated in pregnancy', 'Extra dose', 6, 'week', 11, 'RIVM Rijksvaccinatieprogramma 2026'),
```

That gives 13 doses for these babies. With the flag "unknown", it is safer to show the extra dose as "ask your consultatiebureau".

### 2. Sources and notes

- **RVP vaccinatieschema:** https://rijksvaccinatieprogramma.nl/vaccinaties/vaccinatieschema
  The schedule image is dated Aug 2025; the page has no date. It lists:

  | Age | Vaccines |
  |---|---|
  | 0–2 weeks | RSV shot |
  | 6–9 weeks | Rotavirus (dose 1), plus 6-in-1 only if mother not vaccinated |
  | 3 months | Rotavirus (dose 2), 6-in-1, PCV |
  | 5 months | 6-in-1, PCV |
  | 12 months | 6-in-1, PCV |
  | 14 months | MMR, MenACWY |
  | 3 years | MMR (dose 2) |
  | 5 years | DKT |
  | 10 years | HPV |
  | 14 years | DTP, MenACWY |

- **Changes from 2025** (RIVM news, 11 Sep 2024): https://www.rivm.nl/nieuws/veranderingen-vaccinatieschema-kinderen-2025
  - Infant booster moved from 11 to **12 months** (from birth cohort 2024)
  - MMR-2 moved from 9 years to **3 years** (for children born from 2016; those born 2016–2021 catch up at 5–9)
  - DKTP at 4 years became **DKT at 5 years** (no polio)
  - DTP moved from 9 to **14 years**

  Older apps and websites still show 11 months, 4 years and 9 years. Make sure the app uses the new ages.
- **RVP schedule with intervals 2026** (I could not download it): https://rijksvaccinatieprogramma.nl/sites/default/files/2025-12/Schema-Rijksvaccinatieprogramma-met-intervallen-2026.pdf
- **Rotavirus** has been in the RVP for all babies since 2024. There are 2 oral doses, at 6–9 weeks and at 3 months. Like Rotarix elsewhere, dose 1 must be given early; the consultatiebureau manages this.
- **Hepatitis B birth dose** is only for babies of HBsAg-positive mothers (risk group), so it is left out.
- **No routine MenB, chickenpox or flu** for children.
- **Dutch names.** Parents see BMR (= MMR), DKTP (= DTaP-IPV) and Pneu on their vaccination record, so I put the Dutch abbreviation in the names.
- **Doubt:** I did not confirm the exact earliest day of the "6–9 weeks" visit. RIVM sends an invitation; 6 weeks is the earliest.

### 3. RSV for infants — yes, universal nirsevimab programme in the RVP (started season 2025/26, not 2024/25)

Source: RVP "Addendum: RSV-immunisatie baby's" (Richtlijn Uitvoering 2026; 2026/27 changes adopted by the LRO on 4 Jun 2026): https://rijksvaccinatieprogramma.nl/professionals/richtlijnen/uitvoering/addendum-rsv-immunisatie-babys
Also: RIVM folder "Bescherm je baby tegen het RS-virus", and the schedule footnote above.

- **Product:** nirsevimab (Beyfortus), "RS-virusprik", free for all babies born on or after 1 Apr 2025.
- **Season:** 1 Oct – 31 Mar.
- **Babies born in season (Oct–Mar):** as soon as possible, **no later than 14 days after birth**. Given at home or at the consultatiebureau by the youth health team (JGZ), or on day 10 in hospital.
- **Babies born 1 Apr – 30 Sep (catch-up group):** one shot just before their first season. Preferred window **15 Sep – 15 Oct**, extendable to 14 Sep – 22 Oct 2026. The RIVM sends an invitation. For 2026 this means babies born Apr–Sep 2026, up to about 6 months old.
- **Declined in the first season:** babies may still get it in the second season if under 1 year.
- **High-risk children up to age 2** (stretchable to 2½): second-season dose on a paediatrician's referral, weight-based from 2026/27. In 2025/26 the upper age was 13; it is now 2.
- **Maternal RSV vaccine (Abrysvo):** **not** part of the RVP, as far as I found. If the mother had it privately, the baby can still get nirsevimab (individual decision). It is particularly advised if the vaccine was given less than 2 weeks before birth, the baby is preterm, and similar cases.
- **App rule:** born Oct–Mar: "RSV shot within 14 days of birth". Born Apr–Sep: "RSV shot mid-Sep to mid-Oct".

### 4. Flu for young children — no

- The Dutch national flu programme (Nationaal Programma Grieppreventie) covers people aged 60+ and medical risk groups only. Healthy children are not offered a flu vaccine. Children with risk conditions are vaccinated via the GP or specialist from 6 months.
- **Doubt:** I did not fetch a 2026 source page for this. It is based on the long-standing programme, and I found no sign of a change.

### 5. Emergency numbers

| Number | Service type | Notes |
|---|---|---|
| **112** | `all` | Confirmed. |
| 0900-8844 | `police` | Police non-emergency line. Optional. |

- **Huisartsenpost** (out-of-hours GP) is regional, with no national number. Parents should save their local huisartsenpost number. The app could offer a "my huisartsenpost" custom number; that would need a free-text/custom entry, not a new type.
- **No public poison line.** The NVIC (Nationaal Vergiftigingen Informatie Centrum) is for doctors, pharmacists and other professionals only. The public should call the huisarts or huisartsenpost, or 112 if the child is seriously ill.

**Confidence for NL: high** for the 2026 schedule (official RVP page, with the 2025 changes). **Medium** on the exact 6-week date for rotavirus and the extra 6-in-1 dose (the schedule says 6–9 weeks).
