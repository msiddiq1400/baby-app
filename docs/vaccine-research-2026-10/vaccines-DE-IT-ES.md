# Vaccine schedules: Germany (DE), Italy (IT), Spain (ES)

Researched 27 Oct 2026 for Palna. Each country's section has the SQL rows, then sources and notes, RSV, flu and emergency numbers.

Flags used below: **[CHECK]** means a doubt for the pediatrician to review. **[CHOICE]** means a judgement call that is mine, not the source's.

I could not use the ECDC Vaccine Scheduler as a cross-check: its pages would not load through my fetch tool. The WHO portal was not checked either. Every row below comes from the national primary documents.

---

## Germany (DE)

### 1. Routine schedule (STIKO standard 2+1 for term babies)

```sql
  ('DE', 'ROTA-1',  'Rotavirus (RV, oral)', 'Dose 1', 6, 'week', 10, 'STIKO Germany 2026'),
  ('DE', 'HEXA-1',  '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'STIKO Germany 2026'),
  ('DE', 'PCV-1',   'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 21, 'STIKO Germany 2026'),
  ('DE', 'MENB-1',  'Meningococcal B (MenB)', 'Dose 1', 2, 'month', 22, 'STIKO Germany 2026'),
  ('DE', 'ROTA-2',  'Rotavirus (RV, oral)', 'Dose 2', 3, 'month', 30, 'STIKO Germany 2026'),
  ('DE', 'HEXA-2',  '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 40, 'STIKO Germany 2026'),
  ('DE', 'PCV-2',   'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 41, 'STIKO Germany 2026'),
  ('DE', 'MENB-2',  'Meningococcal B (MenB)', 'Dose 2', 4, 'month', 42, 'STIKO Germany 2026'),
  ('DE', 'ROTA-3',  'Rotavirus (RV, oral) - only with the 3-dose vaccine (RotaTeq)', 'Dose 3', 4, 'month', 43, 'STIKO Germany 2026'),
  ('DE', 'HEXA-3',  '6-in-1 (DTaP-IPV-Hib-HepB)', 'Booster', 11, 'month', 50, 'STIKO Germany 2026'),
  ('DE', 'PCV-3',   'Pneumococcal conjugate (PCV)', 'Booster', 11, 'month', 51, 'STIKO Germany 2026'),
  ('DE', 'MMR-1',   'Measles, mumps, rubella (MMR)', 'Dose 1', 11, 'month', 52, 'STIKO Germany 2026'),
  ('DE', 'VAR-1',   'Chickenpox (varicella, V)', 'Dose 1', 11, 'month', 53, 'STIKO Germany 2026'),
  ('DE', 'MENB-3',  'Meningococcal B (MenB)', 'Booster', 12, 'month', 60, 'STIKO Germany 2026'),
  ('DE', 'MMR-2',   'Measles, mumps, rubella (MMR)', 'Dose 2', 15, 'month', 70, 'STIKO Germany 2026'),
  ('DE', 'VAR-2',   'Chickenpox (varicella, V)', 'Dose 2', 15, 'month', 71, 'STIKO Germany 2026'),
  ('DE', 'TDAP',    'Tetanus-diphtheria-pertussis booster (Tdap)', 'Booster', 60, 'month', 80, 'STIKO Germany 2026'),
```

That is 17 rows, or 16 if ROTA-3 is dropped.

### 2. Sources and notes

**Source**
- STIKO recommendations 2026, *Epidemiologisches Bulletin 4/2026*, 22 Jan 2026. Table 1A/1B "Impfkalender 2026" is on page 8.
  - https://www.rki.de/DE/Aktuelles/Publikationen/Epidemiologisches-Bulletin/2026/04_26.pdf
  - The current PDF version carries margin notes for the 10 Sep 2026 RSV update and the 9 Jul 2026 COVID update.
- RKI calendar page: https://www.rki.de/DE/Themen/Infektionskrankheiten/Impfen/Impfkalender/impfkalender-node.html
- BIÖG (formerly BZgA) simplified parent calendar "Impfkalender 2026, Stand Januar 2026": https://shop.bioeg.de/pdf/11128029.pdf

