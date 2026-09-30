# App Store listing: Palna

Copy each part into App Store Connect > Palna. Character limits are Apple's.

## Distribution > App Information

| Field | Value |
|---|---|
| Name (30) | Palna - Mother & Baby Care |
| Subtitle (30) | Baby tracker for Pakistan |
| Primary category | Health & Fitness |
| Secondary category | Lifestyle |
| Content rights | No, it doesn't contain, show or access third-party content |
| Age rating | See "Age rating" below |

## Distribution > iOS App > 1.0

**Promotional text (170)**

> Log feeds, sleep and diapers in seconds, in English, Urdu or Roman Urdu. Works offline, and the whole family sees the same log.

**Description (4000)**

> Palna is a calm, simple baby tracker made for families in Pakistan. Log feeds, sleep, diapers, growth, vaccines and medicines in a few taps, in English, اردو or Roman Urdu, and share one log with the whole family.
>
> WHY PARENTS USE PALNA
> • One tap to log a feed, a nap or a diaper, even with one hand at 3 am
> • Breastfeeding timer with left and right sides, and a sleep timer that keeps running when you close the app
> • Everything works offline and syncs when you're back online
> • Share with your family: parents, grandparents and helpers see the same log on their own phones
>
> MADE FOR PAKISTAN
> • Pakistan's EPI vaccine schedule, with reminders before each visit
> • Desi first foods and 15 recipes for babies, from lauki purée at 6 months to qeema aloo at 10
> • Emergency numbers and advice for hot weather
> • Full Urdu and Roman Urdu, not just English
>
> TRACK EVERYTHING IN ONE PLACE
> • Feeds: breast, bottle, formula and expressed milk, with amounts
> • Pumping and a breast-milk stash with use-by dates
> • Sleep: naps and night sleep
> • Diapers: wet and dirty
> • Growth on WHO charts: weight, length and head size
> • Vaccines, medicines and doses, with reminders
> • Symptoms and temperature, and sick days tracked day by day until your baby is better
> • Milestones and solid foods tried, with any reactions
>
> SEE HOW YOUR BABY IS DOING
> • 7 and 30 day reports: feeds, sleep and diapers per day, with typical ranges
> • A journal of every day since birth
> • A one-page PDF summary to show the doctor or share on WhatsApp
>
> GENTLE AT NIGHT
> • Dark mode that won't wake you up during night feeds
>
> PRIVATE BY DESIGN
> • No ads and no tracking
> • Your family's data is only shared with the people you invite
> • Delete your account and data in the app at any time
>
> Palna is not a medical device and doesn't replace advice from your doctor. If you're worried about your baby, contact a doctor straight away.

**Keywords (100, comma-separated, no spaces needed)**

> baby tracker,breastfeeding,newborn,feeding,sleep,diaper,vaccine,EPI,urdu,growth,pumping,parenting

**URLs**

| Field | Value |
|---|---|
| Support URL | https://palnacare.com |
| Marketing URL | https://palnacare.com |
| Privacy Policy URL (App Privacy page) | https://palnacare.com/privacy |

**Copyright:** 2026 followed by your legal name, exactly as on your Apple developer account (change it to Toolbox Services (SMC-Private) Limited after the move to an organization)

**Screenshots (6.9" iPhone):** `app/tool/screenshots/out/iphone/` (1320 x 2868, git-ignored; made with
`flutter test tool/screenshots --dart-define=SHOT_DEVICE=iphone`, then flattened to RGB because
App Store Connect rejects images with an alpha channel). Suggested order: timer_en, today_en, reports_en, vaccines_en, illness_en, growth_en, journal_en, timer_en_dark. Up to 10.

## App Review Information

| Field | Value |
|---|---|
| Sign-in required | Yes |
| User name | review@palnacare.com |
| Password | (the password you set in Supabase, see below) |
| Contact | your name, phone and email |

**Notes for the reviewer**

> Palna is a baby tracker for parents. Please sign in with the demo account above (email and password), which already has a sample baby with a few days of logs.
>
> The app also offers Sign in with Apple and Continue with Google, and account deletion is in Settings > Account > Delete my account.
>
> The language can be switched between English, Urdu and Roman Urdu from the globe icon on the sign-in screen or in Settings. Data is stored on the phone and syncs to our server, so the app works offline.
>
> Palna shows general guidance from WHO, NHS and Pakistan's EPI programme and always tells parents to confirm with their doctor; it does not diagnose or give treatment.

**Demo account:** Supabase > Authentication > Users > Add user > Create new user: email `review@palnacare.com`, a strong password, tick "Auto Confirm User". Then sign in with it on your phone and add a sample baby with a few feeds, sleeps, diapers and a vaccine, so the reviewer sees a real app. Keep the account; Apple reuses it for every update.

## App Privacy (Distribution > App Privacy)

Tracking: **No**, Palna doesn't track people across other companies' apps or websites.

Data collected, all **linked to the user**, all **not used for tracking**, purpose **App Functionality** only:

| Apple category | Data type | Why |
|---|---|---|
| Contact Info | Name | Shown to family members who share a baby |
| Contact Info | Email Address | Sign-in and sign-up codes |
| Health & Fitness | Health | Baby's growth, feeds, sleep, vaccines, medicines, symptoms, illnesses |
| User Content | Other User Content | Notes, milestones, foods tried |
| Identifiers | User ID | The account ID that keeps each family's data separate |

Not collected: location, contacts, photos, browsing, purchases, usage data, diagnostics, advertising data.

## Age rating

Answer **None** to everything except:

| Question | Answer |
|---|---|
| Medical or treatment information | Infrequent/Mild (general baby-care guidance, not treatment) |
| Made for kids | No (it's for parents) |

## Other questions

| Question | Answer |
|---|---|
| Export compliance / encryption | Already answered in the app (standard HTTPS only) |
| Advertising identifier (IDFA) | No |
| EU Digital Services Act trader status | Not a trader (free app, no payments), while the account is individual |
| Price | Free |
| Availability | All countries, or start with Pakistan only |
