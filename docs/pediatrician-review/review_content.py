"""Hand-written text for the pediatrician review pack.

make_review_docx.py reads the medical DATA straight from the app's sources
(vaccine rows, RSV / flu rules, wording, emergency numbers, foods, recipes,
milestones). Everything that is NOT in the app's sources lives here: the
letter, each country's sources and open questions, plain-English
explanations, and where each piece of wording appears.

Rules for this file (the doctor reads every word of it):
- plain clinical English;
- never mention code, files, keys or databases;
- every open question is answerable by a doctor (tick / short answer).
"""

TITLE = "Palna: medical content review"
VERSION_DATE = "28 October 2026"
CONTACT = "hello@palnacare.com"
COMPANY = "Toolbox Services (SMC-Private) Limited"

# ---------------------------------------------------------------------------
# Letter (one page)
# ---------------------------------------------------------------------------

LETTER = [
    "Dear Doctor,",
    "Thank you for agreeing to review Palna. Palna is a free baby-tracking app for families. Parents use it to "
    "record feeds, sleep, diapers, growth, vaccinations, medicines, symptoms, first foods and milestones, and to "
    "share the record with the rest of the family. It is used in many countries and is available in English, "
    "Urdu and Roman Urdu.",
    "Alongside the records, Palna shows some medical information: national vaccine schedules for 23 countries, "
    "optional RSV and flu reminders, growth checks against the WHO growth standards, warning signs, emergency "
    "numbers, a starting-solids guide with recipes, and developmental milestones. All of it was taken from "
    "official sources (national immunisation programmes, WHO, NHS, CDC), but none of it has yet been checked by "
    "a clinician. That is what we are asking you to do.",
    "What we ask. Please read each item in this pack and tell us whether it is correct, and what to change if "
    "it is not. Where our sources disagree or we had to make a choice, we list it as an open question at the "
    "end of the section.",
    "How to mark. Every table has a “Reviewer ✓ / ✗ / ?” column and a “Change to / "
    "comment” column. Write ✓ if the item is correct; ✗ if it is wrong, with the correction in the "
    "next column; ? if you are unsure or want to comment. If a whole table is correct, one ✓ next to its "
    "heading is enough. For open questions, tick the box and write your answer on the line. You can mark on "
    "paper or in Word (tracked changes are welcome). It is fine to skip countries outside your experience: "
    "just mark them ?.",
    "Where to start. If time is short, please start with “Questions we most need answered” on the next "
    "page. They are the items where we are least sure.",
    "Important. Palna is not a medical device. It does not diagnose and does not calculate medicine doses; the "
    "app, its store listing and its terms of use tell parents to follow their own doctor’s advice. We want "
    "the information it does show to be correct and safely worded.",
    "How long. About 3 to 4 hours in total: vaccine schedules 90–120 minutes (most items are routine), RSV "
    "and flu 15 minutes, wording parents see 30 minutes, emergency numbers 10 minutes, solids guide 30 minutes, "
    "milestones 15 minutes. Please review the English only; the Urdu and Roman Urdu translations follow the "
    "English and will be checked separately once your corrections are in.",
    f"Questions about this pack: {CONTACT}. Thank you for your time and care.",
    "With thanks,",
    f"The Palna team, {COMPANY}",
]

# ---------------------------------------------------------------------------
# Questions we most need answered (each points at an open question below)
# ---------------------------------------------------------------------------

TOP_QUESTIONS = [
    ("PK-1", "Pakistan (our largest group of families): is the EPI schedule in the app (birth; 6, 10 and 14 "
             "weeks; 9 and 15 months) still the current federal schedule?"),
    ("US-1", "United States: a court appeal heard on 6 October 2026 could bring back the January 2026 CDC "
             "schedule. If it does, what should change in the app?"),
    ("BD-1", "Bangladesh: is the third PCV dose given at 14 weeks or at 18 weeks?"),
    ("IT-1", "Italy: should the MenB doses be shown at 2 and 4 months (earliest allowed) or at 3 and 5 months "
             "(common practice)?"),
    ("G-1", "When a schedule gives an age range (e.g. “16–24 months”) we show the earliest age. "
            "Is that acceptable?"),
    ("G-3", "BCG for babies whose parents come from a high-TB country (Bahrain, France, Norway, Sweden): "
            "should the app show it as a conditional reminder?"),
    ("RSV-2", "Germany, Spain and Italy offer RSV protection to all babies (and Spain and Italy offer flu "
              "vaccine to young children), but the app shows no optional reminder there. Should it?"),
    ("W-1", "Fever: the app only warns for 38 °C or more under 3 months. Should it also warn at other "
            "ages, for example 39 °C or more at 3–6 months?"),
    ("W-3", "Growth check: are the triggers for “Talk to your doctor” and “Mention it at the next "
            "check-up” (section 3.3) appropriate? Should premature babies use corrected age?"),
    ("S-2", "Fish recipe: it suggests rohu, which has many small bones. Is this safe to suggest for babies?"),
    ("E-2", "Emergency numbers: every poison line is labelled “Poison Control”, although some are "
            "not 24-hour or are for less urgent cases. Is that acceptable?"),
]

# ---------------------------------------------------------------------------
# Section 1: vaccine schedules
# ---------------------------------------------------------------------------

SCHEDULE_INTRO = [
    "For each country the app shows the national routine schedule for all babies, from birth to about 6 years. "
    "Each dose is shown with its due date (birth date plus the due age), and parents get a reminder the day "
    "before, on the day, and when it is overdue. Above the list the app says: “Always confirm dates with "
    "your doctor or nurse; they can differ by region and vaccine brand” (wording in section 3.9).",
    "Rules we followed for every country: where the source gives an age range, the earliest recommended age is "
    "used; seasonal vaccines (flu, COVID), RSV protection, risk-group-only, regional and travel vaccines are "
    "left out (RSV and flu are optional reminders, section 2); school-age doses after about 6 years are left "
    "out. Parents can add any other vaccine by name.",
    "“Verified” shows whether a clinician has checked the item. Nothing is verified yet: after your "
    "review we will mark each confirmed item as verified. “—” in the Dose column means the app "
    "shows no dose number (a single dose).",
]

