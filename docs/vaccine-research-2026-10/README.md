# Vaccine research, 27 Oct 2026

Notes behind the 17 new country schedules
(`supabase/migrations/20261027000003_more_country_schedules.sql`, todos.txt
Q2) and the optional RSV and flu reminders (`app/lib/core/optional_vaccines.dart`,
Q5). One file per group of countries, each with the official sources (links
and dates), the doses as SQL rows, RSV and flu policy, emergency numbers, and
the open doubts.

Everything here is unverified until a pediatrician has checked it
(todos.txt 21). Where the migration differs from a file, the migration's
header says why (e.g. brand-specific rotavirus doses left out).
