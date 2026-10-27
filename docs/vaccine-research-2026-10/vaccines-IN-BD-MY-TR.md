# Vaccine schedules: India, Bangladesh, Malaysia, Türkiye

Researched 27 Oct 2026. The main cross-check is the WHO/UNICEF JRF schedule data
(the same data behind immunizationdata.who.int), pulled straight from the public
WHO xMart API:
`https://xmart-api-public.who.int/WIISE/MT_AD_SCHEDULER?$filter=ISO_3_CODE eq 'IND'&$format=csv`
(change IND to BGD/MYS/TUR). All four countries have **reporting year 2025**
data, committed 2026-06-03. Every national change found for 2025-2026 is listed
under the country it applies to.

Some sources could not be opened from here: Indian gov domains (nhm.gov.in,
static.pib.gov.in) did not resolve, and asi.saglik.gov.tr refused the
connection. For those, the WHO JRF data plus news and secondary sources were
used, and the doubts are marked.

---

## India (IN)

### 1. Routine schedule

```sql
  ('IN', 'BCG', 'BCG (tuberculosis)', null, 0, 'day', 10, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 11, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'OPV-0', 'Oral polio (OPV)', 'Birth dose', 0, 'day', 12, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 6, 'week', 20, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'PENTA-1', 'Pentavalent (DTP-HepB-Hib)', 'Dose 1', 6, 'week', 21, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'ROTA-1', 'Rotavirus (RVV, oral)', 'Dose 1', 6, 'week', 22, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'fIPV-1', 'Fractional polio injection (fIPV)', 'Dose 1', 6, 'week', 23, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 6, 'week', 24, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 10, 'week', 30, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'PENTA-2', 'Pentavalent (DTP-HepB-Hib)', 'Dose 2', 10, 'week', 31, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'ROTA-2', 'Rotavirus (RVV, oral)', 'Dose 2', 10, 'week', 32, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'OPV-3', 'Oral polio (OPV)', 'Dose 3', 14, 'week', 40, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'PENTA-3', 'Pentavalent (DTP-HepB-Hib)', 'Dose 3', 14, 'week', 41, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'ROTA-3', 'Rotavirus (RVV, oral)', 'Dose 3', 14, 'week', 42, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'fIPV-2', 'Fractional polio injection (fIPV)', 'Dose 2', 14, 'week', 43, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 14, 'week', 44, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'MR-1', 'Measles-Rubella (MR)', 'Dose 1', 9, 'month', 50, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'fIPV-3', 'Fractional polio injection (fIPV)', 'Dose 3', 9, 'month', 51, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'PCV-B', 'Pneumococcal conjugate (PCV)', 'Booster', 9, 'month', 52, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'MR-2', 'Measles-Rubella (MR)', 'Dose 2', 16, 'month', 60, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'DTP-B1', 'DTP (diphtheria-tetanus-pertussis)', 'Booster 1', 16, 'month', 61, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'OPV-B', 'Oral polio (OPV)', 'Booster', 16, 'month', 62, 'India UIP (MoHFW) / WHO JRF 2025'),
  ('IN', 'DTP-B2', 'DTP (diphtheria-tetanus-pertussis)', 'Booster 2', 60, 'month', 70, 'India UIP (MoHFW) / WHO JRF 2025'),
```
23 doses.