**Changes in 2025–2026 (important)**
- **MenC at 12 months is dropped from 2026** (Epid Bull 44/2025). It is replaced by MenACWY at 12–14 years, which is school age and so not in the rows. **If the app has an older DE MenC row, remove it.**
- MenB has been standard since 2024 at 2, 4 and 12 months. This is 2+1, as the vaccine label sets for a start at 2–23 months.
- RSV: clesrovimab was added alongside nirsevimab on 10 Sep 2026 (see section 3).

**Rotavirus timing [CHECK]**
- STIKO's text says the first dose is given from 6 weeks, and the series is started by 12 weeks at the latest.
  - Rotarix: 2 doses, at least 4 weeks apart, finished preferably by 16 weeks and at the latest by 24 weeks.
  - RotaTeq: 3 doses, finished preferably by 20–22 weeks and at the latest by 32 weeks.
- Table placement:
  - G1 is in the 6-week column.
  - G2 is in the 3-month column.
  - "(G3)" sits at 3–4 months.
- I read the column placement from text extracted out of the PDF, because the table could not be shown as an image. Two separate PDFs (RKI and BIÖG) both put G2 between the 6-in-1 doses at 2 and 4 months, so G2 at 3 months is fairly solid. "(G3)" sits right after G2, at the 3–4 month boundary; I used 4 months.
- **[CHOICE]** ROTA-3 only applies with RotaTeq. Drop it, or show it as conditional, if a reminder for a dose the baby may not need is unwanted.

**Other notes**
- **Preterm (born before 37+0 weeks): 3+1 scheme.** Add a dose of the 6-in-1 and of PCV at 3 months, giving 4 doses in total at 2, 3, 4 and 11 months (footnote c). MenB stays 2+1. Rotavirus follows chronological age from 6 weeks, including in hospital.
- Booster minimum interval: 6 months after the previous dose (footnote f). STIKO wants the 6-in-1 and PCV finished by 11 months, MenB by 12 months and MMR by 15 months.
- **MMR + varicella:** dose 1 at 11 months, dose 2 at 15 months. They can be given at the same visit or at least 4 weeks apart.
  - STIKO prefers MMR and V given separately for the first dose. Combined MMRV carries a slightly higher febrile-seizure risk in under-5s.
  - The first MMR can be given from 9 months if the child starts daycare early; the BIÖG leaflet mentions this.
  - Germany's Masernschutzgesetz requires measles proof for daycare (2 doses from age 2).
- PCV: infants, including preterm babies, get PCV13 or PCV15 (footnote d).
- **5–6 years:** Tdap booster (tetanus, diphtheria, pertussis A1).
  - The polio booster (A1) is at 9–16 years, so it is not in the rows.
  - Hep B at 5+ years is catch-up only.

### 3. RSV for infants: yes, all infants (national standard)

- **Who:** STIKO recommends a single dose of a long-acting monoclonal antibody for **all newborns and infants in their first RSV season**, whatever their risk factors. This has been the standard since June 2024 (Epid Bull 26/2024).
  - **From 10 Sep 2026 (Epid Bull 37/2026), clesrovimab (Enflonsia) and nirsevimab (Beyfortus) are both recommended.**
  - Clesrovimab could be prescribed under statutory health insurance (GKV) from 1 Oct 2026. Some KV notices from mid-September still said nirsevimab only.
- **Season:** usually October to March.
- **Born during the season (Oct–Mar):** dose as soon as possible after birth, ideally at discharge from the birth clinic or at the U2 check-up (day 3–10 of life).
- **Born April–September:** dose in autumn before their first season.
  - STIKO footnote: "im Herbst vor Beginn ihrer 1. RSV-Saison". The BIÖG leaflet says September–November.
  - The Ministry of Health (BMG) suggests doing it at the U4 or U5 check-up.
- **Catch-up:** missed doses as soon as possible during the first season, and up to the first birthday, decided case by case (BMG).
- **Maternal vaccine (Abrysvo):** STIKO does **not** currently recommend RSV vaccination in pregnancy (BMG FAQ, 2 Oct 2026).
- Cost: free under GKV (Sachleistung). Private insurance generally covers it.
- **App suggestion:** one RSV reminder. Born Oct–Mar: "at birth / U2". Born Apr–Sep: "September–November before the first season".

