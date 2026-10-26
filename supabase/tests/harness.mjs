// Test harness for Palna's server rules.
//
// Runs every supabase/migrations/*.sql, in order, on PGlite (real Postgres
// compiled to WASM, in memory). Nothing here talks to the live project.
//
// What Supabase normally provides is stubbed BEFORE the migrations run:
//   auth.users / auth.uid()   auth.uid() reads the setting test.uid
//   anon / authenticated / service_role roles, and Supabase's default grants
//                             (every new public table/function granted to all
//                             three - the worst case, so the migrations' own
//                             revokes are what keep clients out)
//   storage.buckets / storage.objects / storage.foldername()  for photos
//   net.http_post             records each call into test.pushes instead of
//                             calling the Edge Function (or fails, when the
//                             setting test.net_fails is 'on')
//   vault.decrypted_secrets   a table holding 'palna_hook_secret'
// "create extension pg_net" is stripped (PGlite has no pg_net).
//
// Every call made "as a user" runs in its own transaction with
// `set local role authenticated` and test.uid set, like a PostgREST request,
// so grants, RLS and triggers see auth.uid() exactly as for a signed-in phone.
//
// One database per test file (each file is its own process); tests stay
// independent by using fresh users and families (h.family()).

import { PGlite } from "@electric-sql/pglite";
import { readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { randomUUID } from "node:crypto";
import { after, beforeEach } from "node:test";

const here = dirname(fileURLToPath(import.meta.url));
export const migrationsDir = join(here, "..", "migrations");
export const migrationFiles = readdirSync(migrationsDir).filter((f) => f.endsWith(".sql")).sort();

export const MIN = 60_000;
export const HOUR = 60 * MIN;

const STUBS = `
  create role anon nologin noinherit;
  create role authenticated nologin noinherit;
  create role service_role nologin noinherit bypassrls;

  create schema auth;
  create table auth.users (id uuid primary key, email text, raw_user_meta_data jsonb default '{}'::jsonb);
  create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('test.uid', true), '')::uuid $$;
  grant usage on schema auth to anon, authenticated, service_role;

  create schema extensions;

  create schema storage;
  create table storage.buckets (
    id text primary key, name text, public boolean, file_size_limit bigint, allowed_mime_types text[]
  );
  create table storage.objects (id uuid primary key default gen_random_uuid(), bucket_id text, name text);
  alter table storage.objects enable row level security;
  create function storage.foldername(name text) returns text[] language sql immutable as
    $$ select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'), 1) - 1] $$;
  grant usage on schema storage to anon, authenticated, service_role;

  create schema test;
  create table test.pushes (id serial primary key, url text, headers jsonb, body jsonb);

  create schema net;
  create function net.http_post(url text, headers jsonb, body jsonb) returns bigint
    language plpgsql as $$
    begin
      if current_setting('test.net_fails', true) = 'on' then
        raise exception 'pg_net is down';
      end if;
      insert into test.pushes (url, headers, body) values (url, headers, body);
      return currval('test.pushes_id_seq');
    end $$;
  grant usage on schema net to anon, authenticated, service_role;
  grant execute on function net.http_post(text, jsonb, jsonb) to anon, authenticated, service_role;
  grant usage on schema test to anon, authenticated, service_role;
  grant insert on test.pushes to anon, authenticated, service_role;
  grant usage on sequence test.pushes_id_seq to anon, authenticated, service_role;

  create schema vault;
  create table vault.decrypted_secrets (name text primary key, decrypted_secret text);
  insert into vault.decrypted_secrets values ('palna_hook_secret', 'test-secret');

  -- Supabase's default: anything new in public is granted to the API roles.
  grant usage on schema public to anon, authenticated, service_role;
  alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
  alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
  alter default privileges in schema public grant execute on functions to anon, authenticated, service_role;
`;

export async function applyMigrations(db, files = migrationFiles) {
  for (const f of files) {
    const sql = readFileSync(join(migrationsDir, f), "utf8")
      .replace(/create extension if not exists pg_net[^;]*;/gi, "");
    try {
      await db.exec(sql);
    } catch (e) {
      e.message = `${f}: ${e.message}`;
      throw e;
    }
  }
}

/** A fresh database with stubs only (no migrations). */
export async function bareDb() {
  const db = new PGlite();
  await db.exec(STUBS);
  return db;
}

/** A database with every migration applied, plus helpers. */
export async function setup() {
  const db = await bareDb();
  await applyMigrations(db);
  const h = new Harness(db);
  beforeEach(() => h.reset());
  after(() => db.close());
  return h;
}

// Named-argument call like PostgREST's rpc(); argument types come from the
// function itself.
function rpcSql(name, args) {
  const keys = Object.keys(args);
  const list = keys.map((k, i) => `${k} => $${i + 1}`).join(", ");
  return { sql: `select public.${name}(${list}) as r`, params: keys.map((k) => args[k]) };
}

/** A signed-in person (or anon) calling the API. */
export class Client {
  constructor(h, role, id = null, email = null) {
    this.h = h;
    this.role = role;
    this.id = id;
    this.email = email;
  }

  /** Runs one statement as this client, in its own transaction. Returns rows. */
  async sql(q, params = []) {
    return this.h.db.transaction(async (tx) => {
      await tx.query(`select set_config('test.uid', $1, true)`, [this.id ?? ""]);
      await tx.exec(`set local role ${this.role}`);
      return (await tx.query(q, params)).rows;
    });
  }

  /** Calls public.<name>(...) with named arguments; returns its result. */
  async rpc(name, args = {}) {
    const { sql, params } = rpcSql(name, args);
    return (await this.sql(sql, params))[0].r;
  }

  /** register_device with defaults; override any p_ argument. */
  register(token, o = {}) {
    return this.rpc("register_device", {
      p_token: token,
      p_platform: "android",
      p_locale: "en",
      p_time_zone: "Asia/Karachi",
      p_notify_feeds: true,
      p_notify_sleep: true,
      p_notify_medicines: true,
      p_quiet_from: null,
      p_quiet_to: null,
      ...o,
    });
  }

  /**
   * Inserts a row as this person, like a PowerSync upload (family and baby
   * filled in). Returns the new id.
   */
  async insert(table, values) {
    const row = { id: randomUUID(), family_id: this.familyId, baby_id: this.babyId, ...values };
    const keys = Object.keys(row);
    await this.sql(
      `insert into public.${table} (${keys.join(", ")}) values (${keys.map((_, i) => `$${i + 1}`).join(", ")})`,
      keys.map((k) => row[k]),
    );
    return row.id;
  }

  /** Updates a row as this person, like a PowerSync PATCH upload. */
  async update(table, id, values) {
    const keys = Object.keys(values);
    await this.sql(
      `update public.${table} set ${keys.map((k, i) => `${k} = $${i + 1}`).join(", ")} where id = $${keys.length + 1}`,
      [...keys.map((k) => values[k]), id],
    );
  }
}

export class Harness {
  constructor(db) {
    this.db = db;
    this.anon = new Client(this, "anon");
  }

  async reset() {
    await this.db.exec(`
      select set_config('test.net_fails', 'off', false);
      insert into vault.decrypted_secrets values ('palna_hook_secret', 'test-secret') on conflict do nothing;
      delete from test.pushes;
    `);
  }

  /** Runs SQL as the superuser (what the SQL editor / migrations can do). */
  async admin(q, params = []) {
    return (await this.db.query(q, params)).rows;
  }

  /** A new signed-in user (with a profile, as the auth trigger makes). */
  async user({ email, name = null } = {}) {
    const id = randomUUID();
    email ??= `${id.slice(0, 8)}@test.dev`;
    await this.admin(`insert into auth.users (id, email, raw_user_meta_data) values ($1, $2, $3)`, [
      id, email, name == null ? {} : { full_name: name },
    ]);
    return new Client(this, "authenticated", id, email);
  }

  /**
   * A family with one baby: the owner (who adds the baby) and [members]
   * more people who joined. Every client knows familyId and babyId.
   */
  async family(members = 1) {
    const owner = await this.user({ name: "Sana" });
    const familyId = randomUUID();
    const babyId = randomUUID();
    await owner.sql(`insert into public.families (id, name) values ($1, 'Test family')`, [familyId]);
    await owner.sql(
      `insert into public.babies (id, family_id, name, birth_date, country_code) values ($1, $2, 'Aisha', current_date - 100, 'PK')`,
      [babyId, familyId],
    );
    const others = [];
    for (let i = 0; i < members; i++) {
      const m = await this.user({ name: `Member ${i + 1}` });
      await this.admin(`insert into public.family_members (family_id, user_id, role) values ($1, $2, 'caregiver')`, [
        familyId, m.id,
      ]);
      others.push(m);
    }
    for (const c of [owner, ...others]) {
      c.familyId = familyId;
      c.babyId = babyId;
    }
    return { owner, members: others, familyId, babyId };
  }

  /** Calls posted to the notify-family function, oldest first. */
  async pushes() {
    return (await this.admin(`select url, headers, body from test.pushes order by id`));
  }

  /** An ISO time [ms] ago (negative = in the future). */
  ago(ms) {
    return new Date(Date.now() - ms).toISOString();
  }
}