COUNTRY_ORDER = ["PK", "GB", "US", "CA", "AE", "SA", "IN", "BD", "QA", "KW", "OM", "BH", "MY", "AU", "DE",
                 "IE", "IT", "ES", "FR", "NL", "NO", "SE", "TR"]

COUNTRY_NAMES = {
    "PK": "Pakistan", "GB": "United Kingdom", "US": "United States", "CA": "Canada",
    "AE": "United Arab Emirates", "SA": "Saudi Arabia", "IN": "India", "BD": "Bangladesh", "QA": "Qatar",
    "KW": "Kuwait", "OM": "Oman", "BH": "Bahrain", "MY": "Malaysia", "AU": "Australia", "DE": "Germany",
    "IE": "Ireland", "IT": "Italy", "ES": "Spain", "FR": "France", "NL": "Netherlands", "NO": "Norway",
    "SE": "Sweden", "TR": "Türkiye", "NZ": "New Zealand",
}

# Per country: a short note shown above the table, the sources, and the open
# questions (id, text).
COUNTRIES = {
    "PK": {
        "note": "Expanded Programme on Immunization (EPI), all children up to 15 months. This was the first "
                "schedule in the app and was originally entered from general knowledge of the EPI; it was later "
                "compared with the published EPI chart and matches it dose for dose.",
        "sources": [
            "Pakistan EPI schedule chart, Federal Directorate of Immunization, Ministry of National Health "
            "Services, Regulations and Coordination (epi.gov.pk, chart published October 2023): 6 visits by "
            "15 months, 12 diseases.",
        ],
        "questions": [
            ("PK-1", "Is this still the current federal EPI schedule in 2026 (any change to IPV, TCV, PCV or "
                     "rotavirus doses since the 2023 chart)?"),
            ("PK-2", "Do any provinces differ from the federal schedule in a way parents should be told about?"),
            ("PK-3", "The app does not track polio campaign (supplementary) OPV doses. Should it offer a way to "
                     "record them, or a note that campaign drops are in addition to routine doses?"),
        ],
    },
    "GB": {
        "note": "UK routine schedule for babies born on or after 1 January 2025 (MMRV and the new 18-month visit). "
                "We show only this new schedule.",
        "sources": [
            "UKHSA, “Complete routine immunisation schedule from 1 September 2026”, for babies born on "
            "or after 1 January 2025.",
        ],
        "questions": [
            ("GB-1", "The new schedule is shown to every UK baby, including those born before 2025, who follow "
                     "the older schedule (Hib/MenC at 1 year, MMR dose 2 at 3 years 4 months). Is that "
                     "acceptable now that those children are at least 22 months old (they may see reminders for "
                     "doses they were never due), or do we need both schedules?"),
            ("GB-2", "Pre-school booster shown at 3 years 4 months (40 months). Correct?"),
        ],
    },
    "US": {
        "note": "CDC child immunization schedule, 2025 version (in force by court order since March 2026). "
                "Where the CDC gives a range (e.g. hepatitis B dose 3 at 6–18 months), the earliest age is "
                "shown.",
        "sources": [
            "CDC Child and Adolescent Immunization Schedule, 2025 version (July 2025 addendum), in force since "
            "16 March 2026 by court order (AAP v. Kennedy, D. Mass.).",
            "Congressional Research Service reports IN12684 (29 July 2026) and R48982 (11 June 2026) on the "
            "court stay; report of the First Circuit appeal hearing, 6 October 2026.",
        ],
        "questions": [
            ("US-1", "A court appeal heard on 6 October 2026 could bring back the January 2026 CDC schedule "
                     "(and an executive order of 10 August 2026 points the same way). If that happens, which "
                     "routine items in this table should change, and should the app then follow the CDC or the "
                     "AAP schedule?"),
            ("US-2", "Rotavirus dose 3 at 6 months is labelled “RotaTeq only”. Keep it, or leave it out "
                     "as we do for Germany, Spain and France?"),
        ],
    },
    "CA": {
        "note": "National pattern from the Canadian Immunization Guide. Provinces and territories run their own "
                "schedules, so the app tells Canadian parents to follow their province’s schedule.",
        "sources": [
            "Public Health Agency of Canada, Canadian Immunization Guide, Table 1 (June 2026).",
            "NACI statement, May 2026 (meningococcal ACYW conjugate at 12 months).",
        ],
        "questions": [
            ("CA-1", "Is a single national schedule useful for Canadian parents, given the provincial "
                     "differences (for example, provinces that give hepatitis B at school age rather than in a "
                     "6-in-1 in infancy, or MenC instead of MenACWY)? Should we show something different?"),
            ("CA-2", "MMRV dose 2 is shown at 18 months (the earliest option; some provinces give it at "
                     "4–6 years). Acceptable?"),
        ],
    },
    "AE": {
        "note": "Federal (MOHAP) national immunisation programme. Programmes can differ slightly between Abu "
                "Dhabi, Dubai and the northern emirates.",
        "sources": [
            "UAE national immunisation programme (MOHAP) as printed in Dubai Health Authority guideline CG-04, "
            "version 4 (January 2026).",
            "Cross-checked with WHO/UNICEF 2025 schedule data and Abu Dhabi’s April 2026 schedule.",
        ],
        "questions": [
            ("AE-1", "Dose 3 at 6 months is shown as “pentavalent or hexavalent”, with oral polio "
                     "(bOPV) at 6 months, 18 months and 5 years. Correct?"),
            ("AE-2", "PCV booster at 18 months (after doses at 2 and 4 months). Correct?"),
            ("AE-3", "Chickenpox dose 2 at 5 years, MMR dose 2 at 18 months. Correct?"),
        ],
    },
    "SA": {
        "note": "Ministry of Health national schedule. BCG at 6 months is deliberate (the Saudi schedule moved "
                "BCG to 6 months in 2019).",
        "sources": [
            "Saudi Ministry of Health national immunisation schedule (2019 print; page updated June 2026).",
            "Cross-checked with WHO/UNICEF 2025 schedule data.",
        ],
        "questions": [
            ("SA-1", "The official card is a 2019 print. Has anything changed since (vaccine products, ages)?"),
            ("SA-2", "Measles vaccine at 9 months, then MMR at 12 months, 18 months and 4 years (shown as "
                     "“Dose 3”), and chickenpox at 18 months and 4 years. Correct, or is MMRV used?"),
            ("SA-3", "Rotavirus is shown as 3 doses (2, 4 and 6 months). Correct?"),
        ],
    },
    "IN": {
        "note": "Government Universal Immunisation Programme (UIP). Many private clinics follow the Indian "
                "Academy of Pediatrics schedule instead; the app shows the government programme.",
        "sources": [
            "Ministry of Health and Family Welfare, Universal Immunisation Programme (PCV national since "
            "October 2021; third fractional IPV dose at 9 months since January 2023).",
            "WHO/UNICEF 2025 schedule data (published 3 June 2026).",
        ],
        "questions": [
            ("IN-1", "India gives ranges (9–12 months, 16–24 months, 5–6 years); we show 9 months, "
                     "16 months and 5 years. Acceptable?"),
            ("IN-2", "Japanese encephalitis (endemic districts only) and vitamin A (from 9 months) are not "
                     "shown. Should either be added, e.g. as an optional note?"),
            ("IN-3", "Should the app mention that private clinics often use a different (IAP) schedule?"),
        ],
    },
    "BD": {
        "note": "Directorate General of Health Services (DGHS) EPI. There is no hepatitis B birth dose, no "
                "birth OPV dose and no rotavirus vaccine in the national programme.",
        "sources": [
            "DGHS Expanded Programme on Immunization; WHO/UNICEF 2025 schedule data.",
            "News explainers of the schedule, April 2026 (Jagonews24, Prothom Alo).",
            "DGHS directive of 13 July 2026: typhoid conjugate vaccine at 15 months from 1 August 2026.",
        ],
        "questions": [
            ("BD-1", "PCV dose 3: 14 weeks or 18 weeks? The 2015 introduction used 6, 10 and 18 weeks; WHO 2025 "
                     "data and 2026 news give 6, 10 and 14 weeks. We show 14 weeks."),
            ("BD-2", "Typhoid conjugate vaccine at 15 months (one report gives a 15–24 month window; another "
                     "mentioned 9 months, probably the 2025 campaign age). Correct?"),
        ],
    },
    "QA": {
        "note": "Ministry of Public Health national programme. The ministry’s schedule page could not be "
                "opened, so the main source is Qatar’s own report to WHO.",
        "sources": [
            "Qatar MOPH national immunisation programme as reported to WHO/UNICEF (2024 and 2025 data).",
            "Hamad Medical Corporation and Primary Health Care Corporation (PHCC) immunisation pages.",
        ],
        "questions": [
            ("QA-1", "Chickenpox dose 2: 18 months (WHO report) or 4–6 years (clinic guides)? We show "
                     "18 months."),
            ("QA-2", "Dose given at 6 months: hexavalent (WHO report) or pentavalent (older guides)?"),
            ("QA-3", "Hepatitis A at 12 and 18 months as routine (one guide says travellers only). Correct?"),
            ("QA-4", "18-month booster product (DTaP-Hib-HepB per the WHO report). Correct?"),
        ],
    },
    "KW": {
        "note": "Ministry of Health schedule after ministerial decision 83/2024 (in effect from 2025): "
                "hexavalent at 2, 4, 6 and 18 months; MMRV at 2 years; DTaP at 3½ years; the OPV booster "
                "at 3½ years removed.",
        "sources": [
            "Kuwait Ministry of Health ministerial decision 83/2024 (reported 2 April 2024; in effect January "
            "2025).",
            "WHO/UNICEF 2025 schedule data; Kuwait MOH 2019 schedule card (age wording).",
        ],
        "questions": [
            ("KW-1", "Pre-school booster “at the end of 3.5 years” is shown at 42 months. Correct?"),
            ("KW-2", "BCG at 3 months (both the 2019 card and the 2025 WHO report say so). Correct?"),
            ("KW-3", "MenACWY conjugate at 12 months (an earlier report said 2 years). Correct?"),
        ],
    },
    "OM": {
        "note": "Ministry of Health EPI. Rotavirus was added in December 2023.",
        "sources": [
            "Oman Ministry of Health EPI as reported to WHO/UNICEF (2025 data).",
            "PLoS One, 10 July 2025, by Ministry of Health authors (schedule from the EPI manual).",
            "Ministry announcement of rotavirus vaccine, December 2023.",
        ],
        "questions": [
            ("OM-1", "Oral polio at 4 months (in the WHO report and an older card, but not in the 2025 paper). "
                     "Correct?"),
            ("OM-2", "A second chickenpox dose was planned from December 2025 (under 5 years). Has it started, "
                     "and at what age?"),
            ("OM-3", "DT booster at school entry (6 years) is the last item. Keep it?"),
        ],
    },
    "BH": {
        "note": "Ministry of Health schedule (one schedule for citizens and residents). BCG is given only to "
                "babies whose parents come from TB-endemic countries, so it is not in the table.",
        "sources": [
            "Bahrain Ministry of Health immunisation schedule web page (read 27 October 2026) and “Immunization "
            "schedule 2025” PDF.",
            "WHO/UNICEF 2025 schedule data (hexavalent at 6 months since September 2025; PCV20).",
        ],
        "questions": [
            ("BH-1", "BCG at birth for babies of parents from TB-endemic countries (this includes Pakistan, "
                     "India and Bangladesh, so many of our families): should the app show it, with that "
                     "condition?"),
            ("BH-2", "Oral polio booster “4–5 years” shown at 4 years, with the DTaP-IPV booster. "
                     "Correct?"),
            ("BH-3", "18-month booster: “tetravalent (DTP-Hib) or pentavalent (DTP-Hib-HepB), according to "
                     "availability”. Is the generic name acceptable?"),
        ],
    },
    "MY": {
        "note": "National Immunisation Programme (KKM). Hexavalent since November 2020; PCV since December 2020. "
                "Rotavirus is not in the programme.",
        "sources": [
            "Malaysia Ministry of Health (KKM) National Immunisation Programme; WHO/UNICEF 2025 schedule data.",
        ],
        "questions": [
            ("MY-1", "We found no official 2024–2026 schedule page; the WHO 2025 report is the newest "
                     "official data. Is this schedule current?"),
            ("MY-2", "Regional extras are left out (measles at 6 months in Sabah; Japanese encephalitis at 9 "
                     "and 21 months in Sarawak). Acceptable?"),
        ],
    },
    "AU": {
        "note": "National Immunisation Program (NIP) for all children. Aboriginal and Torres Strait Islander and "
                "medical-risk extras are left out, as are state-funded MenB programmes.",
        "sources": [
            "Australian Government National Immunisation Program schedule, current from 9 October 2026 (read "
            "through the NSW Health schedule, October 2026, and NCIRS, August 2026).",
        ],
        "questions": [
            ("AU-1", "First visit: the national schedule says “2 months (can be given from 6 weeks)”; we "
                     "show 6 weeks. Should it be 2 months?"),
            ("AU-2", "Rotavirus has strict upper age limits (dose 1 by 14 weeks, dose 2 by 24 weeks). Should the "
                     "app warn parents about this?"),
            ("AU-3", "MenB is free for all infants in South Australia, Queensland, the Northern Territory and "
                     "Tasmania (6 weeks, 4 and 12 months). Should the app mention it?"),
        ],
    },
    "DE": {
        "note": "STIKO standard schedule for term babies (2+1). MenC at 12 months was dropped in 2026. Rotavirus "
                "dose 3 (only with the 3-dose vaccine) is left out.",
        "sources": [
            "STIKO recommendations 2026, Epidemiologisches Bulletin 4/2026 (22 January 2026), Impfkalender table.",
        ],
        "questions": [
            ("DE-1", "Rotavirus dose 2 at 3 months (read from the PDF table; the column layout was hard to read). "
                     "Correct?"),
            ("DE-2", "Premature babies (before 37 weeks) get an extra 6-in-1 and PCV dose at 3 months (3+1). "
                     "The app does not show this. Should it say so?"),
        ],
    },
    "IE": {
        "note": "HSE primary childhood schedule for babies born on or after 1 October 2024. The 4–5-year doses "
                "are given in school (junior infants) and are shown at 4 years.",
        "sources": [
            "HSE, “Vaccines for your child” (schedule for babies born on or after 1 October 2024).",
            "HSE National Immunisation Office, Supporting Information for Vaccinations in General Practice, "
            "version 13 (August 2025).",
        ],
        "questions": [
            ("IE-1", "4-in-1 and MMRV at 4 years: these are given in school at 4–5 years, and MMRV at that "
                     "age is planned for this cohort (about 2028–29). Show them at 4 years, 5 years, or not "
                     "at all yet?"),
        ],
    },
    "IT": {
        "note": "National calendar of the PNPV 2023–2025 (extended to the end of 2026). Regions may add "
                "vaccines or move dates. Italy counts completed months (“2 months” = from day 61).",
        "sources": [
            "Piano Nazionale di Prevenzione Vaccinale 2023–2025, Calendario Nazionale Vaccinale (Ministero "
            "della Salute), extended to 31 December 2026.",
            "ISS EpiCentro vaccination calendar (April 2025); regional copies (ASL Nuoro, ASL Roma 3, Piemonte).",
        ],
        "questions": [
            ("IT-1", "MenB: we show 2 and 4 months (the earliest the national rules allow). Most regions give it "
                     "1–2 weeks after the 6-in-1, and EpiCentro gives day 91 and day 151 (3 and 5 months). "
                     "Which should the app show?"),
            ("IT-2", "MenB booster at 13 months (national table 13/14 months; some regions 13–15). Correct?"),
            ("IT-3", "Rotavirus dose 2 at 4 months with the 6-in-1 (3 months is also possible). Correct?"),
        ],
    },
    "ES": {
        "note": "Common national calendar (CISNS) 2026. Regions differ (for example MenACWY instead of MenC, "
                "PCV20 regions with an extra 6-month dose, 2 or 3 rotavirus doses).",
        "sources": [
            "Calendario común de vacunación e inmunización a lo largo de toda la vida, 2026 "
            "(approved by the CISNS on 12 December 2025).",
        ],
        "questions": [
            ("ES-1", "Several regions (Madrid, Cantabria, Valencia) now give MenACWY instead of MenC. Should the "
                     "app add a note such as “your region may use MenACWY instead of MenC”?"),
            ("ES-2", "MMR and chickenpox dose 2 at “3–4 years” are shown at 3 years. Correct?"),
        ],
    },
    "FR": {
        "note": "French vaccination calendar 2026. Rotavirus is shown as the 2-dose product (Rotarix); with "
                "RotaTeq there is a third dose at 4 months, which is not shown.",
        "sources": [
            "Calendrier des vaccinations et recommandations vaccinales 2026, Ministère chargé de la "
            "santé (July 2026 version).",
        ],
        "questions": [
            ("FR-1", "MMR dose 2 at 16 months (the window is 16–18 months). Correct?"),
            ("FR-2", "BCG is recommended from 1 month for children with a parent from a high-TB country (this "
                     "includes Pakistan). The app does not show it. Should it, as a conditional reminder?"),
        ],
    },
    "NL": {
        "note": "National programme (Rijksvaccinatieprogramma) 2026, including the 2025 changes (booster at 12 "
                "months, MMR 2 at 3 years, DKT at 5 years).",
        "sources": [
            "RIVM Rijksvaccinatieprogramma, vaccination schedule 2026 (schedule image August 2025) and RIVM "
            "news of 11 September 2024 on the 2025 changes.",
        ],
        "questions": [
            ("NL-1", "Babies whose mother did not have the whooping-cough vaccine at 22 weeks of pregnancy get an "
                     "extra 6-in-1 at 6–9 weeks. The app cannot know this. Should it show a note (“ask "
                     "your consultatiebureau”)?"),
            ("NL-2", "Rotavirus dose 1 at 6 weeks (the window is 6–9 weeks). Correct?"),
        ],
    },
    "NO": {
        "note": "Childhood immunisation programme (barnevaksinasjonsprogrammet). There is no pre-school booster "
                "before 6 years: the DTaP-IPV booster is at about 7 years (school year 2) and is not shown.",
        "sources": [
            "Norwegian Institute of Public Health (FHI), Vaksinasjonshåndboka, childhood programme (updated "
            "16 June 2026).",
        ],
        "questions": [
            ("NO-1", "Should the 7-year DTaP-IPV booster be shown, as other countries’ pre-school boosters "
                     "are?"),
            ("NO-2", "BCG is offered at about 6 weeks to babies with a parent from a high-TB country (this "
                     "includes Pakistani families). Should the app show it as a conditional reminder?"),
        ],
    },
    "SE": {
        "note": "Public Health Agency of Sweden childhood programme. Chickenpox at 18 months starts on 1 January "
                "2027 for children born on or after 1 July 2025.",
        "sources": [
            "Folkhälsomyndigheten, childhood vaccination programme (updated 16 April 2026); 1177 "
            "Vårdguiden (updated 21 October 2026).",
        ],
        "questions": [
            ("SE-1", "Rotavirus dose 3 at 5 months applies only with the 3-dose vaccine. It is shown for Sweden "
                     "(the national page lists 3 doses) but left out for Germany, Spain and France. Keep it?"),
            ("SE-2", "The chickenpox dose at 18 months is shown to every Swedish baby, although it applies only "
                     "to children born on or after 1 July 2025 (from 1 January 2027). Acceptable?"),
        ],
    },
    "TR": {
        "note": "Ministry of Health childhood schedule 2026 (6-in-1 at 2, 4, 6 and 18 months since April 2025; "
                "chickenpox dose 2 at 4 years from September 2026). Rotavirus and meningococcal vaccines are "
                "private, not national.",
        "sources": [
            "Türkiye Ministry of Health national childhood immunisation schedule 2026; WHO/UNICEF 2025 schedule "
            "data. Ministry announcements of 19 March 2025 (hexavalent) and September 2026 (chickenpox dose 2).",
        ],
        "questions": [
            ("TR-1", "Chickenpox dose 2 at 4 years from 1 September 2026 (from news and a provincial page; the "
                     "ministry site could not be opened). Correct?"),
        ],
    },
}