Sources:
- STIKO Epid Bull 4/2026, Table 1 footnote a.
- RKI decision, Epid Bull 37/2026 (DOI 10.25646/14417): https://edoc.rki.de/handle/176904/13913
- BMG FAQ, 2 Oct 2026: https://www.bundesgesundheitsministerium.de/themen/praevention/impfungen/schutz-vor-rsv-infektionen/rsv-prophylaxe-neugeborene-und-saeuglinge
- KBV notice, 17 Sep 2026: https://www.kbv.de/praxis/tools-und-services/praxisnachrichten/2026/09-17/rsv-prophylaxe-bei-gesunden-saeuglingen-vorerst-weiterhin-nur-mit-nirsevimab
- Ärzteblatt on clesrovimab: https://www.aerzteblatt.de/news/rsv-prophylaxe-bei-gesunden-sauglingen-auch-mit-clesrovimab-moglich-6920ae09-2546-43e0-b870-08ea1c85f73d

### 4. Flu for young children: no, risk groups only

- Germany recommends flu vaccine only for children from 6 months with chronic illness (an indication vaccination). There is no universal recommendation for children.
  - Source: BIÖG calendar 2026, "Personen ab 6 Monate mit chronischen Erkrankungen (jährlich)".
  - Source: STIKO 2026, Table 2.
- The 2026 update added a flu indication for people in close contact with pigs or poultry, because of H5N1 bird flu. It does not change anything for children.

### 5. Emergency numbers (DE)

| Number | Service | App type |
|---|---|---|
| 112 | Fire and ambulance (keep the existing "all" row) | all |
| 110 | Police (112 does not reach the police in Germany) | police |
| 116 117 | Out-of-hours doctor service (ärztlicher Bereitschaftsdienst), free, 24/7, nationwide | **new type needed:** `outOfHoursDoctor`. `nurseLine` is the closest existing type, but it is a doctor service, not a nurse line. |
| Regional, see below | Poison centre (Giftnotruf) | poison |

**Poison centres.** There is no single national poison number. Each centre is reached at its own area code plus 19240, except Erfurt.

| Centre | Number | Covers |
|---|---|---|
| Berlin (Charité) | 030 19240 | Berlin, Brandenburg |
| Bonn | 0228 19240 | North Rhine-Westphalia |
| Freiburg | 0761 19240 | Baden-Württemberg |
| Göttingen (GIZ-Nord) | 0551 19240 | Bremen, Hamburg, Lower Saxony, Schleswig-Holstein |
| Mainz | 06131 19240 | Rhineland-Palatinate, Hesse, Saarland |
| Munich | 089 19240 | Bavaria |
| Erfurt (GGIZ) | 0361 730730 | Mecklenburg-Vorpommern, Saxony, Saxony-Anhalt, Thuringia |

- **[CHOICE]** Show "Giftnotruf (Berlin) 030 19240" with a note that every centre answers all callers, or let the user pick their region.
- Source: BfR list of centres: https://www.bfr.bund.de/deutsches-produktregister-depro/giftinformationszentren-in-deutschland/ (numbers checked against several lists; check again before release).

**Confidence for Germany: high.** The rows come straight from the official 2026 table. The one medium point is the rotavirus G2/G3 column, read from extracted PDF text.

---

## Italy (IT)

### 1. Routine schedule (national PNPV calendar, all babies)

Italy counts months as completed ("mesi compiuti"). For example, "2 months" means from day 61 of life.

```sql
  ('IT', 'HEXA-1',    '6-in-1 (DTaP-IPV-HepB-Hib)', 'Dose 1', 2, 'month', 10, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'PCV-1',     'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 11, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'ROTA-1',    'Rotavirus (RV, oral)', 'Dose 1', 2, 'month', 12, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'MENB-1',    'Meningococcal B (MenB)', 'Dose 1', 2, 'month', 13, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'HEXA-2',    '6-in-1 (DTaP-IPV-HepB-Hib)', 'Dose 2', 4, 'month', 20, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'PCV-2',     'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 21, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'ROTA-2',    'Rotavirus (RV, oral)', 'Dose 2', 4, 'month', 22, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'MENB-2',    'Meningococcal B (MenB)', 'Dose 2', 4, 'month', 23, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'HEXA-3',    '6-in-1 (DTaP-IPV-HepB-Hib)', 'Booster', 10, 'month', 30, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'PCV-3',     'Pneumococcal conjugate (PCV)', 'Booster', 10, 'month', 31, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'MMRV-1',    'Measles, mumps, rubella, chickenpox (MMRV or MMR+V)', 'Dose 1', 12, 'month', 40, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'MENACWY-1', 'Meningococcal ACWY (MenACWY)', null, 12, 'month', 41, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'MENB-3',    'Meningococcal B (MenB)', 'Booster', 13, 'month', 50, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'DTAP-IPV',  'Diphtheria-tetanus-pertussis-polio booster (DTaP-IPV)', 'Booster', 60, 'month', 60, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
  ('IT', 'MMRV-2',    'Measles, mumps, rubella, chickenpox (MMRV or MMR+V)', 'Dose 2', 60, 'month', 61, 'Italy PNPV 2023-2025 (extended to 2026) / Ministero della Salute'),
```

