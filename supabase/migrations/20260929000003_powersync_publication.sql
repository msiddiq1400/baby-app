-- Tables PowerSync streams to phones for offline use. The publication must
-- be named "powersync". New tables that should work offline must be added
-- here (alter publication powersync add table ...) and to the sync rules.
--
-- The replication role PowerSync logs in with is created by hand in the SQL
-- editor, because it has a password that must not be in the repo.

-- family_members is needed by the sync rules to decide which families each
-- phone gets. (On the hosted project it was added to the publication during
-- PowerSync setup; it's listed here so fresh setups match.)
create publication powersync for table
  public.families,
  public.family_members,
  public.family_members,
  public.babies,
  public.feeds,
  public.pumping_sessions,
  public.diapers,
  public.sleeps,
  public.growth_measurements,
  public.medications,
  public.medication_doses,
  public.vaccinations,
  public.symptom_logs,
  public.milk_stash,
  public.vaccine_schedule;
