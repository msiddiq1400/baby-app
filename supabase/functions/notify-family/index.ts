// Sends "Sana logged a feed" style notifications to the OTHER members of a
// baby's family when someone logs a feed, a sleep or a medicine dose
// (todos.txt item 36).
//
// Called only by the notify_family trigger on feeds, sleeps and
// medication_doses (supabase/migrations/*_push_notifications.sql) through
// pg_net, with the shared secret in the x-palna-hook header. The trigger has
// already decided the write is news ("event"); this function picks the
// phones, applies each phone's settings (kinds switched off, quiet hours)
// and writes the message in that phone's language.
// Deployed with --no-verify-jwt because the caller is the database.
//
// Secrets (supabase secrets set, never in git):
//   HOOK_SECRET           same value as Vault 'palna_hook_secret'
//   FCM_SERVICE_ACCOUNT   Firebase service account JSON for Palna's project
// Provided by Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const account = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT") ?? "{}");

// ---- Google OAuth access token for FCM, from the service account (cached ~1 h).
let cached: { token: string; expires: number } | null = null;

const b64url = (data: ArrayBuffer | string) =>
  btoa(typeof data === "string" ? data : String.fromCharCode(...new Uint8Array(data)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

async function accessToken(): Promise<string> {
  if (cached && cached.expires > Date.now() + 60_000) return cached.token;
  const pem = account.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${b64url(JSON.stringify({
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: account.token_uri,
    iat: now,
    exp: now + 3600,
  }))}`;
  const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned));
  const res = await fetch(account.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(signature)}`,
    }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Google token error: ${JSON.stringify(body)}`);
  cached = { token: body.access_token, expires: Date.now() + body.expires_in * 1000 };
  return cached.token;
}

// ---- Messages
// Pure functions (no Deno, no network): which phones want this event, and
// the text in each phone's language. Tested from supabase/tests in Node.
// Words follow the app's own (app/lib/l10n/app_*.arb).

type Event =
  | "feed_logged"
  | "feed_timer_started"
  | "feed_timer_finished"
  | "sleep_started"
  | "sleep_ended"
  | "dose_given";
type Locale = "en" | "ur" | "ur-Latn";
// deno-lint-ignore no-explicit-any
type Row = Record<string, any>;
type Device = {
  token: string;
  locale: string;
  time_zone: string;
  notify_feeds: boolean;
  notify_sleep: boolean;
  notify_medicines: boolean;
  quiet_from: number | null;
  quiet_to: number | null;
};
type Names = { baby: string; actor: string | null; medicine?: string | null };

const EVENTS: Event[] = [
  "feed_logged", "feed_timer_started", "feed_timer_finished", "sleep_started", "sleep_ended", "dose_given",
];

/** Which per-phone switch an event belongs to. */
function categoryOf(event: Event): "feeds" | "sleep" | "medicines" {
  if (event.startsWith("feed_")) return "feeds";
  if (event.startsWith("sleep_")) return "sleep";
  return "medicines";
}

/** Minutes after midnight at [now] in [timeZone] (UTC if the zone is unknown). */
function localMinutes(now: Date, timeZone: string): number {
  let parts: Intl.DateTimeFormatPart[];
  try {
    parts = new Intl.DateTimeFormat("en-GB", { timeZone, hour: "2-digit", minute: "2-digit", hourCycle: "h23" })
      .formatToParts(now);
  } catch {
    return now.getUTCHours() * 60 + now.getUTCMinutes();
  }
  const get = (type: string) => Number(parts.find((p) => p.type === type)?.value ?? 0);
  return (get("hour") % 24) * 60 + get("minute");
}

/** Quiet hours from..to (minutes); from > to crosses midnight; from == to = never quiet. */
function inQuietHours(device: Device, now: Date): boolean {
  const from = device.quiet_from;
  const to = device.quiet_to;
  if (from == null || to == null || from === to) return false;
  const m = localMinutes(now, device.time_zone);
  return from < to ? m >= from && m < to : m >= from || m < to;
}

/** Whether this phone shows [event] now: its switch is on and it isn't quiet time. */
function wants(device: Device, event: Event, now: Date): boolean {
  const on = { feeds: device.notify_feeds, sleep: device.notify_sleep, medicines: device.notify_medicines }[
    categoryOf(event)
  ];
  return on !== false && !inQuietHours(device, now);
}

const asLocale = (l: string): Locale => (l === "ur" || l === "ur-Latn" ? l : "en");

const WORDS = {
  en: {
    someone: "A family member",
    left: "Left",
    right: "Right",
    nap: "Nap",
    night: "Night sleep",
    breastMilk: "expressed milk",
    formula: "formula",
    hm: (h: number, m: number) => `${h}h ${m}m`,
    m: (m: number) => `${m}m`,
    feedBreast: (a: string, d: string) => `${a} logged a breastfeed${d}`,
    feedBottle: (a: string, what: string) => `${a} logged a bottle: ${what}`,
    feedSolids: (a: string) => `${a} logged solids`,
    timerStarted: (a: string, side: string) => `${a} started breastfeeding (${side})`,
    timerFinished: (a: string, detail: string) => `Breastfeeding finished${detail} · ${a}`,
    sleepStarted: (a: string, kind: string) => `Fell asleep (${kind}) · ${a}`,
    sleepEnded: (a: string, after: string) => `Woke up after ${after} · ${a}`,
    doseGiven: (a: string, medicine: string) => `${a} gave ${medicine}`,
    medicine: "a medicine",
    sep: ", ",
  },
  ur: {
    someone: "فیملی ممبر",
    left: "بائیں",
    right: "دائیں",
    nap: "قیلولہ",
    night: "رات کی نیند",
    breastMilk: "نکالا ہوا دودھ",
    formula: "فارمولا دودھ",
    hm: (h: number, m: number) => `${h} گھنٹے ${m} منٹ`,
    m: (m: number) => `${m} منٹ`,
    feedBreast: (a: string, d: string) => `${a} نے ماں کا دودھ پلایا${d}`,
    feedBottle: (a: string, what: string) => `${a} نے بوتل درج کی: ${what}`,
    feedSolids: (a: string) => `${a} نے ٹھوس غذا درج کی`,
    timerStarted: (a: string, side: string) => `${a} نے دودھ پلانا شروع کیا (${side})`,
    timerFinished: (a: string, detail: string) => `دودھ پلانا ختم${detail} · ${a}`,
    sleepStarted: (a: string, kind: string) => `سو گیا (${kind}) · ${a}`,
    sleepEnded: (a: string, after: string) => `${after} بعد جاگ گیا · ${a}`,
    doseGiven: (a: string, medicine: string) => `${a} نے ${medicine} دے دی`,
    medicine: "دوا",
    sep: "، ",
  },
  "ur-Latn": {
    someone: "Family member",
    left: "Baayan",
    right: "Daayan",
    nap: "Nap",
    night: "Raat ki neend",
    breastMilk: "nikala hua doodh",
    formula: "formula",
    hm: (h: number, m: number) => `${h} ghante ${m} minute`,
    m: (m: number) => `${m} minute`,
    feedBreast: (a: string, d: string) => `${a} ne maa ka doodh pilaya${d}`,
    feedBottle: (a: string, what: string) => `${a} ne bottle darj ki: ${what}`,
    feedSolids: (a: string) => `${a} ne thos ghiza darj ki`,
    timerStarted: (a: string, side: string) => `${a} ne doodh pilana shuru kiya (${side})`,
    timerFinished: (a: string, detail: string) => `Doodh pilana khatam${detail} · ${a}`,
    sleepStarted: (a: string, kind: string) => `So gaya (${kind}) · ${a}`,
    sleepEnded: (a: string, after: string) => `${after} baad jaag gaya · ${a}`,
    doseGiven: (a: string, medicine: string) => `${a} ne ${medicine} de di`,
    medicine: "dawa",
    sep: ", ",
  },
};

/** "1h 40m" / "40m" in the phone's language (at least 1 minute). */
function duration(ms: number, locale: Locale): string {
  const w = WORDS[locale];
  const total = Math.max(1, Math.round(ms / 60_000));
  const h = Math.floor(total / 60);
  return h > 0 ? w.hm(h, total % 60) : w.m(total);
}

/** " (Left 8m, Right 5m)" from the seconds per side; "" when none were timed. */
function sides(record: Row, locale: Locale): string {
  const w = WORDS[locale];
  const parts: string[] = [];
  const left = Number(record.left_seconds ?? 0);
  const right = Number(record.right_seconds ?? 0);
  if (left > 0) parts.push(`${w.left} ${duration(left * 1000, locale)}`);
  if (right > 0) parts.push(`${w.right} ${duration(right * 1000, locale)}`);
  return parts.length ? ` (${parts.join(w.sep)})` : "";
}

/** Total feed time: the per-side seconds, else ended - started; null if unknown. */
function feedMs(record: Row): number | null {
  const timed = Number(record.left_seconds ?? 0) + Number(record.right_seconds ?? 0);
  if (timed > 0) return timed * 1000;
  if (record.started_at && record.ended_at) {
    const ms = Date.parse(record.ended_at) - Date.parse(record.started_at);
    return ms > 0 ? ms : null;
  }
  return null;
}

/** The notification for one phone: title = the baby's name, body = what happened. */
function message(event: Event, record: Row, names: Names, localeName: string): { title: string; body: string } {
  const locale = asLocale(localeName);
  const w = WORDS[locale];
  const actor = names.actor?.trim() || w.someone;
  const side = (s: string | null | undefined) => (s === "right" ? w.right : w.left);
  let body: string;
  switch (event) {
    case "feed_logged":
      if (record.type === "breast") {
        const d = sides(record, locale);
        const ms = feedMs(record);
        body = w.feedBreast(actor, d || (ms ? ` (${duration(ms, locale)})` : ""));
      } else if (record.type === "solids") {
        body = w.feedSolids(actor);
      } else {
        const kind = record.type === "bottle_formula" ? w.formula : w.breastMilk;
        body = w.feedBottle(actor, record.amount_ml != null ? `${record.amount_ml} ml ${kind}` : kind);
      }
      break;
    case "feed_timer_started":
      body = w.timerStarted(actor, side(record.timer_side));
      break;
    case "feed_timer_finished": {
      const ms = feedMs(record);
      // ": 13m (Left 8m, Right 5m)", or nothing if no time was recorded.
      body = w.timerFinished(actor, ms ? `: ${duration(ms, locale)}${sides(record, locale)}` : "");
      break;
    }
    case "sleep_started":
      body = w.sleepStarted(actor, record.kind === "night" ? w.night : w.nap);
      break;
    case "sleep_ended":
      body = w.sleepEnded(actor, duration(Date.parse(record.ended_at) - Date.parse(record.started_at), locale));
      break;
    case "dose_given":
      body = w.doseGiven(actor, names.medicine?.trim() || w.medicine);
      break;
  }
  return { title: names.baby, body };
}

/** The FCM message for one phone. */
function fcmMessage(token: string, event: Event, record: Row, text: { title: string; body: string }) {
  return {
    token,
    notification: { title: text.title, body: text.body },
    data: { type: event, baby_id: String(record.baby_id), record_id: String(record.id) },
    android: {
      priority: "HIGH",
      ttl: "3600s",
      // One notification per entry: a timer's "started" is replaced by its "finished".
      notification: { channel_id: "family_updates", tag: String(record.id) },
    },
    apns: {
      headers: { "apns-priority": "10", "apns-collapse-id": String(record.id).slice(0, 64) },
      payload: { aps: { sound: "default", "thread-id": String(record.baby_id) } },
    },
  };
}

// ---- One push per phone
async function send(fcm: unknown): Promise<string> {
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`, {
    method: "POST",
    headers: { Authorization: `Bearer ${await accessToken()}`, "Content-Type": "application/json" },
    body: JSON.stringify({ message: fcm }),
  });
  if (res.ok) return "ok";
  const text = await res.text();
  // The app was uninstalled or the token rotated: forget it. Other errors
  // (bad message, quota, Apple/Google outage) keep the token.
  if (res.status === 404 || text.includes("UNREGISTERED")) return "gone";
  console.error("FCM error", res.status, text);
  return `error ${res.status} ${text.match(/"status":\s*"([A-Z_]+)"/)?.[1] ?? ""}`.trim();
}

