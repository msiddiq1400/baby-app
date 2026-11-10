# Google Play listing: Palna

Copy each part into Play Console > Palna. Character limits are Google's.
Package name: `com.palnacare.app` (permanent).

## Grow users > Store presence > Main store listing

| Field | Value |
|---|---|
| App name (30) | Palna - Mother & Baby Care |
| Short description (80) | Baby tracker for feeds, sleep, diapers and vaccines. Works offline. |
| Full description (4000) | "Full description" below (the App Store text, with Google Play instead of Apple ID for subscriptions, plus activities, the widget and CSV export / import) |
| App icon (512 x 512) | `store/play/icon-512.png` |
| Feature graphic (1024 x 500) | `store/play/feature-graphic-1024x500.png` |
| Phone screenshots (9:16, 2 to 8) | `app/tool/screenshots/out/play/` (1080 x 1920, git-ignored; made with `flutter test tool/screenshots --update-goldens --dart-define=SHOT_DEVICE=play`, then flattened to RGB because Play rejects images with an alpha channel). Order: timer_en, today_en, reports_en, vaccines_en, illness_en, growth_en, journal_en, timer_en_dark |

## Full description (Play)

```
Palna is a calm, simple baby tracker for families everywhere, made with Pakistani and Urdu-speaking families in mind. Log feeds, sleep, diapers, growth, vaccines and medicines in a few taps, in English, اردو or Roman Urdu, and share one log with the whole family.

WHY PARENTS USE PALNA
• Feed, Diaper and Sleep buttons on every screen: a repeat bottle or a wet diaper takes two taps, even with one hand at 3 am
• Breastfeeding timer with left and right sides, and a sleep timer that keeps running when you close the app
• Everything works offline and syncs when you're back online
• Share with your family: parents, grandparents and helpers see the same log on their own phones

YOUR LANGUAGE, YOUR COUNTRY
• Vaccine schedules for 23 countries: Pakistan's EPI, the UK, US, Canada, the Gulf, Europe, Australia and more, with reminders before each visit
• Emergency numbers for your country, and hot-weather advice where it matters
• Desi first foods and 15 recipes for babies, from lauki purée at 6 months to qeema aloo at 10
• Full Urdu and Roman Urdu, not just English

TRACK EVERYTHING IN ONE PLACE
• Feeds: breast, bottle, formula and expressed milk, with amounts
• Pumping and a breast-milk stash with use-by dates
• Sleep: naps and night sleep
• Diapers: wet and dirty
• Activities: tummy time with a timer, bath, play, outdoors, reading and more
• Growth on WHO charts: weight, length and head size
• Vaccines, medicines and doses, with reminders
• Symptoms and temperature, and sick days tracked day by day until your baby is better
• Milestones and solid foods tried, with any reactions

SEE HOW YOUR BABY IS DOING
• 7 and 30 day reports: feeds, sleep and diapers per day, with typical ranges
• A journal of every day since birth
• A one-page PDF summary to show the doctor or share on WhatsApp
• Home-screen widget with today's feeds, sleep and diapers

YOUR DATA IS YOURS
• Export your baby's whole log as a CSV file, free
• Moving from Nara Baby or Huckleberry? Import your history in a few taps

GENTLE AT NIGHT
• Dark mode that won't wake you up during night feeds

PRIVATE BY DESIGN
• No ads and no tracking
• Your family's data is only shared with the people you invite
• Delete your account and data in the app at any time

Palna is not a medical device and doesn't replace advice from your doctor. If you're worried about your baby, contact a doctor straight away.

PALNA PRO (OPTIONAL)
Palna is free. Palna Pro is optional, for the whole family: monthly, yearly (with a 7-day free trial), or a one-time lifetime purchase. It adds more than one baby, more photos each month, next nap and bedtime times, 30-day reports, the PDF summary for your doctor, colour themes and widget extras. Subscriptions renew automatically until cancelled; manage or cancel them any time in Google Play > Payments & subscriptions. Lifetime is charged once and never renews.

Terms of use: https://palnacare.com/terms/
Privacy policy: https://palnacare.com/privacy/
```

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
| Content rating | All other app types. No to all content questions; users interact: Yes, limited to invited people: Yes; no block/report/chat; online content: No; digital purchases: **Yes** (Palna Pro; redone 10 Nov) |
| Target audience | 18 and over only; "restrict minors" unticked |
| Government apps | No |
| Financial features | My app doesn't provide any financial features |
| Health | Nutrition and weight management, Sleep management, Diseases and conditions management, Disease prevention and public health, Emergency and first aid, Medical reference and education, Medication and treatment management. Not a medical device |

## Data safety

Collects data: Yes. Encrypted in transit: Yes. Accounts: username/password and OAuth.
Delete account URL: https://palnacare.com/delete-account/
Partial data deletion: **Yes**, URL https://palnacare.com/delete-account/#some-data (deleted
entries are purged after 30 days, nightly since 5 Oct).

Every type: collected, **not shared**, not ephemeral.

| Type | Required? | Purposes |
|---|---|---|
| Personal info > Name | Required | App functionality, Account management |
| Personal info > Email address | Required | App functionality, Account management |
| Personal info > User IDs | Required | App functionality, Account management |
| Personal info > Other info (baby's birth date, sex, country) | Required | App functionality |
| Financial info > Purchase history | Required | App functionality (Palna Pro, via RevenueCat) |
| Health and fitness > Health info | Required | App functionality |
| App activity > Other user-generated content | Optional | App functionality |
| Photos and videos > Photos | Optional | App functionality |
| App info and performance > Crash logs | Required | Analytics (Firebase Crashlytics, to fix crashes) |
| App info and performance > Diagnostics | Required | Analytics (Firebase Crashlytics) |
| Device or other IDs | Required | App functionality (push address for family notifications), Analytics (Crashlytics installation ID) |

Firebase (Google) acts as our service provider, so this counts as **not shared** in Play's terms.

## Palna Pro (todos.txt 38b, 38d)

Monetize > Products > Subscriptions, product IDs matching RevenueCat, plus Lifetime under
Monetize > Products > In-app products (one-time). Prices decided 28 Oct 2026 (todos.txt 52):

| Product ID | Type / base plan | Price | Offer |
|---|---|---|---|
| palna_pro_monthly | subscription, monthly, auto-renewing | US $3.99; Pakistan Rs 299 | none |
| palna_pro_yearly | subscription, yearly, auto-renewing | US $24.99; Pakistan Rs 1,999 | 7-day free trial, new customers |
| palna_pro_lifetime | in-app product (one-time, not consumed) | US $49.99; Pakistan Rs 4,999 | none |

Set the US price, let Play convert the rest, then override Pakistan by hand (otherwise Play
converts $3.99 to about Rs 1,100). India optional: Rs 149 / 999 / 2,499 as ₹.

Content rating: digital purchases **Yes**. Data safety: add **Financial info > Purchase history**
(collected, not shared, required, App functionality). Financial features stay "none". The demo
account review@palnacare.com already has Pro (pro_emails table).
