// Push notifications between family phones (todos.txt item 36).
//
// 1. register_device / unregister_device and who can see push_devices.
// 2. The notify_family trigger: which writes call the notify-family Edge
//    Function (net.http_post is recorded in test.pushes) and which don't.
// 3. The Edge Function's "---- Messages" section (pure TypeScript): cut out
//    of supabase/functions/notify-family/index.ts, types stripped with
//    Node's built-in stripper, and evaluated here - no Deno needed.
import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { stripTypeScriptTypes } from "node:module";
import { setup, HOUR, MIN } from "./harness.mjs";

const h = await setup();

const TOKEN = "fcm-token-0123456789-abcdef";
const token = (n) => `${TOKEN}-${n}-${Math.random().toString(36).slice(2)}`;

/** Expects the promise to fail with this SQLSTATE. */
async function rejects(promise, code) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code, e.message);
    return true;
  });
}

const devices = (userId) =>
  h.admin(`select * from public.push_devices where user_id = $1 order by updated_at`, [userId]);

// ---------------------------------------------------------------- devices

describe("register_device", () => {
  test("saves the phone's token with its settings for the signed-in person", async () => {
    const u = await h.user();
    const t = token(1);
    await u.register(t, {
      p_platform: "ios", p_locale: "ur", p_time_zone: "Europe/London",
      p_notify_feeds: true, p_notify_sleep: false, p_notify_medicines: true,
      p_quiet_from: 1320, p_quiet_to: 420,
    });
    const [d] = await devices(u.id);
    assert.equal(d.token, t);
    assert.equal(d.platform, "ios");
    assert.equal(d.locale, "ur");
    assert.equal(d.time_zone, "Europe/London");
    assert.deepEqual([d.notify_feeds, d.notify_sleep, d.notify_medicines], [true, false, true]);
    assert.deepEqual([d.quiet_from, d.quiet_to], [1320, 420]);
  });

  test("calling it again updates the same phone (settings changed)", async () => {
    const u = await h.user();
    const t = token(2);
    await u.register(t);
    await u.register(t, { p_locale: "ur-Latn", p_notify_feeds: false, p_quiet_from: 0, p_quiet_to: 360 });
    const rows = await devices(u.id);
    assert.equal(rows.length, 1);
    assert.equal(rows[0].locale, "ur-Latn");
    assert.equal(rows[0].notify_feeds, false);
    assert.deepEqual([rows[0].quiet_from, rows[0].quiet_to], [0, 360]);
  });

  test("turning quiet hours off clears them", async () => {
    const u = await h.user();
    const t = token(3);
    await u.register(t, { p_quiet_from: 1320, p_quiet_to: 420 });
    await u.register(t, { p_quiet_from: null, p_quiet_to: null });
    const [d] = await devices(u.id);
    assert.deepEqual([d.quiet_from, d.quiet_to], [null, null]);
  });

  test("a phone belongs to whoever signed in on it last", async () => {
    const a = await h.user();
    const b = await h.user();
    const t = token(4);
    await a.register(t);
    await b.register(t);
    assert.equal((await devices(a.id)).length, 0);
    assert.equal((await devices(b.id)).length, 1);
  });

  test("needs a signed-in person", async () => {
    const nobody = new (h.anon.constructor)(h, "authenticated", null);
    await rejects(nobody.register(token(5)), "42501");
    await rejects(h.anon.register(token(5)), "42501"); // anon can't even call it
  });

  for (const [what, args] of [
    ["a short token", { p_token: "short" }],
    ["a huge token", { p_token: "x".repeat(4097) }],
    ["an unknown platform", { p_platform: "web" }],
    ["an unknown language", { p_locale: "fr" }],
    ["an empty time zone", { p_time_zone: "" }],
    ["a very long time zone", { p_time_zone: "x".repeat(65) }],
    ["only one end of quiet hours", { p_quiet_from: 1320, p_quiet_to: null }],
    ["quiet hours past midnight's minutes", { p_quiet_from: 1440, p_quiet_to: 60 }],
    ["negative quiet hours", { p_quiet_from: -1, p_quiet_to: 60 }],
  ]) {
    test(`refuses ${what}`, async () => {
      const u = await h.user();
      const { p_token = token(6), ...rest } = args;
      await rejects(u.register(p_token, rest), "22023");
      assert.equal((await devices(u.id)).length, 0);
    });
  }
});

