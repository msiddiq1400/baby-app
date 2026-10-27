# Vaccine schedules: France (FR), Norway (NO), Sweden (SE)

Research date: 27 Oct 2026. Primary sources were read directly wherever possible: the French 2026 calendrier PDF (full text), the DGS-Urgent RSV message, FHI pages, the Folkhälsomyndigheten programme page and the NT-rådet statement. Every row below is for review by a pediatrician.

Conventions used (same as the existing rows):
- A 2+1 infant series (e.g. 2, 4, 11 months) is entered as `Dose 1`, `Dose 2`, `Booster`.
- A second MMR dose is `Dose 2`: France says outright that it is not a booster.
- School-age doses are left out (Norway 7 y, Sweden MMR-2 in grade 1–2, etc.). Doses that are close to the cut-off, or due to start soon, are given as commented-out or separate rows for the owner to decide on.

---

## 1. France (FR)

### 1.1 Routine schedule

```sql
  ('FR', 'HEXA-1',    '6-in-1 (DTaP-IPV-Hib-HepB)',       'Dose 1',  2,  'month', 10, 'France calendrier vaccinal 2026'),
  ('FR', 'PCV-1',     'Pneumococcal (PCV)',               'Dose 1',  2,  'month', 11, 'France calendrier vaccinal 2026'),
  ('FR', 'ROTA-1',    'Rotavirus (oral)',                 'Dose 1',  2,  'month', 12, 'France calendrier vaccinal 2026'),
  ('FR', 'MENB-1',    'Meningococcal B (MenB)',           'Dose 1',  3,  'month', 20, 'France calendrier vaccinal 2026'),
  ('FR', 'ROTA-2',    'Rotavirus (oral)',                 'Dose 2',  3,  'month', 21, 'France calendrier vaccinal 2026'),
  ('FR', 'HEXA-2',    '6-in-1 (DTaP-IPV-Hib-HepB)',       'Dose 2',  4,  'month', 30, 'France calendrier vaccinal 2026'),
  ('FR', 'PCV-2',     'Pneumococcal (PCV)',               'Dose 2',  4,  'month', 31, 'France calendrier vaccinal 2026'),
  ('FR', 'MENB-2',    'Meningococcal B (MenB)',           'Dose 2',  5,  'month', 40, 'France calendrier vaccinal 2026'),
  ('FR', 'MENACWY-1', 'Meningococcal ACWY (MenACWY)',     'Dose 1',  6,  'month', 50, 'France calendrier vaccinal 2026'),
  ('FR', 'HEXA-3',    '6-in-1 (DTaP-IPV-Hib-HepB)',       'Booster', 11, 'month', 60, 'France calendrier vaccinal 2026'),
  ('FR', 'PCV-3',     'Pneumococcal (PCV)',               'Booster', 11, 'month', 61, 'France calendrier vaccinal 2026'),
  ('FR', 'MMR-1',     'MMR (measles, mumps, rubella)',    'Dose 1',  12, 'month', 70, 'France calendrier vaccinal 2026'),
  ('FR', 'MENACWY-2', 'Meningococcal ACWY (MenACWY)',     'Booster', 12, 'month', 71, 'France calendrier vaccinal 2026'),
  ('FR', 'MENB-3',    'Meningococcal B (MenB)',           'Booster', 12, 'month', 72, 'France calendrier vaccinal 2026'),
  ('FR', 'MMR-2',     'MMR (measles, mumps, rubella)',    'Dose 2',  16, 'month', 80, 'France calendrier vaccinal 2026'),
  ('FR', 'DTAP-IPV',  '4-in-1 booster (DTaP-IPV)',        'Booster', 72, 'month', 90, 'France calendrier vaccinal 2026'),
```
That is 16 rows. Rotavirus is given here as the 2-dose Rotarix schedule. If the baby gets RotaTeq, there is a third dose at 4 months:
```sql
  -- optional, RotaTeq only (3-dose product):
  -- ('FR', 'ROTA-3',  'Rotavirus (oral)',                 'Dose 3',  4,  'month', 32, 'France calendrier vaccinal 2026'),
```