SCHEDULE_SOURCES = [
    "Each country’s official schedule, listed under the country.",
    "WHO/UNICEF Joint Reporting Form schedule data, reporting year 2025 (published 3 June 2026), used as a "
    "cross-check for every country.",
    "All sources were read between 1 and 27 October 2026.",
]

SCHEDULE_QUESTIONS = [
    ("G-1", "Where a source gives an age range, the app shows the earliest age (e.g. 16–24 months → 16 "
            "months). Is that the right choice for reminders, or should we use the usual age?"),
    ("G-2", "Doses that apply only with one vaccine brand (e.g. a third rotavirus dose) are left out for "
            "Germany, Spain and France but shown for the United States and Sweden. Which rule should we use?"),
    ("G-3", "BCG for babies whose parents come from a high-TB country is recommended in Bahrain, France, Norway "
            "and Sweden but not shown in the app. Should the app ask about this and show BCG when it applies?"),
    ("G-4", "Premature babies: the app uses chronological age for all due dates. Is that right for "
            "vaccinations in every country we cover?"),
]

# ---------------------------------------------------------------------------
# Section 2: RSV and flu
# ---------------------------------------------------------------------------

OPTIONAL_INTRO = [
    "Next to the routine schedule, the app shows RSV protection and the flu vaccine as “Optional – ask "
    "your doctor”, but only in countries that offer them to all babies or young children (not only to risk "
    "groups). Families can hide these reminders.",
    "How the RSV reminder works. A baby born inside the country’s window gets a reminder due on the day of "
    "birth. A baby born before the window gets a catch-up reminder on the catch-up date, but only if still under "
    "the age limit on that date. The reminder disappears at the end of the window if no dose is recorded. One "
    "RSV reminder per baby (first season only).",
    "How the flu reminder works. One reminder per season. It is due on the season start date, or on the day the "
    "child reaches the minimum age if that is later, and is shown for 6 months. If no flu vaccine has been "
    "recorded before and the child is under the two-dose age, the app adds the two-dose note. In the United "
    "Kingdom and Ireland it adds the nasal-spray note.",
]

