# Vaccine schedules: Qatar, Kuwait, Oman, Bahrain (researched 27 Oct 2026)

## How this was researched

- **WHO/UNICEF Joint Reporting Form (JRF) schedule data.** This is the dataset behind immunizationdata.who.int, which each ministry reports itself. I pulled the **2025** reporting year (the latest; submitted in 2026) straight from WHO's public xMart API:
  `https://xmart-api-public.who.int/WIISE/AD_SCHEDULES?$filter=COUNTRY eq 'QAT'` (and KWT / OMN / BHR).
  It is the most current machine-readable official source for all four countries. The portal page itself renders in JavaScript only, so it can't be read directly.
- **Ministry documents cross-checked where reachable:**
  - Bahrain MOH: the live web page plus the 2025 PDF.
  - Kuwait MOH: the 2019 PDF, the ministerial decisions on the 2025 changes, and the RSV decision.
  - Oman: the Dec 2023 MOH rotavirus launch and a 2025 PLoS One paper by MOH authors.
- **Blocked sources:**
  - Qatar MOPH's schedule page (moph.gov.qa "Baby-Immunization") is behind a captcha, and so is its Wayback copy. **For Qatar the main source is WHO JRF 2025.**
  - moh.gov.kw refused connections, so the Kuwait 2025 PDF could not be opened.
- Ages use the source's unit. "End of 2nd month" (Kuwait) = 2 'month'. Ranges use the earliest age: 4–6 y = 48 months; 4–5 y = 48 months.

---

## Qatar (QA)

### 1. Routine schedule

```sql
  ('QA', 'BCG', 'BCG (tuberculosis)', null, 0, 'day', 10, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 11, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'HEXA-1', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'PCV-1', 'Pneumococcal conjugate (PCV20)', 'Dose 1', 2, 'month', 21, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 22, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'HEXA-2', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 30, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'PCV-2', 'Pneumococcal conjugate (PCV20)', 'Dose 2', 4, 'month', 31, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 32, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'HEXA-3', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 3', 6, 'month', 40, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'PCV-3', 'Pneumococcal conjugate (PCV20)', 'Dose 3', 6, 'month', 41, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 6, 'month', 42, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 50, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'VAR-1', 'Chickenpox (varicella)', 'Dose 1', 12, 'month', 51, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'HEPA-1', 'Hepatitis A', 'Dose 1', 12, 'month', 52, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'PCV-4', 'Pneumococcal conjugate (PCV20)', 'Booster', 12, 'month', 53, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'PENTA-B', 'Pentavalent booster (DTaP-Hib-HepB)', 'Booster', 18, 'month', 60, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'MMR-2', 'MMR (measles, mumps, rubella)', 'Dose 2', 18, 'month', 61, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'VAR-2', 'Chickenpox (varicella)', 'Dose 2', 18, 'month', 62, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'HEPA-2', 'Hepatitis A', 'Dose 2', 18, 'month', 63, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 18, 'month', 64, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'DTAP-IPV', 'DTaP-IPV pre-school booster (diphtheria, tetanus, whooping cough, polio)', 'Booster', 48, 'month', 70, 'Qatar MOPH NIP via WHO JRF 2025'),
  ('QA', 'OPV-3', 'Oral polio (OPV)', 'Booster', 48, 'month', 71, 'Qatar MOPH NIP via WHO JRF 2025'),
```
22 doses. School-age vaccines are left out: Tdap at 13–18 y and HPV9 at 9–14 y.

### 2. Sources and notes

- **WHO JRF 2025** (QAT, AD_SCHEDULES, general population). The 2024 and 2025 years give identical childhood rows:
  - BCG and HepB at birth.
  - DTaP-Hib-HepB-IPV at 2/4/6 m, then DTaP-Hib-HepB at 18 m.
  - DTaP-IPV at 4–6 y.
  - OPV at 6 m, 18 m and 4–6 y.
  - PCV20 at 2/4/6/12 m.
  - Rotavirus (monovalent, 2 doses) at 2/4 m.
  - MMR, varicella and HepA at 12 and 18 m.