describe("unregister_device and access", () => {
  test("signing out removes the phone", async () => {
    const u = await h.user();
    const t = token(7);
    await u.register(t);
    await u.rpc("unregister_device", { p_token: t });
    assert.equal((await devices(u.id)).length, 0);
  });

  test("nobody can remove another person's phone", async () => {
    const a = await h.user();
    const b = await h.user();
    const t = token(8);
    await a.register(t);
    await b.rpc("unregister_device", { p_token: t });
    assert.equal((await devices(a.id)).length, 1);
  });

  test("phones can't read or change push_devices directly", async () => {
    const u = await h.user();
    await u.register(token(9));
    await rejects(u.sql(`select * from public.push_devices`), "42501");
    await rejects(u.sql(`insert into public.push_devices (token, user_id, platform) values ($1, $2, 'android')`, [token(10), u.id]), "42501");
    await rejects(u.sql(`update public.push_devices set notify_feeds = false`), "42501");
    await rejects(u.sql(`delete from public.push_devices`), "42501");
    await rejects(h.anon.sql(`select * from public.push_devices`), "42501");
  });

  test("the Edge Function's role can read and delete phones", async () => {
    const u = await h.user();
    const t = token(11);
    await u.register(t);
    const service = new (h.anon.constructor)(h, "service_role", null);
    assert.equal((await service.sql(`select token from public.push_devices where token = $1`, [t])).length, 1);
    await service.sql(`delete from public.push_devices where token = $1`, [t]);
    assert.equal((await devices(u.id)).length, 0);
  });

  test("deleting the account removes its phones", async () => {
    const u = await h.user();
    await u.register(token(12));
    await h.admin(`delete from auth.users where id = $1`, [u.id]);
    assert.equal((await devices(u.id)).length, 0);
  });
});

// ---------------------------------------------------------------- trigger

/** What the trigger posted: [{event, actor, record}]. */
async function posted() {
  return (await h.pushes()).map((p) => p.body);
}

describe("notify_family trigger: feeds", () => {
  test("logging a feed posts feed_logged with the row and who did it", async () => {
    const { owner, familyId } = await h.family();
    const id = await owner.insert("feeds", { type: "bottle_formula", started_at: h.ago(5 * MIN), amount_ml: 120 });
    const pushes = await h.pushes();
    assert.equal(pushes.length, 1);
    assert.match(pushes[0].url, /\/functions\/v1\/notify-family$/);
    assert.equal(pushes[0].headers["x-palna-hook"], "test-secret");
    const { event, actor, record } = pushes[0].body;
    assert.equal(event, "feed_logged");
    assert.equal(actor, owner.id);
    assert.equal(record.id, id);
    assert.equal(record.family_id, familyId);
    assert.equal(record.amount_ml, 120);
  });

  test("starting a breastfeeding timer, then finishing it", async () => {
    const { owner } = await h.family();
    const id = await owner.insert("feeds", {
      type: "breast", started_at: h.ago(MIN), timer_side: "left", timer_started_at: h.ago(MIN),
    });
    await owner.update("feeds", id, {
      ended_at: h.ago(0), timer_side: null, timer_started_at: null, left_seconds: 480, right_seconds: 300, side: "both",
    });
    assert.deepEqual((await posted()).map((b) => b.event), ["feed_timer_started", "feed_timer_finished"]);
  });

  test("switching sides or pausing a running timer doesn't post", async () => {
    const { owner } = await h.family();
    const id = await owner.insert("feeds", {
      type: "breast", started_at: h.ago(5 * MIN), timer_side: "left", timer_started_at: h.ago(5 * MIN),
    });
    await owner.update("feeds", id, { timer_side: "right", timer_started_at: h.ago(0), left_seconds: 300 });
    await owner.update("feeds", id, { timer_started_at: null, right_seconds: 10 });
    assert.deepEqual((await posted()).map((b) => b.event), ["feed_timer_started"]);
  });

  test("editing a feed doesn't post", async () => {
    const { owner } = await h.family();
    const id = await owner.insert("feeds", { type: "bottle_formula", started_at: h.ago(MIN), amount_ml: 90 });
    await owner.update("feeds", id, { amount_ml: 100 });
    assert.equal((await posted()).length, 1);
  });

  test("a feed uploaded more than 3 hours late doesn't post", async () => {
    const { owner } = await h.family();
    await owner.insert("feeds", { type: "bottle_formula", started_at: h.ago(5 * HOUR), amount_ml: 90 });
    await owner.insert("feeds", { type: "breast", started_at: h.ago(4 * HOUR), timer_side: "left", timer_started_at: h.ago(4 * HOUR) });
    assert.deepEqual(await posted(), []);
  });

  test("a deleted feed, or deleting one, doesn't post", async () => {
    const { owner } = await h.family();
    await owner.insert("feeds", { type: "bottle_formula", started_at: h.ago(MIN), deleted_at: h.ago(0) });
    const id = await owner.insert("feeds", {
      type: "breast", started_at: h.ago(MIN), timer_side: "left", timer_started_at: h.ago(MIN),
    });
    // Discarding a running timer: deleted, and ended.
    await owner.update("feeds", id, { deleted_at: h.ago(0), ended_at: h.ago(0), timer_side: null, timer_started_at: null });
    assert.deepEqual((await posted()).map((b) => b.event), ["feed_timer_started"]);
  });
});