### 2. Sources and notes
- WHO/UNICEF JRF, India, reporting year 2025 (committed 2026-06-03), from the xMart API above. It lists every dose above as NATIONAL: BCG at birth (allowed up to 1 yr); HepB at birth; OPV at birth, 6, 10 and 14 wk and 16-24 mo; Penta at 6, 10 and 14 wk; RV1/RV5 (both products used) at 6, 10 and 14 wk; fIPV at 6 wk, 14 wk and 9 mo; PCV at 6 wk, 14 wk and 9 mo; MR at 9-12 mo and 16-24 mo; DTwP at 16-24 mo and 5-6 yr. Td at 10 and 16 yr is school age and left out. Vitamin A (9 mo, then every 6 mo to 5 yr) is a supplement, not a vaccine, and is left out; the app could add it as a separate reminder.
- MoHFW National Immunization Schedule (NHM, 2018 version, superseded on PCV and fIPV): https://nhm.gov.in/New_Updates_2018/NHM_Components/Immunization/report/National_%20Immunization_Schedule.pdf (could not be fetched; known from search snippets).
- **PCV is national** since the nationwide expansion launched 29 Oct 2021 (Union Health Minister Mandaviya). Before that it was only in selected states, which the 2018 PDF still says. Sources: https://biospectrumindia.com/news/22/19878/govt-launches-nationwide-expansion-of-pneumococcal-conjugate-vaccine-under-uip.html and https://www.deccanherald.com/national/pneumonia-vaccine-to-be-rolled-out-nationwide-1045540.html
- **fIPV-3 at 9 months**: added nationally from 1 Jan 2023 and given with MR-1 (https://www.tribuneindia.com/news/jalandhar/3-fractional-doses-for-kids-from-january1-smo-463458). It is in the WHO JRF 2025 as NATIONAL, M9. Some older or state pages still show only 2 fIPV doses.
- Ages: India's schedule gives ranges (MR-1, fIPV-3 and PCV-B at "9-12 months"; DPT-B1, OPV-B and MR-2 at "16-24 months"; DPT-B2 at "5-6 years"). Earliest ages are used: 9, 16 and 60 months.
- Rotavirus: India's rotavirus vaccines (Rotavac, Rotasiil) are 3-dose. Some states give Rotasiil as liquid or lyophilised, but the schedule is the same.
- **Regional, not in the SQL**: Japanese Encephalitis (JE-1 at 9-12 mo, JE-2 at 16-24 mo) only in endemic districts (WHO: SUBNATIONAL). If the app later supports regions, add it as `('IN','JE-1','Japanese Encephalitis (JE)','Dose 1',9,'month',53,...)` and `JE-2` at 16 months.
- 2026 changes: Td replaced TT under UIP (Feb 2026; adolescents, adults and pregnancy). A nationwide HPV campaign for 14-year-old girls started 28 Feb 2026 (https://www.drishtiias.com/daily-updates/daily-news-analysis/national-vaccination-day-and-universal-immunisation-programme/print_manually). Both are outside the 0-6 yr range. No change to the infant schedule was found for 2025-2026.
- Doubt: whole-cell DTP (DTwP) is the UIP product. Private clinics often give DTaP or hexavalent on the IAP (Indian Academy of Pediatrics) schedule, which is a different schedule.

### 3. RSV for infants
**No national programme.** RSV is not part of the UIP, and no MoHFW nirsevimab or maternal RSV programme was found. Some private use may exist.

### 4. Flu for young children
**Not routine.** Influenza vaccine is not in the UIP for children. The IAP (professional body, private sector) recommends it yearly from 6 mo to 5 yr, but that is not the national programme.

### 5. Emergency numbers
- 112: verified, all-in-one (ERSS: police, fire, ambulance). Keep as `all`.
- 108: verified, emergency ambulance in most states. Keep as `ambulance`.
- Add 102: free ambulance for pregnant women and sick infants under 1 year (JSSK, Janani Shishu Suraksha Karyakram, state-run). Type `ambulance`. This matters for a baby app, but availability and number vary by state.
- Add **1800-116-117**: National Poisons Information Centre, AIIMS New Delhi, toll-free, 24x7 (https://aiims.edu/index.php/en/npic_intro; also on the NCDC list https://ncdc.mohfw.gov.in/wp-content/uploads/2025/07/List-of-Poison-Information-Information-Centres.pdf). Type `poison`.
- Optional: 100 police, 101 fire. Both still work in most states but are being folded into 112.

**Confidence: high.**

---

## Bangladesh (BD)

### 1. Routine schedule

```sql
  ('BD', 'BCG', 'BCG (tuberculosis)', null, 0, 'day', 10, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'PENTA-1', 'Pentavalent (DTP-HepB-Hib)', 'Dose 1', 6, 'week', 20, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 6, 'week', 21, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 6, 'week', 22, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'fIPV-1', 'Fractional polio injection (fIPV)', 'Dose 1', 6, 'week', 23, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'PENTA-2', 'Pentavalent (DTP-HepB-Hib)', 'Dose 2', 10, 'week', 30, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 10, 'week', 31, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 10, 'week', 32, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'PENTA-3', 'Pentavalent (DTP-HepB-Hib)', 'Dose 3', 14, 'week', 40, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'OPV-3', 'Oral polio (OPV)', 'Dose 3', 14, 'week', 41, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'PCV-3', 'Pneumococcal conjugate (PCV)', 'Dose 3', 14, 'week', 42, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'fIPV-2', 'Fractional polio injection (fIPV)', 'Dose 2', 14, 'week', 43, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'MR-1', 'Measles-Rubella (MR)', 'Dose 1', 9, 'month', 50, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'MR-2', 'Measles-Rubella (MR)', 'Dose 2', 15, 'month', 60, 'Bangladesh EPI (DGHS) / WHO JRF 2025'),
  ('BD', 'TCV', 'Typhoid conjugate (TCV)', null, 15, 'month', 61, 'Bangladesh EPI (DGHS) 2026'),
```
15 doses.

### 2. Sources and notes
- WHO/UNICEF JRF, Bangladesh, reporting year 2025 (committed 2026-06-03): BCG at birth; Penta, OPV and PCV10 at 6, 10 and 14 wk; fIPV at 6 and 14 wk; MR at W38 (about 9 mo) and 15 mo. There is **no HepB birth dose, no OPV birth dose and no rotavirus** in the national programme.
- News explainers from April 2026 (Jagonews24 https://www.jagonews24.com/en/national/news/91363 and Prothom Alo https://www.prothomalo.com/lifestyle/health/urfp5i5q6g) give the same schedule: BCG at birth; Penta, OPV and PCV at 6, 10 and 14 wk; IPV at 6 and 14 wk; MR at 9 and 15 mo.
- **TCV added to routine EPI from 1 Aug 2026**: one dose at 15 months, given with the second measles dose. DGHS directive of 13 Jul 2026; NITAG recommended it 8 Dec 2025 (https://www.tbsnews.net/node/1487521; also https://www.dhakatribune.com/bangladesh/health/415247/govt-to-add-typhoid-vaccine-to-epi-from-1-august). It follows the nationwide TCV catch-up campaign of 12 Oct 2025 for ages 9 mo to under 15 yr (https://www.unicef.org/bangladesh/en/press-releases/bangladesh-launches-nationwide-typhoid-conjugate-vaccine-campaign-protect-50-million).
  - Doubt: one report gives the window as 15-24 months, and the April 2026 Jagonews piece mentioned TCV at 9 months (likely the campaign age). The 15-month routine age comes from the later DGHS directive.
  - Doubt: the TBS article says "MMR-2". Bangladesh uses **MR**, not MMR, and no MMR switch was found. This is probably a reporting error.
- **PCV 3rd dose: 14 weeks or 18 weeks?** When PCV10 was introduced in 2015, the schedule was 6, 10 and **18** weeks (Gates Open Research PCV impact paper, https://gatesopenresearch.org/articles/2-21). The WHO JRF 2025 and the 2026 news explainers say 6, 10 and **14** weeks, so 14 weeks is used. **Ask the pediatrician or DGHS EPI to confirm.**
- The fIPV doses are reported as rounds 1 and 3 in JRF, but they are just the 2 fractional doses at 6 and 14 wk.
- Td for women of childbearing age and pregnant women, and HPV for girls at 10 yr, are left out. Vitamin A campaigns (6-59 mo) are not vaccines.
- Rotavirus: planned for years but not introduced as of these sources. No 2025-2026 introduction was found.

### 3. RSV for infants
**No national programme** (no nirsevimab and no maternal RSV vaccine in the EPI).

### 4. Flu for young children
**Not routine.** The WHO JRF lists influenza only for adult risk groups. Children are not included.

### 5. Emergency numbers
- 999: verified, National Emergency Service (police, fire, ambulance). Keep as `all`.
- Optional: 16263 "Shastho Batayon", the DGHS 24h free health advice line staffed by doctors (https://en.prothomalo.com/amp/story/bangladesh/t6a9p1gdfe). Type `nurseLine`, though it is really a doctor line. **Caveat:** there are 2025-2026 reports that it faces shutdown over funding (https://thefinancialexpress.com.bd/health/natl-telehealth-helpline-16263-faces-shutdown-amid-funding-crisis). Check it still works before adding.
- No national poison line was found.

**Confidence: medium-high.** The open questions are the PCV 3rd dose at 14 vs 18 weeks, and the exact TCV age and window.

---

## Malaysia (MY)

### 1. Routine schedule

```sql
  ('MY', 'BCG', 'BCG (tuberculosis)', null, 0, 'day', 10, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 11, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'HEXA-1', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'HEXA-2', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 2', 3, 'month', 30, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 4, 'month', 40, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'HEXA-3', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 3', 5, 'month', 50, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 6, 'month', 60, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'MMR-1', 'Measles-Mumps-Rubella (MMR)', 'Dose 1', 9, 'month', 70, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'MMR-2', 'Measles-Mumps-Rubella (MMR)', 'Dose 2', 12, 'month', 80, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'PCV-B', 'Pneumococcal conjugate (PCV)', 'Booster', 15, 'month', 90, 'Malaysia NIP (KKM) / WHO JRF 2025'),
  ('MY', 'HEXA-B', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Booster', 18, 'month', 100, 'Malaysia NIP (KKM) / WHO JRF 2025'),
```
11 doses.

### 2. Sources and notes
- WHO/UNICEF JRF, Malaysia, reporting year 2025 (committed 2026-06-03): BCG at birth; HepB at birth only ("From November 2020 onwards, only Hep B birth dose given. Subsequent doses given as hexavalent vaccine"); DTaP-Hib-HepB-IPV at 2, 3, 5 and 18 mo ("From November 2020 onwards"); PCV at 4, 6 and 15 mo (from 1 Dec 2020); MMR at 9 and 12 mo (children born July 2015 onwards); DT at 7 yr (school, left out); HPV at 13 yr (school, left out).
- Hexavalent switch in Nov 2020, which dropped the HepB doses at 1 and 6 months (https://codeblue.galencentre.org/2020/11/17/malaysia-updates-child-immunisation-schedule-with-hexavalent-vaccine/ and https://codeblue.galencentre.org/2020/11/19/the-new-national-immunisation-schedule/).
- PCV started at KKM clinics in Dec 2020 with PCV10 (Synflorix) (https://utusansarawak.com.my/pemberian-pcv-di-fasiliti-kkm-bermula-disember). The WHO JRF 2025 codes it as PCV13, so the product may have changed. The app name is kept generic ("PCV"). The 15-month dose is labelled Booster (2+1 schedule).
- An official KKM/MyHealth schedule page from 2024-2026 was not found online. The WHO JRF 2025 is the most recent official-country data.
- **Regional, not in the SQL**:
  - **Sabah only**: Measles dose at 6 months (WHO: SUBNATIONAL, M6).
  - **Sarawak only**: Japanese Encephalitis (live attenuated) at 9 and 21 months.
- Risk-group extras, left out: babies of HBsAg-positive mothers get HBIG and extra HepB doses.
- **Rotavirus is NOT in the NIP**, confirmed by a University of Nottingham Malaysia item dated 19 Aug 2026 (https://www.nottingham.edu.my/NewsEvents/News/2026/UNM-Hosts-Regional-Experts-to-Tackle-Rotavirus-Vaccine-Gaps-in-Malaysia.aspx). Families pay for it privately.
- No 2025-2026 change to the NIP infant schedule was found.

### 3. RSV for infants
**No national programme.** Nirsevimab (Beyfortus) was approved by NPRA in Nov 2025 and launched privately in Dec 2025 "for all infants", but it is paid privately. A Sept 2026 pediatricians' column in Code Blue still asks for it to be added to the NIP (https://codeblue.galencentre.org/2026/09/game-changer-for-infant-health-dr-musa-mohd-nordin-dr-husna-musa/; https://www.malaymail.com/news/life/2025/12/16/beyfortus-nirsevimab-now-available-in-malaysia-to-help-protect-all-infants-against-rsv-disease/202095). There is no maternal RSV programme. Malaysia has year-round RSV with peaks, not a temperate season.

### 4. Flu for young children
**Not routine or free for all children.** The WHO JRF has a general "paediatric influenza >= 6 months" line, but in practice KKM gives flu vaccine only to risk groups; it is otherwise private. Doubt: it is unclear what that JRF line means, so I treat it as a recommendation, not a funded programme.

### 5. Emergency numbers
- 999: verified, MERS 999, covering police, ambulance, fire and civil defence. Keep as `all`.
- 112: also works from mobile phones and connects to 999. Optional `all`.
- 994: fire and rescue (Bomba) direct line. Optional `fire`.
- Poison: National Poison Centre (Pusat Racun Negara, USM) **+604-653 6999**. **Not 24h**: Mon-Fri 8am-10pm, Sat/Sun/public holidays 8am-5pm, per https://prn.usm.my/. Type `poison`. If added, say it is not 24h. The often-quoted toll-free 1-800-88-8099 could **not** be verified, so don't use it.

**Confidence: high.** The one product doubt is PCV10 vs PCV13, which doesn't change the schedule.

---

## Türkiye (TR)

### 1. Routine schedule

```sql
  ('TR', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 10, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'BCG', 'BCG (tuberculosis)', null, 2, 'month', 20, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'HEXA-1', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 21, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 22, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'HEXA-2', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 30, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 31, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'HEXA-3', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 3', 6, 'month', 40, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 6, 'month', 41, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'MMR-1', 'Measles-Mumps-Rubella (MMR)', 'Dose 1', 12, 'month', 50, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'VAR-1', 'Chickenpox (varicella)', 'Dose 1', 12, 'month', 51, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'PCV-B', 'Pneumococcal conjugate (PCV)', 'Booster', 12, 'month', 52, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'HEXA-B', '6-in-1 (DTaP-IPV-Hib-HepB)', 'Booster', 18, 'month', 60, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 18, 'month', 61, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'HEPA-1', 'Hepatitis A', 'Dose 1', 18, 'month', 62, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'HEPA-2', 'Hepatitis A', 'Dose 2', 24, 'month', 70, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'DTAP-IPV-B', '4-in-1 (DTaP-IPV)', 'Booster', 48, 'month', 80, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'MMR-2', 'Measles-Mumps-Rubella (MMR)', 'Dose 2', 48, 'month', 81, 'Türkiye MoH childhood schedule 2026'),
  ('TR', 'VAR-2', 'Chickenpox (varicella)', 'Dose 2', 48, 'month', 82, 'Türkiye MoH childhood schedule 2026'),
```
18 doses.

### 2. Sources and notes
- WHO/UNICEF JRF, Türkiye, reporting year 2025 (committed 2026-06-03): HepB at birth; BCG at 2 mo; DTaP-Hib-HepB-IPV at 2, 4, 6 and 18 mo; PCV13 at 2, 4 and 12 mo; OPV at 6 and 18 mo; MMR at 12 and 48 mo; varicella at 12 mo; HepA at 18 and 24 mo; DTaP-IPV at 48 mo; Td at 13 yr (school, left out).
- **Hexavalent from 14 Apr 2025** (Ministry of Health announcement, 19 Mar 2025): HepB is merged into the 5-in-1. The separate HepB birth dose stays, and the follow-up HepB doses (formerly 1 and 6 months) now come in the 6-in-1. Children who started the 5-in-1 finish with the 6-in-1. Sources: https://www.trthaber.com/haber/saglik/cocukluk-donemi-asi-takviminde-degisiklige-gidiliyor-901244.html and https://www.ntv.com.tr/saglik/saglik-bakanligi-duyurdu-cocukluk-donemi-asi-takviminde-degisik,WR_ZPd9Cmk6BBVXo2v0ePw
  - So **there is no longer a HepB dose at 1 month**. Older Turkish schedules show HepB at 0, 1 and 6 months.
- **Varicella dose 2 at 48 months, from 1 Sep 2026** (Ministry of Health update to the "Ulusal Çocukluk Dönemi Aşılama Takvimi"). There is catch-up for children aged 49-72 months. Sources: https://www.gazetevatan.com/galeri/sucicegi-asisi-kac-doz-saglik-bakanligi-takvimi-degistirdi-4-yasa-ikinci-doz-geldi-2405224 (7 Sep 2026) and https://www.aile.gov.tr/tekirdag/haberler/asinin-yolculugu/ ("1 Eylül 2026 tarihi itibarıyla tüm Türkiye'de, 48. ayda suçiçeği ikinci doz"). This change is too recent to be in the WHO JRF 2025.
  - Doubt: I could not open the Ministry's own page (asi.saglik.gov.tr refused the connection), so this comes from a news report plus a provincial government page.
- Turkish schedule wording is "2. ayın sonunda" (at the end of month 2), meaning when the baby turns 2 months. Kept as 2 'month', 4 'month', etc.
- "48. ay" is often written as "ilkokul 1. sınıf" (first grade) in older schedules. WHO and current sources give 48 months.
- Left out: Td at 13 yr; extra MMR at 9-11 months in outbreaks (risk group); pregnancy Tdap/Td; flu for risk groups.
- **Rotavirus is not in the national schedule.** It is recommended but private (Turkish pediatric sources). Meningococcal vaccine is private too.

### 3. RSV for infants
**No national programme found.** Nirsevimab (Beyfortus) is licensed in Türkiye (Turkish product information, Sanofi, Mar 2025: https://sanofi.com/assets/countries/turkey/docs/products/prescription-products/B/2025-03-21-Beyfortus-50-mg-KUB.pdf), but I found no Ministry of Health programme for all infants. Palivizumab is reimbursed for high-risk preterm babies only. There is no maternal RSV programme. Confidence medium: Turkish-language Ministry sources could not be opened directly.

### 4. Flu for young children
**Not routine for all children.** The WHO JRF has a general "paediatric influenza >= 6 months" line, but the Turkish programme gives flu vaccine to risk groups (chronic illness, pregnancy, elderly and healthcare workers). Healthy children get it privately. Doubt: what that JRF line means, the same as for Malaysia.

### 5. Emergency numbers
- 112: verified. Since 2021 it is the single emergency number in all provinces, absorbing 155 police, 156 gendarmerie and 110 fire. Keep as `all`.
- Add **114**: National Poison Information Centre (UZEM, Ulusal Zehir Danışma Merkezi), Ministry of Health, 24/7, for the public and health workers. Type `poison`.
- Optional: ALO 184 (SABİM), the Ministry of Health's citizen line. It handles complaints and information, not medical triage, so it doesn't really fit `nurseLine`. Not recommended.

**Confidence: high for the schedule up to 2025; medium-high for the Sept 2026 varicella dose.**

---

## Summary of emergency changes for the app

| Country | Number | Service | Action |
|---|---|---|---|
| IN | 112 | all | keep |
| IN | 108 | ambulance | keep |
| IN | 102 | ambulance (mother and infant transport, state-run) | add (optional) |
| IN | 1800-116-117 | poison (AIIMS NPIC, 24x7) | add |
| BD | 999 | all | keep |
| BD | 16263 | nurseLine (doctor advice line; funding at risk) | add only if confirmed working |
| MY | 999 | all | keep |
| MY | 112 | all (mobile, connects to 999) | optional |
| MY | 994 | fire | optional |
| MY | +604-653 6999 | poison (not 24h) | optional |
| TR | 112 | all | keep |
| TR | 114 | poison (UZEM, 24/7) | add |

No new service type is needed.