# Short basis for each country that has an RSV rule (from the research notes).
RSV_BASIS = {
    "US": "CDC/ACIP: all infants under 8 months entering their first season, unless the mother had the RSV "
          "vaccine 14 or more days before birth. Mainland season October–March.",
    "CA": "NACI: all infants in their first season; provinces run it, most from about 1 October.",
    "AE": "MOHAP decree 189/2025; Abu Dhabi and Dubai circulars: babies born 1 September – 1 March, at "
          "birth. No catch-up programme found.",
    "SA": "Public Health Authority (Weqaya) national schedule since 2025: born in season at birth; under 8 "
          "months at season start from mid-September.",
    "KW": "National committee 2024: within 24 hours of birth in season; babies born up to 6 months before get it "
          "at the season start. Months set each year.",
    "FR": "DGS-Urgent 2026-10: campaign 14 September 2026 – 28 February 2027; at the maternity ward; babies "
          "born earlier get it before the season (no age limit stated).",
    "IE": "HSE 2026/27: born 1 September – 28 February in hospital; born 1 March – 31 August at the GP "
          "from 1 September.",
    "NL": "RIVM: born October–March within 14 days of birth; born April–September at the catch-up, "
          "15 September – 15 October.",
    "SE": "Joint recommendation to the regions, 27 August 2026: born from 10 September, at the maternity ward or "
          "first check; no catch-up.",
}