/** The actor's name: their profile name, else the part of their email before '@'. */
async function actorName(actor: string | null): Promise<string | null> {
  if (!actor) return null;
  const { data: profile } = await db.from("profiles").select("display_name").eq("id", actor).maybeSingle();
  if (profile?.display_name?.trim()) return profile.display_name.trim();
  const { data } = await db.auth.admin.getUserById(actor);
  return data?.user?.email?.split("@")[0] ?? null;
}

Deno.serve(async (req) => {
  const secret = Deno.env.get("HOOK_SECRET");
  if (!secret || req.headers.get("x-palna-hook") !== secret) {
    return new Response("Forbidden", { status: 403 });
  }
  const { event, record, actor } = await req.json().catch(() => ({}));
  if (!EVENTS.includes(event) || typeof record?.family_id !== "string") {
    return new Response("Bad request", { status: 400 });
  }

  // Everyone in the family except the person who logged it.
  const { data: members } = await db.from("family_members").select("user_id").eq("family_id", record.family_id);
  const recipients = (members ?? []).map((m) => m.user_id).filter((id) => id !== actor);
  if (!recipients.length) return Response.json({ sent: 0 });
  const { data: devices } = await db.from("push_devices").select("*").in("user_id", recipients);
  const now = new Date();
  const targets = ((devices ?? []) as Device[]).filter((d) => wants(d, event, now));
  if (!targets.length) return Response.json({ sent: 0 });

  const [{ data: baby }, name, medicine] = await Promise.all([
    db.from("babies").select("name").eq("id", record.baby_id).maybeSingle(),
    actorName(actor ?? null),
    event === "dose_given"
      ? db.from("medications").select("name").eq("id", record.medication_id).maybeSingle().then((r) => r.data?.name ?? null)
      : Promise.resolve(null),
  ]);
  const names: Names = { baby: baby?.name ?? "Palna", actor: name, medicine };

  const results = await Promise.all(
    targets.map((d) => send(fcmMessage(d.token, event, record, message(event, record, names, d.locale)))),
  );
  const gone = targets.filter((_, i) => results[i] === "gone").map((d) => d.token);
  if (gone.length) await db.from("push_devices").delete().in("token", gone);
  const errors = results.filter((r) => r.startsWith("error"));
  return Response.json({ sent: results.filter((r) => r === "ok").length, removed: gone.length, errors });
});
