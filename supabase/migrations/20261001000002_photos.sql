-- Monthly photos: one photo per baby per month of age (the free plan's
-- limit; a paid plan will allow more, see todos.txt item 38).
--
-- The picture itself is a file in the private Storage bucket "photos", at
-- <family_id>/<photo id>.jpg. Phones upload and download it with PowerSync's
-- attachment queue; this table is the record that syncs like every other.

create table public.photos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  -- Completed months of age the photo is for: 0 = newborn, 1 = one month...
  age_month integer not null check (age_month between 0 and 60),
  caption text check (caption is null or char_length(caption) <= 200),
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

-- The free limit, enforced here so it can't be bypassed: one live photo per
-- baby per month. (Drop or relax this for the paid plan.)
create unique index photos_one_per_month on public.photos (baby_id, age_month) where deleted_at is null;
create index photos_family_updated_idx on public.photos (family_id, updated_at);

create trigger set_updated_at before update on public.photos
  for each row execute function private.set_updated_at();

alter table public.photos enable row level security;
create policy "family members can do everything" on public.photos
  for all to authenticated
  using ((select private.is_family_member(family_id)))
  with check ((select private.is_family_member(family_id)));

grant select, insert, update, delete on public.photos to authenticated;

alter publication powersync add table public.photos;

-- ── Storage ──────────────────────────────────────────────────────────────────
-- Private bucket; phones shrink photos to about 1600 px JPEG before upload,
-- so 2 MB is plenty.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 2097152, array['image/jpeg'])
on conflict (id) do nothing;

-- Only members of the family in the first folder of the path can read,
-- upload or delete its photos.
create policy "family members read photos" on storage.objects
  for select to authenticated
  using (bucket_id = 'photos' and (select private.is_family_member(((storage.foldername(name))[1])::uuid)));
create policy "family members upload photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (select private.is_family_member(((storage.foldername(name))[1])::uuid)));
create policy "family members replace photos" on storage.objects
  for update to authenticated
  using (bucket_id = 'photos' and (select private.is_family_member(((storage.foldername(name))[1])::uuid)));
create policy "family members delete photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and (select private.is_family_member(((storage.foldername(name))[1])::uuid)));