# What each programme offers (research summary), for the 23-country overview.
PROGRAMME_OVERVIEW = {
    "PK": ("Not in the EPI.", "Not in the EPI."),
    "GB": ("Maternal vaccine from 28 weeks; infant antibody only for babies born before 32 weeks or high-risk.",
           "All children aged 2 or 3 on 31 August, then school years; under 2 only in risk groups."),
    "US": ("All infants under 8 months (CDC 2025 schedule in force; under legal challenge).",
           "Everyone from 6 months (CDC 2025 schedule; AAP agrees; under legal challenge)."),
    "CA": ("All infants in most provinces; British Columbia high-risk only; Alberta hospital births "
           "November–April only.", "Everyone from 6 months."),
    "AE": ("Babies born 1 September – 1 March, at birth.", "Everyone from 6 months; children a priority."),
    "SA": ("All infants born in season; catch-up under 8 months.", "From 6 months (priority 6 months–5 years)."),
    "IN": ("No national programme.", "Not routine (IAP recommends privately)."),
    "BD": ("No national programme.", "Not routine for children."),
    "QA": ("Maternal vaccine at 28–36 weeks; infant antibody only “planned”.",
           "Everyone from 6 months (priority 6 months–5 years)."),
    "KW": ("All infants under 8 months (birth dose in season; catch-up at season start).",
           "Probably from 6 months; age range unclear."),
    "OM": ("No national programme.", "Not yet routine (under-5 introduction planned, not confirmed)."),
    "BH": ("Maternal vaccine from 32 weeks; no infant programme.", "Children 6 months to 5 years, every season."),
    "MY": ("Private only.", "Risk groups only."),
    "AU": ("Maternal vaccine nationally; infant antibody run by each state.", "All children 6 months to under 5 "
           "years."),
    "DE": ("All infants in their first season (STIKO, national).", "Risk groups only."),
    "IE": ("All infants (season September–February).", "Nasal spray for all children aged 2–17."),
    "IT": ("Free for all newborns, run by the regions.", "Children 6 months to 6 years."),
    "ES": ("All infants (national, 1 April – 31 March cohort).", "Children 6–59 months, every season."),
    "FR": ("All infants (antibody or maternal vaccine).", "Risk groups only."),
    "NL": ("All infants born from 1 April 2025.", "Risk groups only."),
    "NO": ("Risk groups only; a programme for all babies is planned from 1 July 2027.", "Risk groups only."),
    "SE": ("Regions: babies born from 10 September 2026, at birth; no catch-up.", "Risk groups only."),
    "TR": ("No national programme.", "Risk groups only."),
}

