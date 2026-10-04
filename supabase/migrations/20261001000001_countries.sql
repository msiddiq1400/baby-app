-- Countries: each baby has one (it picks the vaccine schedule and emergency
-- numbers), vaccines can be recorded by name, and schedules for the UK, US,
-- Canada, UAE and Saudi Arabia join Pakistan's.
--
-- Babies saved before this are in Pakistan (the app was Pakistan-only), and
-- older app versions that don't send a country get Pakistan too.

alter table public.babies
  add column country_code text not null default 'PK' check (country_code ~ '^[A-Z]{2}$');

-- A vaccine outside the schedule (private, travel, or a country without a
-- schedule in the app): vaccine_code 'OTHER' with the name the parent typed.
alter table public.vaccinations
  add column vaccine_name text check (vaccine_name is null or char_length(vaccine_name) between 1 and 100),
  add constraint vaccinations_other_has_name check (vaccine_code <> 'OTHER' or vaccine_name is not null);

-- Schedules, from each country's official source (listed per row). Where the
-- source gives an age range, the earliest recommended age is used. Seasonal
-- vaccines (flu, COVID), RSV antibodies and risk-group-only vaccines are left
-- out, as for Pakistan. All unverified until a clinician checks them.
--
-- GB: UKHSA "Complete routine immunisation schedule from 1 September 2026",
--     for babies born on or after 1 January 2025 (MMRV, 18-month visit).
-- US: CDC child schedule, July 2025 version (in force by court order since
--     March 2026; may change after the October 2026 appeal).
-- CA: Canadian Immunization Guide Table 1 (June 2026) and NACI May 2026
--     (Men-C-ACYW). Provinces differ; the app tells parents to follow theirs.
-- AE: MOHAP national programme as printed in DHA guideline CG-04 v4
--     (January 2026), matching WHO 2025 data and Abu Dhabi's April 2026 schedule.
-- SA: MOH national schedule (2019 print, page updated June 2026), matching
--     WHO 2025 data. BCG is at 6 months on purpose (since 2019).
insert into public.vaccine_schedule
  (country_code, code, name, dose_label, due_age_value, due_age_unit, sort_order, source)