describe("notify_family trigger: sleep", () => {
  test("falling asleep, then waking up", async () => {
    const { owner } = await h.family();
    const id = await owner.insert("sleeps", { kind: "nap", started_at: h.ago(40 * MIN) });
    await owner.update("sleeps", id, { ended_at: h.ago(0) });
    assert.deepEqual((await posted()).map((b) => b.event), ["sleep_started", "sleep_ended"]);
  });

  test("the person who ends a sleep is the actor, not who started it", async () => {
    const { owner, members } = await h.family(1);
    const id = await owner.insert("sleeps", { kind: "night", started_at: h.ago(HOUR) });
    await members[0].update("sleeps", id, { ended_at: h.ago(0) });
    const [start, end] = await posted();
    assert.equal(start.actor, owner.id);
    assert.equal(end.actor, members[0].id);
  });

  test("a past sleep added already finished doesn't post", async () => {
    const { owner } = await h.family();
    await owner.insert("sleeps", { kind: "nap", started_at: h.ago(2 * HOUR), ended_at: h.ago(HOUR) });
    assert.deepEqual(await posted(), []);
  });

  test("a wake-up uploaded hours late doesn't post; editing a finished sleep doesn't either", async () => {
    const { owner } = await h.family();
    const late = await owner.insert("sleeps", { kind: "night", started_at: h.ago(2 * HOUR) });
    await owner.update("sleeps", late, { ended_at: h.ago(0) });
    await owner.update("sleeps", late, { kind: "nap" });
    const old = await h.admin(
      `insert into public.sleeps (family_id, baby_id, kind, started_at, created_by) values ($1, $2, 'night', now() - interval '10 hours', $3) returning id`,
      [owner.familyId, owner.babyId, owner.id]);
    await owner.update("sleeps", old[0].id, { ended_at: h.ago(5 * HOUR) });
    assert.deepEqual((await posted()).map((b) => b.event), ["sleep_started", "sleep_ended"]);
  });
});

describe("notify_family trigger: medicine doses", () => {
  async function medicine(owner) {
    return owner.insert("medications", { name: "Paracetamol", prescribed_dose: "2.5 ml", start_date: "2026-10-01", as_needed: true });
  }

  test("a dose given posts dose_given", async () => {
    const { owner } = await h.family();
    const med = await medicine(owner);
    await owner.insert("medication_doses", { medication_id: med, given_at: h.ago(MIN), skipped: false });
    const [b] = await posted();
    assert.equal(b.event, "dose_given");
    assert.equal(b.record.medication_id, med);
  });

  test("a skipped dose, a late upload or undoing a dose doesn't post", async () => {
    const { owner } = await h.family();
    const med = await medicine(owner);
    await owner.insert("medication_doses", { medication_id: med, given_at: h.ago(MIN), skipped: true });
    await owner.insert("medication_doses", { medication_id: med, given_at: h.ago(6 * HOUR), skipped: false });
    const id = await owner.insert("medication_doses", { medication_id: med, given_at: h.ago(MIN), skipped: false });
    await owner.update("medication_doses", id, { deleted_at: h.ago(0) });
    assert.deepEqual((await posted()).map((b) => b.event), ["dose_given"]);
  });

  test("adding the medicine itself doesn't post", async () => {
    const { owner } = await h.family();
    await medicine(owner);
    assert.deepEqual(await posted(), []);
  });
});