OPTIONAL_SOURCES = [
    "United States: CDC RSV immunization guidance for infants (August 2025); CDC 2025 child schedule; AAP "
    "2026–27 influenza recommendations; Congressional Research Service reports on the court stay.",
    "Canada: NACI statement on RSV monoclonal antibodies (10 April 2026); NACI seasonal influenza statement; "
    "provincial pages (Ontario 15 October 2026, Nova Scotia, Alberta, British Columbia).",
    "UAE: MOHAP decree 189/2025; Abu Dhabi DoH circular 37/2026; Dubai DHA circular CIR-2026-00000027; MOHAP "
    "flu campaign 2026–27 (as reported by Gulf News).",
    "Saudi Arabia: Public Health Authority (Weqaya) recommendations (as summarised by the manufacturer, July "
    "2026); MOH immunisation schedule card; MOH flu campaign news, 30 September 2026.",
    "Kuwait: ministerial letter 226 (2024) and national committee recommendation of 24 December 2024.",
    "France: DGS-Urgent n°2026_10 (10 August 2026). Ireland: HSE RSV immunisation for babies (14 August "
    "2026); HSE children’s flu vaccine 2026/27. Netherlands: RIVM addendum on RSV immunisation of babies "
    "(June 2026). Sweden: NT-rådet statement on nirsevimab (27 August 2026).",
    "United Kingdom: national flu immunisation programme 2026 to 2027 letter; UKHSA poster “Which flu vaccine "
    "should children have? 2026 to 2027”. Australia: NIP schedule and NCIRS. Qatar and Bahrain: MOPH and "
    "MOH flu pages and campaign news.",
    "Germany: STIKO Epidemiologisches Bulletin 37/2026. Spain: CISNS calendar 2026. Italy: Ministry flu "
    "circular 5134 (23 June 2026) and regional RSV campaigns. Norway: government budget proposal for 2027 "
    "(RSV from 1 July 2027).",
]

OPTIONAL_QUESTIONS = [
    ("RSV-1", "United States: if the appeal court reinstates the January 2026 CDC schedule, RSV protection "
              "becomes “high-risk groups” and flu “shared decision”. Should the app then "
              "drop both reminders, or keep them as “ask your doctor” (the AAP still recommends both)?"),
    ("RSV-2", "Germany, Spain and Italy offer RSV protection to all babies, and Spain (6–59 months) and "
              "Italy (6 months to 6 years) offer flu vaccine to all young children, but the app shows no "
              "optional reminder there. Should we add them, and with which dates?"),
    ("RSV-3", "Netherlands: a baby born between 15 and 30 September gets no RSV reminder at all (the catch-up "
              "date of 15 September has passed and the at-birth window only starts on 1 October). What should "
              "the app show for these babies?"),
    ("RSV-4", "UAE: no catch-up was found for babies born before 1 September, so they get no reminder. Should "
              "they get a soft “ask your doctor” in late August?"),
    ("RSV-5", "Canada: the reminder is shown to all Canadian babies, although British Columbia offers it only to "
              "high-risk babies and Alberta only to babies born in hospital November–April. Acceptable "
              "with the “ask your doctor” wording?"),
    ("RSV-6", "France: the source gives no age limit for the catch-up dose; the app uses “under 7 months on "
              "14 September”. Is that reasonable?"),
    ("RSV-7", "The RSV note says “If the mother had the RSV vaccine in pregnancy, the baby may not need "
              "it.” Is this right for every country listed? (Spain gives the antibody regardless; the "
              "Netherlands decides case by case.)"),
    ("RSV-8", "The maternal RSV vaccine is the main programme in the UK, Australia, Qatar and Bahrain. The app "
              "does not track pregnancy, so it shows nothing for these babies. Is a note needed?"),
    ("FLU-1", "Two-dose note: the app shows it when no flu vaccine has been recorded in the app and the child is "
              "under 9. The US rule is “fewer than 2 doses before 1 July”. Is the simpler rule "
              "acceptable?"),
    ("FLU-2", "United Kingdom: the app reminds from the second birthday, but only children aged 2 or 3 on 31 "
              "August are offered it that season. Acceptable, or should the app follow the 31 August rule?"),
    ("FLU-3", "Bahrain offers flu vaccine “from 6 months to 5 years”; the app stops at the 5th "
              "birthday. Correct?"),
    ("FLU-4", "Kuwait (probably from 6 months) and Oman (under-5 programme planned) have no flu reminder. "
              "Should they?"),
]

