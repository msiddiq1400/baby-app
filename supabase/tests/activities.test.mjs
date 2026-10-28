// Activities (tummy time, bath, ...; migration 20261028000001): family
// members share them, outsiders can't see or add any, the server refuses
// values the app never writes, and phones get them through PowerSync.
import { test } from "node:test";
import assert from "node:assert/strict";
import { setup } from "./harness.mjs";

const h = await setup();

async function rejects(promise, code) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code, e.message);
    return true;
  });
}

const start = "2026-10-20T08:00:00Z";

test("a family member logs one; everyone in the family sees it, outsiders don't", async () => {
  const { owner, members: [m] } = await h.family(1);
  const id = await m.insert("activities", { kind: "tummy_time", started_at: start, ended_at: "2026-10-20T08:10:00Z" });
  const seen = await owner.sql(`select kind, created_by from public.activities where id = $1`, [id]);
  assert.deepEqual(seen, [{ kind: "tummy_time", created_by: m.id }]);

  const outsider = await h.user();
  assert.deepEqual(await outsider.sql(`select id from public.activities`), []);
  outsider.familyId = owner.familyId;
  outsider.babyId = owner.babyId;
  await rejects(outsider.insert("activities", { kind: "bath", started_at: start }), "42501");
});

test("a running timer (no end) and an entry without a duration (end = start) are both fine", async () => {
  const { owner } = await h.family();
  await owner.insert("activities", { kind: "tummy_time", started_at: start });
  await owner.insert("activities", { kind: "bath", started_at: start, ended_at: start });
  await owner.insert("activities", { kind: "other", label: "Swimming", started_at: start, notes: "First time!" });
});

test("the server refuses what the app never writes", async () => {
  const { owner } = await h.family();
  await rejects(owner.insert("activities", { kind: "juggling", started_at: start }), "23514");
  await rejects(owner.insert("activities", { kind: "other", label: "x".repeat(61), started_at: start }), "23514");
  await rejects(owner.insert("activities", { kind: "bath", notes: "x".repeat(501), started_at: start }), "23514");
  await rejects(
    owner.insert("activities", { kind: "play", started_at: start, ended_at: "2026-10-20T07:59:00Z" }),
    "23514",
  );
});

test("activities are streamed to phones", async () => {
  const published = (await h.admin(`select tablename from pg_publication_tables where pubname = 'powersync'`)).map(
    (r) => r.tablename,
  );
  assert.ok(published.includes("activities"));
});