That is 15 rows. If the source label is too long, a shorter one is `'Italy PNPV 2023-2025 (prorogato 2026)'`.

### 2. Sources and notes

**Status of the plan**
- The PNPV 2023-2025 was **extended by one year, to 31 Dec 2026**, by the Stato-Regioni Intesa rep. atti 243/CSR of 18 Dec 2025.
- A timetable for immunisation activities followed in Intesa 29/CSR of 18 Mar 2026: https://www.statoregioni.it/media/eqpdiws2/p-3-csr-atto-rep-n29-18marzo2026.pdf
- **No new PNPV had been approved as of Oct 2026.** A new plan with a changed calendar could arrive for 2027. Re-check early in 2027.
- Background on the extension (Quotidiano Sanità): https://www.quotidianosanita.it/governo-e-parlamento/piano-nazionale-vaccini-dal-ministero-la-proposta-di-prorogare-l-attuale-fino-al-dicembre/
- Do not confuse it with the "PNP 2026-2031", the general prevention plan agreed 26 May 2026. It is not the vaccine calendar.

**Calendar source**
- I read the "Calendario Nazionale Vaccinale per età", annex to the PNPV 2023-2025, from the image copy that ASL Nuoro republished.
  - https://www.asl3nuoro.it/wp-content/uploads/2024/06/Calendario-in-allegato-al-Piano-Nazionale-di-Prevenzione-Vaccinale-2023-2025.docx
  - The same calendar appears in the ASL Roma 3 copy (July 2026): https://www.aslroma3.it/wp-content/uploads/2026/07/Allegato-n°-2-Calendario_vaccinale_PNPV-_2023-2025.pdf
- Cross-checked with ISS EpiCentro: https://www.epicentro.iss.it/vaccini/calendario (updated 24 Apr 2025).
- Cross-checked with the Piemonte regional calendar, which applies the PNPV: https://www.regione.piemonte.it/web/media/40989/download

**What the national table shows**

| Vaccine | Ages (completed) | Notes |
|---|---|---|
| 6-in-1 | 2, 4 and 10 months | 10 months = from day 301 |
| PCV | 2, 4 and 10 months | |
| Rotavirus | Band from 2 to 5 months, 2 or 3 doses | From week 6; finish by 24 or 32 weeks depending on the product |
| MenB | Band from 2 to 5 months, then booster at 13/14 months | Not before 2 months; 2nd dose at least 2 months after the 1st; booster at least 6 months after the primary series |
| MMRV or MMR+V | 12 months and 5 years | |
| MenACWY | 12 months | Adolescent dose later |
| DTaP-IPV | 5 years | Adult-type dTaP allowed from 4 years |
| Flu | Band from 6 months to 6 years | |