# ---------------------------------------------------------------------------
# Section 3: medical wording
# ---------------------------------------------------------------------------

WORDING_INTRO = [
    "Below is the exact English text parents see, grouped by topic, with where it appears. Words in [square "
    "brackets] are filled in by the app (for example the baby’s name or a number). Long texts are split "
    "into their bullet points so each can be marked.",
]

# (heading, intro or None, [(arb key, where it appears, split_bullets)])
WORDING_GROUPS = [
    ("3.1 Fever and temperature", None, [
        ("youngFeverWarning", "Red warning shown when a parent logs a symptom with a temperature (see rule above)",
         False),
        ("invalidTemperature", "Error when a temperature outside the accepted range is entered", False),
    ]),
    ("3.2 Medicines", None, [
        ("medicineSafetyNote", "Shown on the medicines screen", False),
        ("prescribedDoseLabel", "Label of the dose field when adding a medicine (the parent types the dose)",
         False),
    ]),
    ("3.4 Illness, symptoms and the doctor summary", None, [
        ("startIllnessButton", "Button on the health screen", False),
        ("startIllnessHelp", "Explains illness tracking", False),
        ("severityLabel", "Question when logging a symptom (answers: Mild / Moderate / Severe)", False),
        ("sumFooter", "Last line of the summary for the doctor", False),
    ]),
    ("3.5 Emergency signs and the help screen", None, [
        ("callEmergencyWhen", "Heading of the red box at the top of the help screen", False),
        ("emergencySigns", "Red box on the help screen (all countries)", True),
        ("emergencyNumbersNote", "Under the emergency numbers", False),
        ("noEmergencyNumbers", "When we have no numbers for the country", False),
        ("helpSources", "Last line of the help screen", False),
    ]),
    ("3.6 Hot weather and dehydration", None, [
        ("heatTitle", "Heading (shown only in Pakistan, India and Bangladesh)", False),
        ("heatGuide", "Hot-weather advice (Pakistan, India and Bangladesh only)", True),
        ("dehydrationTitle", "Heading (all countries)", False),
        ("dehydrationSigns", "Dehydration signs (all countries)", True),
    ]),
    ("3.7 Feeding, diapers and sleep guidance", None, [
        ("newbornFeedsGuide", "Reports screen, first 8 weeks", False),
        ("wetGuide", "Reports screen, from day 5 to 13 weeks", False),
        ("dirtyGuide", "Reports screen, from day 5 to 6 weeks", False),
        ("reportSources", "Reports screen, under the charts", False),
    ]),
    ("3.8 Breast milk storage", "The app also uses these limits to mark stored milk as “expires soon” "
                                "or “expired”: room 4 hours, cooler bag 24 hours, fridge 4 days, "
                                "freezer 6 months, thawed 24 hours.", [
        ("storageGuide", "“How long milk keeps” guide", True),
        ("loadSheddingGuide", "Power-cut (load-shedding) advice for stored milk", True),
    ]),
    ("3.9 Vaccination screen", None, [
        ("vaccineScheduleNote", "Above the Pakistan schedule", False),
        ("vaccineScheduleNoteCountry", "Above every other country’s schedule", False),
        ("vaccineScheduleNoteCanada", "Above the Canadian schedule", False),
        ("catchUpNote", "Shown when a vaccine is overdue", False),
        ("noScheduleBody", "Countries without a built-in schedule", False),
        ("otherVaccinesHelp", "Section for vaccines outside the schedule", False),
    ]),
]

GROWTH_STRINGS = [
    ("growthCheckDoctorTitle", "Growth check result: highest level", False),
    ("growthCheckDoctorBody", "Text under “Talk to your doctor”", False),
    ("growthCheckMentionTitle", "Growth check result: middle level", False),
    ("growthCheckMentionBody", "Text under “Mention it at the next check-up”", False),
    ("growthCheckOkTitle", "Growth check result: nothing found", False),
    ("growthCheckOkBody", "Text under “Growing as expected”", False),
    ("growthFlagBelowRange", "Reason shown with the result", False),
    ("growthFlagAboveRange", "Reason shown with the result", False),
    ("growthFlagFallingAcross", "Reason shown with the result", False),
    ("growthFlagRisingAcross", "Reason shown with the result", False),
    ("growthFlagBelowBirthWeight", "Reason shown with the result", False),
    ("growthFlagSlowGain", "Reason shown with the result", False),
    ("growthCheckTypo", "Under the result", False),
    ("weightGainSummary", "Weight-gain card (birth to 12 months)", False),
    ("weightGainRange", "Weight-gain card", False),
    ("weightGainUsual", "Weight-gain card, gain between the WHO 5th and 95th centiles", False),
    ("weightGainSlow", "Weight-gain card, gain below the WHO 5th centile", False),
    ("weightGainFast", "Weight-gain card, gain above the WHO 95th centile", False),
    ("percentileExplain", "“What do percentiles mean?”", False),
    ("percentileMeaningWeight", "Next to each weight", False),
    ("curvesLegend", "Under the growth chart", False),
    ("whoAgeLimit", "Under the growth chart", False),
]

# Fill-ins for {placeholders}, shown to the doctor in [brackets].
PLACEHOLDERS = {
    "name": "baby’s name", "number": "emergency number", "emergency": "emergency number",
    "measure": "Weight / Length / Head size", "percentile": "number", "gain": "number", "days": "number",
    "low": "number", "high": "number", "median": "number", "country": "country", "age": "age",
    "season": "season, e.g. 2026–27", "vaccine": "vaccine name", "count": "number", "months": "number",
    "allergens": "allergens",
}

WORDING_SOURCES = [
    "Fever, emergency and dehydration signs: NHS and WHO guidance (as stated in the app); NICE guideline NG143 "
    "(fever in under 5s) for the under-3-months threshold.",
    "Growth: WHO Child Growth Standards (2006) and WHO growth velocity standards (weight 1-month increments); "
    "NHS / RCPCH guidance on reading growth charts.",
    "Feeds and diapers: NHS. Sleep ranges: National Sleep Foundation (under 4 months) and American Academy of "
    "Sleep Medicine (4 months and older, endorsed by the AAP).",
    "Breast milk storage: CDC, “Proper storage and preparation of breast milk”.",
]

