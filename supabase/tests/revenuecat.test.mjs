// The revenuecat Edge Function's "---- Rules" section (pure TypeScript), cut
// out of supabase/functions/revenuecat/index.ts and evaluated here like the
// notify-family messages in push.test.mjs. No Deno or RevenueCat needed.
import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { stripTypeScriptTypes } from "node:module";

const src = readFileSync(fileURLToPath(new URL("../functions/revenuecat/index.ts", import.meta.url)), "utf8");
const from = src.indexOf("// ---- Rules");
const to = src.indexOf("// ---- Service");
assert.ok(from > 0 && to > from, "revenuecat/index.ts still has its '---- Rules' section");
const rc = new Function(
  `${stripTypeScriptTypes(src.slice(from, to)).replace(/^export /gm, "")}; return { eventUserIds, subscriptionFrom, ENTITLEMENT };`,
)();

const A = "6f1c2a4e-1b2c-4d5e-8f90-123456789abc";
const B = "0d9e8f7a-6b5c-4d3e-9f21-abcdef012345";

describe("eventUserIds", () => {
  test("the buyer, without RevenueCat's anonymous ids", () => {
    assert.deepEqual(
      rc.eventUserIds({ app_user_id: A, original_app_user_id: "$RCAnonymousID:abc", aliases: [A, "$RCAnonymousID:abc"] }),
      [A],
    );
  });

  test("a transfer names both people", () => {
    assert.deepEqual(rc.eventUserIds({ type: "TRANSFER", transferred_from: [A], transferred_to: [B] }).sort(), [A, B].sort());
  });

  test("no event: nobody", () => {
    assert.deepEqual(rc.eventUserIds(undefined), []);
  });
});

describe("subscriptionFrom", () => {
  test("active yearly subscription", () => {
    const s = rc.subscriptionFrom({
      entitlements: { pro: { expires_date: "2027-10-27T10:00:00Z", product_identifier: "palna_pro_yearly" } },
      subscriptions: { palna_pro_yearly: { store: "app_store" } },
    });
    assert.deepEqual(s, { pro_until: "2027-10-27T10:00:00.000Z", product_id: "palna_pro_yearly", store: "app_store" });
  });

  test("billing problem: Pro lasts through the grace period", () => {
    const s = rc.subscriptionFrom({
      entitlements: { pro: { expires_date: "2026-10-20T00:00:00Z", product_identifier: "m" } },
      subscriptions: { m: { store: "play_store", grace_period_expires_date: "2026-11-03T00:00:00Z" } },
    });
    assert.equal(s.pro_until, "2026-11-03T00:00:00.000Z");
  });

  test("lifetime (no end date) and never bought", () => {
    assert.equal(rc.subscriptionFrom({ entitlements: { pro: { expires_date: null } } }).pro_until, "infinity");
    assert.equal(rc.subscriptionFrom({ entitlements: {} }).pro_until, null);
    assert.equal(rc.subscriptionFrom({}).pro_until, null);
  });

  test("expired: the date is kept (in the past), so the family is Free again", () => {
    const s = rc.subscriptionFrom({ entitlements: { pro: { expires_date: "2025-01-01T00:00:00Z" } } });
    assert.equal(s.pro_until, "2025-01-01T00:00:00.000Z");
  });
});