describe("notify_family trigger: never in the way", () => {
  test("other tables (diapers, pumping) don't post", async () => {
    const { owner } = await h.family();
    await owner.insert("diapers", { occurred_at: h.ago(MIN), is_wet: true });
    await owner.insert("pumping_sessions", { started_at: h.ago(MIN), amount_ml: 80 });
    assert.deepEqual(await posted(), []);
  });

  test("without the hook secret in Vault nothing is posted (push not set up)", async () => {
    await h.admin(`delete from vault.decrypted_secrets`);
    const { owner } = await h.family();
    await owner.insert("feeds", { type: "bottle_formula", started_at: h.ago(MIN), amount_ml: 90 });
    assert.deepEqual(await posted(), []);
    assert.equal((await h.admin(`select count(*)::int as n from public.feeds where family_id = $1`, [owner.familyId]))[0].n, 1);
  });

  test("if pg_net fails, the feed is still saved", async () => {
    const { owner } = await h.family();
    await h.admin(`select set_config('test.net_fails', 'on', false)`);
    await owner.insert("feeds", { type: "bottle_formula", started_at: h.ago(MIN), amount_ml: 90 });
    await h.admin(`select set_config('test.net_fails', 'off', false)`);
    assert.deepEqual(await posted(), []);
    assert.equal((await h.admin(`select count(*)::int as n from public.feeds where family_id = $1`, [owner.familyId]))[0].n, 1);
  });
});

// ---------------------------------------------------------------- messages

const src = readFileSync(fileURLToPath(new URL("../functions/notify-family/index.ts", import.meta.url)), "utf8");
const from = src.indexOf("// ---- Messages");
const to = src.indexOf("// ---- One push per phone");
assert.ok(from > 0 && to > from, "notify-family/index.ts still has its '---- Messages' section");
const edge = new Function(
  `${stripTypeScriptTypes(src.slice(from, to))}; return { categoryOf, localMinutes, inQuietHours, wants, message, fcmMessage, duration, EVENTS };`,
)();

const device = (o = {}) => ({
  token: "t", locale: "en", time_zone: "Asia/Karachi",
  notify_feeds: true, notify_sleep: true, notify_medicines: true, quiet_from: null, quiet_to: null, ...o,
});
// 17:30 UTC = 22:30 in Karachi (UTC+5), 13:30 in New York (EDT, UTC-4).
const evening = new Date("2026-10-27T17:30:00Z");
const morning = new Date("2026-10-27T02:30:00Z"); // 07:30 in Karachi

describe("notify-family: who gets it", () => {
  test("each event belongs to one switch", () => {
    assert.deepEqual(edge.EVENTS.map(edge.categoryOf), ["feeds", "feeds", "feeds", "sleep", "sleep", "medicines"]);
  });

  test("local time follows the phone's time zone; an unknown zone falls back to UTC", () => {
    assert.equal(edge.localMinutes(evening, "Asia/Karachi"), 22 * 60 + 30);
    assert.equal(edge.localMinutes(evening, "UTC"), 17 * 60 + 30);
    assert.equal(edge.localMinutes(evening, "America/New_York"), 13 * 60 + 30);
    assert.equal(edge.localMinutes(evening, "Not/AZone"), 17 * 60 + 30);
  });

  test("quiet hours across midnight (22:00 to 07:00)", () => {
    const d = device({ quiet_from: 22 * 60, quiet_to: 7 * 60 });
    assert.equal(edge.inQuietHours(d, evening), true); // 22:30
    assert.equal(edge.inQuietHours(d, morning), false); // 07:30
    assert.equal(edge.inQuietHours(d, new Date("2026-10-27T01:59:00Z")), true); // 06:59
  });

  test("quiet hours within one day, in another time zone", () => {
    const d = device({ time_zone: "America/New_York", quiet_from: 13 * 60, quiet_to: 15 * 60 });
    assert.equal(edge.inQuietHours(d, evening), true); // 13:30 there
    assert.equal(edge.inQuietHours({ ...d, time_zone: "Asia/Karachi" }, evening), false); // 22:30
  });

  test("no quiet hours, or from == to, is never quiet", () => {
    assert.equal(edge.inQuietHours(device(), evening), false);
    assert.equal(edge.inQuietHours(device({ quiet_from: 600, quiet_to: 600 }), evening), false);
  });

  test("a switched-off kind isn't sent; the others are", () => {
    const d = device({ notify_sleep: false });
    assert.equal(edge.wants(d, "sleep_started", morning), false);
    assert.equal(edge.wants(d, "feed_logged", morning), true);
    assert.equal(edge.wants(d, "dose_given", morning), true);
    assert.equal(edge.wants(device({ notify_medicines: false }), "dose_given", morning), false);
    assert.equal(edge.wants(device({ notify_feeds: false }), "feed_timer_finished", morning), false);
  });

  test("quiet hours silence every kind", () => {
    const d = device({ quiet_from: 22 * 60, quiet_to: 7 * 60 });
    for (const e of edge.EVENTS) assert.equal(edge.wants(d, e, evening), false, e);
  });
});

