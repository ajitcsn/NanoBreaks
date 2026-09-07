# NanoBreaks Product Requirements Document

**Status:** Draft for implementation  
**Version:** 2.2  
**Date:** 24 August 2026  
**Platform:** macOS 14 or later  
**Product name:** NanoBreaks  
**Tagline:** small breaks for the mind, body, voice, and psyche  
**Naming note:** Preliminary checks found no exact-name productivity app or matching trademark result. The `.com` is registered and the word has older travel and music uses, so formal legal clearance is still required before public release.

## 1. Product vision

Build NanoBreaks as a small, native macOS menu-bar app that turns the workday into a sequence of tiny wins. Every 20 minutes by default, it offers one useful activity that takes 20 to 60 seconds: rest the eyes, move, loosen up, breathe, drink water, solve a playful brain teaser, sing, type, make a rhythm, practice mindfulness, or read an affirmation. Completing it earns points and fills the day's category mix.

NanoBreaks is not a workout program, medical app, meditation course, or productivity system. It is the lightest possible bridge between knowing a small habit is useful and actually doing it while absorbed in work.

All core behavior stays on the Mac. No account, camera, activity surveillance, or internet connection is required.

### Product promise

**Every 20 minutes, NanoBreaks gives you one small thing worth doing and gets out of the way in under a minute.**

### Why build rather than only recommend an existing app

The category is established but fragmented:

- [LookAway](https://lookaway.com/) and [Twenty](https://trytwenty.com/) focus mainly on eye and screen breaks.
- [Stretchly](https://hovancik.net/stretchly/) focuses on configurable microbreaks.
- [MicroReps](https://patakolabs.com/projects/microreps) focuses on sub-one-minute physical exercise.
- [Caesura](https://caesura.rest/) runs separate timers for water, walking, wrists, eyes, posture, and breathing.

NanoBreaks's position is **the varied daily mix**: one timer, one tiny prompt at a time, broad categories, safe personalization, playful brain sparks, and a points system that rewards showing up and trying different kinds of breaks. It should feel more like drawing a useful card from a thoughtfully prepared deck than managing six wellness timers.

This differentiation is credible for an MVP, but the category is busy. Validate reminder tolerance, category appeal, and willingness to keep the app enabled before commercial investment.

## 2. Problem

People who work at a Mac for long periods lose track of time while concentrating. They may intend to look away, stand, move, breathe, or drink water, but each intention is too small and unscheduled to win against the current task. Ordinary notifications are easy to dismiss, while forced full-screen interruptions create resentment and get disabled.

NanoBreaks must make a useful break:

1. hard enough to miss accidentally;
2. gentle enough to keep enabled;
3. short and specific enough to do immediately;
4. varied enough not to become wallpaper;
5. safe and adaptable to the user's space and ability;
6. satisfying enough to repeat throughout the day.

## 3. Product goal

Help screen-heavy Mac users interrupt long periods of static screen work with a sustainable mix of tiny eye, body, mind, hydration, and play breaks.

### Success criteria for the first 30 days after launch

- At least 60% of activated users complete three or more breaks on their first active day.
- At least 35% of activated users return and complete a break on day 7.
- Median completed-break rate is at least 50% of reminders shown.
- At least 40% of users complete activities from three or more categories in their first week.
- Fewer than 15% of reminders are followed by pausing NanoBreaks for the rest of the day.
- Crash-free sessions exceed 99.5%.

These metrics are calculated locally in MVP. If product analytics are added later, they require explicit opt-in and a separate specification.

## 4. Audience

### Primary user

A developer, designer, writer, student, gamer, or office worker who uses a Mac for several hours a day and wants reminders without a wellness dashboard or account.

### Primary job to be done

“When I become absorbed in screen work, give me one small, worthwhile reset I can do immediately, then show me that those tiny actions are adding up.”

### Secondary users

- People who mainly want an eye-break reminder but appreciate occasional variety.
- People who want movement prompts but cannot or do not want to perform floor exercises at work.
- People with ADHD who benefit from a concrete next action, short duration, and immediate closure.

## 5. Product principles

### Calm, not coercive

The popup never covers the whole screen or uses shame. It intentionally takes keyboard focus when it appears so its controls and temporary hotkeys work immediately. Skipping costs no points and breaks no existing streak.

### Action before information

Every reminder contains one instruction and one duration or rep target. It starts automatically after a five-second countdown, then presents one completion action when the timer ends. Background explanation and settings live elsewhere.

### Trust, not surveillance

Completion is honor-based. NanoBreaks never uses the camera, gaze tracking, screen recording, active-window titles, or accessibility monitoring to verify an activity.

### Honest health language

The product distinguishes three levels of language:

- **Supported habit:** “break up sitting,” “change position,” or “rest from screen work.”
- **Low-claim experience:** “take a calm pause,” “play with a puzzle,” or “reset your attention.”
- **Prohibited claim:** prevents disease or injury, corrects vision, reverses myopia, treats dry eye, builds muscle from one-minute sets, improves intelligence, prevents dementia, or guarantees focus or stress reduction.

### Variety with guardrails

Surprise keeps prompts fresh, but suitability beats randomness. The user controls categories, movement level, standing availability, sound, and work schedule. Any activity can be swapped or permanently hidden in two clicks.

## 6. MVP scope

### Included

- Menu-bar-only native macOS app.
- First-run setup in under 45 seconds.
- Adjustable reminder interval from 10 to 120 minutes, default 20.
- Eleven individually enabled categories and 1,000 short activities, with at least 70 in every category.
- Balanced, Eyes-first, Move-more, and Calm-focus presets.
- Seated-only, Quiet-office, and Standard movement modes.
- Small reminder popup with Start, Swap, Eye break, Next, Snooze, and Skip.
- Timed, repetition-based, brain-spark, and interactive writing formats.
- Optional gentle completion sound.
- Immediate category-colored points animation after completion.
- Five user-selectable popup color themes.
- Local points, category variety, daily goal, completed count, and streak.
- Working days and hours.
- Pause for 1 hour, until tomorrow, or indefinitely.
- Exact countdown pause while the Mac is asleep or the screen is locked, including an activity already in progress.
- Launch at login toggle.
- Reduced motion, sound-off, and high-contrast support.
- Local-only settings and progress.
- Signed, notarized universal `.app` inside a drag-to-Applications `.dmg`.

### Explicitly excluded from MVP

- Accounts, cloud sync, leaderboards, social sharing, or purchases.
- Camera-based completion checks.
- Calendar, meeting, video, presentation, or game detection.
- iPhone, iPad, Apple Watch, or Windows companion apps.
- AI-generated exercises or health advice.
- Blue-light filtering or claims about blue-light glasses.
- Diagnostic symptom tracking.
- Forced full-screen breaks.
- Clinician-prescribed convergence or accommodation exercises.
- Personalized exercise prescriptions, calorie estimates, fitness plans, or recovery advice.
- Claims that micro-activities replace recommended weekly physical activity.
- Trivia feeds or remotely generated content.

## 7. Activity system

The UI calls everything an **activity**. “Exercise” is used only inside the Movement category where it is ordinary language.

### 7.1 Eyes

**Purpose:** break continuous near-screen attention and encourage comfortable blinking.  
**Default share:** 12% of the Balanced mix.  
**Clinical review:** optometrist or ophthalmologist before release.

#### Distant gaze

**Default:** enabled  
**Duration:** 20 seconds  
**Prompt:** “Look at something far away, ideally across the room or out a window.”  
**During timer:** “Let the distant object stay soft. Breathe normally.”

The 20-minute/20-second/20-foot pattern is widely recommended by optometry organizations, including the [American Optometric Association](https://www.aoa.org/healthy-eyes/eye-and-vision-conditions/computer-vision-syndrome). Evidence for the exact numbers is limited, so the product describes it as a memorable break rhythm, not a guaranteed treatment.

#### Complete blinks

**Default:** enabled  
**Duration:** 15 seconds  
**Prompt:** “Slowly close and open your eyes five times. Do not squeeze.”  
**During timer:** A quiet five-step visual pulse, with no need to keep looking at it.

Blinking is relevant because reading tasks can reduce blink rate, and recent controlled research reports benefits from blink training for some dry-eye symptoms and tear-film measures. Sources: [blink rate during reading study](https://pubmed.ncbi.nlm.nih.gov/36763349/) and [2025 randomized blinking-exercise trial](https://pubmed.ncbi.nlm.nih.gov/39920919/).

#### Eyes-closed rest

**Default:** enabled  
**Duration:** 30 seconds  
**Prompt:** “Close your eyes gently. Drop your shoulders and take three easy breaths.”

This is a general screen-rest activity. No therapeutic claim is attached to it.

#### Pressure-free palming

**Default:** enabled  
**Duration:** 30 seconds  
**Prompt:** “Close your eyes and cup your palms over them without touching or pressing.”  
**Safety line:** “No pressure on your eyes.”

Palming is included because the user requested it, but its benefit beyond ordinary eyes-closed rest is not established. It must never instruct users to rub their eyes, generate heat, press on the eyeballs, or expect vision improvement.

#### Eye safety rules

- Do not include eye rolling, rapid tracking, pencil push-ups, near-far focusing, or convergence drills in MVP. Some are condition-specific and can worsen symptoms when used without assessment.
- Instructions must remain usable for people with one eye, low vision, glasses, or contact lenses.

### 7.2 Movement

**Purpose:** interrupt sitting with brief, ordinary movement.  
**Default share:** 10% of the Balanced mix.  
**Professional review:** physiotherapist or qualified exercise professional before release.

MVP activities:

- **Wall pushups:** 8 controlled repetitions, 30 to 45 seconds. Use a clear wall, keep the body straight, and do not hold the breath.
- **Calf raises:** 12 controlled repetitions, 30 seconds. Hold a stable support if needed.
- **March in place:** comfortable pace for 45 seconds. A seated march is available.
- **Side steps:** step side to side at a comfortable pace for 45 seconds. Excluded in Seated-only mode.
- **Sit to stand:** 8 repetitions from a stable, non-rolling chair, 30 to 45 seconds. Excluded when the user selects Seated-only.
- **Floor pushups:** 5 to 12 repetitions, 30 to 45 seconds. Available only in Standard mode and disabled by default.

The [WHO physical-activity and sedentary-behavior guidelines](https://www.who.int/publications/i/item/9789240015128) recommend limiting sedentary time and being physically active. The [CDC workplace activity guide](https://www.cdc.gov/workplace-health-promotion/media/pdfs/2024/06/Workplace-Physical-Activity-Break-Guide-508.pdf) supports incorporating activity breaks into workdays and notes that some benefits begin immediately, but its example breaks are longer than NanoBreaks activities. Product copy therefore says these prompts help users move more, not that a single short set produces a specific health outcome or replaces regular exercise.

### 7.3 Mobility and posture change

**Purpose:** vary static desk posture and gently move commonly fixed areas.  
**Default share:** 8% of the Balanced mix.

MVP activities:

- **Shoulder rolls:** five slow rolls backward, then five forward, 30 seconds.
- **Reach tall:** stand or sit tall, reach comfortably upward, release, repeat three times, 30 seconds.
- **Chin reset:** draw the chin gently back without tilting the head, release, repeat five times, 25 seconds.
- **Hands off keyboard:** relax hands, open and close them slowly, then let the arms hang, 30 seconds.
- **Ankle pumps:** seated or standing with support, lift and lower the toes slowly for 30 seconds.
- **Change position:** stand, or choose a different supported sitting position, for 45 seconds.

[OSHA's computer-workstation guidance](https://www.osha.gov/etools/computer-workstations/work-process) recommends short pauses, posture variation, standing, stretching, and movement during prolonged repetitive computer work. Activities must use comfortable ranges, never bouncing, force, or promises to fix pain or posture.

### 7.4 Calm

**Purpose:** provide a brief downshift from cognitive intensity.  
**Default share:** 9% of the Balanced mix.

MVP activities:

- **Longer exhale:** breathe normally and comfortably, letting each exhale run slightly longer, for 60 seconds. No breath holds.
- **Drop tension:** unclench the jaw, lower the shoulders, soften the hands, and take three easy breaths, 30 seconds.
- **Three senses:** notice one thing you can see, hear, and physically feel, 45 seconds.
- **External focus:** choose a neutral object away from the screen and notice its shape, color, and texture for 45 seconds.
- **Quiet count:** close the eyes if comfortable and count four normal breaths, 30 seconds.

Brief paced or mindful breathing has research support, including studies of one-minute interventions, but effects vary and stronger programs generally use repeated multi-minute practice. See this [one-minute just-in-time intervention study](https://pmc.ncbi.nlm.nih.gov/articles/PMC12371293/) and [NHS breathing guidance](https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/breathing-exercises-for-stress/). NanoBreaks must not promise treatment for anxiety or stress.

### 7.5 Hydration

**Purpose:** create an occasional chance to notice thirst or refill a drink.  
**Default share:** 8% of the Balanced mix, capped at one completed prompt every two hours.

MVP activities:

- **Take a few sips:** drink if comfortable and appropriate, 20 seconds.
- **Refill:** refill or fetch a drink, up to 60 seconds.
- **Water check:** notice whether you are thirsty and place a drink within reach, 20 seconds.

Hydration needs differ. The app never prescribes a volume, treats coffee or tea as inherently dehydrating, or prompts through a user-specified fluid restriction. Users following medical fluid advice should follow that advice and disable this category if needed.

### 7.6 Brain sparks

**Purpose:** offer brief play and a change of mental mode.  
**Default share:** 9% of the Balanced mix, capped at three per day.

MVP formats:

- one-line riddle;
- mental arithmetic with adjustable difficulty;
- word scramble;
- next-in-pattern puzzle;
- “name five uses for this object” creativity prompt;
- ten-second memory flash followed by one recall question.

Brain sparks are entertainment and variety, not cognitive treatment. Puzzle research generally studies repeated sessions lasting much longer than 20 to 60 seconds, often in specific populations. A small [pilot randomized study](https://pubmed.ncbi.nlm.nih.gov/37916859/) supports the feasibility of casual puzzle training but does not justify claiming that a single NanoBreaks prompt improves intelligence, memory, or prevents cognitive decline.

### 7.7 Voice

**Purpose:** use the voice, add play, and break the silent-screen pattern.  
**Default share:** 9% of the Balanced mix.

MVP activities include humming a tune, singing one familiar line, a tongue twister, saying the days backward, and reading a sentence in a dramatic narrator voice. Quiet volume counts. Prompts must never encourage shouting, extreme pitch, or continuing through vocal discomfort.

### 7.8 Writing

**Purpose:** create a short, active typing task instead of passive consumption.  
**Default share:** 9% of the Balanced mix.

MVP activities include a six-word story, next tiny action, rapid list, vivid object description, sentence without the letter E, and one-line daily win. The popup provides a real text field. Completion becomes available after 20 to 30 seconds and requires non-empty input. Text remains ephemeral and is never persisted.

### 7.9 Rhythm

**Purpose:** add simple coordination, sound, and physical involvement at the desk.  
**Default share:** 8% of the Balanced mix.

MVP activities include a clap pattern, alternating fingertip taps, thigh drumming, snap-and-clap, and holding a steady beat. Every audible task offers a quiet tap alternative.

### 7.10 Mindfulness

**Purpose:** briefly notice present experience without requiring a meditation session.  
**Default share:** 9% of the Balanced mix.

MVP activities include noticing one complete breath, checking three body areas, finding the farthest sound, naming a current feeling or sensation, and observing one object. Copy invites noticing without promising stress or anxiety treatment.

### 7.11 Affirmations

**Purpose:** offer concise, believable self-directed statements related to effort, attention, and meaningful work.  
**Default share:** 9% of the Balanced mix.

MVP affirmations include “I am working on something important to me right now,” “Small, steady effort counts,” “I can choose the next useful step,” and “My attention can return, gently.” Avoid grandiose, compulsory-positive, medical, financial, or outcome-guaranteeing statements.

### 7.12 Candidate future packs

These expand the vision without entering MVP:

- **Tiny reset:** put one object away, clear one small surface, or write the next single task.
- **Creativity:** tiny drawing, association, observation, or alternate-use prompts.
- **Connection:** write a one-line thank-you or check in with someone, never auto-send.
- **Outdoor:** step to a window, balcony, or safe outdoor spot when the user has time.
- **Custom cards:** user-authored prompts that remain private and carry no health endorsement.

### Universal safety rules

- Settings > About says: “NanoBreaks offers general break ideas, not medical care or a fitness program. Choose only activities that are safe for you and your surroundings. Stop if you feel pain, chest discomfort, dizziness, unusual shortness of breath, or worsening symptoms. Seek appropriate medical help for urgent or persistent symptoms.”
- Before the first Movement activity, show the safety line and require “Show movement prompts.” Declining disables Movement without blocking the rest of the app.
- Do not ask users to disclose diagnoses, weight, age, pregnancy, disability, or injury history.
- Always provide Swap and “Hide this activity.” A skipped or hidden activity has no penalty.
- Activity copy avoids absolutes such as “safe for everyone.”
- Eye content receives clinical review; movement and mobility content receives review from a qualified movement professional before public release.

## 8. Reminder and scheduling behavior

### Default schedule

- Interval: every 20 minutes.
- Active hours: 9:00 a.m. to 6:00 p.m.
- Active days: Monday through Friday.
- Sound: on, low-volume system-like chime.
- Daily goal: 60 points.

### Timer rules

1. The interval starts when the user enables NanoBreaks, completes a break, or skips a break.
2. Snooze delays the current reminder by 5 minutes and does not reset the underlying interval until the reminder is completed or skipped.
3. Only one reminder can be pending. New reminders never stack.
4. Sleep and locked-screen time do not count toward the interval.
5. After wake or unlock, wait at least 60 seconds before showing an overdue reminder.
6. Outside active hours, no reminder appears. The next interval starts at the next active-period boundary.
7. If the user changes the interval, the new interval starts immediately from the change time.
8. A system clock or timezone change recalculates the next due time without generating duplicate reminders.

### Daily Mix rotation

Balanced uses category targets rather than pure randomness:

- Eyes: 12%.
- Movement: 10%.
- Mobility: 8%.
- Calm: 9%.
- Hydration: 8%.
- Brain sparks: 9%.
- Voice: 9%.
- Writing: 9%.
- Rhythm: 8%.
- Mindfulness: 9%.
- Affirmations: 9%.

The selector tracks every task presentation, including tasks later skipped or swapped. It chooses an under-served enabled category relative to its target, then randomly chooses a suitable activity within it. Additional rules:

- Do not repeat a category twice unless fewer than three categories are enabled.
- Do not repeat an individual activity until all suitable activities in that category have appeared.
- Every enabled category has an 8% minimum target and receives priority before its target-relative maximum gap is exceeded.
- A skipped eye task counts as an eye presentation, preventing repeated eye prompts caused by non-completion.
- Hydration appears no more than once every two hours.
- Brain sparks appear no more than three times per day and never twice consecutively.
- Swap selects another suitable activity, preferably from a different category, without counting as a skip.
- Hidden and unsuitable activities are removed before selection.
- At least one category and one activity must remain enabled.
- The popup background automatically follows the selected category. Eyes use red; every other category has its own distinct, accessible color.
- Settings can switch from category-matched colors to a single fixed theme.

Preset weights:

- **Balanced:** the defaults above.
- **Eyes-first:** Eyes 20%; every other category 8%.
- **Move-more:** Movement 16%, Mobility 12%; every other category 8%.
- **Calm-focus:** Calm 16%, Mindfulness 12%; every other category 8%.

## 9. Core experience

### First launch

1. Show: “small breaks for the mind, body, voice, and psyche”
2. Choose a mix: Balanced, Eyes-first, Move-more, or Calm-focus. Balanced is default.
3. Choose movement setup: Seated-only, Quiet-office, or Standard. Quiet-office is default.
4. Confirm the interval, default 20 minutes, and show the one-line safety note.
5. Offer “Start NanoBreaks” and an optional “Launch at login” checkbox, on by default.
6. On completion, close the window and leave the menu-bar item running.

Do not request notification, accessibility, camera, microphone, screen-recording, calendar, or contact permissions.

### Menu-bar popover

The menu-bar icon is a compact `20` inside a partial progress ring. The ring fills toward the next reminder and shows a pause mark while paused.

The popover uses macOS window-style MenuBarExtra presentation at a fixed 380-point content width. Menu-style presentation is prohibited because it flattens custom cards into disabled-looking menu rows and compresses labels.

The popover shows:

- A tinted status card with “Next break in 12:34,” the active break, or the current pause state.
- A restrained daily scorecard: points inside a goal ring, completed breaks, streak days, and points remaining to the goal.
- A compact “Mix” row containing colored badges only for categories completed today. Uncompleted categories are not shown as disabled icons.
- A real seven-day bar chart based on retained daily completion totals, including zero-break days.
- A “Recent tasks” history showing the latest three completed task names, categories, completion times, and awarded points. The local history retains up to 50 entries.
- A directly accessible “Queued task types” picker with a toggle for every category and a visible selected count. Changes apply to future selections, and the final enabled type cannot be turned off.
- Primary action: “Take a break now,” with “Next task” and “Eye break” immediately below it.
- Direct footer actions for Pause or Resume, Settings, and Quit. Quit is never placed alone inside a submenu.

Gamification stays supportive rather than competitive. The popover uses progress, streak, and variety because each maps to an existing healthy behavior. It does not add levels, currencies, leaderboards, loss framing, random rewards, or repeated celebration.

The menu-bar title remains icon-only by default. A setting may show the countdown as text.

### Reminder popup

Display a 320–360 point-wide floating panel near the top-right of the active screen. It is visible across Spaces, activates NanoBreaks, and takes keyboard focus immediately so shortcuts work without a preliminary click.

Content order:

1. Activity name and duration.
2. One-sentence instruction.
3. A visible five-second automatic-start countdown.
4. Hot actions: “Swap,” “Eye break,” and “Next.”
5. Secondary actions: “Snooze 5 min” and “Skip.”
6. An overflow action: “Hide this activity.”

While a due popup is visible, register temporary system hotkeys that need no Accessibility permission:

- `Control-S`: swap to a different category.
- `Control-E`: replace the card with an eye activity.
- `Control-N`: mark the card skipped and show the next task immediately.

Show these keys in the popup. Unregister them as soon as the activity starts, the popup closes, or the app pauses so they never interfere with normal work outside the decision moment.

When the activity timer reaches zero, register `Control-D` for Complete. Show the matching Complete button at the same time. Either action confirms completion and awards points; neither is available before the timer ends.

The panel stays visible until acted on. It may be dragged. Its last screen-relative position is remembered.

### Active break

- The activity starts automatically after the reminder's five-second countdown. No Start click is required.
- Starting a timed break begins a monotonic timer, immune to wall-clock adjustments.
- The popup contracts into a small countdown pill so the screen stops competing for attention.
- At zero, timed and repetition activities show a **Complete** button and enable `Control-D`. Either confirmation awards points immediately; completion is never assumed automatically.
- Rep activities show a suggested count and never use the camera or motion sensors.
- Brain sparks show **Reveal & complete** after 10 seconds. Any answer is self-checked; correctness does not change points.
- Writing activities focus an inline text field when the countdown ends. Typed text is discarded when the card completes, swaps, skips, or closes.
- On completion, immediately play the optional chime and animate the awarded total, category icon, and category name in that category's color. Dismiss after 3 seconds.
- The user can end early. An early end is a skip and awards no points.
- If the Mac sleeps or locks mid-break, cancel the activity without penalty and offer it again 60 seconds after return.

## 10. Points and streaks

Points should reinforce the habit without becoming a second job.

### Rules

- Completed activity: **10 points**.
- On-time bonus: **2 points** when started within 60 seconds of appearing.
- Variety bonus: **2 points** for the first completed activity in each enabled category per day.
- Daily goal: **60 points**, adjustable from 20 to 200 in steps of 10.
- Daily streak: complete at least three activities in a local calendar day.
- Streak protection: weekends or user-disabled days do not break a streak.
- No points are removed for skips, snoozes, pauses, missed days, or quitting.
- No multiplier, currency, store, ranking, loot box, or loss-aversion mechanic.
- Points reset to zero each local day; lifetime completed activities and category totals remain visible in Settings > Progress.

### Integrity

A timed or repetition activity must finish or be explicitly marked Completed; a writing activity needs non-empty input after its minimum window; and a brain spark must reach Reveal. Points are awarded in the same state transition and cannot be replayed. This is intentionally not proof that the activity happened. Since points have no monetary or competitive value, surveillance would cost more trust than it creates integrity.

## 11. Functional requirements

### FR-1: Menu-bar lifecycle

- NanoBreaks launches as an agent app with no Dock icon by default.
- Closing Settings does not quit NanoBreaks.
- Quit is always available from the menu-bar popover.

### FR-2: Persistent scheduling

- Save settings, next scheduled reminder, pause state, and progress after every change.
- Restore correctly after app restart, crash, Mac restart, sleep, and timezone change.
- Never show more than one reminder for a single due event.

### FR-3: Popup placement

- Show on the display containing the pointer at due time.
- Keep the full panel inside that display’s visible frame, below the menu bar and outside the Dock.
- Reposition safely when a display disconnects or its resolution changes.

### FR-4: Preferences

Settings include General, Mix, Activities, Schedule, Progress, Accessibility, and About.

General contains interval, sound, popup color, countdown in menu bar, launch at login, and reset onboarding. Mix contains preset, category weights, and movement mode. Activities contains category toggles, individual activity toggles, hidden activities, plain-language instructions, and safety copy. Schedule contains active days, start/end time, and daily goal. Progress contains today, category mix, current streak, lifetime completed, and “Delete all progress.”

### FR-5: Local data

Store only:

- settings;
- per-day points, category completion counts, completed, skipped, swapped, and snoozed counts;
- current and longest streak;
- lifetime completed count;
- reminder state needed for recovery.

Do not store active app names, typed content, websites, screenshots, or a timestamped history of individual behavior beyond what scheduling requires.

### FR-6: Data deletion

“Delete all progress” requires a confirmation sheet, removes progress and streaks, preserves settings, and is irreversible. “Reset NanoBreaks” removes both progress and settings and returns to onboarding.

### FR-7: Activity catalog

- Every bundled activity declares a stable ID, category, format, duration or rep target, eligible movement modes, instruction, accessibility alternative, and any safety line.
- Activity content is bundled, versioned, and available offline. MVP does not download or generate prompts.
- Swap never returns the same activity and tries another category first.
- “Hide this activity” removes it immediately and exposes an Undo action for 10 seconds.
- Resetting hidden activities restores the shipped catalog without changing progress.

## 12. Non-functional requirements

- **Performance:** under 80 MB steady-state memory and under 1% average CPU while idle on an Apple-silicon Mac.
- **Battery:** no polling loop faster than once per second; prefer system lifecycle notifications and a single next-fire timer.
- **Reliability:** reminder time is within 2 seconds while awake under ordinary load.
- **Startup:** menu-bar item appears within 1 second on a supported Mac.
- **Offline:** every MVP feature works without network access.
- **Privacy:** no telemetry SDK, ads SDK, login, or network entitlement.
- **Compatibility:** universal binary for Apple silicon and Intel, macOS 14+.
- **Localization readiness:** all user-facing copy uses string catalogs; MVP ships in English.
- **Accessibility:** full keyboard navigation, VoiceOver labels, 44-point minimum interactive targets where layout permits, Reduce Motion compliance, sufficient contrast, and no color-only status.

## 13. Technical approach

### App architecture

- Swift 6, SwiftUI, and a small AppKit bridge where native menu-bar or floating-panel behavior requires it.
- `MenuBarExtra` for the status item and popover.
- A borderless `NSPanel` for the reminder, configured to float without becoming key until clicked.
- `SMAppService` for launch at login.
- `NSWorkspace` lifecycle notifications for sleep, wake, lock, and unlock handling.
- `ContinuousClock` or equivalent monotonic timing for an active activity.
- A single `ReminderScheduler` as the source of truth. UI views observe scheduler state; views never own timers.
- Codable local models stored atomically in Application Support. UserDefaults may hold simple UI preferences, but progress uses a versioned data file.

### Suggested modules

- `AppLifecycle`: startup, login-item state, termination, system events.
- `ReminderScheduler`: next due time, snooze, pause, recovery, timezone handling.
- `ActivityEngine`: catalog eligibility, category-debt rotation, safety copy, and activity format.
- `ProgressStore`: points, daily rollover, streaks, migration, reset.
- `MenuBarUI`: status item and popover.
- `ReminderPanel`: due, active, completed, and cancelled states.
- `SettingsUI`: preferences, progress, about, and data deletion.

### Core state machine

`inactive → counting → due → active → completed → counting`

Alternative paths:

- `counting/due → paused → counting`
- `due → snoozed → due`
- `due/active → skipped → counting`
- `any state → sleeping/locked → recovery → counting or due`

Transitions must be centralized and unit-tested to prevent duplicate panels and points.

## 14. Data model

### Settings

```text
reminderIntervalMinutes: Int
activeDays: Set<Weekday>
activeStartMinutes: Int
activeEndMinutes: Int
enabledActivityIDs: Set<String>
enabledCategoryIDs: Set<String>
hiddenActivityIDs: Set<String>
mixPreset: balanced | eyesFirst | moveMore | calmFocus | custom
categoryWeights: Map<CategoryID, Int>
movementMode: seatedOnly | quietOffice | standard
movementConsentShown: Bool
soundEnabled: Bool
menuBarCountdownEnabled: Bool
launchAtLoginEnabled: Bool
dailyPointGoal: Int
lastPopupPosition: Optional<Point>
```

### Daily progress

```text
localDate: YYYY-MM-DD
points: Int
completedCount: Int
skippedCount: Int
snoozedCount: Int
swappedCount: Int
completedByCategory: Map<CategoryID, Int>
awardedVarietyBonusCategoryIDs: Set<String>
goalReached: Bool
```

### Scheduler snapshot

```text
state: inactive | counting | due | snoozed | paused
nextDueAt: Optional<Date>
pauseUntil: Optional<Date>
pendingActivityID: Optional<String>
lastCompletedActivityID: Optional<String>
lastCompletedCategoryID: Optional<String>
lastCompletedAtByCategory: Map<CategoryID, Date>
seenActivityIDsByCategory: Map<CategoryID, Set<String>>
```

All persisted models include a schema version and migration path.

## 15. Acceptance criteria

### Scheduling

- Given a 20-minute interval, an awake and unlocked Mac shows one reminder 20 minutes after the timer starts, within 2 seconds.
- Sleeping for 30 minutes does not consume 30 minutes of the interval.
- Unlocking never produces an immediate popup; the minimum delay is 60 seconds.
- Snoozing three times produces one popup per snooze and no stacked panels.
- Changing timezone near midnight does not award duplicate points or corrupt a streak.

### Completion and points

- Completing a full activity adds 10 points exactly once.
- Starting within 60 seconds adds 2 bonus points exactly once.
- The first completion in each category each day adds 2 variety points exactly once.
- A timed or repetition activity awards points immediately when Completed is clicked, and timed activities also award automatically at zero.
- A writing activity awards only with non-empty input after its minimum window; a brain spark only after Reveal becomes available.
- Brain-spark correctness never changes points.
- Ending early adds no points.
- Reopening or restarting after completion cannot replay the award.
- A streak increments only when the third daily completion finishes.
- An inactive scheduled day leaves the existing streak intact.

### Activity selection and safety

- Eligible categories are selected randomly using the active mix preset as weights. Eye and movement maximum-gap rules, cooldowns, and category caps still take priority.
- Activities are randomized within the chosen category and do not repeat until the unseen pool is exhausted where possible.
- Swapping never returns the same activity and does not count as a skip.
- Seated-only never selects standing, floor, or unsupported movement.
- Quiet-office never selects floor pushups or impact movement.
- Hiding an activity prevents it from being selected after the Undo window expires.
- Declining the first movement safety acknowledgement disables Movement and continues onboarding.

### UI

- Reminder appears on the pointer’s display and remains fully visible.
- Reminder activates and takes focus as soon as it appears.
- `Control-S`, `Control-E`, and `Control-N` work immediately during the automatic-start countdown and are unavailable after it closes or starts.
- When the activity timer reaches zero, one click on Complete or `Control-D` confirms completion and awards points.
- Completion immediately shows the exact points and category with a category-colored animation.
- Coral, Ocean, Forest, Plum, and Graphite settings visibly change the popup background.
- VoiceOver reads the activity, instruction, duration, and each action in logical order.
- Brain sparks work with VoiceOver and never rely only on a visual pattern.
- Reduce Motion replaces pulse or scale animation with static state changes.
- Disconnecting the active external display moves the popup to the main display.

### Privacy and distribution

- A clean install requests no protected-system permission.
- Network inspection shows no outbound connection during normal use.
- The distributed app passes `codesign`, Gatekeeper `spctl`, and notarization validation.
- The stapled `.dmg` installs and launches while the test Mac is offline.

## 16. QA matrix

Test on:

- Apple silicon and Intel hardware.
- macOS 14, 15, and the current public macOS release.
- One display, two displays, display disconnect, Spaces, fullscreen app, and hidden menu bar.
- Light, Dark, increased contrast, reduced motion, VoiceOver, and 200% display scaling.
- Sleep/wake, lock/unlock, logout/login, restart, app crash recovery, and daylight-saving/timezone changes.
- Fresh install, upgrade install, duplicate app copy, and launch directly from the mounted disk image.
- All activity formats, presets, category caps, movement modes, Swap, Hide, and catalog migration.
- Content review against the prohibited-claims list and movement/eye professional sign-off.

## 17. `.dmg` release requirements

The release artifact is `NanoBreaks-x.y.z.dmg` containing `NanoBreaks.app` and an Applications-folder shortcut.

Release pipeline:

1. Build a Release archive with Hardened Runtime enabled and only required entitlements.
2. Export a universal app signed with a **Developer ID Application** certificate.
3. Create the disk image with `hdiutil` or an equivalent reproducible script.
4. Sign the disk image.
5. Submit the outer `.dmg` to Apple’s notary service using `notarytool`.
6. Staple the notarization ticket to the `.dmg`.
7. Verify with `codesign --verify --deep --strict`, `spctl --assess`, `xcrun stapler validate`, and a SHA-256 checksum.
8. Test first launch and upgrade on a separate clean Mac, including offline launch.

Apple requires direct-distribution software to be appropriately signed and recommends notarizing and stapling the shipped container. See [Apple’s packaging guide](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution) and [notarization guide](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

**External dependency:** A public, warning-free `.dmg` requires an active Apple Developer Program team with access to its Developer ID certificate and notarization credentials. Development can produce an unsigned or ad-hoc-signed local `.dmg`, but Gatekeeper will warn users and it does not meet the release definition.

## 18. Risks and mitigations

### Users disable intrusive reminders

Keep the panel small and non-blocking. Make Snooze and Pause obvious. Measure pause-for-day behavior locally during usability testing.

### Gamification encourages fake completion or guilt

Keep points private and valueless. Award only positive feedback. Never punish skipping or missed days.

### A physical prompt is unsafe or unsuitable

Default to Quiet-office movement, gate floor activities behind Standard mode, provide seated alternatives, and keep Swap and Hide immediately available. Require professional content review. Never infer a user's capability from past completion.

### The broad concept loses a clear identity

Keep one memorable promise: one good minute every 20 minutes. Present the category mix as variety inside that promise, not eleven separate products or timers.

### Brain sparks add more screen time

Cap them at three per day, use large high-contrast copy, and keep them optional. Never describe them as an eye break or cognitive treatment.

### Activity novelty wears off

Ship 1,000 reviewed-style activities, avoid repeats until a category deck is exhausted, and measure Hide and Swap rates during testing. Keep the smallest category at 70 or more activities. Add future reviewed content packs only through app updates in MVP.

### Hydration prompts conflict with medical advice

Never prescribe a volume. Cap frequency, use “if appropriate” language, and let the category be disabled during onboarding or Settings.

### Health claims exceed evidence

Maintain the supported, low-claim, and prohibited language levels in Section 5. Disclose that 20-20-20’s exact timing has limited evidence and that micro-activities do not replace normal exercise. Require appropriate content review before public launch. A 2023 systematic review found evidence around digital-eye-strain interventions heterogeneous and highlighted ergonomics and screen duration rather than a single cure: [PubMed review](https://pubmed.ncbi.nlm.nih.gov/36977430/).

### Popup appears at a bad moment

MVP provides one-click snooze and pause. Context-aware meeting/video detection is postponed because it increases complexity, permissions, and false positives.

### Menu-bar space is crowded

Use an icon-only default. Ensure the app is discoverable through Spotlight and provide a preference for a visible countdown.

## 19. Delivery plan

### Milestone 1: Functional core

Native project, menu-bar popover, scheduler state machine, one activity from each category, local persistence, and unit tests.

### Milestone 2: Complete MVP

1,000 activities, Daily Mix rotation, interactive writing, popup hotkeys, immediate eye/next actions, category-matched popup colors, fixed popup themes, category points animation, presets, movement modes, points, streaks, settings, working hours, exact sleep/lock timer suspension, accessibility, and progress reset.

### Milestone 3: Release candidate

Visual polish, icon and DMG presentation, full QA matrix, clinical and movement-content review, privacy copy, signing, notarization, stapling, and clean-Mac verification.

### Definition of done

The MVP is done when all acceptance criteria pass, no P0/P1 defects remain, health copy has been reviewed, and a versioned notarized `.dmg` installs and launches on a clean supported Mac without a Gatekeeper warning.

## 20. Post-MVP candidates

Prioritize only after observing real completion and disablement behavior:

1. Smart deferral during meetings, screen sharing, media, or fullscreen work.
2. Weekly local trend view and exportable CSV.
3. Reviewed Tiny Reset, Creativity, Connection, and Outdoor content packs.
4. Apple Shortcuts actions for pause, resume, and take a break.
5. Optional iCloud sync with explicit consent.
6. User-authored break activities with a safety warning.

Do not prioritize competitive leaderboards, camera verification, or generic wellness features unless user research changes the core product direction.
