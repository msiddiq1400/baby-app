// Paid plans (todos.txt 38b): who is Pro, and the Free limits the server
// enforces (one baby per family; one photo per baby per month, Pro 10).
import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { setup } from "./harness.mjs";

const h = await setup();

async function rejects(promise, code) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code, e.message);
    return true;
  });
}

const DAY = 86_400_000;
const proUntil = async (familyId) =>
  (await h.admin(`select pro_until from public.families where id = $1`, [familyId]))[0].pro_until;

/** What the revenuecat Edge Function writes (service role). */
const subscribe = (userId, until) =>
  h.admin(
    `insert into public.subscriptions (user_id, pro_until, product_id, store) values ($1, $2, 'palna_pro_yearly', 'app_store')
     on conflict (user_id) do update set pro_until = excluded.pro_until`,
    [userId, until],
  );

async function addBaby(c) {
  const id = randomUUID();
  await c.sql(
    `insert into public.babies (id, family_id, name, birth_date, country_code) values ($1, $2, 'Ali', '2026-09-01', 'PK')`,
    [id, c.familyId],
  );
  return id;
}

async function addPhoto(c, ageMonth = 2) {
  const id = randomUUID();
  await c.sql(`insert into public.photos (id, family_id, baby_id, age_month) values ($1, $2, $3, $4)`, [
    id, c.familyId, c.babyId, ageMonth,
  ]);
  return id;
}

describe("who is Pro", () => {
  test("a new family is Free", async () => {
    const { familyId } = await h.family();
    assert.equal(await proUntil(familyId), null);
  });

  test("one member buys Pro: the whole family has it, until it ends", async () => {
    const { members: [m], familyId } = await h.family(1);
    const until = new Date(Date.now() + 30 * DAY);
    await subscribe(m.id, until.toISOString());
    assert.equal((await proUntil(familyId)).getTime(), until.getTime());
    await subscribe(m.id, null); // refunded
    assert.equal(await proUntil(familyId), null);
  });

  test("joining brings Pro into a family, leaving takes it away", async () => {
    const { familyId } = await h.family();
    const buyer = await h.user();
    await subscribe(buyer.id, new Date(Date.now() + DAY).toISOString());
    await h.admin(`insert into public.family_members (family_id, user_id) values ($1, $2)`, [familyId, buyer.id]);
    assert.ok(await proUntil(familyId));
    await buyer.sql(`delete from public.family_members where family_id = $1 and user_id = $2`, [familyId, buyer.id]);
    assert.equal(await proUntil(familyId), null);
  });

  test("the reviewer's demo account is Pro with no end date", async () => {
    const reviewer = await h.user({ email: "review@palnacare.com" });
    const familyId = randomUUID();
    await reviewer.sql(`insert into public.families (id, name) values ($1, 'Review family')`, [familyId]);
    const [f] = await h.admin(`select pro_until::text as until from public.families where id = $1`, [familyId]);
    assert.equal(f.until, "infinity");
  });

  test("phones can't make themselves Pro", async () => {
    const { owner, familyId } = await h.family();
    await owner.sql(`update public.families set pro_until = 'infinity', name = 'Khan family' where id = $1`, [familyId]);
    const [f] = await h.admin(`select name, pro_until from public.families where id = $1`, [familyId]);
    assert.deepEqual([f.name, f.pro_until], ["Khan family", null]);
    await rejects(owner.sql(`insert into public.subscriptions (user_id, pro_until) values ($1, 'infinity')`, [owner.id]), "42501");
  });

  test("people see only their own subscription", async () => {
    const a = await h.user();
    const b = await h.user();
    await subscribe(a.id, new Date(Date.now() + DAY).toISOString());
    assert.equal((await a.sql(`select * from public.subscriptions`)).length, 1);
    assert.equal((await b.sql(`select * from public.subscriptions`)).length, 0);
  });
});

describe("Free limits", () => {
  test("Free: one baby per family; Pro: more", async () => {
    const { owner } = await h.family();
    await rejects(addBaby(owner), "42501");
    await subscribe(owner.id, new Date(Date.now() + DAY).toISOString());
    await addBaby(owner);
    await addBaby(owner);
  });

  test("Free: a deleted baby frees the place", async () => {
    const { owner, babyId } = await h.family();
    await owner.update("babies", babyId, { deleted_at: new Date().toISOString() });
    await addBaby(owner);
  });

  test("Pro ended: the babies stay, but no new ones", async () => {
    const { owner } = await h.family();
    await subscribe(owner.id, new Date(Date.now() + DAY).toISOString());
    await addBaby(owner);
    await subscribe(owner.id, new Date(Date.now() - DAY).toISOString());
    assert.equal((await owner.sql(`select id from public.babies where deleted_at is null`)).length, 2);
    await rejects(addBaby(owner), "42501");
  });

  test("Free: one photo per baby per month; deleting it frees the month", async () => {
    const { owner } = await h.family();
    const first = await addPhoto(owner, 2);
    await rejects(addPhoto(owner, 2), "42501");
    await addPhoto(owner, 3);
    await owner.update("photos", first, { deleted_at: new Date().toISOString() });
    await addPhoto(owner, 2);
  });

  test("Pro: up to 10 photos per month", async () => {
    const { owner } = await h.family();
    await subscribe(owner.id, new Date(Date.now() + DAY).toISOString());
    for (let i = 0; i < 10; i++) await addPhoto(owner, 4);
    await rejects(addPhoto(owner, 4), "42501");
  });

  test("Free: moving a photo into a month that has one is refused", async () => {
    const { owner } = await h.family();
    await addPhoto(owner, 5);
    const other = await addPhoto(owner, 6);
    await rejects(owner.update("photos", other, { age_month: 5 }), "42501");
    await owner.update("photos", other, { caption: "Smiling" });
  });
});