const names = { baby: "Aisha", actor: "Sana", medicine: "Paracetamol" };
const feed = (o) => ({ id: "f1", baby_id: "b1", family_id: "fam", ...o });

describe("notify-family: messages", () => {
  const cases = [
    ["feed_logged", feed({ type: "bottle_breast_milk", amount_ml: 120 }), {
      en: "Sana logged a bottle: 120 ml expressed milk",
      ur: "Sana نے بوتل درج کی: 120 ml نکالا ہوا دودھ",
      "ur-Latn": "Sana ne bottle darj ki: 120 ml nikala hua doodh",
    }],
    ["feed_logged", feed({ type: "bottle_formula", amount_ml: null }), {
      en: "Sana logged a bottle: formula",
      ur: "Sana نے بوتل درج کی: فارمولا دودھ",
      "ur-Latn": "Sana ne bottle darj ki: formula",
    }],
    ["feed_logged", feed({ type: "breast", left_seconds: 480, right_seconds: 300 }), {
      en: "Sana logged a breastfeed (Left 8m, Right 5m)",
      ur: "Sana نے ماں کا دودھ پلایا (بائیں 8 منٹ، دائیں 5 منٹ)",
      "ur-Latn": "Sana ne maa ka doodh pilaya (Baayan 8 minute, Daayan 5 minute)",
    }],
    ["feed_logged", feed({ type: "breast", started_at: "2026-10-27T10:00:00+00:00", ended_at: "2026-10-27T10:15:00+00:00" }), {
      en: "Sana logged a breastfeed (15m)",
      ur: "Sana نے ماں کا دودھ پلایا (15 منٹ)",
      "ur-Latn": "Sana ne maa ka doodh pilaya (15 minute)",
    }],
    ["feed_logged", feed({ type: "solids" }), {
      en: "Sana logged solids",
      ur: "Sana نے ٹھوس غذا درج کی",
      "ur-Latn": "Sana ne thos ghiza darj ki",
    }],
    ["feed_timer_started", feed({ type: "breast", timer_side: "left" }), {
      en: "Sana started breastfeeding (Left)",
      ur: "Sana نے دودھ پلانا شروع کیا (بائیں)",
      "ur-Latn": "Sana ne doodh pilana shuru kiya (Baayan)",
    }],
    ["feed_timer_finished", feed({ type: "breast", left_seconds: 480, right_seconds: 300 }), {
      en: "Breastfeeding finished: 13m (Left 8m, Right 5m) · Sana",
      ur: "دودھ پلانا ختم: 13 منٹ (بائیں 8 منٹ، دائیں 5 منٹ) · Sana",
      "ur-Latn": "Doodh pilana khatam: 13 minute (Baayan 8 minute, Daayan 5 minute) · Sana",
    }],
    ["sleep_started", { id: "s1", baby_id: "b1", kind: "nap" }, {
      en: "Fell asleep (Nap) · Sana",
      ur: "سو گیا (قیلولہ) · Sana",
      "ur-Latn": "So gaya (Nap) · Sana",
    }],
    ["sleep_ended", { id: "s1", baby_id: "b1", kind: "night", started_at: "2026-10-27T00:00:00+00:00", ended_at: "2026-10-27T01:40:00+00:00" }, {
      en: "Woke up after 1h 40m · Sana",
      ur: "1 گھنٹے 40 منٹ بعد جاگ گیا · Sana",
      "ur-Latn": "1 ghante 40 minute baad jaag gaya · Sana",
    }],
    ["dose_given", { id: "d1", baby_id: "b1", medication_id: "m1" }, {
      en: "Sana gave Paracetamol",
      ur: "Sana نے Paracetamol دے دی",
      "ur-Latn": "Sana ne Paracetamol de di",
    }],
  ];
  for (const [event, record, texts] of cases) {
    for (const [locale, body] of Object.entries(texts)) {
      test(`${event} (${record.type ?? record.kind ?? "dose"}) in ${locale}`, () => {
        assert.deepEqual(edge.message(event, record, names, locale), { title: "Aisha", body });
      });
    }
  }

  test("a night sleep says night sleep", () => {
    assert.equal(edge.message("sleep_started", { kind: "night" }, names, "en").body, "Fell asleep (Night sleep) · Sana");
    assert.equal(edge.message("sleep_started", { kind: "night" }, names, "ur").body, "سو گیا (رات کی نیند) · Sana");
  });

  test("a finished timer with only one side, or no time, still reads well", () => {
    assert.equal(
      edge.message("feed_timer_finished", feed({ left_seconds: 0, right_seconds: 600 }), names, "en").body,
      "Breastfeeding finished: 10m (Right 10m) · Sana",
    );
    assert.equal(edge.message("feed_timer_finished", feed({}), names, "en").body, "Breastfeeding finished · Sana");
  });

  test("without a name: 'A family member'; without a medicine name: 'a medicine'", () => {
    const anon = { baby: "Aisha", actor: null, medicine: null };
    assert.equal(edge.message("dose_given", {}, anon, "en").body, "A family member gave a medicine");
    assert.equal(edge.message("dose_given", {}, anon, "ur").body, "فیملی ممبر نے دوا دے دی");
    assert.equal(edge.message("dose_given", {}, anon, "ur-Latn").body, "Family member ne dawa de di");
    assert.equal(edge.message("feed_logged", { type: "solids" }, { ...anon, actor: "  " }, "en").body, "A family member logged solids");
  });

  test("an unknown language falls back to English", () => {
    assert.equal(edge.message("feed_logged", feed({ type: "solids" }), names, "fr").body, "Sana logged solids");
  });

  test("durations: at least a minute, hours and minutes after an hour", () => {
    assert.equal(edge.duration(10_000, "en"), "1m");
    assert.equal(edge.duration(59 * MIN, "en"), "59m");
    assert.equal(edge.duration(60 * MIN, "en"), "1h 0m");
    assert.equal(edge.duration(125 * MIN, "ur"), "2 گھنٹے 5 منٹ");
  });
});