values
  ('GB', '6IN1-1', '6-in-1 (DTaP/IPV/Hib/HepB)', 'Dose 1', 8, 'week', 10, 'UKHSA schedule 2026'),
  ('GB', 'MENB-1', 'MenB', 'Dose 1', 8, 'week', 11, 'UKHSA schedule 2026'),
  ('GB', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 8, 'week', 12, 'UKHSA schedule 2026'),
  ('GB', '6IN1-2', '6-in-1 (DTaP/IPV/Hib/HepB)', 'Dose 2', 12, 'week', 20, 'UKHSA schedule 2026'),
  ('GB', 'MENB-2', 'MenB', 'Dose 2', 12, 'week', 21, 'UKHSA schedule 2026'),
  ('GB', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 12, 'week', 22, 'UKHSA schedule 2026'),
  ('GB', '6IN1-3', '6-in-1 (DTaP/IPV/Hib/HepB)', 'Dose 3', 16, 'week', 30, 'UKHSA schedule 2026'),
  ('GB', 'PCV-1', 'Pneumococcal (PCV)', 'Dose 1', 16, 'week', 31, 'UKHSA schedule 2026'),
  ('GB', 'PCV-2', 'Pneumococcal (PCV)', 'Dose 2 (booster)', 12, 'month', 40, 'UKHSA schedule 2026'),
  ('GB', 'MENB-3', 'MenB', 'Dose 3 (booster)', 12, 'month', 41, 'UKHSA schedule 2026'),
  ('GB', 'MMRV-1', 'MMRV (measles, mumps, rubella, chickenpox)', 'Dose 1', 12, 'month', 42, 'UKHSA schedule 2026'),
  ('GB', '6IN1-4', '6-in-1 (DTaP/IPV/Hib/HepB)', 'Dose 4', 18, 'month', 50, 'UKHSA schedule 2026'),
  ('GB', 'MMRV-2', 'MMRV (measles, mumps, rubella, chickenpox)', 'Dose 2', 18, 'month', 51, 'UKHSA schedule 2026'),
  ('GB', '4IN1-PS', '4-in-1 pre-school booster (dTaP/IPV)', 'Booster', 40, 'month', 60, 'UKHSA schedule 2026'),
  ('US', 'HEPB-1', 'Hepatitis B', 'Dose 1', 0, 'day', 10, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HEPB-2', 'Hepatitis B', 'Dose 2', 1, 'month', 20, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'ROTA-1', 'Rotavirus', 'Dose 1', 2, 'month', 30, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'DTAP-1', 'DTaP (diphtheria, tetanus, pertussis)', 'Dose 1', 2, 'month', 31, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HIB-1', 'Hib (Haemophilus influenzae type b)', 'Dose 1', 2, 'month', 32, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 33, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'IPV-1', 'Polio (IPV)', 'Dose 1', 2, 'month', 34, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'ROTA-2', 'Rotavirus', 'Dose 2', 4, 'month', 40, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'DTAP-2', 'DTaP (diphtheria, tetanus, pertussis)', 'Dose 2', 4, 'month', 41, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HIB-2', 'Hib (Haemophilus influenzae type b)', 'Dose 2', 4, 'month', 42, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 43, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'IPV-2', 'Polio (IPV)', 'Dose 2', 4, 'month', 44, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HEPB-3', 'Hepatitis B', 'Dose 3', 6, 'month', 50, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'ROTA-3', 'Rotavirus', 'Dose 3 (RotaTeq only)', 6, 'month', 51, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'DTAP-3', 'DTaP (diphtheria, tetanus, pertussis)', 'Dose 3', 6, 'month', 52, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HIB-3', 'Hib (Haemophilus influenzae type b)', 'Dose 3', 6, 'month', 53, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'PCV-3', 'Pneumococcal conjugate (PCV)', 'Dose 3', 6, 'month', 54, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'IPV-3', 'Polio (IPV)', 'Dose 3', 6, 'month', 55, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HIB-4', 'Hib (Haemophilus influenzae type b)', 'Booster', 12, 'month', 60, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'PCV-4', 'Pneumococcal conjugate (PCV)', 'Booster', 12, 'month', 61, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 62, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'VAR-1', 'Varicella (chickenpox)', 'Dose 1', 12, 'month', 63, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HEPA-1', 'Hepatitis A', 'Dose 1', 12, 'month', 64, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'DTAP-4', 'DTaP (diphtheria, tetanus, pertussis)', 'Dose 4', 15, 'month', 70, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'HEPA-2', 'Hepatitis A', 'Dose 2', 18, 'month', 80, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'DTAP-5', 'DTaP (diphtheria, tetanus, pertussis)', 'Dose 5', 48, 'month', 90, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'IPV-4', 'Polio (IPV)', 'Dose 4', 48, 'month', 91, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'MMR-2', 'MMR (measles, mumps, rubella)', 'Dose 2', 48, 'month', 92, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('US', 'VAR-2', 'Varicella (chickenpox)', 'Dose 2', 48, 'month', 93, 'CDC schedule 2025 (Jul 2025 addendum)'),
  ('CA', 'DTAP-HB-IPV-HIB-1', 'DTaP-HB-IPV-Hib (6-in-1)', 'Dose 1', 2, 'month', 10, 'PHAC CIG 2026'),
  ('CA', 'PNEU-1', 'Pneumococcal conjugate (Pneu-C)', 'Dose 1', 2, 'month', 11, 'PHAC CIG 2026'),
  ('CA', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 12, 'PHAC CIG 2026'),
  ('CA', 'DTAP-HB-IPV-HIB-2', 'DTaP-HB-IPV-Hib (6-in-1)', 'Dose 2', 4, 'month', 20, 'PHAC CIG 2026'),
  ('CA', 'PNEU-2', 'Pneumococcal conjugate (Pneu-C)', 'Dose 2', 4, 'month', 21, 'PHAC CIG 2026'),
  ('CA', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 22, 'PHAC CIG 2026'),
  ('CA', 'DTAP-HB-IPV-HIB-3', 'DTaP-HB-IPV-Hib (6-in-1)', 'Dose 3', 6, 'month', 30, 'PHAC CIG 2026'),
  ('CA', 'PNEU-3', 'Pneumococcal conjugate (Pneu-C)', 'Booster', 12, 'month', 40, 'PHAC CIG 2026'),
  ('CA', 'MENACYW-1', 'Meningococcal ACYW conjugate (Men-C-ACYW)', 'Dose 1', 12, 'month', 41, 'NACI 2026'),
  ('CA', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 42, 'PHAC CIG 2026'),
  ('CA', 'VAR-1', 'Varicella (chickenpox)', 'Dose 1', 12, 'month', 43, 'PHAC CIG 2026'),
  ('CA', 'DTAP-IPV-HIB-4', 'DTaP-IPV-Hib (5-in-1)', 'Booster', 18, 'month', 50, 'PHAC CIG 2026'),
  ('CA', 'MMRV-2', 'MMRV (measles, mumps, rubella, varicella)', 'Dose 2', 18, 'month', 51, 'PHAC CIG 2026'),
  ('CA', 'TDAP-IPV', 'Tdap-IPV (4-in-1)', 'Booster', 48, 'month', 60, 'PHAC CIG 2026'),
  ('AE', 'BCG', 'BCG', null, 0, 'day', 10, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 11, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'HEXA-1', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 21, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 22, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'HEXA-2', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 30, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 31, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 32, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'PENTA', 'Pentavalent or hexavalent (DTP-Hib-HepB)', 'Dose 3', 6, 'month', 40, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'OPV-1', 'Oral polio (bOPV)', 'Dose 1', 6, 'month', 41, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 50, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'VAR-1', 'Varicella (chickenpox)', 'Dose 1', 12, 'month', 51, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'MENACWY-1', 'Meningococcal ACWY conjugate', 'Dose 1', 12, 'month', 52, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'DTAP-HIB-IPV', 'DTaP-Hib-IPV', 'Booster 1', 18, 'month', 60, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'OPV-2', 'Oral polio (bOPV)', 'Booster 1', 18, 'month', 61, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'MMR-2', 'MMR (measles, mumps, rubella)', 'Dose 2', 18, 'month', 62, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'PCV-3', 'Pneumococcal conjugate (PCV)', 'Booster', 18, 'month', 63, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'DTAP-IPV', 'DTaP-IPV', 'Booster 2', 60, 'month', 70, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'OPV-3', 'Oral polio (bOPV)', 'Booster 2', 60, 'month', 71, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('AE', 'VAR-2', 'Varicella (chickenpox)', 'Dose 2', 60, 'month', 72, 'UAE NIP (DHA CG-04 v4) 2026'),
  ('SA', 'HEPB-0', 'Hepatitis B', 'Birth dose', 0, 'day', 10, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'HEXA-1', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 1', 2, 'month', 20, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'ROTA-1', 'Rotavirus (oral)', 'Dose 1', 2, 'month', 21, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'PCV-1', 'Pneumococcal conjugate (PCV)', 'Dose 1', 2, 'month', 22, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'HEXA-2', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 2', 4, 'month', 30, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'ROTA-2', 'Rotavirus (oral)', 'Dose 2', 4, 'month', 31, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'PCV-2', 'Pneumococcal conjugate (PCV)', 'Dose 2', 4, 'month', 32, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'BCG', 'BCG (tuberculosis)', null, 6, 'month', 40, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'HEXA-3', 'Hexavalent (DTaP-IPV-Hib-HepB)', 'Dose 3', 6, 'month', 41, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'ROTA-3', 'Rotavirus (oral)', 'Dose 3', 6, 'month', 42, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'PCV-3', 'Pneumococcal conjugate (PCV)', 'Dose 3', 6, 'month', 43, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'OPV-1', 'Oral polio (OPV)', 'Dose 1', 6, 'month', 44, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'MEASLES', 'Measles', null, 9, 'month', 50, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'MCV4-1', 'Meningococcal ACWY conjugate (MCV4)', 'Dose 1', 9, 'month', 51, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'PCV-4', 'Pneumococcal conjugate (PCV)', 'Booster', 12, 'month', 60, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'OPV-2', 'Oral polio (OPV)', 'Dose 2', 12, 'month', 61, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'MCV4-2', 'Meningococcal ACWY conjugate (MCV4)', 'Dose 2', 12, 'month', 62, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'MMR-1', 'MMR (measles, mumps, rubella)', 'Dose 1', 12, 'month', 63, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'DTAPHIB-B', 'DTaP-Hib', 'Booster 1', 18, 'month', 70, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'OPV-3', 'Oral polio (OPV)', 'Dose 3', 18, 'month', 71, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'HEPA-1', 'Hepatitis A', 'Dose 1', 18, 'month', 72, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'VAR-1', 'Varicella (chickenpox)', 'Dose 1', 18, 'month', 73, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'MMR-2', 'MMR (measles, mumps, rubella)', 'Dose 2', 18, 'month', 74, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'HEPA-2', 'Hepatitis A', 'Dose 2', 24, 'month', 80, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'DTAP-B', 'DTaP', 'Booster 2', 48, 'month', 90, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'OPV-4', 'Oral polio (OPV)', 'Dose 4', 48, 'month', 91, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'VAR-2', 'Varicella (chickenpox)', 'Dose 2', 48, 'month', 92, 'MOH KSA 2019 / WHO 2025'),
  ('SA', 'MMR-3', 'MMR (measles, mumps, rubella)', 'Dose 3', 48, 'month', 93, 'MOH KSA 2019 / WHO 2025');