### 1.2 Sources and notes
- **Calendrier des vaccinations et recommandations vaccinales 2026**, Ministère chargé de la santé, version dated **"Juillet 2026"** (sante.fr says it was published 26/08/2026 as an update of the April 2026 calendar). Official page: https://sante.gouv.fr/prevention-en-sante/preserver-sa-sante/vaccination/calendrier-vaccinal (it showed a captcha to the fetcher). The full PDF was read from a mirror (https://res.cloudinary.com/dpkkwt8w0/raw/upload/v1786964353/2026-08/CALENDRIER%202026.pdf), using the text of chapters 2.2, 2.11, 2.13, 2.14, 2.17, 2.18 and synoptic table 4.1. Summary page: https://www.sante.fr/node/1134620 (26/08/2026).
- Ages taken from the official text:
  - **Hexavalent:** 2 months (8 weeks), 4 months and 11 months; mandatory for children born since 1 Jan 2018. In the table, Hep B is at 2, 4 and 11 months.
  - **Pneumococcal:** 2, 4 and 11 months, with VPC15 Vaxneuvance or VPC13 Prevenar13; mandatory. Premature or high-risk babies get 2, 3 and 4 months plus 11 months. That extra 3-month dose is not a routine row.
  - **MenB (Bexsero):** "M3, M5, M12"; mandatory.
  - **MenACWY:** 6 months with Nimenrix, then a booster at 12 months with Nimenrix or MenQuadfi; mandatory. This replaced MenC (5 and 12 months) from 1 Jan 2025.
  - **MMR (ROR):** 12 months, then 16–18 months (16 used as the earliest age); mandatory.
  - **Rotavirus:** *recommended, not mandatory*. Rotarix at 2 and 3 months, or RotaTeq at 2, 3 and 4 months. Rotarix must be finished before 24 weeks, RotaTeq before 32 weeks.
  - **DTCaP booster at 6 years:** recommended.
- **The 11 mandatory vaccines** (D, T, P, aP, Hib, HepB, pneumo, MenC, MMR) apply to children born since 1 Jan 2018. On top of that, the 2026 calendar says: *"Pour tous les enfants nés après le 1er janvier 2023, les vaccinations contre les méningocoques ACWY et contre le méningocoque B sont obligatoires."* Some press articles give 1 Jan 2025 as the date, because that is when the new schedule started. The official text says born after 1 Jan 2023, with the obligation enforced through catch-up.
- **Transitional catch-up for MenACWY + MenB, ages 2 to 4 years inclusive.** This includes children who already had MenC. It is mandatory only for children born from 1 Jan 2023 who were not vaccinated before age 2. If the app wants catch-up reminders, they would be extra rows, e.g. MenACWY 1 dose and MenB 2 doses at least 1 month apart. Not included above.
- **Not routine, so left out:**
  - BCG: only for children at high TB risk, from 1 month of age. **Important for Palna users: the risk criteria include "Enfant dont au moins l'un des parents est originaire de l'un de ces pays [forte endémie]" and children who will stay ≥1 month in such a country. Pakistan is a high-incidence country, so most Palna families in France ARE in the BCG target group.** Consider an in-app note or a risk-flag row for BCG at 1 month.
  - Varicella: generalised vaccination of children "n'est pas recommandée".
  - Hepatitis A: risk groups only.
  - Flu and COVID: covered in sections 1.4 and 1.3.
- **Recent changes:**
  - 2025: MenC replaced by MenACWY at 6 and 12 months; MenB made mandatory.
  - 2026: MenACWY/B catch-up for ages 2–4 introduced; Flucelvax allowed for at-risk children aged 6–23 months; LFSS 2026 measles obligation for health and childcare staff.
  - Products: Neisvac (MenC) withdrawn 30 Jun 2025; Menjugate withdrawal planned for autumn 2026; Pentavac withdrawal planned for 31 Mar 2027.
- **Doubts:**
  1. Rotavirus product choice (2 vs 3 doses) depends on the doctor. I used Rotarix (2 doses).
  2. 16 months is the earliest age in the "16–18 mois" window for MMR-2.
  3. DOM-TOM (overseas territories) have extra items, e.g. yellow fever at 12 months in Guyane and BCG at birth in Guyane/Mayotte. Not included.

