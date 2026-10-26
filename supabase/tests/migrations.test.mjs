// Every migration applies cleanly, in order, on a fresh Postgres (PGlite with
// Supabase stubs), and the result has what the app and PowerSync rely on.
import { test } from "node:test";
import assert from "node:assert/strict";
import { applyMigrations, bareDb, migrationFiles } from "./harness.mjs";

test("all migrations apply in order on a fresh database", async () => {
  const db = await bareDb();
  try {
    await applyMigrations(db);
    const tables = (await db.query(
      `select table_name from information_schema.tables where table_schema = 'public' order by 1`)).rows.map((r) => r.table_name);
    for (const t of ["families", "family_members", "babies", "feeds", "sleeps", "medication_doses", "push_devices"]) {
      assert.ok(tables.includes(t), `public.${t} exists`);
    }
  } finally {
    await db.close();
  }
});

test("migration file names are unique and in timestamp order", () => {
  const stamps = migrationFiles.map((f) => f.split("_")[0]);
  assert.equal(new Set(stamps).size, stamps.length, "no two migrations share a timestamp");
  assert.deepEqual([...stamps].sort(), stamps);
});

test("push_devices is server-only: not streamed to phones", async () => {
  const db = await bareDb();
  try {
    await applyMigrations(db);
    const published = (await db.query(
      `select tablename from pg_publication_tables where pubname = 'powersync'`)).rows.map((r) => r.tablename);
    assert.ok(published.includes("feeds"));
    assert.equal(published.includes("push_devices"), false);
  } finally {
    await db.close();
  }
});
