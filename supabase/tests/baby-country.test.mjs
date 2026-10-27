// Only the person who added a baby changes its country (todos.txt Q1).
import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { setup } from "./harness.mjs";

const h = await setup();

async function rejects(promise, code) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code, e.message);
    return true;
  });
}

/** Adds a baby as [c] (like a PowerSync upload); returns its id. */
async function addBaby(c, extra = {}) {
  const row = { id: crypto.randomUUID(), family_id: c.familyId, name: "Ali", birth_date: "2026-09-01", country_code: "PK", ...extra };
  const keys = Object.keys(row);
  await c.sql(
    `insert into public.babies (${keys.join(", ")}) values (${keys.map((_, i) => `$${i + 1}`).join(", ")})`,
    keys.map((k) => row[k]),
  );
  return row.id;
}

const country = async (babyId) =>
  (await h.admin(`select country_code from public.babies where id = $1`, [babyId]))[0].country_code;

describe("baby country", () => {
  test("the person who added the baby can change it", async () => {
    const { owner, babyId } = await h.family(1);
    await owner.update("babies", babyId, { country_code: "GB" });
    assert.equal(await country(babyId), "GB");
  });

  test("an invited member can't change it, but can edit the rest", async () => {
    const { members: [m], babyId } = await h.family(1);
    await rejects(m.update("babies", babyId, { country_code: "GB" }), "42501");
    await m.update("babies", babyId, { name: "Aisha Khan", country_code: "PK" });
    const [b] = await h.admin(`select name, country_code from public.babies where id = $1`, [babyId]);
    assert.deepEqual([b.name, b.country_code], ["Aisha Khan", "PK"]);
  });

  test("a baby added by a member: only that member, not the owner", async () => {
    const { owner, members: [m], familyId } = await h.family(1);
    const babyId = await addBaby(m);
    await rejects(owner.update("babies", babyId, { country_code: "AE" }), "42501");
    await m.update("babies", babyId, { country_code: "AE" });
    assert.equal(await country(babyId), "AE");
    assert.ok(familyId);
  });

  test("creator left the family: the owner can change it, other members can't", async () => {
    const { owner, members: [m1, m2], familyId } = await h.family(2);
    const babyId = await addBaby(m1);
    await m1.sql(`delete from public.family_members where family_id = $1 and user_id = $2`, [familyId, m1.id]);
    await rejects(m2.update("babies", babyId, { country_code: "CA" }), "42501");
    await owner.update("babies", babyId, { country_code: "CA" });
    assert.equal(await country(babyId), "CA");
  });

  test("creator deleted their account: the owner can change it", async () => {
    const { owner, members: [m], familyId } = await h.family(1);
    const babyId = await addBaby(m);
    await m.rpc("delete_my_account");
    const [b] = await h.admin(`select created_by from public.babies where id = $1`, [babyId]);
    assert.equal(b.created_by, null);
    await owner.update("babies", babyId, { country_code: "US" });
    assert.equal(await country(babyId), "US");
    assert.ok(familyId);
  });

  test("nobody can put a baby in someone else's name", async () => {
    const { owner, members: [m], babyId } = await h.family(1);
    await rejects(m.update("babies", babyId, { created_by: m.id }), "42501");
    await rejects(
      addBaby(m, { created_by: owner.id }),
      "42501",
    );
  });
});