- **MOPH Baby Immunization page:** https://www.moph.gov.qa/english/OurServices/eservices/Pages/Baby-Immunization.aspx (captcha-blocked).
- **HMC page** (says the schedule is on MOPH's page; lists the diseases covered, including hepatitis A and chickenpox): https://hamad.qa/EN/your%20health/Maternal-and-Child-Health/Newborn-Health/Pages/Your-Childs-Immunization.aspx
- **PHCC** (BCG at birth, MMR1 at 12 m, follows the NIP): https://www.phcc.gov.qa/clinics-and-services/browse-by-category/health-protection/immunization-support
- **QNA, 7 May 2025:** the NIP now has 15 vaccines covering 17 diseases, free at PHCC centres and about 70 private centres. https://qna.org.qa/en/News-Area/News/2025-5/7/moph-continues-efforts-to-improve-vaccine-access-across-qatar
- **Doubts:**
  - **Second chickenpox dose: 18 m or 4–6 y?** WHO JRF (2024 and 2025) says 18 m. Expat/clinic guides (DohaGuides, updated Nov 2025; Aster) say 4–6 y. I used 18 m (official report), but this needs checking with PHCC.
  - **18-month DTP booster.** WHO JRF says DTaP-Hib-HepB (pentavalent). Older guides say "Tetra" or Penta. The visit timing is the same either way; only the product name is uncertain.
  - **Hexa at 6 m vs Penta at 6 m.** Older guides give Penta (no IPV) at 6 m. WHO JRF 2024–25 says Hexa at 6 m.
  - **Hepatitis A.** WHO JRF lists it as routine at 12 and 18 m. DohaGuides lists it as "travellers only". I kept it as routine.
  - **Citizens vs expats.** The schedule is the same. Vaccines are free at PHCC and HMC (a health card is needed). MenACWY is only for travellers and high-risk children, so it is not included.

### 3. RSV for infants

- **Maternal vaccine: yes.** MOPH offers an RSV vaccine to pregnant women at **28–36 weeks**, free at PHCC centres and HMC hospitals. No season restriction is mentioned. The product isn't named; probably Abrysvo, but that is unconfirmed.
  - Sources: Marhaba, 7 May 2026, https://marhaba.qa/phcc-and-hmc-offer-free-rsv-vaccine-for-pregnant-women/ ; Peninsula, 29 May 2026, http://thepeninsulaqatar.com/article/29/05/2026/moph-highlights-importance-of-rsv-vaccination-to-protect-mothers-and-infants
  - A Gulf Times piece (20 Jan 2026) presents pregnant women as one of the "high-risk" groups advised to get it: https://www.gulf-times.com/article/718896/qatar/ministry-calls-upon-high-risk-category-to-get-rsv-vaccine
- **Infant antibody (nirsevimab): no universal programme confirmed.** WHO JRF 2025 lists "RSV_MONO – planned introduction; infants", with no date. I found no MOPH announcement for the 2026–27 season. High-risk infants get palivizumab under hospital protocols; a 2026 review says national guidelines are lacking.
- **For the app:** show "RSV vaccine in pregnancy, 28–36 weeks (free)" as a pregnancy reminder. Don't schedule a newborn nirsevimab dose for QA yet.

### 4. Flu for young children

- **Yes.** MOPH recommends flu vaccine for everyone **≥6 months**, and **children 6 months–5 years** are a named priority group. It is free at PHCC, HMC and 50+ private facilities, with walk-in access.
- **When:** the 2026–27 campaign started in Sept/Oct 2026 and runs to **end of March 2027**. MOPH stresses getting it in Oct–Nov.
- **Two doses for first-timers:** Qatari sources don't mention it. The standard WHO/CDC rule applies (under 9 years, first season: 2 doses at least 4 weeks apart), but **this is not confirmed in MOPH text**.
- Sources:
  - Gulf Times, 8 Oct 2026: https://www.gulf-times.com/article/735161/qatar/national-campaign-for-flu-vaccination-begins
  - QNA/PHCC, 12 Oct 2026: https://qna.org.qa/en/News-Area/News/2026-10/12/as-winter-approaches-phcc-steps-up-vaccination-awareness
  - WHO JRF 2025: INFLUENZA_PEDIATRIC, general population, ≥6 m.

### 5. Emergency numbers

- **999 (all)** for police, ambulance and fire. This is correct; no change needed.
- Optional: PHCC contact centre **107** is for appointments and health information. It is not an emergency or nurse line, so I wouldn't add it.

---

## Kuwait (KW)

### 1. Routine schedule

```sql
  ('KW', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 10, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'HEXA-1', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'PCV-1', 'Pneumococcal conjugate (PCV20)', 'Dose 1', 2, 'month', 21, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 22, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'BCG', 'BCG (tuberculosis)', null, 3, 'month', 30, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'HEXA-2', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 40, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'PCV-2', 'Pneumococcal conjugate (PCV20)', 'Dose 2', 4, 'month', 41, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 42, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'HEXA-3', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 3', 6, 'month', 50, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'PCV-3', 'Pneumococcal conjugate (PCV20)', 'Dose 3', 6, 'month', 51, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'ROTA-3', 'Rotavirus (oral)', 'Dose 3', 6, 'month', 52, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 60, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'VAR-1', 'Chickenpox (varicella)', 'Dose 1', 12, 'month', 61, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 12, 'month', 62, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'MENACWY-1', 'Meningococcal ACWY conjugate (MenACWY)', null, 12, 'month', 63, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'HEXA-4', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Booster', 18, 'month', 70, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'PCV-4', 'Pneumococcal conjugate (PCV20)', 'Booster', 18, 'month', 71, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 18, 'month', 72, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'MMRV-2', 'MMRV (measles, mumps, rubella + chickenpox)', 'Dose 2', 24, 'month', 80, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
  ('KW', 'DTAP-B', 'DTaP pre-school booster (diphtheria, tetanus, whooping cough)', 'Booster', 42, 'month', 90, 'Kuwait MOH schedule 2025 / WHO JRF 2025'),
```
20 doses. School-age vaccines are left out: Tdap at 10–12 y and 16–18 y, and HPV9. The MMR booster for girls at 10–12 y was dropped in 2025.

### 2. Sources and notes

- **Ministerial decision 83/2024** (Arab Times, 2 Apr 2024; start date Jan 2025): https://www.arabtimesonline.com/news/health-ministry-issues-new-guidance-on-child-vaccinations/ It made these changes:
  - Hexavalent replaces pentavalent at 2, 4, 6 and 18 m (IPV is now inside the hexa).
  - MMRV at 2 y replaces the 2nd MMR and 2nd varicella doses.
  - DTaP replaces DTwP at 3.5 y.
  - **The OPV booster at 3.5 y is removed.**
  - The MMR booster for girls at 10–12 y is removed.
  - Tdap replaces Td in pregnancy and at school.
- **WHO JRF 2025 (KWT)** confirms all of this happened "since mid-2025". PCV20 replaced PCV13 in the last months of 2025. Rotavirus is RV5, 3 doses (2/4/6 m). BCG is at M3. MenACWY conjugate at Y1. OPV at M12 and M18. DTaP at "Y3.6" (3.5 y).
- **Kuwait MOH 2019 schedule PDF** (layout and age wording: "Within 24 hrs of birth", "End of 2nd/3rd/4th/6th month", "End of 12 months", "18th month", "End of 2 years", "End of 3.5 years"; BCG at end of 3rd month): https://kfmrp.com/documents/kw-vaccine.pdf
- **Official 2025 PDF** (could not be downloaded, server refused): https://www.moh.gov.kw/UserRefs/PublicHealth/KuwaitImmunization2025En.pdf
- **Doubts:**
  - **Pre-school booster age.** The schedule says "End of 3.5 years". I used 42 months. A parent might read "end of" as just before 4 y.
  - **Pre-school booster product.** WHO JRF says DTaP only (not DTaP-IPV), consistent with the decision. Polio now ends with OPV2 at 18 m.
  - **BCG at 3 months is unusual** (most countries give it at birth), but both the 2019 MOH PDF and JRF 2025 say month 3.
  - **MenACWY age.** JRF 2024 said polysaccharide at Y2; JRF 2025 says conjugate at Y1. The 2019 MOH PDF also has conjugate at 12 m, so I used 12 m.
  - **Expats:** the basic schedule (ministerial decision 75/2008, as amended) applies to all children. I didn't verify whether it is free for expatriate children.

### 3. RSV for infants

- **Yes: universal nirsevimab for newborns and infants since the 2024–25 season** (Kuwait says it was the first in the Middle East). The basis is ministerial decision/letter 226 (2024) on the national committee's recommendation of 24 Dec 2024. It is part of the **optional** vaccination schedule but **free for all target groups**, including in private hospitals (the invoice must say "free of charge").
- **Who gets it:** infants under 8 months who are born during the season or entering their first season, when the mother had no RSV vaccine in pregnancy, her status is unknown, or the baby was born less than 14 days after her dose.
  - **Born during the season:** one dose **within 24 hours of birth**, in the postnatal ward or NICU.
  - **Born in the 6 months before the season:** catch-up dose **at the start of the season**, given with the 2/4/6-month routine vaccines at preventive health centres. Effectively a catch-up up to 6 months old at season start (limit under 8 months).
  - **8–24 months with risk factors** (CLD, CHD, severe immunodeficiency, Down syndrome): a dose each season. Never at 24 months or older.
- **Season months:** **not fixed.** The National Committee sets them each year from surveillance data. In practice the programme started in **Nov 2024**, and Kuwait's respiratory season peaks **Oct–Mar**. I'd use Oct–Mar as an approximation and flag it.
- **Maternal vaccine:** RSV vaccine for pregnant women at **32–36 weeks**, optional and free, given at PHC maternity clinics and government pregnancy clinics. A June 2026 MOH "expansion" re-announced it. WHO JRF 2025 says "23–26 weeks", which looks like a typo; the decision says 32–36.
- Sources:
  - Ministerial letter, English translation (5 pp, Mar 2026): https://www.campus.sanofi/dam/jcr:51d88dc2-cce4-4c62-a14f-79dcb0f92513/KW%20letter%20translation.pdf
  - Sanofi summary, Apr 2026: https://pro.campus.sanofi/sa/respiratory-syncytial-virus/articles/expanding-rsv-protection-in-kuwait-new-national-directive-for-monoclonal-antibody-use
  - Arab Times, 21 Sep 2025: https://www.arabtimesonline.com/news/kuwait-approves-rsv-immunization-for-infants-and-at-risk-groups/
  - Al-Rai, 25 Jun 2026: https://www.alraimedia.com/ampArticle/1770698
  - EMPHNET, 23 Nov 2024: https://epinews.emphnet.net/en/news/kuwait-sets-middle-east-precedent-with-anti-respiratory-disease-vaccine-for-kids
- **Note:** the decision text names no product, but Sanofi's material says nirsevimab is first choice, with palivizumab as fallback.

### 4. Flu for young children

- **Probably yes, but the age range is unclear.**
  - WHO JRF 2024 and 2025 report pediatric flu for the **general population from 6 months**.
  - The MOH winter campaign (Kuwait Times, 2 Sep 2026) names "children" as a priority group without an age range: https://kuwaittimes.com/article/49113/kuwait/other-news/moh-launches-seasonal-vaccination-drive-to-prevent-respiratory-diseases/
  - An older Kuwait Times report defined the child group as starting at 5 y.
- **When:** the campaign starts in Sept–Oct. The season runs mid-September to May and peaks Oct–March.
- **Two doses:** not stated in Kuwaiti sources.
- **Recommendation:** treat it as "recommended from 6 months each season", with medium-low confidence.

### 5. Emergency numbers

- **112 (all)** is correct. It is Kuwait's unified police, ambulance and fire number. No change needed.

---

## Oman (OM)

### 1. Routine schedule

```sql
  ('OM', 'BCG', 'BCG (tuberculosis)', null, 0, 'day', 10, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 11, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'HEXA-1', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'PCV-1', 'Pneumococcal conjugate (PCV13)', 'Dose 1', 2, 'month', 21, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 22, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'HEXA-2', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 30, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'PCV-2', 'Pneumococcal conjugate (PCV13)', 'Dose 2', 4, 'month', 31, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 32, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 4, 'month', 33, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'PENTA-3', 'Pentavalent (DTP-Hib-HepB)', 'Dose 3', 6, 'month', 40, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 6, 'month', 41, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 50, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'VAR-1', 'Chickenpox (varicella)', 'Dose 1', 12, 'month', 51, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'PENTA-B', 'Pentavalent booster (DTP-Hib-HepB)', 'Booster', 13, 'month', 60, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'PCV-3', 'Pneumococcal conjugate (PCV13)', 'Booster', 13, 'month', 61, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'MMR-2', 'MMR (measles, mumps, rubella)', 'Dose 2', 18, 'month', 70, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'HEPA-1', 'Hepatitis A', 'Dose 1', 18, 'month', 71, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'OPV-3', 'Oral polio (OPV)', 'Booster', 18, 'month', 72, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'HEPA-2', 'Hepatitis A', 'Dose 2', 24, 'month', 80, 'Oman MOH EPI via WHO JRF 2025'),
  ('OM', 'DT-B', 'DT booster (diphtheria, tetanus) at school entry', 'Booster', 72, 'month', 90, 'Oman MOH EPI via WHO JRF 2025'),
```
20 doses.
- **The DT row at 6 y (72 m)** is given at school in **grade 1**. It sits right at the ~72-month limit, so the reviewer can decide whether to keep it.
- **Left out:** vitamin A at 12 and 18 m (a supplement, not a vaccine), plus Tdap at 11–12 y and HPV9 at 12 y.

### 2. Sources and notes

- **WHO JRF 2025 (OMN)**, general population. It matches 2024 exactly:
  - BCG and HepB at birth.
  - DTaP-Hib-HepB-IPV (hexa) at 2 and 4 m; DTwP-Hib-HepB (penta) at 6 m and 13 m.
  - OPV at 4, 6 and 18 m.
  - PCV13 at 2, 4 and 13 m.
  - Rotavirus at 2 and 4 m.
  - MMR at 12 and 18 m; varicella at 12 m; HepA at 18 and 24 m.
  - DT at 6 y (grade 1); vitamin A at 12 and 18 m.
- **Rotavirus** was added Dec 2023: 2 doses at 2 and 4 m, for babies born from Nov 2023. The 4th edition of the National Immunization Program Guide was launched at the same time (ministerial decision 274/2023). Al-Roya, 4 Dec 2023: https://alroya.om/post/334883/ ; Al-Sahwa: https://alsahwa.om/?p=202649
- **PLoS One, 10 Jul 2025** (MOH authors, from the EPI manual): the schedule is free for every child. It lists hexa 2/4 m, penta + OPV 6 m, MMR1 + varicella 12 m, penta + PCV booster 13 m, MMR2 + HepA1 + OPV 18 m, HepA2 24 m. https://pmc.ncbi.nlm.nih.gov/articles/PMC12244637/
- **Planned changes (WHO JRF 2025)** that I could not confirm have happened:
  - Varicella dose 2: "planned introduction Dec 2025; <5 yrs". The 2024 report said "2–4 yrs".
  - MenACWY conjugate: "planned Dec 2026; <5 yrs". It was planned for Dec 2025 in the 2024 report, so it slipped.
  - Influenza: "planned introduction Sept 2026; <5 years".
  - **If varicella dose 2 has started, a row will be needed.** Its age is not yet known.
- **Doubts:**
  - The PLoS paper omits OPV at 4 m. WHO JRF and an older Oman schedule card both have OPV-1 at 4 m (https://resources.finalsite.net/images/v1597744929/abaomaneduom/r7bgashisriq52eisoit/ImmunizationScheduleforOman.pdf), so I kept it.
  - The rotavirus product isn't stated (JRF codes it RV5, yet 2 doses). I didn't name the product.
  - The MOH website schedule couldn't be found or reached.
- **Expats:** the PLoS paper says the vaccines are free for "every child". I didn't verify this for expatriates.

### 3. RSV for infants

- **No national programme found.** WHO JRF 2025 lists no RSV entry for Oman, and I found no MOH announcement of nirsevimab or a maternal RSV vaccine. Palivizumab is used in hospitals for preterm babies under 32 weeks (SQUH study).

### 4. Flu for young children

- **Not yet routine for all young children.**
  - WHO JRF 2025 lists pediatric flu for the general population only at "M24". Older MOH priority lists name children at 9 m, 24 m, 3 y and 4 y, plus children with chronic conditions.
  - **Introduction for all children under 5 was planned for September 2026** (WHO JRF 2025). I found no announcement confirming it started.
  - The May 2026 MOH flu campaign (Muscat Daily, 4 May 2026) targets high-risk groups: https://www.muscatdaily.com/2026/05/04/moh-launches-flu-vaccine-campaign-targeting-high-risk-groups/
- **Timing:** Oman's campaigns don't follow the usual Oct–Mar pattern. There was one in May 2026, "ahead of the respiratory peak season".
- **Two doses:** not stated.
- **Recommendation:** don't add a routine flu reminder for OM until the under-5 introduction is confirmed.

### 5. Emergency numbers

- **9999 (all)** is correct. It is the Royal Oman Police number for police, ambulance and fire; 112 reportedly redirects to 9999. Some lists give 999 for Civil Defence/fire, which is old or unclear, so I'd keep 9999 as 'all'. No change needed.

---

## Bahrain (BH)

### 1. Routine schedule

```sql
  ('BH', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 10, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'HEXA-1', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'PCV-1', 'Pneumococcal conjugate (PCV20)', 'Dose 1', 2, 'month', 21, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 22, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'HEXA-2', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 30, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'PCV-2', 'Pneumococcal conjugate (PCV20)', 'Dose 2', 4, 'month', 31, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 32, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 4, 'month', 33, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'HEXA-3', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 3', 6, 'month', 40, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 6, 'month', 41, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 50, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'VAR-1', 'Chickenpox (varicella)', 'Dose 1', 12, 'month', 51, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'PCV-3', 'Pneumococcal conjugate (PCV20)', 'Booster', 15, 'month', 60, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'HEPA-1', 'Hepatitis A', 'Dose 1', 15, 'month', 61, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'MMR-2', 'MMR (measles, mumps, rubella)', 'Dose 2', 18, 'month', 70, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'DTP-B1', 'DTP-Hib booster (4-in-1 or 5-in-1 with HepB)', 'Booster 1', 18, 'month', 71, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'OPV-3', 'Oral polio (OPV)', 'Dose 3', 18, 'month', 72, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'MENACWY-1', 'Meningococcal ACWY conjugate (MenACWY)', null, 24, 'month', 80, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'HEPA-2', 'Hepatitis A', 'Dose 2', 24, 'month', 81, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'VAR-2', 'Chickenpox (varicella)', 'Dose 2', 36, 'month', 90, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'DTAP-IPV', 'DTaP-IPV pre-school booster (diphtheria, tetanus, whooping cough, polio)', 'Booster 2', 48, 'month', 100, 'Bahrain MOH immunization schedule 2025'),
  ('BH', 'OPV-B', 'Oral polio (OPV)', 'Booster', 48, 'month', 101, 'Bahrain MOH immunization schedule 2025'),
```
22 doses. Tdap and HPV at 12–13 y are left out.

**BCG is risk-based in Bahrain:** at birth, "for newborns born to parents originally from endemic countries". **Pakistan is a TB-endemic country**, so in practice it applies to most Palna families in Bahrain. Suggested row, kept separate so it can be shown for this audience or behind a flag:
```sql
  -- risk-group (parents from TB-endemic country, e.g. Pakistan):
  -- ('BH', 'BCG', 'BCG (tuberculosis) – for babies of parents from TB-endemic countries', null, 0, 'day', 11, 'Bahrain MOH immunization schedule 2025'),
```

### 2. Sources and notes

- **Bahrain MOH live schedule page** (read 27 Oct 2026; the dose labels used above come from here): https://www.moh.gov.bh/HealthInfo/Immunizations?lang=en
- **MOH "Immunization schedule 2025" PDF.** It was uploaded around Jan 2026 (judging by the file id) and is marked "Printed in 2024". https://www.moh.gov.bh/Content/Upload/File/639044931620020273-Immunization-schedule-2025.pdf
- **Older version** (Penta at 6 m), for comparison: https://www.moh.gov.bh/Content/Upload/File/638771217724743135-Recommended-Immunization-Schedule-for-the-Kingdom-of-Bahrain.pdf
- **WHO JRF 2025 (BHR):**
  - Hexa "recently added for 6 months (since September 2025)", replacing Penta at 6 m.
  - PCV20 (replacing PCV13) at 2, 4 and 15 m; a 6-month PCV dose is for high-risk babies only.
  - Rotavirus (monovalent) at 2 and 4 m.
  - Varicella at 1 y and 3 y; HepA at 15 m and 2 y; MenACWY at 2 y.
  - DTaP-IPV at 4–5 y.
  - OPV at 4 m, 6 m, 18 m and 5 y.
  - BCG for risk groups only.
- **Doubts and inconsistencies:**
  - **OPV dose labels.** The live web page says 1st (4 m), 2nd (6 m), 3rd (18 m), Booster (4–5 y). The PDF says 2nd, 3rd, 1st booster, 2nd booster, because hexa at 2 m counts as polio dose 1. I used the web page labels.
  - **Rotavirus at 2 m** is labelled "2nd Dose" on the web page, which is a typo. I used Dose 1.
  - **OPV booster age.** It is "4–5 years" on the card and Y5 in JRF. I used 48 m with DTaP-IPV, as the card has them at the same visit.
  - **18-month DTP booster.** It is "Tetravalent (DPT-Hib) or Pentavalent (DTP-Hib-HepB) according to availability", so the name is generic.
  - **Catch-up MMR at 4–5 y** applies only if 2 doses aren't documented, so it is not included.
  - **Citizens vs expats:** one schedule for all. I didn't verify whether it is free for expat children at health centres.

### 3. RSV for infants

- **Maternal vaccine: yes, in the national schedule.** The MOH page lists "RSV: one dose in the third trimester, **from 32 weeks' gestation onwards**, and **at least two weeks prior to delivery**", in the pregnancy section beside Tdap at 27–36 weeks and flu. WHO JRF 2025 recorded it as "planned introduction February 2026; pregnant women". No season restriction is stated, and I couldn't confirm whether it is free for all.
- **Infant antibody (nirsevimab): no national programme found.**
- Source: https://www.moh.gov.bh/HealthInfo/Immunizations?lang=en

### 4. Flu for young children

- **Yes.** MOH recommends seasonal flu "in every season" for **children ≥6 months and ≤5 years** (also adults ≥50, pregnant women, chronic conditions and health workers). WHO JRF 2025 reports pediatric flu for the general population up to 9 y.
- **Months:** not stated. Gulf campaigns usually start in Sept–Oct.
- **Two doses for first-timers:** not stated in Bahrain MOH text. The page says "one dose in the season" for pregnant women only.
- Sources: the MOH page above and the 2025 schedule PDF.

### 5. Emergency numbers

- **999 (all)** is correct. The official bahrain.bh portal describes 999 as the toll-free number for police, fire and ambulance. No change needed. (MOH customer service 8000 8100 is not an emergency line.)

---

## Summary table for the app

| Country | Routine doses | RSV infants | Flu for young children | Emergency |
|---|---|---|---|---|
| QA | 22 | Maternal vaccine 28–36 wk (free); infant nirsevimab only "planned" | Yes, ≥6 m (priority 6 m–5 y), Oct–Mar | 999 all ✔ |
| KW | 20 | **Universal nirsevimab** <8 m (birth dose within 24 h in season; catch-up at season start for babies born ≤6 m before); maternal 32–36 wk optional; free | Likely yes from 6 m (age unclear) | 112 all ✔ |
| OM | 20 | None | Not yet (under-5 planned Sept 2026, unconfirmed) | 9999 all ✔ |
| BH | 22 (+ BCG for parents from endemic countries) | Maternal vaccine ≥32 wk, ≥2 wk before delivery; no infant programme | Yes, 6 m–5 y every season | 999 all ✔ |