WORDING_QUESTIONS = [
    ("W-1", "Fever: the red warning appears only for 38 °C or more under 3 months. Should the app also "
            "warn at 3–6 months (e.g. 39 °C or more), or for any age with a very high temperature?"),
    ("W-2", "Fever: the app does not ask how the temperature was taken (armpit, ear, forehead, rectal). Does "
            "the 38 °C threshold need a note about this?"),
    ("W-3", "Growth check: are the triggers and levels in the table in 3.3 appropriate (“Talk to your "
            "doctor” vs “Mention it at the next check-up”)?"),
    ("W-4", "Growth check: the app uses chronological age. Should babies born before 37 weeks use corrected age "
            "(and if so, until what age)?"),
    ("W-5", "Growth check: “crossing two lines” uses the five lines on the chart (3rd, 15th, 50th, "
            "85th, 97th). This needs a fall of at least about 0.85 standard deviations, usually more than 1. Is "
            "that sensitive enough, or too sensitive?"),
    ("W-6", "“Talk to your doctor” text says “Book a visit in the next few days. Go today if your "
            "baby is feeding poorly, has few wet diapers or seems unwell.” Is this the right urgency?"),
    ("W-7", "Emergency signs list: is anything important missing (for example a non-blanching rash, a bulging "
            "fontanelle, or fever in a baby under 3 months)?"),
    ("W-8", "Hot-weather advice is shown only for Pakistan, India and Bangladesh. Should it be shown in the Gulf "
            "countries too (UAE, Saudi Arabia, Qatar, Kuwait, Oman, Bahrain)?"),
    ("W-9", "Symptom list and illness types (3.4): anything missing that parents should be able to record (e.g. "
            "breathing difficulty, jaundice, fewer wet diapers)?"),
]

# ---------------------------------------------------------------------------
# Section 4: emergency numbers
# ---------------------------------------------------------------------------

EMERGENCY_INTRO = [
    "The help screen lists these numbers for the baby’s country; a tap calls the number. The first number "
    "is also used in “call now” warnings (for Pakistan the warning says “1122 / 115”). The "
    "label is what the app shows under the number.",
]

EMERGENCY_SOURCES = [
    "Official emergency-service and health-service pages for each country, checked 27 October 2026 (for "
    "example NHS 111, healthdirect Australia, 1177 Vårdguiden, Norwegian Poison Information Centre, "
    "National Poisons Information Centre Ireland, AIIMS National Poisons Information Centre India, Türkiye "
    "UZEM).",
]

EMERGENCY_QUESTIONS = [
    ("E-1", "Pakistan: Rescue 1122 first, then Edhi 115 and Chhipa 1020 (Karachi). Is this the right order and "
            "set of numbers for parents of a sick baby?"),
    ("E-2", "Every poison line is labelled “Poison Control”. Ireland’s public line is open "
            "8 am–10 pm only, and Sweden’s is for less urgent cases (acute poisoning: 112). Should "
            "the labels say so?"),
    ("E-3", "Countries with no poison line in the app (e.g. Pakistan, the Gulf countries): is there a "
            "national poison line we should add?"),
]

# ---------------------------------------------------------------------------
# Section 5: solids
# ---------------------------------------------------------------------------

SOLIDS_INTRO = [
    "The solids guide has short guides, a list of first foods with preparation notes, allergen tracking, and 15 "
    "home-style recipes for 6 to 12 months. Foods marked “choking risk” show “Choking risk: "
    "prepare as described”. When a parent records a reaction, the app shows the reaction texts below.",
]

SOLIDS_STRINGS = [
    ("solidsTooYoung", "Shown before 6 months", False),
    ("chokingRisk", "On every food marked as a choking risk", False),
    ("reactionWarning", "After a parent records a reaction to a food", False),
    ("severeReactionNow", "After a parent records a severe reaction", False),
    ("recipesRules", "Top of the recipes list", False),
    ("recipesSource", "Bottom of the recipes list", False),
]

SOLIDS_QUESTIONS = [
    ("S-1", "All allergens (egg, milk, peanut, tree nuts, sesame, wheat, fish) are offered from about 6 months. "
            "Should the app say more for babies with severe eczema or a known food allergy (currently: “ask "
            "your doctor first”)?"),
    ("S-2", "The fish recipe suggests rohu or surmai fillet. Rohu has many small bones. Is it safe to suggest, "
            "or should we name other fish?"),
    ("S-3", "Several recipes use ghee, which is not flagged as a milk allergen. Should it be?"),
    ("S-4", "Is any common allergen missing for our families (e.g. soya, shellfish)?"),
    ("S-5", "The “not before 12 months” list has only honey (plus salt, sugar, whole nuts and cow’s "
            "milk as a main drink in the rules). Should anything else be added (e.g. fruit juice, rice drinks, raw or "
            "unpasteurised foods)?"),
]

SOLIDS_SOURCES = [
    "NHS, “Your baby’s first solid foods” and “Foods to avoid giving babies and young "
    "children”.",
    "WHO guidance on infant and young child feeding (complementary feeding).",
]

# ---------------------------------------------------------------------------
# Section 6: milestones
# ---------------------------------------------------------------------------

MILESTONES_INTRO = [
    "Parents can tick milestones for each age (2, 4, 6, 9, 12, 15 and 18 months). Each age also shows a few "
    "“Ways to help”. The app does not score or diagnose; it shows the “When to talk to the "
    "doctor” text below.",
]

MILESTONES_QUESTIONS = [
    ("M-1", "The checklists stop at 18 months. Should we add 24 and 30 months and 3 years?"),
    ("M-2", "Premature babies: should milestones use corrected age?"),
    ("M-3", "Are any milestones or tips inappropriate for families in Pakistan or the Gulf (for example the "
            "“no screens” advice, or cultural fit of the play examples)?"),
]

# ---------------------------------------------------------------------------
# Final page
# ---------------------------------------------------------------------------

SIGN_OFF = [
    "I have reviewed the medical content in this pack. My corrections and comments are marked above.",
]
