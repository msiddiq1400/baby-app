// Keeps public.subscriptions in step with RevenueCat, which handles Apple
// and Google billing for Palna Pro (todos.txt 38b). The family's Pro status
// (families.pro_until) follows from it in the database.
//
// Two callers:
//   * RevenueCat's webhook, on every purchase, renewal, cancellation,
//     expiry, refund or transfer: header "Authorization: Bearer
//     <REVENUECAT_WEBHOOK_AUTH>" (set the same value in RevenueCat >
//     Integrations > Webhooks > Authorization header).
//   * The app, right after a purchase or "Restore purchases", with the
//     person's Supabase login, so the family's other phones see Pro within
//     seconds instead of waiting for the webhook.
// Either way this asks RevenueCat's REST API for the current state and saves
// that, so it doesn't matter in which order events arrive.
// Deployed with --no-verify-jwt (the webhook has no Supabase login); the
// app's login is checked here.
//
// Secrets (supabase secrets set, never in git):
//   REVENUECAT_SECRET_KEY    RevenueCat > Project > API keys > secret key (v1)
//   REVENUECAT_WEBHOOK_AUTH  a long random string, also set in the webhook
// Provided by Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const secretKey = Deno.env.get("REVENUECAT_SECRET_KEY") ?? "";
const webhookAuth = Deno.env.get("REVENUECAT_WEBHOOK_AUTH") ?? "";

// ---- Rules (pure; tested in supabase/tests/revenuecat.test.mjs)

/** The entitlement that means Pro, as set up in RevenueCat. */
export const ENTITLEMENT = "pro";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * The Palna people a webhook event is about. The app logs in to RevenueCat
 * with the Supabase user id, so anonymous ids ($RCAnonymousID:...) are
 * skipped. Transfers (a store account restored on another login) name both.
 */
export function eventUserIds(event: Record<string, unknown> | undefined): string[] {
  if (!event) return [];
  const ids = [
    event.app_user_id,
    event.original_app_user_id,
    ...((event.aliases as unknown[]) ?? []),
    ...((event.transferred_from as unknown[]) ?? []),
    ...((event.transferred_to as unknown[]) ?? []),
  ];
  return [...new Set(ids.filter((id): id is string => typeof id === "string" && UUID.test(id)))];
}

type Entitlement = { expires_date: string | null; product_identifier?: string; grace_period_expires_date?: string | null };
type Subscription = { store?: string; grace_period_expires_date?: string | null };
type Subscriber = {
  entitlements?: Record<string, Entitlement>;
  subscriptions?: Record<string, Subscription>;
  non_subscriptions?: Record<string, unknown[]>;
};

/**
 * Until when this person has Pro, from RevenueCat's subscriber record:
 * "infinity" for a lifetime purchase, an ISO date (maybe in the past) for a
 * subscription, including any billing grace period; null if never.
 */
export function subscriptionFrom(subscriber: Subscriber): {
  pro_until: string | null;
  product_id: string | null;
  store: string | null;
} {
  const e = subscriber.entitlements?.[ENTITLEMENT];
  if (!e) return { pro_until: null, product_id: null, store: null };
  const product = e.product_identifier ?? null;
  const sub = product ? subscriber.subscriptions?.[product] : undefined;
  const store = sub?.store ?? null;
  if (e.expires_date === null) return { pro_until: "infinity", product_id: product, store };
  const dates = [e.expires_date, e.grace_period_expires_date, sub?.grace_period_expires_date]
    .filter((d): d is string => typeof d === "string")
    .map((d) => new Date(d).getTime())
    .filter((t) => !Number.isNaN(t));
  const until = dates.length ? new Date(Math.max(...dates)).toISOString() : null;
  return { pro_until: until, product_id: product, store };
}

// ---- Service

async function refresh(userId: string) {
  const res = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`, {
    headers: { Authorization: `Bearer ${secretKey}`, Accept: "application/json" },
  });
  if (!res.ok) throw new Error(`RevenueCat ${res.status}: ${await res.text()}`);
  const { subscriber } = await res.json();
  const row = subscriptionFrom(subscriber ?? {});
  // People who never bought anything don't need a row.
  if (row.pro_until === null) {
    await db.from("subscriptions").delete().eq("user_id", userId);
  } else {
    const { error } = await db
      .from("subscriptions")
      .upsert({ user_id: userId, ...row, updated_at: new Date().toISOString() });
    if (error) throw error;
  }
  return row;
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

if (import.meta.main) {
  Deno.serve(async (req) => {
    if (req.method !== "POST") return json({ error: "method" }, 405);
    if (!secretKey) return json({ error: "not configured" }, 503);
    const auth = req.headers.get("authorization") ?? "";

    let ids: string[];
    if (webhookAuth && auth === `Bearer ${webhookAuth}`) {
      const body = await req.json().catch(() => ({}));
      ids = eventUserIds(body.event);
    } else if (auth.startsWith("Bearer ")) {
      const { data, error } = await db.auth.getUser(auth.slice("Bearer ".length));
      if (error || !data.user) return json({ error: "unauthorized" }, 401);
      ids = [data.user.id];
    } else {
      return json({ error: "unauthorized" }, 401);
    }

    try {
      const results: Record<string, unknown> = {};
      for (const id of ids) results[id] = await refresh(id);
      return json({ ok: true, results });
    } catch (e) {
      console.error(e);
      // RevenueCat retries webhooks that fail.
      return json({ error: "refresh failed" }, 502);
    }
  });
}