### 1.3 RSV for infants: YES, for all infants, national (since 2023 for nirsevimab, 2024 for Abrysvo)
Source: **DGS-Urgent n°2026_10, 10/08/2026** "Campagne de vaccination et d'immunisation contre les infections à VRS du nourrisson". Read in full via https://www.urml-normandie.org/wp-content/uploads/2026/08/DGS-Urgent-n°2026-10-campagne-VRS-2026.pdf. Also calendar chapter 2.14.

**Campaign dates for 2026/27:**
- Metropolitan France: **14 Sep 2026 – 28 Feb 2027**
- Antilles (Martinique, Guadeloupe, St-Martin, St-Barth): 31 Aug 2026 – 28 Feb 2027
- La Réunion: 28 Sep 2026 – 28 Mar 2027
- Mayotte: 1 Oct 2026 – 31 May 2027
- Guyane: all year

The PDF's dates table is laid out out of line with its labels; this matching of dates to territories is my reading of it.

**Two options; the parents choose:**
- **Maternal vaccine Abrysvo:** one dose at **32–36 weeks of amenorrhoea**, during the campaign period.
- **Monoclonal antibody for the baby:** Beyfortus (nirsevimab) or **Enflonsia (clesrovimab, new for 2026/27)**. Synagis is for preterm or high-risk babies only.

**Rules for the baby:**
- **Born during the campaign:** antibody **from birth, ideally before leaving the maternity ward**.
- **Born before or outside the campaign:** antibody **"idéalement avant la saison d'épidémie"**, for infants in their *first* RSV season, "y compris ceux nés hors période épidémique". No explicit age cut-off is given. In practice it means babies born since the end of the previous season, roughly from March 2026. No fixed cut-off was found, so please flag it.
- **Doses:**
  - Beyfortus: one dose, 50 mg if under 5 kg, 100 mg if 5 kg or more.
  - Enflonsia: one dose of 105 mg.
  - Second season: Beyfortus 200 mg only for vulnerable children under 24 months.

**Interplay with the maternal vaccine:** the antibody is *reserved for babies whose mother did NOT get Abrysvo*. The exceptions are birth less than 14 days after the vaccine and premature birth; those babies get the antibody as well. A mother who was vaccinated in a previous pregnancy should not get Abrysvo again; her baby gets the antibody instead.

**Cost:** reimbursement starts with the campaign start date. Press reports say 65 % from 31 Aug 2026, up from 30 %, plus top-up insurance (larevuedupraticien.fr). The 65 % figure was not in the DGS text.

### 1.4 Flu for young children: NOT routine
The calendar recommends flu vaccine only for children **from 6 months with risk conditions**. Flucelvax is newly possible for at-risk children aged 6–23 months. There is no universal paediatric flu programme. The calendar has no 2-dose rule for first-time children under 9 in this section (the SmPC rule applies). Source: calendar chapter 2.7 (Jul 2026).

### 1.5 Emergency numbers (France)
| Number | Service | App type | Note |
|---|---|---|---|
| 112 | EU emergency number | `all` | keep |
| **15** | SAMU, medical emergencies (doctor on the line) | `ambulance` | **The most useful one for parents** of a sick baby. |
| 17 | Police | `police` | |
| 18 | Pompiers (fire and rescue; they also do first aid) | `fire` | |
| 114 | Emergency number by SMS/app for deaf or hard-of-hearing people | `all` (or a new `textRelay` type) | optional |
| 116 117 | Out-of-hours GP (permanence des soins / médecin de garde) | **new type needed**, e.g. `outOfHoursDoctor` (or put it under `nurseLine`) | **Not yet nationwide**: rollout is regional (started 2017 in 3 regions, later extended). Current coverage was not verified; if unsure, tell users to call 15. |
| Poison centres | regional, no single national number | `poison` | Paris 01 40 05 48 48, Angers 02 41 48 21 21, Bordeaux 05 56 96 40 80, Lille 0 800 59 59 59, Lyon 04 72 11 69 11, Marseille 04 91 75 25 25, Nancy 03 83 22 50 50, Toulouse 05 61 77 74 47 (and Strasbourg 03 88 37 37 37 per one source). All 24/7. Suggest listing Paris (it covers Île-de-France) or skipping it and relying on 15. |

