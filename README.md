# healthyme

Impulse-control wellness app. A personal check-in companion that combines clinical context with yoga and breathwork so impulsive phone use and unplanned food choices can be interrupted before they stack up through the day.

Source requirements: [Impulse Control Wellness App — Requirements Document](https://docs.google.com/document/d/1Jq9fLpcE3w6SO8wsGnEZ2_p53qYWSsleCzDN7jOF7aw/edit).

Web preview (GitHub Pages, may take a minute after a publish): https://oreon.github.io/healthyme/

## Product vision

A mobile and wearable app that acts as a well-being check-in companion. It is built around a physician, yoga-studio, and biohacker background. It is not a passive reminder list. It gates flagged behaviors behind a short active intervention, then shows progress over time.

Initial impulse categories:

- Compulsive phone usage (user-selected apps)
- Impulsive or unplanned food choices

## Core features

### Periodic check-ins

Default interval is about every 30 minutes, with configurable frequency, waking hours, quiet hours, snooze, and pause. Each check-in offers a short guided action: 10-minute yoga, 10-minute pranayama, a short meditation, or a healthy food suggestion. Content depends on time of day and the health profile.

### Impulse gate

Before a flagged app or a food log, the user completes 1 minute of comfortable Buteyko-style breathing and a brief body-relaxation prompt. Access is then temporary. Users choose which apps participate. An explicit bypass stays available for urgent use and is recorded. Food interception is a voluntary pre-eating check-in. The app cannot physically prevent eating.

### Control Pause tracking

Manual Control Pause at check-ins, with skip. The trend is logged and shown as a self-reported breathing-practice trend. Do not claim that a rising Control Pause proves better physiological health without evidence and clinical review. Pair it with completed pauses, reported hunger, intentional choices, and reduced unwanted app use.

### Health profile

Filters nudges, food suggestions, and activity intensity. Initial conditions and goals: diabetic, hypertension, weight loss, muscle building, healthy weight gain.

### Eating windows

6-hour, 8-hour, and 10-hour windows, plus a custom start and end. The planned window must end at least 2 hours 30 minutes before the chosen bedtime. A longer gap is allowed. Conflicts are explained, never silently rewritten. Timezone changes and windows that cross midnight are supported. Eating reminders coexist with meditation reminders.

### Before-snacking check-in

Photograph the snack and record the reason: hunger, boredom, stress, habit, social eating, or other. Capture a hunger rating and optional note, then the one-minute pause. After the pause, record the decision: eat as planned, change the snack, delay, or skip. Eating when hungry is valid. Store photo, reason, hunger, pause, decision, and timestamp locally. Allow correction or deletion. A photo does not imply nutrition analysis.

### Points

Award points for meditation, yoga, exercise, a completed impulse pause, and a chosen habit. Configurable deductions only for user-confirmed unwanted behaviors, such as snacking without hunger or purposeless phone use. Each event stores reason, timestamp, and linked activity. Daily totals persist across restarts. Users can undo entries. Do not deduct points from a photo alone, from eating outside a window, or from sleep duration. Exact point values are still TBD.

### On-device coaching

A small on-device model for habit coaching. Inference must not call an external AI API. Local history personalizes prompts and stays separate from model weights. Any upload for training requires explicit opt-in. Coaching must work offline without that consent. Model output must not override health-profile rules. If inference fails, offer the basic guided actions and say AI coaching is unavailable.

### Sleep

A Sleep hub for falling asleep and winding down. Bedtime mode reduces light, interaction, and pressure to hit a sleep score. Users set bedtime and wake time. At bedtime, a configurable alarm says to stop and go to bed. Wake is a gentle alarm. Eating-window end is shown against the 2-hour-30-minute buffer. Spoken content uses device text-to-speech, split into resumable sections. Native apps must keep playback going with the screen locked. Web playback depends on the browser and is not advertised as background audio until tested. No points for sleep duration or sleep score. Persistent insomnia gets a CBT-I pathway or referral, not stories alone.

### Fasting clock

Elapsed time from the last user-confirmed caloric intake, hour by hour, with the next eating window. Water does not reset the timer. Logged eating does. Milestone cards are optional and must not claim autophagy or a measured hormone surge. Fasting prompts follow the health profile. Users on insulin or medicines that can cause hypoglycemia need safety guidance before fasting features are enabled.

### Five pillars

Fasting, exercise, diet, sleep, and meditation. Show chosen actions and trends. Do not collapse them into one health score.

Existing screens to keep: lower- and upper-body strength, yoga, pranayama, kickboxing, Kegel, facial exercise, body scan, breath, walking, eating meditation, loving-kindness, and box breathing. Add cardio and grease-the-groove only if those screens do not already cover them.

### Help Me

Always available from home, one tap, no points or diary required. Choices: strong emotion, help me sleep, help me focus, other needs. Durations of 1, 3, and 10 minutes, text and optional speech, stop and skip.

Emotion paths stay distinct: panic or anxiety (grounding, unforced breathing, option to contact someone), anger (pause before acting), worry (one next step or park it), remorse (self-compassion and one repair), grief (validate, grounding, optional contact), other (grounding and a chosen next step). If someone indicates immediate danger or intent to harm themselves or others, show local emergency and crisis options and a way to contact a trusted person. Do not treat that as a routine exercise.

## Platform

- Flutter codebase for iOS, Android, and GitHub Pages web. Validate each platform separately.
- Phone app is the full MVP. Wear OS and Apple Watch come after, limited to the check-in nudge, the 1-minute gate, and Control Pause logging.
- Do not assume the phone can block other apps until iOS and Android permissions are validated.
- Spoken guides use text-to-speech instead of large bundled audio files.

## Build order

1. Stabilize logging, score persistence, task completion, and reminders.
2. Phone MVP: check-ins, impulse gate, Control Pause, health profile, eating windows, snack check-in, points, on-device model.
3. Founder daily use, including offline, restart, reminder coexistence, and bypass.
4. Evaluated model updates only with consent.
5. Wearable companion.
6. Deeper clinical personalization and the food library.

## Acceptance checks

- An eating window calculates correctly across midnight and timezone changes, and saving it does not cancel other reminders.
- Snack check-ins keep photo, reason, hunger, and outcome after restart. Users can edit or delete them.
- Points survive restart and are not duplicated by repeated submission.
- The gate completes a one-minute intervention and then grants the configured access. Bypass stays available.
- Coaching runs with the network off. History is not sent to an external API.
- Control Pause trends are shown without unvalidated health claims.
- From home, Help Me starts in one tap, works offline, and can be left without logging.

## Current web preview status

The Pages build skips native notifications, stores logs in the browser, plays a completion chime, and speaks body scan as nine slow cues. Score is 10 points per finished task today. Notifications, background tasks, app blocking, Control Pause, and the on-device model are not in that preview.

## Open questions

Flagged-app list, Control Pause protocol, exact point values, model license and device budget, interception permissions, privacy retention and export, monetization, and fundraising timeline are not decided.
