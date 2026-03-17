# Circadian MVP — Product Specification

**Version:** 1.0 Draft  
**Date:** March 16, 2026  
**Author:** Dan / Fibonacci Labs  
**Status:** Pre-Development  
**Platform:** iOS (native) + Web (quiz funnel)

---

## Table of Contents

1. [Product Thesis](#1-product-thesis)
2. [What We're Building (And What We're Not)](#2-what-were-building-and-what-were-not)
3. [Competitive Context](#3-competitive-context)
4. [Target Users](#4-target-users)
5. [Architecture Philosophy](#5-architecture-philosophy)
6. [The Two Products](#6-the-two-products)
7. [Web Quiz Funnel — Detailed Spec](#7-web-quiz-funnel--detailed-spec)
8. [iOS App — Detailed Spec](#8-ios-app--detailed-spec)
9. [The Adaptive Engine](#9-the-adaptive-engine)
10. [HealthKit Integration](#10-healthkit-integration)
11. [Notification System](#11-notification-system)
12. [Data Model](#12-data-model)
13. [Monetization](#13-monetization)
14. [Growth Mechanics](#14-growth-mechanics)
15. [Retention Mechanics](#15-retention-mechanics)
16. [MVP Scope & Phasing](#16-mvp-scope--phasing)
17. [Key Metrics](#17-key-metrics)
18. [Open Questions](#18-open-questions)

---

## 1. Product Thesis

Most circadian/chronotype apps deliver a static result from a one-time quiz. You answer 15 questions, get told you're a "Wolf," and receive a fixed daily schedule. The novelty fades in a week. The subscription cancels in a month.

**Our thesis:** The lasting version of this product is one that *learns from your actual sleep and behavior data* and gets more useful over time. The quiz is the hook. HealthKit is the engine. The adaptive daily trajectory is the product.

We treat the chronotype label as an identity layer (fun, shareable, emotionally resonant) and the real data as the intelligence layer (practical, evolving, personalized). The label gets people in. The data keeps them.

**One-sentence pitch:** "Your body already knows your perfect schedule — we just read the data."

---

## 2. What We're Building (And What We're Not)

### We ARE building:
- A web-based chronotype quiz that stands alone as a lead generation and viral acquisition tool
- An iOS app that connects to HealthKit and builds an adaptive daily trajectory from real sleep data
- A notification system that nudges users at biologically optimal moments
- A shareable identity system (chronotype cards) designed for organic social spread

### We are NOT building:
- A sleep tracker (Oura, Whoop, Apple Watch already do this — we consume their data)
- A habit tracker (we don't track tasks or streaks — we tell you *when* your biology supports different activities)
- A meditation or wellness content app (no articles, no audio, no "Intel Drops")
- A clinical tool (we don't diagnose, treat, or make medical claims)

### What we keep from ARC:
- Chronotype quiz as onboarding hook
- Four-chronotype model (Lion/Bear/Wolf/Dolphin)
- Science-backed positioning (Huberman/Walker research)
- Local-first privacy architecture
- Caffeine cutoff calculation
- Morning sunlight nudge
- Digital sunset protocol

### What we change from ARC:
- **Add HealthKit integration** — adaptive trajectory from real data, not just a quiz
- **Add web quiz funnel** — acquisition happens before app install
- **Add shareable chronotype cards** — social virality baked in from day one
- **Add Apple Watch companion** — ambient energy state + haptic nudges
- **Add calendar integration** — export trajectory to Apple/Google Calendar
- **Remove content library** — no articles, no "Intel Drops" — keep the app focused on the daily operating system
- **Remove jargon** — plain language by default, science terms opt-in
- **Simplify pricing** — annual only, no weekly plan
- **Add conversational data calibration** — when HealthKit data suggests a different chronotype than the quiz, surface it as a question, not a correction

---

## 3. Competitive Context

### ARC (Primary Competitor)
- Quiz-based, static daily schedule
- No HealthKit, no biometric data
- 200+ downloads, 6 weeks post-launch
- Aggressive weekly pricing ($3.99/week)
- Strong marketing, weak retention mechanics
- Solo developer, fast iteration

### Rise Science
- HealthKit-integrated, adaptive
- Focuses on sleep debt calculation
- More clinical positioning
- Higher price point
- Less emphasis on chronotype identity

### The Gap We Exploit
ARC has the better brand energy and chronotype identity layer but no real data integration. Rise has the data integration but no fun identity layer and targets a more clinical audience. We combine ARC's approachable chronotype identity with Rise's adaptive data engine, and add a web-first acquisition funnel that neither has.

---

## 4. Target Users

### Primary: The Curious Optimizer
- 25-40, knowledge worker, remote or hybrid
- Listens to Huberman, reads about biohacking casually but doesn't own an Oura ring
- Has an Apple Watch or uses iPhone sleep tracking
- Would take a "What's your chronotype?" quiz on Instagram without thinking twice
- Willing to pay $30/year for something that makes their days feel more structured
- NOT a hardcore biohacker — more "interested in wellness" than "obsessive about metrics"

### Secondary: The Struggling Sleeper
- Knows their sleep is bad, has tried various things
- Wants practical guidance, not another tracker showing them data they can't act on
- Drawn in by caffeine timing and wind-down protocols

### Tertiary: The Night Shift Worker
- Underserved by every mainstream app
- Needs inverted protocols
- High loyalty if well-served — they have almost no options

### Who We're NOT Targeting (Yet)
- Hardcore biohackers (they want raw data, not a simplified interface)
- Clinical sleep disorder patients (we're wellness, not medical)
- People without smartphones or wearables (our adaptive engine needs data)

---

## 5. Architecture Philosophy

### Local-First, Adaptive, Privacy-Respecting

All user data stays on-device. No cloud backend for user data. No accounts to create. This isn't just a privacy feature — it's a cost and complexity advantage. We don't need to run servers, manage databases, handle GDPR deletion requests, or worry about data breaches. The user's iPhone IS the server.

**What lives on-device (SQLite):**
- Quiz answers and chronotype result
- HealthKit-derived sleep data (cached locally)
- Generated daily trajectories
- Notification history and user interactions
- Bio-anchor logs (sunlight, caffeine)

**What lives in the cloud (minimal):**
- Web quiz results (pre-app-install, stored temporarily for handoff)
- Email addresses (for nurture sequences, stored in email platform e.g., Buttondown or Loops)
- Anonymous analytics (PostHog or similar, no PII)

**What we NEVER store or transmit:**
- Raw HealthKit data to any external server
- Personally identifiable health information
- Data for advertising or third-party use

---

## 6. The Two Products

This is really two products that work together:

### Product A: The Web Quiz (Acquisition Engine)
- Standalone web experience, works on any device
- No app install required
- Captures email or phone number after delivering result
- Generates a shareable chronotype card
- Funnels to iOS app for the full experience
- Can run independently as a viral tool even if someone never installs the app

### Product B: The iOS App (Retention Engine)
- HealthKit-integrated adaptive daily trajectory
- Push notifications at biologically optimal times
- Apple Watch companion for ambient energy state
- Calendar export for practical integration
- The thing people pay for

**The handoff:** Take quiz on web → get chronotype result + shareable card → prompted to "get your adaptive daily schedule" → download app → app recognizes returning user (via deep link or code) → pre-populates chronotype from web quiz → asks to connect HealthKit → begins building adaptive trajectory immediately using quiz as bootstrap, real data as engine.

---

## 7. Web Quiz Funnel — Detailed Spec

### 7.1 Purpose
The web quiz is the top-of-funnel acquisition tool. Its job is to:
1. Deliver a compelling chronotype result that people want to share
2. Capture an email address or phone number
3. Generate a shareable social card
4. Drive app installs with a clear value upgrade pitch

### 7.2 Tech Stack
- **Framework:** Next.js (static export or Vercel-hosted)
- **Styling:** Tailwind CSS
- **Analytics:** PostHog (web analytics, funnel tracking)
- **Email capture:** Buttondown or Loops API
- **SMS:** Twilio (optional, for text-me-a-link flow)
- **OG/Social cards:** Dynamic image generation (Vercel OG or Satori)
- **Deep linking:** iOS Universal Links for app handoff

### 7.3 Quiz Flow

```
Landing Page
  → Headline: "What's Your Chronotype? Find out in 60 seconds."
  → Single CTA: "Take the Quiz"
  
Quiz (8-10 questions, one per screen, progress bar)
  → Q1: "If you had nothing to do tomorrow, when would you naturally wake up?"
       [Before 6 AM / 6-7:30 AM / 7:30-9 AM / After 9 AM]
  → Q2: "When do you feel most mentally sharp?"
       [Early morning / Late morning / Afternoon / Evening]
  → Q3: "How would you describe your energy at 10 PM?"
       [Exhausted / Winding down / Still going strong / Just hitting my stride]
  → Q4: "How quickly do you fall asleep?"
       [Out in minutes / 15-30 min / Takes a while / Unpredictable]
  → Q5: "When do you have your first coffee?"
       [Right after waking / Within an hour / Late morning / I don't drink coffee]
  → Q6: "How many cups of coffee/caffeinated drinks per day?"
       [0 / 1-2 / 3-4 / 5+]
  → Q7: "What time do you usually go to bed?"
       [Before 10 PM / 10-11 PM / 11 PM-12 AM / After midnight]
  → Q8: "Do you consider yourself a morning person or night person?"
       [Definitely morning / Slightly morning / Slightly night / Definitely night]
  → Q9: "What's your age range?"
       [18-25 / 26-35 / 36-45 / 46-55 / 55+]
  → Q10: "What's your primary goal?"
       [Better focus / Better sleep / More energy / All of the above]

Processing Screen
  → "Analyzing your biological rhythm..."
  → Brief animated transition (2-3 seconds, builds anticipation)

Result Screen
  → Large chronotype reveal: "You're a Wolf 🐺"
  → 3-4 sentence description of what this means
  → Key stat highlights:
     - "Your peak creative hours: 5-9 PM"
     - "Your ideal caffeine cutoff: 2 PM"
     - "Your optimal wake time: ~8:30 AM"
  → Shareable card CTA: "Share Your Chronotype"
  → Email capture: "Get your personalized daily schedule"
     [Email input] [Send My Schedule]
  → App CTA: "Want your schedule to adapt to your real sleep data?"
     [Download the App]
  → SMS option: "Text me the link"
     [Phone input] [Send]
```

### 7.4 The Shareable Card

This is the single most important growth mechanic. The card should be:

- **Beautiful enough to post unprompted** — not a screenshot, a designed artifact
- **Sized for Instagram Stories** (1080x1920) AND Twitter/X (1200x675)
- **Contains:** Chronotype animal + emoji, name, 2-3 key stats, subtle app branding
- **Does NOT contain:** Full daily schedule (that's the app's value — don't give it all away)
- **Generated dynamically** using user's quiz results
- **One-tap share** to Instagram Stories, X, iMessage, or download to camera roll
- **Has a QR code or short URL** that links back to the quiz ("Find yours at [domain]/quiz")

### 7.5 Email Nurture Sequence

After email capture, a 5-email sequence over 10 days:

| Day | Email | Purpose |
|---|---|---|
| 0 | "You're a [Chronotype] — here's what that means" | Deliver value, reinforce identity |
| 2 | "The one thing most [Chronotypes] get wrong about caffeine" | Practical tip, builds trust |
| 4 | "Your peak focus window (and how to protect it)" | Actionable advice, shows app value |
| 7 | "Why a quiz isn't enough — how your real data tells a different story" | Bridge to app install |
| 10 | "Your schedule should evolve with you" | Final app CTA, soft close |

### 7.6 Conversion Goals

| Metric | Target |
|---|---|
| Landing page → quiz start | >60% |
| Quiz start → completion | >75% |
| Completion → email capture | >30% |
| Completion → share card | >15% |
| Completion → app install (direct) | >10% |
| Email → app install (nurture) | >8% |

---

## 8. iOS App — Detailed Spec

### 8.1 Onboarding Flow (New User, No Web Quiz)

```
App Launch
  → Welcome screen: value prop + "Get Started"
  → Abbreviated quiz (same questions as web, skip if deep-linked from web)
  → Chronotype reveal (same as web, or pre-populated)
  → HealthKit permission screen:
     "Your Apple Watch tracks your sleep every night.
      Connect to Health and we'll build a schedule 
      that adapts to your actual patterns — not just
      a quiz you took once."
     [Connect to Apple Health] [Maybe Later]
  → If connected: "Great. We'll start with your quiz results 
     and refine as we learn your patterns."
  → If declined: "No problem. We'll use your quiz results.
     You can connect anytime in Settings."
  → Daily Trajectory preview (today's schedule)
  → Notification permission:
     "Can we nudge you at the right moments?
      We'll only ping you for sunlight, caffeine cutoff,
      and wind-down — nothing else."
     [Allow Notifications] [Not Now]
  → Home screen
```

### 8.2 Onboarding Flow (Returning User from Web Quiz)

```
App Launch (via deep link or code entry)
  → "Welcome back, Wolf 🐺"
  → Skip quiz entirely — pre-populated from web results
  → HealthKit permission screen (same as above)
  → Notification permission (same as above)
  → Home screen with trajectory already generated
```

### 8.3 Screen Architecture

```
Tab Bar (3 tabs — keep it minimal)
│
├── TODAY (Home)
│   ├── Energy State Card
│   │   └── Current state: Peak / Dip / Recovery
│   │   └── Time until next state change
│   │   └── One-line suggestion ("Deep work window — protect the next 90 minutes")
│   │
│   ├── Daily Trajectory Timeline
│   │   └── Visual 24-hour timeline (scrollable, current time highlighted)
│   │   └── Time blocks:
│   │       ├── Wake Window
│   │       ├── Sunlight Window (with one-tap log)
│   │       ├── Caffeine OK → Caffeine Cutoff (with countdown)
│   │       ├── Peak Focus Block(s)
│   │       ├── Energy Dip / Recovery Block
│   │       ├── Digital Sunset
│   │       ├── Wind-Down
│   │       └── Sleep Target
│   │   └── Each block expandable for brief science context
│   │
│   ├── Quick Actions
│   │   ├── ☀️ Log Sunlight (one tap)
│   │   ├── ☕ Log Coffee (one tap, increments count)
│   │   └── 📤 Share My Chronotype
│   │
│   └── Confidence Indicator (if HealthKit connected)
│       └── "Based on 3 nights of data — accuracy improves over time"
│       └── "Based on 14 nights — high confidence"
│
├── PATTERNS (Insights)
│   ├── Sleep Consistency Chart (7/14/30 day)
│   │   └── Actual sleep/wake times plotted over time
│   │   └── "Social jetlag" gap visualization (weekday vs. weekend)
│   │
│   ├── Chronotype Confidence
│   │   └── "Your data points to: Wolf 🐺"
│   │   └── Confidence percentage based on data volume and consistency
│   │   └── If data diverges from quiz result:
│   │       "Your sleep patterns over the past 2 weeks look
│   │        more like a Bear than a Wolf. Does that feel right?"
│   │       [Yes, update my type] [No, keep Wolf]
│   │
│   ├── Caffeine Impact
│   │   └── Sleep onset time on coffee days vs. no-coffee days
│   │   └── "You fell asleep 23 minutes later on days you had 
│   │        coffee after 2 PM"
│   │
│   └── Weekly Summary Card
│       └── Auto-generated each Monday
│       └── Shareable
│
└── SETTINGS
    ├── Profile
    │   ├── Chronotype (with option to retake quiz)
    │   ├── Goal (Focus / Sleep / Energy)
    │   ├── Age range
    │   └── Night shift mode toggle
    │
    ├── Connections
    │   ├── Apple Health (connect/disconnect)
    │   ├── Calendar Export (Apple Calendar / Google Calendar)
    │   └── Apple Watch (status)
    │
    ├── Notifications
    │   ├── Morning sunlight (on/off, custom offset)
    │   ├── Caffeine cutoff (on/off)
    │   ├── Peak focus (on/off)
    │   ├── Digital sunset (on/off)
    │   ├── Wind-down (on/off)
    │   └── Weekly summary (on/off)
    │
    ├── Preferences
    │   ├── Language: Plain / Science Mode
    │   ├── Caffeine sensitivity: Normal / High / Low
    │   └── Units: 12h / 24h
    │
    ├── Data
    │   ├── Export my data (JSON)
    │   └── Delete all data
    │
    ├── Subscription management
    ├── Privacy policy
    ├── Terms of service
    └── About / Credits
```

### 8.4 Apple Watch Companion (MVP)

Minimal viable Watch app — this is a complication and glance, not a full app:

**Complication (watch face):**
- Shows current energy state icon (⚡ Peak / 📉 Dip / 🔄 Recovery)
- Tapping opens glance view

**Glance view:**
- Current energy state + time until next transition
- Caffeine cutoff countdown (or "☕ Clear" if past cutoff)
- Next notification preview ("Sunlight window in 20 min")

**Haptic nudges:**
- Gentle tap for sunlight window opening
- Strong tap for caffeine cutoff
- Gentle tap for digital sunset

No logging, no trajectory view, no settings on Watch. Keep it ambient.

### 8.5 Calendar Export

**On toggle:**
- Creates a dedicated calendar called "[App Name] — Daily Rhythm"
- Populates today and tomorrow with time blocks
- Updates daily (regenerated each morning based on trajectory)
- Uses calendar colors: green for Peak Focus, yellow for transitions, purple for Wind-Down, blue for Sleep

**Blocks exported:**
- ☀️ Sunlight Window (15 min)
- ☕ Caffeine OK (start of caffeine window)
- 🚫 Caffeine Cutoff (all-day event from cutoff to sleep)
- ⚡ Peak Focus (90-min blocks, up to 2 per day)
- 📉 Energy Dip (marks the dip window)
- 🌅 Digital Sunset (30 min)
- 😴 Wind-Down → Sleep (marks the full wind-down period)

**The key insight:** When your circadian schedule shows up alongside your meetings, you can see conflicts. "Oh, I have a strategy meeting at 2 PM but that's my dip — let me see if I can move it." This is the bridge from novelty app to daily utility.

---

## 9. The Adaptive Engine

This is the core differentiator and the retention moat. The adaptive engine is what makes this product get better over time rather than delivering all its value on day one.

### 9.1 How It Works

```
LAYER 1: Quiz Bootstrap (Day 1)
  → User takes quiz → chronotype assigned → static trajectory generated
  → This is identical to what ARC does
  → Accuracy: Low-Medium (self-report bias, social schedule contamination)

LAYER 2: HealthKit Observation (Days 2-7)
  → Pull sleep onset, wake time, duration each morning
  → Begin building actual sleep profile
  → Trajectory starts adjusting wake time to match real data
  → Caffeine cutoff recalculates based on actual sleep onset
  → Confidence indicator: "Based on X nights of data"

LAYER 3: Pattern Recognition (Days 8-21)
  → Enough data to detect weekday/weekend split (social jetlag)
  → Can estimate natural chronotype from weekend/free-day sleep times
  → If data diverges from quiz result, surface conversational prompt:
     "Your sleep patterns over the past 2 weeks look more like
      a Bear than a Wolf. Does that feel right?"
     [Yes, update] [No, keep current]
  → Trajectory becomes significantly more personalized

LAYER 4: Continuous Refinement (Day 22+)
  → Rolling 14-day window for trajectory calculation
  → Detects seasonal drift, travel recovery, schedule changes
  → Caffeine impact correlation (if user logs coffee + we see sleep onset shift)
  → Weekly summary highlights trends and adjustments
  → "High confidence" indicator unlocked
```

### 9.2 The Conversational Calibration Model

This is the key UX innovation. When data contradicts the quiz, we don't override — we ask.

**Why this matters:** People are emotionally invested in their chronotype identity. If someone identifies as a Wolf and we silently reclassify them as a Bear based on data, they'll feel the app is broken. If we say "the data says you're a Bear," they'll argue with the app. Instead:

```
Trigger: 14+ days of data where sleep midpoint consistently 
         aligns with a different chronotype than the quiz result.

Prompt (in Patterns tab, not a push notification):
  "Quick check-in 👋
   
   Over the past 2 weeks, your natural sleep window has been
   roughly 11 PM – 7 AM. That's closer to a Bear rhythm than
   the Wolf pattern from your quiz.
   
   This could mean:
   • Your schedule is influencing your sleep more than your
     natural preference (social jetlag)
   • Your chronotype may have shifted (this happens with age)
   • You might actually be more of a Bear than you thought
   
   What feels right to you?"
   
   [I think I am more of a Bear — update my schedule]
   [I'm a Wolf stuck in a Bear schedule — keep my Wolf trajectory]
   [I'm not sure — show me both and let me compare]
```

The third option is the magic one — it lets the user see their day optimized for both chronotypes side by side and choose which feels right. This is respectful, educational, and builds trust.

### 9.3 Confidence Scoring

| Data Volume | Confidence Level | UI Treatment |
|---|---|---|
| Quiz only, no HealthKit | Low | "Based on your quiz — connect Health for better accuracy" |
| 1-3 nights of data | Low-Medium | "Learning your patterns... (3 nights)" |
| 4-7 nights | Medium | "Based on [N] nights of data" |
| 8-14 nights | Medium-High | "Your schedule is calibrating well" |
| 14-21 nights | High | "Based on [N] nights — high confidence" |
| 21+ nights | Very High | "Personalized to your biology" (no qualifier needed) |

The confidence indicator serves two purposes: it manages expectations early ("this will get better") and creates a progress mechanic that encourages daily engagement ("I want to get to high confidence").

---

## 10. HealthKit Integration

### 10.1 Data We Read

| Data Type | HealthKit Identifier | Purpose | Required? |
|---|---|---|---|
| Sleep Analysis | `HKCategoryTypeIdentifier.sleepAnalysis` | Sleep onset, wake time, duration, stages | Required for adaptive engine |
| Heart Rate | `HKQuantityTypeIdentifier.heartRate` | Resting HR trend as recovery signal | Optional, nice-to-have |
| Active Energy | `HKQuantityTypeIdentifier.activeEnergyBurned` | Detect exercise timing for trajectory adjustment | Optional, future |

### 10.2 Data We Write

| Data Type | Purpose |
|---|---|
| Sleep Schedule | Write recommended bedtime/wake time to Apple Health sleep schedule |

### 10.3 Permission Flow

**Pre-permission screen (custom, shown before system dialog):**

```
[Illustration: iPhone + Apple Watch with sleep data flowing into a daily schedule]

"Your Watch already knows when you sleep.

We read your sleep times from Apple Health to build
a daily schedule that adapts to your real patterns —
not just a quiz you took once.

What we read:
✓ Sleep times and duration
✓ Sleep stages (if available)

What we never do:
✗ Send your data to any server
✗ Share with third parties
✗ Use for advertising

All your data stays on this device."

[Connect to Apple Health]
[Maybe Later]
```

**Critical:** This screen must appear BEFORE the system HealthKit permission dialog. We get one shot at the system dialog — if the user denies it, we can never show it again. The pre-permission screen educates and builds trust so the system dialog gets a "yes."

### 10.4 Handling "Maybe Later" and Denied Permissions

If the user taps "Maybe Later":
- App works in quiz-only mode
- Subtle banner on Home: "Connect Health for a schedule that adapts to you →"
- Remind again after 3 days, then after 7 days, then stop asking
- Always accessible via Settings

If the user denied the system permission:
- App works in quiz-only mode
- Settings shows: "Health access was denied. To connect, go to Settings → Privacy → Health → [App Name]"
- We cannot re-trigger the system dialog — this is an iOS limitation
- Don't nag; respect the decision

### 10.5 Data Processing (All On-Device)

```
Each morning (triggered by app launch or background refresh):

1. Query HealthKit for last night's sleep data
   → sleepAnalysis samples from 6 PM yesterday to 12 PM today
   → Filter for primary sleep period (ignore naps)
   
2. Extract:
   → sleep_onset_time (first inBed or asleepUnspecified sample)
   → wake_time (last sample end time)
   → total_duration
   → sleep_stages (if Apple Watch data available):
      → deep_sleep_minutes
      → rem_sleep_minutes
      → core_sleep_minutes
      → awake_minutes

3. Store in local SQLite:
   → date, sleep_onset, wake_time, duration, stages (JSON)

4. Recalculate trajectory:
   → Use actual wake_time (not quiz answer) for today's schedule
   → Caffeine cutoff = sleep_onset - 8 hours (based on 14-day rolling average)
   → Sunlight window = wake_time + 15 min to wake_time + 60 min
   → Peak focus windows = chronotype-specific offsets from wake_time
   → Digital sunset = average sleep_onset - 2 hours
   
5. Update notifications for today
```

### 10.6 Apple Review Compliance

- HealthKit entitlement in Xcode project capabilities
- `NSHealthShareUsageDescription` in Info.plist with clear, user-facing explanation
- HealthKit functionality clearly visible in app UI (not hidden)
- Privacy policy explicitly mentions HealthKit data handling
- No HealthKit data transmitted to external servers
- No HealthKit data used for advertising
- App Store description mentions Apple Health integration
- Screenshots show Health connection UI

---

## 11. Notification System

Notifications are the primary retention mechanic. They bring the user back into the app at the exact moments their biology matters most.

### 11.1 Notification Types

| Notification | Default Time | Trigger | Priority | Copy Style |
|---|---|---|---|---|
| **Sunlight Window** | Wake + 15 min | Scheduled from HealthKit wake time or quiz | High | "Your sunlight window is open — even 10 minutes outside helps set your rhythm for the day." |
| **Caffeine OK** | Wake + 90 min | Calculated from wake time | Low | "Adenosine has had time to clear. Coffee is a go. ☕" |
| **Peak Focus** | Chronotype-specific | Calculated from chronotype + wake time | Medium | "Your brain is at its sharpest right now. Great time for your hardest task." |
| **Caffeine Cutoff** | Sleep onset - 8 hrs | Rolling average sleep onset | High | "Last call for caffeine. After now, it starts cutting into tonight's sleep." |
| **Digital Sunset** | Sleep onset - 2 hrs | Rolling average sleep onset | Medium | "Time to start dimming. Lower the lights and screens over the next couple hours." |
| **Wind-Down** | Sleep onset - 45 min | Rolling average sleep onset | Medium | "Almost there. Your body is ready to wind down." |
| **Weekly Summary** | Monday 9 AM | Fixed schedule | Low | "Your week in review is ready. See how your patterns are shaping up." |

### 11.2 Notification Principles

1. **Maximum 3 notifications per day** by default. Users can enable more in Settings.
2. **Default set:** Sunlight Window, Caffeine Cutoff, Digital Sunset. Everything else is opt-in.
3. **Adaptive timing:** Notification times shift based on HealthKit data. If you woke up 30 minutes late, your sunlight window notification shifts accordingly.
4. **No notification on app open:** If the user opens the app within 15 minutes of a scheduled notification, suppress it — they're already engaged.
5. **Plain language always.** No "Photon Latency alert" or "Bio-Anchor reminder." Say what you mean.
6. **Actionable, not informational.** Every notification should imply something the user can DO right now.

### 11.3 Night Shift Mode

For night shift workers, the entire notification schedule inverts:
- "Morning" sunlight notification fires at their actual wake time (e.g., 6 PM)
- Caffeine cutoff calculates from their actual sleep onset (e.g., 8 AM)
- All copy adjusts: "Your sunlight window is open" regardless of actual solar time

---

## 12. Data Model

### 12.1 Local SQLite Schema

```sql
-- User profile (single row, updated on quiz or settings change)
CREATE TABLE user_profile (
    id INTEGER PRIMARY KEY DEFAULT 1,
    chronotype TEXT NOT NULL, -- 'lion', 'bear', 'wolf', 'dolphin'
    chronotype_source TEXT NOT NULL, -- 'quiz', 'data', 'user_override'
    chronotype_confidence REAL DEFAULT 0.0, -- 0.0 to 1.0
    goal TEXT DEFAULT 'focus', -- 'focus', 'sleep', 'energy'
    age_range TEXT,
    is_night_shift INTEGER DEFAULT 0,
    caffeine_sensitivity TEXT DEFAULT 'normal', -- 'low', 'normal', 'high'
    quiz_wake_time TEXT, -- HH:MM from quiz
    quiz_sleep_time TEXT, -- HH:MM from quiz
    quiz_answers TEXT, -- JSON blob of all quiz answers
    healthkit_connected INTEGER DEFAULT 0,
    notifications_enabled INTEGER DEFAULT 0,
    science_mode INTEGER DEFAULT 0, -- 0 = plain language, 1 = jargon
    web_quiz_id TEXT, -- links to web quiz session for handoff
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Sleep log (one row per night, populated from HealthKit or manual)
CREATE TABLE sleep_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL UNIQUE, -- YYYY-MM-DD (date of wake-up)
    sleep_onset TEXT, -- ISO datetime
    wake_time TEXT, -- ISO datetime
    duration_minutes INTEGER,
    deep_sleep_minutes INTEGER, -- nullable if no Watch
    rem_sleep_minutes INTEGER,
    core_sleep_minutes INTEGER,
    awake_minutes INTEGER,
    source TEXT DEFAULT 'healthkit', -- 'healthkit', 'manual', 'inferred'
    created_at TEXT NOT NULL
);

-- Daily trajectory (one row per day, regenerated each morning)
CREATE TABLE daily_trajectory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL UNIQUE,
    chronotype TEXT NOT NULL,
    wake_time TEXT NOT NULL,
    sunlight_window_start TEXT,
    sunlight_window_end TEXT,
    caffeine_ok_time TEXT,
    caffeine_cutoff_time TEXT,
    peak_focus_1_start TEXT,
    peak_focus_1_end TEXT,
    peak_focus_2_start TEXT, -- nullable, some chronotypes get 2
    peak_focus_2_end TEXT,
    energy_dip_start TEXT,
    energy_dip_end TEXT,
    digital_sunset_time TEXT,
    wind_down_time TEXT,
    sleep_target_time TEXT,
    confidence_level TEXT, -- 'low', 'medium', 'high', 'very_high'
    data_nights_count INTEGER, -- how many nights of data informed this
    created_at TEXT NOT NULL
);

-- Caffeine log (user-initiated, one-tap logging)
CREATE TABLE caffeine_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    logged_at TEXT NOT NULL, -- ISO datetime
    created_at TEXT NOT NULL
);

-- Sunlight log (user-initiated, one-tap logging)
CREATE TABLE sunlight_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    logged_at TEXT NOT NULL,
    minutes_after_wake INTEGER, -- calculated from sleep_log.wake_time
    created_at TEXT NOT NULL
);

-- Notification log (tracks delivery and engagement)
CREATE TABLE notification_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL, -- 'sunlight', 'caffeine_ok', 'peak_focus', etc.
    scheduled_at TEXT NOT NULL,
    delivered INTEGER DEFAULT 0,
    tapped INTEGER DEFAULT 0,
    created_at TEXT NOT NULL
);

-- Chronotype check-ins (conversational calibration)
CREATE TABLE chronotype_checkin (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    suggested_type TEXT NOT NULL,
    current_type TEXT NOT NULL,
    user_response TEXT, -- 'accepted', 'rejected', 'compare'
    data_nights_count INTEGER,
    created_at TEXT NOT NULL
);
```

### 12.2 Web Quiz Temporary Storage

The web quiz needs to store results temporarily for app handoff:

```
Quiz Session (server-side, ephemeral)
├── session_id: uuid (used in deep link)
├── chronotype: string
├── quiz_answers: json
├── wake_time_preference: string
├── sleep_time_preference: string
├── caffeine_data: json
├── goal: string
├── age_range: string
├── email: string (optional, for nurture)
├── phone: string (optional, for SMS link)
├── card_generated: boolean
├── app_installed: boolean
├── created_at: datetime
├── expires_at: datetime (created_at + 30 days)
```

This data lives in a simple key-value store (Redis, DynamoDB, or even a Supabase table). It's not health data — it's quiz answers. It expires after 30 days. Once the app imports it, it can be deleted.

---

## 13. Monetization

### 13.1 Pricing

**One plan. One price. Simple.**

| Plan | Price | Trial |
|---|---|---|
| **Annual** | $29.99/year ($2.50/month) | 7-day free trial |

No weekly plan. No monthly plan. Here's why:
- Weekly at $3.99 ($207/year) creates churn machines and signals "not confident in retention"
- Monthly at $9.99 creates comparison anxiety against Calm, Headspace, etc.
- Annual at $29.99 is an impulse-friendly price point, signals confidence, and gives us 12 months to prove value
- 7-day trial (not 3) gives the adaptive engine time to start showing real data value

### 13.2 Free vs. Paid

| Feature | Free | Pro |
|---|---|---|
| Chronotype quiz (web + app) | ✅ | ✅ |
| Chronotype result + shareable card | ✅ | ✅ |
| Basic daily trajectory (quiz-based, static) | ✅ | ✅ |
| Today view with energy state | ✅ | ✅ |
| HealthKit integration | ❌ | ✅ |
| Adaptive trajectory | ❌ | ✅ |
| Push notifications | ❌ | ✅ |
| Patterns / Insights tab | ❌ | ✅ |
| Caffeine impact analysis | ❌ | ✅ |
| Calendar export | ❌ | ✅ |
| Apple Watch companion | ❌ | ✅ |
| Weekly summary | ❌ | ✅ |
| Conversational chronotype calibration | ❌ | ✅ |

**The free tier is generous enough to be useful** (you still get a daily schedule) **but limited enough that the upgrade is obvious** (the adaptive engine is the whole point).

### 13.3 Revenue Projections (Conservative)

| Month | Downloads | Free Users | Trial Starts | Paid Converts | MRR | Cumulative ARR |
|---|---|---|---|---|---|---|
| 1 | 500 | 400 | 250 | 38 (15%) | $95 | $1,140 |
| 3 | 2,000 | 1,500 | 1,000 | 150 | $375 | $4,500 |
| 6 | 5,000 | 3,500 | 2,500 | 375 | $938 | $11,250 |
| 12 | 15,000 | 10,000 | 7,500 | 1,125 | $2,813 | $33,750 |

*Assumes 50% of downloads start trial, 15% trial-to-paid conversion, $2.50/month ARPU on annual plan. Does not account for churn, which would reduce active subscriber count. Does not account for viral coefficient from shareable cards, which could significantly increase downloads.*

---

## 14. Growth Mechanics

### 14.1 Organic / Viral

**The shareable chronotype card** is the primary organic growth mechanic.

Loop: User takes quiz → shares card on Instagram/X → friend sees card → clicks QR/link → takes quiz → shares card → ...

Expected viral coefficient: 0.3-0.5 (each user brings in 0.3-0.5 additional users). This won't sustain growth alone but meaningfully reduces CAC.

**Weekly summary cards** are the secondary organic mechanic. Each Monday, users get a shareable weekly summary that shows their consistency score and patterns. Less viral than the chronotype card but maintains ongoing social visibility.

### 14.2 Paid Acquisition

**Channel: Reddit**
- Target: r/biohacking, r/productivity, r/sleep, r/ADHD, r/nootropics
- Creative: "I just found out I've been fighting my chronotype for years. Took this quiz and everything clicked."
- CTA: Link to web quiz (not app store — lower friction)
- Expected CPA: $2-5 per quiz completion, $15-30 per app install

**Channel: Instagram/TikTok**
- Format: Short-form video showing the quiz experience and card share
- Hook: "Your chronotype explains why you crash at 2 PM"
- CTA: Link to web quiz
- Expected CPA: $1-3 per quiz completion

**Channel: Google/Apple Search Ads**
- Keywords: "chronotype quiz," "circadian rhythm app," "when to drink coffee," "sleep schedule optimizer"
- CTA: Direct to App Store (Apple Search Ads) or web quiz (Google)

### 14.3 Content/SEO

**Blog on web domain:**
- "What's your chronotype? The complete guide"
- "Wolf chronotype: your guide to thriving as a night owl"
- "When to drink coffee based on your chronotype"
- "The science behind your 2 PM crash (and how to fix it)"

These are high-intent search terms with moderate competition. The web quiz is the CTA on every blog post.

---

## 15. Retention Mechanics

This is the section that determines whether this is a business or a novelty.

### 15.1 Daily Retention Drivers

| Mechanic | How It Works | Why It Works |
|---|---|---|
| **Adaptive trajectory** | Schedule changes daily based on real sleep data | "It's different today" creates reason to check |
| **Push notifications** | 3 well-timed nudges per day | Brings user back at high-relevance moments |
| **One-tap logging** | Sunlight and caffeine logging | Micro-engagement, builds data, creates habit |
| **Energy state card** | Glanceable "you're in Peak/Dip/Recovery" | Quick value without deep engagement |
| **Caffeine countdown** | Live timer to cutoff | Creates urgency and practical utility |

### 15.2 Weekly Retention Drivers

| Mechanic | How It Works | Why It Works |
|---|---|---|
| **Weekly summary** | Patterns, consistency score, trends | Reward for week's data, shareable |
| **Confidence progression** | "Based on N nights" improving over time | Progress mechanic — "I want to reach high confidence" |
| **Caffeine impact insight** | Shows correlation between late coffee and sleep onset | "Whoa, I really do sleep 20 min later when I have afternoon coffee" |

### 15.3 Monthly Retention Drivers

| Mechanic | How It Works | Why It Works |
|---|---|---|
| **Chronotype recalibration** | Conversational prompt if data diverges | Keeps the product evolving with the user |
| **Seasonal adjustment** | Trajectory shifts with sunrise/sunset changes | Invisible but user notices "my schedule shifted" |
| **Calendar integration** | Daily blocks in their actual calendar | Deeply embedded in workflow, high switching cost |

### 15.4 The Retention Moat

After 30 days of use, we have:
- 30 nights of personalized sleep data informing the trajectory
- Established notification patterns the user relies on
- Calendar blocks embedded in their daily workflow
- A confidence score the user has "earned" over time
- Caffeine and sunlight logging history showing trends

A competitor starting from scratch (including ARC) would ask the user to start over with a quiz. We have a month of real data. That's the moat.

---

## 16. MVP Scope & Phasing

### Phase 0: Web Quiz (Weeks 1-2)
**Ship independently. This is the acquisition engine.**

Deliverables:
- [ ] Landing page with quiz CTA
- [ ] 8-10 question quiz flow
- [ ] Chronotype calculation algorithm
- [ ] Result screen with shareable card generation
- [ ] Email capture with Buttondown/Loops integration
- [ ] SMS text-me-a-link flow (optional, defer if slow)
- [ ] PostHog analytics on full funnel
- [ ] OG image / social card generation
- [ ] Universal link setup for iOS handoff

**Definition of done:** Quiz is live, shareable cards work, email capture flows, we can drive paid traffic to it.

### Phase 1: iOS App Core (Weeks 3-6)
**The minimum viable app.**

Deliverables:
- [ ] Onboarding flow (quiz or web handoff)
- [ ] HealthKit integration (sleep analysis read)
- [ ] Daily trajectory generation (quiz-bootstrapped, data-adaptive)
- [ ] Home screen (energy state + timeline + quick actions)
- [ ] Push notification system (3 default notifications)
- [ ] Caffeine cutoff countdown
- [ ] One-tap sunlight and caffeine logging
- [ ] Confidence indicator
- [ ] Settings screen
- [ ] Subscription paywall (annual only, 7-day trial)
- [ ] Privacy policy on custom domain
- [ ] App Store listing and screenshots

**Definition of done:** App approved on App Store, web quiz deep-links to app, HealthKit pulls sleep data, trajectory adapts after 3+ nights, notifications fire at correct times.

### Phase 2: Intelligence Layer (Weeks 7-10)
**Make the adaptive engine smart.**

Deliverables:
- [ ] Patterns tab with sleep consistency charts
- [ ] Conversational chronotype calibration
- [ ] Caffeine impact analysis
- [ ] Weekly summary generation (shareable)
- [ ] Night shift mode
- [ ] Email nurture sequence (5 emails)

**Definition of done:** Users who've been on the app 2+ weeks see meaningful personalized insights. Conversational calibration fires when data diverges from quiz.

### Phase 3: Integration Layer (Weeks 11-14)
**Embed in daily workflow.**

Deliverables:
- [ ] Apple Calendar export
- [ ] Google Calendar export
- [ ] Apple Watch complication + glance
- [ ] Watch haptic notifications
- [ ] Social jetlag visualization

**Definition of done:** Daily rhythm blocks appear in user's calendar. Watch shows energy state on wrist.

### What's Explicitly NOT in MVP
- Content library / articles / "Intel Drops"
- Social features / friends / accountability
- Android version
- AI coaching or LLM integration
- Meal timing recommendations
- Exercise timing recommendations
- Integration with Oura, Whoop, or other third-party wearables
- B2B / team features

These are all potential roadmap items but they dilute focus. Ship the core loop first: quiz → data → adaptive schedule → notifications → retention.

---

## 17. Key Metrics

### Acquisition (Web Quiz)

| Metric | Target | Measurement |
|---|---|---|
| Quiz start rate | >60% of landing page visitors | PostHog |
| Quiz completion rate | >75% of starts | PostHog |
| Email capture rate | >30% of completions | PostHog |
| Card share rate | >15% of completions | PostHog |
| App install rate (direct) | >10% of completions | PostHog + App Store |
| App install rate (email nurture) | >8% of email captures | Email platform + App Store |
| Viral coefficient | >0.3 | Referral link tracking |

### Activation (iOS App)

| Metric | Target | Measurement |
|---|---|---|
| Onboarding completion | >80% | In-app analytics |
| HealthKit connection rate | >50% | In-app analytics |
| First notification tapped | >40% within 24 hours | Notification log |
| D1 retention | >45% | App Store analytics |
| Trial start rate | >40% of installs | StoreKit |

### Engagement (Weekly)

| Metric | Target | Measurement |
|---|---|---|
| DAU/MAU | >25% | In-app analytics |
| Avg sessions per week | >4 | In-app analytics |
| Sunlight logs per week | >3 per active user | SQLite |
| Notification tap-through rate | >18% | Notification log |
| Patterns tab views per week | >1 per active user | In-app analytics |

### Revenue

| Metric | Target | Measurement |
|---|---|---|
| Trial-to-paid conversion | >15% | StoreKit |
| MRR growth rate | >20% MoM for first 6 months | StoreKit |
| Annual plan take rate | 100% (only plan offered) | StoreKit |
| Subscriber M1 retention | >55% | StoreKit |
| Subscriber M3 retention | >35% | StoreKit |
| Subscriber M12 retention | >20% | StoreKit |

### North Star Metric

**"Adaptive nights"** — the number of nights of HealthKit data informing a user's trajectory. This single metric captures HealthKit adoption, daily engagement, and long-term retention. A user with 30+ adaptive nights is deeply engaged and very unlikely to churn.

---

## 18. Open Questions

### Product
1. **App name?** Need something distinct from "ARC." Should convey rhythm/timing/biology without being too clinical.
2. **Do we need the chronotype animal metaphor?** It's fun and shareable but it's Breus's framework — any IP concerns? (Likely not since it's widely used, but worth checking.)
3. **How aggressive on night shift features in MVP?** It's an underserved market but adds complexity. Lean toward including in Phase 2.
4. **Should the web quiz work on Android too?** Yes — it's a web page. But the "download the app" CTA only has an iOS option initially. We need good UX for Android visitors (email capture, waitlist).

### Technical
5. **Native Swift or React Native?** HealthKit integration and Watch app favor native Swift. But React Native with Expo has HealthKit modules and would speed development. Decision needed.
6. **How to handle the HealthKit "one shot" permission?** Pre-permission screen is specced above, but what conversion rate should we expect? Industry benchmarks for health apps suggest 60-70% grant rate with a good pre-permission screen.
7. **Background refresh reliability?** We need to pull HealthKit data each morning. iOS background app refresh is notoriously unreliable. Fallback: pull data on app launch, which means the trajectory recalculates when you first open the app each day. Acceptable for MVP.
8. **Calendar sync — EventKit or manual .ics export?** EventKit (native iOS calendar API) is better UX but requires additional permissions. Manual .ics export is simpler but less magical.

### Business
9. **Should we offer a lifetime deal?** Could drive early revenue and build a base of committed users. $79.99 one-time? Risk: cannibalizes subscription revenue long-term.
10. **When to pursue Android?** After iOS proves the model (6-12 months) or sooner if web quiz shows significant Android traffic?
11. **Trademark the app name** before launch. Domain acquisition as part of pre-launch.
12. **Should we incorporate user feedback on the web quiz into the product?** E.g., a post-quiz "was this accurate?" question that feeds into our algorithm calibration.

---

*This spec is a working document. It will evolve as we validate assumptions through the web quiz launch and early iOS beta testing. The web quiz is designed to ship and generate data independently — we don't need the iOS app to start learning about our audience.*