Sources: ARS Île-de-France CAPTV page (https://www.iledefrance.ars.sante.fr/centre-antipoison-et-de-toxicovigilance-dile-de-france-captv); inc-conso.fr list of numbers. These are widely documented, but only partly checked.

---

## 2. Norway (NO)

### 2.1 Routine schedule

```sql
  ('NO', 'ROTA-1', 'Rotavirus (oral)',               'Dose 1',  6,  'week',  10, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'HEXA-1', '6-in-1 (DTaP-IPV-Hib-HepB)',     'Dose 1',  3,  'month', 20, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'PCV-1',  'Pneumococcal (PCV)',             'Dose 1',  3,  'month', 21, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'ROTA-2', 'Rotavirus (oral)',               'Dose 2',  3,  'month', 22, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'HEXA-2', '6-in-1 (DTaP-IPV-Hib-HepB)',     'Dose 2',  5,  'month', 30, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'PCV-2',  'Pneumococcal (PCV)',             'Dose 2',  5,  'month', 31, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'HEXA-3', '6-in-1 (DTaP-IPV-Hib-HepB)',     'Booster', 12, 'month', 40, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'PCV-3',  'Pneumococcal (PCV)',             'Booster', 12, 'month', 41, 'FHI Barnevaksinasjonsprogrammet 2026'),
  ('NO', 'MMR-1',  'MMR (measles, mumps, rubella)',  'Dose 1',  15, 'month', 50, 'FHI Barnevaksinasjonsprogrammet 2026'),
```
That is 9 rows. Norway has **no pre-school booster before age 6**. The DTaP-IPV booster comes in school year 2, at about 7 years. Optional row if the owner wants it, since it is the counterpart of other countries' pre-school booster:
```sql
  -- optional (school-age, ~7 y, 2nd grade):
  -- ('NO', 'DTAP-IPV', '4-in-1 booster (DTaP-IPV)',  'Booster', 84, 'month', 60, 'FHI Barnevaksinasjonsprogrammet 2026'),
```

### 2.2 Sources and notes
- FHI: "Når får barnet ditt tilbud om de ulike vaksinene i barnevaksinasjonsprogrammet?", https://www.fhi.no/va/vaksiner-barn/nar-far-barnet-ditt-tilbud-om-de-ulike-vaksinene/ (last changed 24.02.2025). Ages it gives:
  - **6 weeks:** rotavirus (BCG for risk groups)
  - **3 months:** rotavirus, DTP-IPV-Hib-HepB, pneumococcal
  - **5 months:** DTP-IPV-Hib-HepB, pneumococcal
  - **12 months:** DTP-IPV-Hib-HepB, pneumococcal
  - **15 months:** MMR
  - **2nd grade:** DTP-IPV
  - **6th grade:** MMR
  - **7th grade:** HPV
  - **10th grade:** dTP-IPV
  - **In pregnancy:** pertussis vaccine at week 24, since May 2024
- FHI Vaksinasjonshåndboka, "Barnevaksinasjonsprogrammet", https://www.fhi.no/va/vaksinasjonshandboka/vaksinasjon/barnevaksinasjonsprogrammet/ (last updated 16.06.2026). Same schedule. Hep B has been universal through the hexavalent vaccine since late 2016/2017 (the page gives both 1 Nov 2016 and 2017). Rotavirus started autumn 2014 for children born from 1 Sep 2014.
- Rotavirus is 2 doses (Rotarix) at 6 weeks and 3 months.
- **Left out:**
  - BCG: risk groups only, i.e. children with a parent from a high-TB-incidence country. **This includes Pakistani-origin families, who are offered BCG around 6 weeks.** Consider an in-app note or a risk-flag row, as for France.
  - The extra hexavalent "dose 0" at 6–8 weeks for babies born before week 32.
- **Upcoming change:** FHI recommended varicella vaccine at **15 months + 2nd grade** on 28.01.2026 (https://www.fhi.no/nyheter/2026/fhi-anbefaler-a-innfore-vannkoppevaksine-i-barnevaksinasjonsprogrammet/). **No government decision was found** as of Oct 2026, so it is not in the programme yet. FHI's programme strategy 2026–2030 was published in 2026.
- **Doubts:**
  1. Pneumococcal product (PCV13/15/20) is not named on the pages, so the row uses the generic "PCV".
  2. Whether to include the 7-year booster (see above).

### 2.3 RSV for infants: NOT yet national for all infants in 2026/27
- FHI recommended RSV immunisation to protect all infants (maternal vaccine or infant antibody) on 27.11.2025: https://www.fhi.no/publ/2025/anbefaling-om-immunisering-mot-rsv-for-a-beskytte-spedbarn/
- Stortinget (parliament) pushed in spring 2026 for a programme, ideally before the 2026/27 season.
- **The government's 2027 budget proposal (Oct 2026)** would bring RSV protection into the barnevaksinasjonsprogrammet **from 1 July 2027**, with NOK 55 million. It is **still undecided whether this will be a seasonal infant antibody or the maternal vaccine**; that will be settled in procurement. Source: regjeringen.no, "Regjeringen vil ha beskyttelse mot RS-virus inn i barnevaksinasjonsprogrammet" (https://www.regjeringen.no/no/aktuelt/regjeringen-vil-ha-beskyttelse-mot-rs-virus-inn-i-barnevaksinasjonsprogrammet/id3174122/). The page returned 403 to the fetcher; its content is known only from search snippets, so treat it as medium confidence. Still to be passed by Stortinget.
- **2026/27 season:** only **risk groups** get nirsevimab/palivizumab through the hospitals. Per Helsebiblioteket, Nye Metoder widened reimbursement in Sept 2026 to include, among others, babies born before week 35. Abrysvo can be bought privately at pharmacies (~NOK 2,500).
- **For the app:** no universal RSV reminder for Norway in 2026/27. Revisit in spring 2027 (likely the 2027/28 season).

### 2.4 Flu for young children: NOT routine
Flu vaccine is recommended only for children in risk groups from 6 months. These include, e.g., babies born before week 32 (from 6 months up to 5 years) and chronic conditions. Fluenz nasal spray is used for risk-group children aged 2–17. Children under 9 vaccinated for the first time get 2 doses at least 4 weeks apart. FHI says there are no changes in target groups for autumn 2026. No universal paediatric programme or pilot was found. Sources: FHI "Bestilling av sesonginfluensavaksine 2026/2027" (https://www.fhi.no/meldinger/bestilling-av-sesonginfluensavaksine-20262027/) and NHI/DMP 2026/27 influenza vaccine notes.

### 2.5 Emergency numbers (Norway)
| Number | Service | App type | Note |
|---|---|---|---|
| 112 | Police (and EU emergency number) | `police`, or keep `all` | In Norway 112 goes to the **police**, not to a unified centre. Keeping "112 (all)" is OK, since calls get routed, but parents should know 113 is the medical line. |
| **113** | Medical emergency / ambulance (AMK) | `ambulance` | **The most important one for a sick baby.** |
| 110 | Fire | `fire` | |
| **116 117** | Legevakt, out-of-hours doctor (nationwide; connects to the local legevakt) | **new type needed**, e.g. `outOfHoursDoctor` (or `nurseLine`) | Very useful for parents. |
| 22 59 13 00 | Giftinformasjonen, Norwegian Poison Information Centre, 24/7 | `poison` | Verified on helsenorge.no / FHI (https://www.fhi.no/kl/giftinformasjon/akutt-forgiftning-ring-giftinformas/) |

---

## 3. Sweden (SE)

### 3.1 Routine schedule

```sql
  ('SE', 'ROTA-1',   'Rotavirus (oral)',               'Dose 1',  6,  'week',  10, 'Folkhälsomyndigheten 2026'),
  ('SE', 'HEXA-1',   '6-in-1 (DTaP-IPV-Hib-HepB)',     'Dose 1',  3,  'month', 20, 'Folkhälsomyndigheten 2026'),
  ('SE', 'PCV-1',    'Pneumococcal (PCV)',             'Dose 1',  3,  'month', 21, 'Folkhälsomyndigheten 2026'),
  ('SE', 'ROTA-2',   'Rotavirus (oral)',               'Dose 2',  3,  'month', 22, 'Folkhälsomyndigheten 2026'),
  ('SE', 'HEXA-2',   '6-in-1 (DTaP-IPV-Hib-HepB)',     'Dose 2',  5,  'month', 30, 'Folkhälsomyndigheten 2026'),
  ('SE', 'PCV-2',    'Pneumococcal (PCV)',             'Dose 2',  5,  'month', 31, 'Folkhälsomyndigheten 2026'),
  ('SE', 'ROTA-3',   'Rotavirus (oral)',               'Dose 3',  5,  'month', 32, 'Folkhälsomyndigheten 2026'),
  ('SE', 'HEXA-3',   '6-in-1 (DTaP-IPV-Hib-HepB)',     'Booster', 12, 'month', 40, 'Folkhälsomyndigheten 2026'),
  ('SE', 'PCV-3',    'Pneumococcal (PCV)',             'Booster', 12, 'month', 41, 'Folkhälsomyndigheten 2026'),
  ('SE', 'MMR-1',    'MMR (measles, mumps, rubella)',  'Dose 1',  18, 'month', 50, 'Folkhälsomyndigheten 2026'),
  ('SE', 'DTAP-IPV', '4-in-1 booster (DTaP-IPV)',      'Booster', 60, 'month', 60, 'Folkhälsomyndigheten 2026'),
```
That is 11 rows.

**Coming 1 Jan 2027 (decided):** chickenpox vaccine at 18 months, for children born on or after 1 Jul 2025. The second dose is at 7–8 years, through school, so it is skipped. Add this row when the cohort rule can be handled, or now, since any baby born after Jul 2025 turns 18 months in Jan 2027 or later:
```sql
  ('SE', 'VAR-1',    'Chickenpox (varicella)',         'Dose 1',  18, 'month', 51, 'Folkhälsomyndigheten 2027'),
```

### 3.2 Sources and notes
- Folkhälsomyndigheten, "Barnvaccinationsprogram", https://www.folkhalsomyndigheten.se/vara-amnesomraden/vaccinationer/nationella-vaccinationsprogram/barnvaccinationsprogram/ (updated 16 Apr 2026). Table:
  - **Rotavirus:** 6 weeks, 3 months, 5 months. Footnote: the 3rd dose applies only to a 3-dose vaccine.
  - **D/T/aP:** 3, 5 and 12 months, 5 years, grade 8–9 (dTaP).
  - **Polio:** 3, 5 and 12 months, 5 years.
  - **Hib, Hep B, pneumococcal:** 3, 5 and 12 months.
  - **MPR (MMR):** 18 months, grade 1–2.
  - **HPV:** grade 5.
- 1177 (Stockholm), "Vaccinationsprogrammet för barn", https://www.1177.se/Stockholm/undersokning-behandling/vaccinationer/vaccinationsprogrammet-for-barn/ (updated 2026-10-21). Same ages. It says varicella will be added on **1 Jan 2027 for children born on or after 1 Jul 2025**.
- 1177, "Vaccination mot rotavirus", https://www.1177.se/undersokning-behandling/vaccinationer/vaccination-mot-rotavirus/ (2023-10-05). Three doses:
  - Dose 1 at 6 weeks (latest before 12 weeks)
  - Dose 2 at 3 months (latest before 16 weeks)
  - Dose 3 at 5 months (latest before 32 weeks)
  - That matches RotaTeq. Rotavirus has been national since 1 Sep 2019.
- Varicella decision: FoHM "Nationella vaccinationsprogram" page (8 Sep 2026): "I januari 2027 kommer vaccination mot vattkoppor att införas i barnvaccinationsprogrammet". TT/TV4, 31 Jul 2026, "Klart: gratis vattkoppsvaccin för barn": dose 1 at 18 months at BVC and dose 2 at 7–8 years in school; temporary catch-up for ages 5–17. Government press release Sep 2025: https://regeringen.se/pressmeddelanden/2025/09/vaccin-mot-vattkoppor-infors-i-det-nationella-allmanna-vaccinationsprogrammet-for-barn/
- **Hepatitis B, a correction to the brief:** I found **no evidence that Hep B became part of the *national* programme**. FoHM still says that the regions offer it free through **regional** programmes, which all regions have done since 2016, and that FoHM "rekommenderar vaccination mot hepatit B till alla spädbarn". The government decided against national inclusion in 2017. In practice every Swedish baby gets the 6-in-1, so the rows are right for users; only the legal status differs.
- **Doubts:**
  1. **Rotavirus dose count by region.** The national pages list 3 doses (RotaTeq). A region using Rotarix would give only 2 (6 weeks + 3 months), so ROTA-3 may not apply everywhere. Current regional procurement was not checked.
  2. The dose_label "Booster" for the 12-month dose; FoHM's table calls it "dos 3".
  3. MMR dose 2 (grade 1–2, about 6–8 years) is left out as school-age.
  4. BCG is for risk groups only, e.g. a parent from a high-TB-incidence country. **This includes Pakistani-origin families in practice**; the regional BVC offers it, often around 6 weeks. Consider a note, as for France and Norway.

### 3.3 RSV for infants: YES, but via the regions (NT-rådet), antibody at birth only
- Source: **NT-rådets yttrande till regionerna, Beyfortus (nirsevimab), 2026-08-27**. Read in full: https://samverkanlakemedel.se/download/18.628deecb1a0421f757a1206/1787832827884/Beyfortus%20nirsevimab%20med%20uppdatering%202026-08-27.pdf. Product page: https://samverkanlakemedel.se/produktinfo/beyfortus-nirsevimab
- This is not part of the national vaccination programme. It is a joint recommendation to all 21 regions, second season after the 2025/26 start, and regional rollout may vary a little.
- **Babies born during the season:** Beyfortus is offered to **babies born from 10 Sep 2026**. It is given at the delivery ward / BB, **right after birth before going home, or at a routine follow-up visit**.
- **Season end:** immunisation stops when Folkhälsomyndigheten judges that spread has declined, usually around March; there is no fixed end date.
- **Babies born before 10 Sep 2026:** **no universal catch-up.** Only risk groups 1–2 get it, i.e. under 12 months with medical risk conditions, plus up to 24 months in the 2nd season for high-risk children (the old Synagis criteria).
- **Maternal vaccine Abrysvo:** not part of the regional programme (privately available). There is no NT guidance on interplay; ask the midwife or BVC.
- Results: Socialstyrelsen reports fewer RSV hospitalisations in infants under 6 months since the 2025 start (LäkemedelsVärlden).

### 3.4 Flu for young children: NOT routine
Flu vaccine is recommended only for risk-group children from 6 months (FoHM risk-group guidance of 4 Sep 2025, carried into 2026/27 regional guidelines). There is no universal paediatric flu programme or national pilot. The first-time 2-dose rule for children under 9 applies per the SmPC. Source: 1177 regional "Vaccination covid-19 influensa" pages and regional 2025/26 guidelines (e.g. Region Kalmar). Unlike Finland, which vaccinates all children aged 6 months – 6 years.

### 3.5 Emergency numbers (Sweden)
| Number | Service | App type | Note |
|---|---|---|---|
| 112 | Unified emergency: ambulance, police, fire, and acute poisoning | `all` / `unified` | keep |
| **1177** | Healthcare advice (Vårdguiden), nurse line, 24/7 | `nurseLine` | "Ring telefonnummer 1177 för sjukvårdsrådgivning dygnet runt" (1177.se) |
| 114 14 | Police, non-emergency | `police` | optional |
| 010-456 67 00 | Giftinformationscentralen (poison information), for *less acute* cases; acute → 112 | `poison` | Verified on giftinformation.se ("I mindre akuta fall: 010-456 6700"; "När det är akut: 112") |

---

## Summary table

| Country | Routine rows (birth–6 y) | Confidence | Main doubts |
|---|---|---|---|
| FR | 16 (+1 optional RotaTeq dose 3) | High | Rotavirus product (2 vs 3 doses); MMR-2 window 16–18 months (16 used); BCG recommended for Pakistani-origin families; 116 117 only regional |
| NO | 9 (+1 optional 7-year DTaP-IPV) | High | No booster before 6 years; varicella recommended but not decided; RSV programme only from 1 Jul 2027 (product undecided) |
| SE | 11 (+1 varicella row from 1 Jan 2027) | High for the schedule, medium for rotavirus dose count | ROTA-3 depends on the product; Hep B is regional (all regions), not national; RSV is regional, at birth only, born ≥10 Sep 2026 |

**New app service type suggested:** `outOfHoursDoctor` for France 116 117 (regional) and Norway 116 117 (legevakt). If no new type is wanted, map them to `nurseLine`.