**Doubts and choices**
- **MenB timing [CHECK]**
  - I used the earliest ages the national rules allow: 2 months, then 4 months.
  - In practice most regions give MenB 1–2 weeks after the 6-in-1 visit, to space out fever. Examples:
    - Piemonte: from day 76 and from day 136.
    - EpiCentro text: day 91 (3 months) and day 151 (5 months), booster at 15 months.
  - **[CHOICE]** If you prefer the typical practice over the earliest age, use MENB-1 = 3 months and MENB-2 = 5 months.
  - I put the booster at 13 months (the national table's 13/14-month column). EpiCentro and some regions say 13–15 months.
- **Rotavirus [CHECK]**
  - Dose 1 at 2 months: the table's band starts at 2 months and the dose is usually given with the 6-in-1, although the footnote allows it from 6 weeks.
  - Dose 2 at 4 months: assumes Rotarix given with the 2nd 6-in-1. With a 4-week minimum gap, 3 months is also possible.
  - Regions using RotaTeq give a 3rd dose (for example 3rd, 4th and 5th month of life). I left that row out because the national calendar gives no age.
- **Hep B at birth:** only for babies of HBsAg-positive mothers (risk group), so not in the rows.
- **Regional extras:** regions can and do add vaccines or move dates. Examples:
  - MenB and rotavirus visit dates differ by region.
  - Some regions use MMR + separate V instead of MMRV.
  - Some offer extra flu or RSV programmes (see section 3).
- **Preterm babies:** the national calendar has no 3+1 rule. Preterm babies follow chronological age.

### 3. RSV for infants: free for all newborns in practice, run by the regions (not in the national calendar)

**2024/25**
- A State-Regions agreement (17 Oct 2024, €50 million) funded free nirsevimab for all newborns nationwide.
  - Babies born from November got it at the birth clinic.
  - Babies born in the previous ~100 days got it from family pediatricians.
- This followed Ministry circular prot. 9486 of 27 Mar 2024, "Misure di prevenzione e immunizzazione contro il VRS".
- Sources:
  - https://tg24.sky.it/salute-e-benessere/2024/10/17/vaccino-bronchiolite-neonati
  - https://quifinanza.it/salute/farmaco-anti-bronchiolite-gratis-neonati/858603/

**2025/26**
- A national document with about €50 million for universal infant immunisation, plus RSV vaccination for pregnant women, went to the State-Regions conference (reported Nov 2025).
- Regions ran their own campaigns; for example Emilia-Romagna started in September 2025 and Valle d'Aosta on 1 Oct 2025.
- **[CHECK]** I could not open the article to confirm that the 2025/26 agreement was finally approved, or its exact rules.
- Source: https://www.quotidianosanita.it/governo-e-parlamento/virus-respiratorio-sinciziale-immunizzazione-universale-per-neonati-e-vaccino-per-le-donne-in-gravidanza-in-arrivo-mln-dal-fondo-sanitario/

**2026/27**
- Campaigns are again **regional**. I found no national circular for 2026/27.
- Examples:
  - Piemonte: DGR of 30 Jul 2026, voluntary passive immunisation for the 2026/27 season.
  - Liguria: nirsevimab at birth clinics for newborns, and through the family pediatrician for babies born from April 2026.
  - Lombardia and Friuli Venezia Giulia also have campaigns.
- Clesrovimab (MSD) became available in Italy in October 2026 after AIFA approval. Regional use still needs local decisions.
- Sources:
  - Piemonte DGR: https://www.regione.piemonte.it/governo/bollettino/abbonati/2026/31/attach/dgr_02906_1050_30072026.pdf
  - RIFday, 14 Oct 2026: https://www.rifday.it/2026/10/14/prevenzione-rsv-arriva-in-italia-il-monoclonale-clesrovimab-per-neonati-nella-prima-stagione/

**Typical rules**
- Season: about November to March; some regions start in October.
- Born in season: dose at the birth clinic before discharge.
- Born from about April to October: catch-up at the start of the season through the pediatrician or vaccination centre.
- Exact cohorts vary by region.

**Maternal vaccine:** included in the 2025/26 national proposal. Availability by region is unclear **[CHECK]**.

**App suggestion:** show RSV as "offered free to all newborns by your region; ask your pediatrician or birth clinic". Do not give exact national dates.

**Confidence: medium-low.** The policy is spread across regions and not written in one national document.

### 4. Flu for young children: yes, ages 6 months to 6 years

- The PNPV calendar band runs from 6 months to 6 years, with details set each year by Ministry circular.
- The **2026-2027 circular n. 5134 of 23 Jun 2026** offers flu vaccine free and actively to **children from 6 months to 6 years**.
  - Campaigns start from early October (week 40), and the vaccine can be given at any point in the season.
  - Vaccines are trivalent this season.
- **2-dose rule:** children under 9 vaccinated for the first time get 2 doses at least 4 weeks apart (EpiCentro / circular standard). I did not read the circular text itself.
- Nasal spray (LAIV) is used from 2 years in several regions.
- Sources:
  - AIFA, 9 vaccines authorised for 2026-2027: https://www.aifa.gov.it/-/influenza-9-i-vaccini-autorizzati-per-la-stagione-2026-2027
  - Circular summary: https://certifico.com/news/circolare-min-salute-n-5134-del-23-giugno-2026
  - EpiCentro: https://www.epicentro.iss.it/influenza/raccomandazioni-ministero

### 5. Emergency numbers (IT)

| Number | Service | App type |
|---|---|---|
| 112 | Single European emergency number (NUE). Keep it. | all (or unified where NUE is active) |
| 118 | Medical emergency / ambulance. Works everywhere; where NUE 112 is active it is routed through 112. | ambulance |
| 113 | Police (Polizia di Stato) | police |
| 115 | Fire brigade (Vigili del Fuoco) | fire |
| 116117 | Out-of-hours GP service (ex guardia medica / continuità assistenziale), for non-urgent care | new type `outOfHoursDoctor` (as for DE) |

**116117 coverage [CHECK]**
- It is regional and not yet everywhere.
- Active in Lazio region-wide since 24 Aug 2026, in Trentino, in Lombardia, in parts of Veneto, and elsewhere.
- Where it is not active, the local guardia medica number applies.
- Lazio source: https://regione.lazio.it/notizie/salute-attivo-in-tutta-la-regione-il-numero-116117

**Poison centres (Centri Antiveleni, 24h) [CHECK numbers before release]**

| Centre | Number |
|---|---|
| Milano Niguarda | 02 6610 1029 |
| Roma, Ospedale Pediatrico Bambino Gesù (children's hospital) | 06 6859 3726 |
| Roma Gemelli | 06 305 4343 |
| Pavia | 0382 24444 |
| Firenze Careggi | 055 794 7819 |
| Napoli Cardarelli | 081 545 3333 |
| Bergamo | 800 883 300 |

- **[CHOICE]** Suggest Bambino Gesù (pediatric) or Niguarda as the single "poison" line.
- I took these numbers from memory and did not verify them online this session.

---

## Spain (ES)

### 1. Routine schedule (CISNS common calendar 2026)

```sql
  ('ES', 'HEXA-1',  '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 10, 'Spain CISNS calendario común 2026'),
  ('ES', 'PCV-1',   'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 11, 'Spain CISNS calendario común 2026'),
  ('ES', 'ROTA-1',  'Rotavirus (RV, oral)', 'Dose 1', 2, 'month', 12, 'Spain CISNS calendario común 2026'),
  ('ES', 'MENB-1',  'Meningococcal B (MenB)', 'Dose 1', 2, 'month', 13, 'Spain CISNS calendario común 2026'),
  ('ES', 'HEXA-2',  '6-in-1 (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 20, 'Spain CISNS calendario común 2026'),
  ('ES', 'PCV-2',   'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 21, 'Spain CISNS calendario común 2026'),
  ('ES', 'ROTA-2',  'Rotavirus (RV, oral)', 'Dose 2', 4, 'month', 22, 'Spain CISNS calendario común 2026'),
  ('ES', 'MENB-2',  'Meningococcal B (MenB)', 'Dose 2', 4, 'month', 23, 'Spain CISNS calendario común 2026'),
  ('ES', 'MENC-1',  'Meningococcal C (MenC)', 'Dose 1', 4, 'month', 24, 'Spain CISNS calendario común 2026'),
  ('ES', 'ROTA-3',  'Rotavirus (RV, oral) - only with the 3-dose vaccine (RotaTeq)', 'Dose 3', 6, 'month', 30, 'Spain CISNS calendario común 2026'),
  ('ES', 'HEXA-3',  '6-in-1 (DTaP-IPV-Hib-HepB)', 'Booster', 11, 'month', 40, 'Spain CISNS calendario común 2026'),
  ('ES', 'PCV-3',   'Pneumococcal conjugate (PCV)', 'Booster', 11, 'month', 41, 'Spain CISNS calendario común 2026'),
  ('ES', 'MENB-3',  'Meningococcal B (MenB)', 'Booster', 12, 'month', 50, 'Spain CISNS calendario común 2026'),
  ('ES', 'MENC-2',  'Meningococcal C (MenC)', 'Booster', 12, 'month', 51, 'Spain CISNS calendario común 2026'),
  ('ES', 'MMR-1',   'Measles, mumps, rubella (MMR, triple vírica)', 'Dose 1', 12, 'month', 52, 'Spain CISNS calendario común 2026'),
  ('ES', 'VAR-1',   'Chickenpox (varicella)', 'Dose 1', 15, 'month', 60, 'Spain CISNS calendario común 2026'),
  ('ES', 'MMR-2',   'Measles, mumps, rubella (MMR, triple vírica)', 'Dose 2', 36, 'month', 70, 'Spain CISNS calendario común 2026'),
  ('ES', 'VAR-2',   'Chickenpox (varicella)', 'Dose 2', 36, 'month', 71, 'Spain CISNS calendario común 2026'),
  ('ES', 'DTAP-IPV','Diphtheria-tetanus-pertussis-polio booster (DTaP-IPV)', 'Booster', 72, 'month', 80, 'Spain CISNS calendario común 2026'),
```

That is 19 rows, or 18 if ROTA-3 is dropped.

### 2. Sources and notes

**Source**
- "Calendario común de vacunación e inmunización a lo largo de toda la vida – Calendario recomendado año 2026". Approved by the CISNS (Consejo Interterritorial del SNS) on 12 Dec 2025; the document is dated December 2025.
  - https://www.sanidad.gob.es/areas/promocionPrevencion/vacunaciones/calendario/docs/CalendarioVacunacion_Todalavida.pdf
  - Calendar page: https://www.sanidad.gob.es/areas/promocionPrevencion/vacunaciones/calendario/home.htm

**Ages from the table and footnotes**

| Vaccine | Ages | Notes |
|---|---|---|
| 6-in-1 (DTPa/VPI/Hib/HB) | 2, 4 and 11 months | "important to give on time" |
| PCV | 2, 4 and 11 months | Footnote: from 2 months, "schedule per the product label" |
| Rotavirus | 2 and 4 months, or 2, 4 and 6 months | From 6 weeks, schedule per product. The vaccination working group (Ponencia) extended it to all healthy infants from 1 Sep 2024. |
| MenB | 2, 4 and 12 months | |
| MenC | 4 and 12 months | |
| MMR (triple vírica, TV) | 12 months and 3–4 years | |
| Varicella | 15 months and 3–4 years | |
| DTaP-IPV | 6 years | For children vaccinated at 2, 4 and 11 months. Older 2-4-6-18 schedule children get dTpa without IPV. |
| Flu | 6–59 months, every season | |
| RSV | 0–6 months | See section 3 |

**Doubts and choices**
- **[CHOICE]** MMR-2 and VAR-2: "3–4 years" is entered as 36 months, the earliest age in the range.
- **[CHOICE]** DTaP-IPV: "6 years" is entered as 72 months. This is at the ~6-year limit and fits the existing rule.
- **[CHECK] Rotavirus:**
  - The 2026 table only says "per product".
  - The 2 and 4 month schedule is for Rotarix. RotaTeq is 2, 4 and 6 months; for example the Balearic Islands use RotaTeq (2-4-6).
  - Galicia's calendar note limits the programme to babies born from 1 Aug 2023.
  - **[CHOICE]** ROTA-3 is included as a conditional row. Drop it if unwanted.
- **[CHECK] PCV:** "per product label" exists because some regions switched to PCV20, whose infant label is 3+1 (2, 4, 6 and 11 months). In those regions there is an extra PCV dose at 6 months. I kept the 2+1 shown in the common table.
- **Hep B at birth (0 months):** only for babies of HBsAg-positive or unscreened mothers (0, 2, 4, 11), so not in the rows.
- **Preterm babies:** handled in the separate risk-group calendar (CalendarioVacunacion_GRinfantil.pdf). I did not review it.

**Notable regional extras**
- **MenACWY instead of MenC.** Several regions switched in 2026:
  - Madrid: 12-month MenC replaced by MenACWY from 1 Jan 2026.
  - Cantabria: 4 and 12 months, from 1 Feb 2026.
  - Comunitat Valenciana: from 1 Apr 2026, for babies born from 1 Jan 2026.
  - The Spanish Paediatric Association (AEP) recommends MenACWY at 4 and 12 months.
  - Source (Madrid professionals page): https://www.comunidad.madrid/salud/vacunas-informacion-profesionales
  - **[CHOICE]** Consider a note in the app: "your region may use MenACWY instead of MenC".
- **Flu beyond 59 months:** Extremadura vaccinates up to 11 years in schools from 2026, and other regions use the nasal spray.

### 3. RSV for infants: yes, all infants (national, 4th season)

- **Who:** the 2026 common calendar recommends immunising **everyone born between 1 April of the year the season starts and 31 March of the next year**, so for 2026/27 that is 1 Apr 2026 to 31 Mar 2027. It is one dose of monoclonal antibody (nirsevimab) for under-6-month-olds before and during the season.
- **Born in season (Oct–Mar):** "very early, preferably in the first 24–48 hours after birth".
- **Born April–September (catch-up):** immunise as soon as possible before the RSV wave, during October.
  - The campaign starts **1 Oct 2026**. Under-3-month-olds get priority.
  - Castilla y León example: being 6 months or older does not exclude a baby born in the target dates.
- **High-risk babies:**
  - Preterm under 35 weeks: up to 12 months.
  - Babies with certain conditions: before each season up to 24 months.
- **Maternal vaccine (Abrysvo):** **not part of the public programme.** It is available only privately from pharmacies on prescription. The infant should still get the antibody whatever the maternal vaccination (CyL, Sep 2026).
- Sources:
  - CISNS calendar 2026, footnote 13.
  - Castilla y León "Actualización del programa de inmunización con nirsevimab 2026-2027", Sep 2026 V2: https://www.saludcastillayleon.es/profesionales/fr/vacunaciones/campana-inmunizacion-frente-vrs-nirsevimab-poblacion-17dc04.fichiers/3440246-Actualizacion%20del%20PROGRAMA%20DE%20INMUNIZACI%C3%93N%20CON%20%20NIRSERVIMAB%20FRENTE%20A%20VRS_%20campa%C3%B1a%202026-2027_V2.doc.pdf
  - Ministry RSV page: https://www.sanidad.gob.es/areas/promocionPrevencion/vacunaciones/VRS/poblacionInfantil/home.htm

### 4. Flu for young children: yes, ages 6 to 59 months

- The CISNS 2026 calendar (footnote 11) recommends **1 dose each season for all children aged 6–59 months**.
- The 2026-2027 season recommendations were approved by the Public Health Commission on 14 May 2026: https://www.sanidad.gob.es/areas/promocionPrevencion/vacunaciones/gripe_covid19/docs/recomendacionesVacunacionGripe_2026_2027.pdf
  - The PDF timed out when I tried to fetch it, so I could not read its pediatric section.
- Campaigns start around early October; Castilla y León starts 1 Oct 2026.
- **2-dose rule [CHECK]:** the common calendar says 1 dose for healthy 6–59-month-olds. In earlier seasons Spain said healthy children need only 1 dose even the first time, and children under 9 with risk conditions vaccinated for the first time need 2 doses at least 4 weeks apart. Confirm against the 2026-27 PDF.
- Many regions use the nasal spray from 24 months.

### 5. Emergency numbers (ES)

| Number | Service | App type |
|---|---|---|
| 112 | All emergencies, nationwide. Keep it. | all |
| 061 | Health emergencies / medical advice line in some regions | ambulance |
| 091 | National Police (Policía Nacional) | police |
| 062 | Guardia Civil | police (optional) |
| 080 / 085 | Fire brigade; varies by city or province | not recommended; 112 covers it |
| 91 562 04 20 | Poison: Servicio de Información Toxicológica (INTCF), 24h, national | poison |

- **061 [CHECK]:** active in, for example, Andalucía, Galicia, Aragón, Murcia, Baleares, Cantabria and La Rioja; Cataluña has 061 CatSalut Respon. Elsewhere 112 handles it. **[CHOICE]** Add it with a note "some regions"; in some regions it is also a health advice line, which is closer to `nurseLine`.
- Poison source: https://www.mjusticia.gob.es/eu/institucional/organismos/instituto-nacional/servicios/servicio-informacion/servicio-informacion1

**Confidence for Spain: high** for the core rows, which come from the official 2026 PDF and footnotes. The medium points are rotavirus dose count by region, PCV20 regions and MenC versus MenACWY by region.

---

## Summary of new app needs
- **New service type suggested: `outOfHoursDoctor`.** It covers 116 117 in Germany and 116117 in Italy (regional), and is a doctor service, not a nurse line.
- **DE:** remove any MenC 12-month row; it was dropped in 2026.
- **Conditional rows:** decide whether "only with the 3-dose vaccine" rotavirus rows (DE ROTA-3, ES ROTA-3) should stay. A per-dose "conditional" flag in the table would also help for PCV20 3+1 regions in Spain and preterm 3+1 in Germany.
