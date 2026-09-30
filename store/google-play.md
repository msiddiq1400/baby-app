# Google Play listing: Palna

Copy each part into Play Console > Palna. Character limits are Google's.
Package name: `com.palnacare.app` (permanent).

## Grow users > Store presence > Main store listing

| Field | Value |
|---|---|
| App name (30) | Palna - Mother & Baby Care |
| Short description (80) | Baby tracker in Urdu & English: feeds, sleep, diapers, vaccines. Works offline. |
| Full description (4000) | The "Description" from [app-store.md](app-store.md), unchanged |
| App icon (512 x 512) | `store/play/icon-512.png` |
| Feature graphic (1024 x 500) | `store/play/feature-graphic-1024x500.png` |
| Phone screenshots (9:16, 2 to 8) | `app/tool/screenshots/out/play/` (1080 x 1920, git-ignored; made with `flutter test tool/screenshots --update-goldens --dart-define=SHOT_DEVICE=play`, then flattened to RGB because Play rejects images with an alpha channel). Order: timer_en, today_en, reports_en, vaccines_en, illness_en, growth_en, journal_en, timer_en_dark |

## Store settings

| Field | Value |
|---|---|
| App or game | App |
| Category | Parenting |
| Tags | Baby care, Parenting, and up to 3 more that fit (not Activity tracker) |
| Contact email | hello@palnacare.com |
| Website | https://palnacare.com |
| Phone | (blank) |

## Policy > App content

| Section | Answer |
|---|---|
| Privacy policy | https://palnacare.com/privacy/ |
| App access | Restricted. Demo account `review@palnacare.com` (created with `supabase/snippets/review_account.sql`); gives full access |
| Ads | No |
| Content rating | All other app types. No to all content questions; users interact: Yes, limited to invited people: Yes; no block/report/chat; online content: No; digital purchases: No |
| Target audience | 18 and over only; "restrict minors" unticked |
| Government apps | No |
| Financial features | My app doesn't provide any financial features |
| Health | Nutrition and weight management, Sleep management, Diseases and conditions management, Disease prevention and public health, Emergency and first aid, Medical reference and education, Medication and treatment management. Not a medical device |

## Data safety

Collects data: Yes. Encrypted in transit: Yes. Accounts: username/password and OAuth.
Delete account URL: https://palnacare.com/delete-account/
Partial data deletion: No (entries deleted in the app are only marked deleted on the server).

Every type: collected, **not shared**, not ephemeral.

| Type | Required? | Purposes |
|---|---|---|
| Personal info > Name | Required | App functionality, Account management |
| Personal info > Email address | Required | App functionality, Account management |
| Personal info > User IDs | Required | App functionality, Account management |
| Personal info > Other info (baby's birth date, sex) | Required | App functionality |
| Health and fitness > Health info | Required | App functionality |
| App activity > Other user-generated content | Optional | App functionality |

## When paid plans arrive

Content rating: digital purchases Yes. Data safety: add Financial info > Purchase history.
Give the demo account the top plan. Financial features stay "none".