describe("notify-family: the FCM message", () => {
  test("a visible notification on Palna's channel, one per entry, grouped by baby", () => {
    const m = edge.fcmMessage("tok", "feed_timer_started", feed({}), { title: "Aisha", body: "x" });
    assert.equal(m.token, "tok");
    assert.deepEqual(m.notification, { title: "Aisha", body: "x" });
    assert.equal(m.android.notification.channel_id, "family_updates");
    assert.equal(m.android.notification.tag, "f1");
    assert.equal(m.apns.payload.aps.sound, "default");
    assert.equal(m.apns.payload.aps["thread-id"], "b1");
    assert.deepEqual(m.data, { type: "feed_timer_started", baby_id: "b1", record_id: "f1" });
    for (const v of Object.values(m.data)) assert.equal(typeof v, "string", "FCM data values are strings");
  });

  test("a timer's start and finish share a tag, so the finish replaces the start", () => {
    const start = edge.fcmMessage("t", "feed_timer_started", feed({}), { title: "", body: "" });
    const end = edge.fcmMessage("t", "feed_timer_finished", feed({}), { title: "", body: "" });
    assert.equal(start.android.notification.tag, end.android.notification.tag);
    assert.equal(start.apns.headers["apns-collapse-id"], end.apns.headers["apns-collapse-id"]);
  });
});
