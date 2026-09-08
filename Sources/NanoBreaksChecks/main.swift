import Foundation
import NanoBreaksCore

private var failureCount = 0

@MainActor
private func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if condition() {
        print("PASS  \(message)")
    } else {
        failureCount += 1
        print("FAIL  \(message)")
    }
}

@MainActor
private func checkCatalog() {
    expect(ActivityCatalog.all.count == 1_000, "catalog contains 1,000 activities")
    expect(Set(ActivityCatalog.all.map(\.id)).count == 1_000, "activity IDs are unique")
    expect(Set(ActivityCatalog.all.map(\.title)).count == 1_000, "activity titles are unique")
    expect(Set(ActivityCatalog.all.map(\.category)) == Set(ActivityCategory.allCases), "all eleven categories are represented")
    let expectedCounts: [ActivityCategory: Int] = [
        .eyes: 70, .movement: 80, .mobility: 80, .calm: 95, .hydration: 70,
        .brain: 120, .voice: 100, .writing: 120, .rhythm: 85,
        .mindfulness: 95, .affirmations: 85
    ]
    expect(expectedCounts.allSatisfy { category, count in
        ActivityCatalog.all.filter { $0.category == category }.count == count
    }, "category distribution matches the reviewed 1,000-task mix")
    expect(ActivityCategory.allCases.allSatisfy { category in
        ActivityCatalog.all.filter { $0.category == category }.count >= 45
    }, "every category has at least 70 activities")
    expect(ActivityCatalog.all.allSatisfy {
        !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !$0.instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }, "every activity has complete display copy")
    expect(ActivityCatalog.all.allSatisfy { (10...60).contains($0.format.minimumSeconds) }, "activities stay within the short-break timing boundary")
    expect(ActivityCatalog.all.filter { $0.category == .writing }.allSatisfy {
        if case .writing = $0.format { return true }
        return false
    }, "every writing activity uses the interactive writing format")
    expect(ActivityCatalog.all.filter { $0.category == .brain }.allSatisfy { $0.answer != nil }, "every brain activity includes a reveal answer")
}

@MainActor
private func checkMovementModes() {
    var settings = AppSettings()
    settings.enabledCategories = [.movement]
    settings.movementMode = .seatedOnly
    let progress = DailyProgress(localDate: "2026-08-24")
    let scheduler = SchedulerSnapshot()

    let results = (0..<20).compactMap {
        ActivitySelectionEngine.select(
            settings: settings,
            progress: progress,
            scheduler: scheduler,
            now: Date(),
            seed: $0
        )
    }
    expect(!results.isEmpty, "seated mode still has eligible movement")
    expect(results.allSatisfy { $0.movementModes.contains(.seatedOnly) }, "seated mode excludes standing-only movement")
    expect(results.allSatisfy { $0.id != "movement.floor-pushups" }, "seated mode excludes floor pushups")
}

@MainActor
private func checkCustomActivities() {
    let custom = CustomActivity(
        category: .calm,
        title: "Desk reset",
        instruction: "Put one item back where it belongs.",
        seconds: 5
    )
    expect(custom.seconds == 20, "custom activities keep the short-break minimum")
    expect(
        custom.definition.id.hasPrefix("custom.") &&
        custom.definition.category == .calm &&
        custom.definition.format.minimumSeconds == 20,
        "custom activities become normal selectable activities"
    )

    var settings = AppSettings()
    settings.enabledCategories = [.calm]
    settings.customActivities = [custom]
    let selected = ActivitySelectionEngine.select(
        catalog: [custom.definition],
        settings: settings,
        progress: DailyProgress(localDate: "2026-09-08"),
        scheduler: SchedulerSnapshot(),
        now: Date(),
        seed: 1
    )
    expect(selected?.id == custom.definition.id, "custom activities enter the normal rotation")
}

@MainActor
private func checkCategoryCadence() {
    let settings = AppSettings()
    let progress = DailyProgress(localDate: "2026-08-24")
    var scheduler = SchedulerSnapshot()
    let now = Date()
    scheduler.presentedCount = 7
    scheduler.presentedByCategory = [.movement: 1, .mobility: 1, .calm: 1, .brain: 1, .voice: 1, .writing: 1, .mindfulness: 1]
    scheduler.lastPresentedSequenceByCategory = [.movement: 1, .mobility: 2, .calm: 3, .brain: 4, .voice: 5, .writing: 6, .mindfulness: 7]

    let selected = ActivitySelectionEngine.select(
        settings: settings,
        progress: progress,
        scheduler: scheduler,
        now: now,
        seed: 0
    )
    expect(selected?.category == .eyes, "eyes appear by the eighth queued task")

    var shownScheduler = SchedulerSnapshot()
    shownScheduler.presentedCount = 1
    shownScheduler.presentedByCategory = [.eyes: 1]
    shownScheduler.lastPresentedCategoryID = .eyes
    shownScheduler.lastPresentedSequenceByCategory = [.eyes: 1]
    shownScheduler.lastCompletedAtByCategory[.eyes] = .distantPast
    var twoCategorySettings = AppSettings()
    twoCategorySettings.enabledCategories = [.eyes, .writing]
    let afterShownEye = ActivitySelectionEngine.select(
        settings: twoCategorySettings,
        progress: progress,
        scheduler: shownScheduler,
        now: now,
        seed: 0
    )
    expect(afterShownEye?.category == .writing, "a shown eye task counts even when it was not completed")
}

@MainActor
private func checkLongRunCategoryMix() {
    let settings = AppSettings()
    var scheduler = SchedulerSnapshot()
    var counts: [ActivityCategory: Int] = [:]
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let firstDay = calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 9))!
    let breaksPerDay = 27
    let workdays = 200

    for day in 0..<workdays {
        let dayStart = calendar.date(byAdding: .day, value: day, to: firstDay)!
        var progress = DailyProgress(localDate: DateKey.localDay(for: dayStart, calendar: calendar))

        for breakIndex in 0..<breaksPerDay {
            let now = dayStart.addingTimeInterval(TimeInterval(breakIndex * 20 * 60))
            let sequence = UInt64(day * breaksPerDay + breakIndex + 1)
            let seed = Int(truncatingIfNeeded: sequence &* 0x9E37_79B9_7F4A_7C15)
            guard let activity = ActivitySelectionEngine.select(
                settings: settings,
                progress: progress,
                scheduler: scheduler,
                now: now,
                seed: seed
            ) else {
                failureCount += 1
                print("FAIL  long-run category simulation always finds an activity")
                return
            }

            counts[activity.category, default: 0] += 1
            progress.completedCount += 1
            progress.completedByCategory[activity.category, default: 0] += 1
            scheduler.presentedCount += 1
            scheduler.presentedByCategory[activity.category, default: 0] += 1
            scheduler.lastPresentedCategoryID = activity.category
            scheduler.lastPresentedSequenceByCategory[activity.category] = scheduler.presentedCount
            scheduler.lastCompletedActivityID = activity.id
            scheduler.lastCompletedCategoryID = activity.category
            scheduler.lastCompletedAtByCategory[activity.category] = now
            scheduler.seenActivityIDsByCategory[activity.category, default: []].insert(activity.id)
        }
    }

    let total = workdays * breaksPerDay
    let mix = ActivityCategory.allCases.map { category in
        let percentage = 100 * Double(counts[category, default: 0]) / Double(total)
        return "\(category.title) \(String(format: "%.1f%%", percentage))"
    }.joined(separator: ", ")
    print("INFO  simulated default mix over \(total) completed breaks: \(mix)")
    expect(counts.values.reduce(0, +) == total, "long-run category simulation accounts for every break")
    expect(ActivityCategory.allCases.allSatisfy {
        Double(counts[$0, default: 0]) / Double(total) >= 0.08
    }, "every category reaches at least eight percent of the effective default mix")

    expect(MixPreset.allCases.allSatisfy { preset in
        preset.weights.values.reduce(0, +) == 100 &&
        ActivityCategory.allCases.allSatisfy { preset.weights[$0, default: 0] >= 8 }
    }, "every mix preset keeps an eight-percent floor")
}

@MainActor
private func checkHydrationCooldown() {
    var settings = AppSettings()
    settings.enabledCategories = [.hydration, .calm]
    var progress = DailyProgress(localDate: "2026-08-24")
    progress.completedByCategory[.calm] = 20
    var scheduler = SchedulerSnapshot()
    let now = Date()
    scheduler.lastCompletedAtByCategory[.hydration] = now.addingTimeInterval(-60)
    scheduler.lastCompletedAtByCategory[.eyes] = now
    scheduler.lastCompletedAtByCategory[.movement] = now
    scheduler.lastCompletedAtByCategory[.mobility] = now

    let selected = ActivitySelectionEngine.select(
        settings: settings,
        progress: progress,
        scheduler: scheduler,
        now: now,
        seed: 0
    )
    expect(selected?.category == .calm, "hydration is excluded during its two-hour cooldown")
}

@MainActor
private func checkRandomizedTaskOrder() {
    var settings = AppSettings()
    settings.enabledCategories = [.calm, .voice, .writing]
    let progress = DailyProgress(localDate: "2026-08-24")
    var scheduler = SchedulerSnapshot()
    let now = Date()
    scheduler.lastCompletedAtByCategory[.eyes] = now
    scheduler.lastCompletedAtByCategory[.movement] = now
    scheduler.lastCompletedAtByCategory[.mobility] = now

    let categories = Set((0..<100).compactMap {
        ActivitySelectionEngine.select(
            settings: settings,
            progress: progress,
            scheduler: scheduler,
            now: now,
            seed: $0
        )?.category
    })
    expect(categories.count == 3, "task selection randomizes across eligible categories")

    settings.enabledCategories = [.voice]
    scheduler.pendingActivityID = "voice.hum"
    let selections = (0..<30).compactMap {
        ActivitySelectionEngine.select(
            settings: settings,
            progress: progress,
            scheduler: scheduler,
            now: now,
            seed: $0
        )
    }
    expect(selections.allSatisfy { $0.id != scheduler.pendingActivityID }, "random selection avoids the task currently being replaced")
    expect(Set(selections.map(\.id)).count > 1, "random selection varies activities within a category")
}

@MainActor
private func checkPoints() {
    let now = Date()
    let settings = AppSettings()
    var state = ProgressState(today: DailyProgress(localDate: DateKey.localDay(for: now)))
    let first = ProgressEngine.complete(
        category: .eyes,
        startedOnTime: true,
        now: now,
        settings: settings,
        state: &state
    )
    let second = ProgressEngine.complete(
        category: .eyes,
        startedOnTime: false,
        now: now,
        settings: settings,
        state: &state
    )
    expect(first.points == 14 && first.varietyBonus, "first on-time category completion earns 14 points")
    expect(second.points == 10 && !second.varietyBonus, "repeat category completion earns 10 base points")
    expect(state.today.points == 24 && state.lifetimeCompleted == 2, "daily and lifetime totals update once")
}

@MainActor
private func checkSleepShift() {
    let start = Date(timeIntervalSinceReferenceDate: 1_000)
    let snapshot = SchedulerEngine.started(now: start, intervalMinutes: 20)
    let sleepStarted = start.addingTimeInterval(420)
    let resumed = sleepStarted.addingTimeInterval(7_200)
    let shifted = SchedulerEngine.shiftedAfterInactivity(
        snapshot,
        inactiveDuration: resumed.timeIntervalSince(sleepStarted),
        resumedAt: resumed
    )
    expect(shifted.nextDueAt == resumed.addingTimeInterval(780), "sleep preserves the exact 13 minutes remaining")
    expect(shifted.nextDueAt!.timeIntervalSince(resumed) == 780, "closed-lid time does not consume the reminder interval")
}

@MainActor
private func checkTimerRestart() {
    let completionTime = Date(timeIntervalSinceReferenceDate: 20_000)
    var dueSnapshot = SchedulerSnapshot()
    dueSnapshot.state = .due
    dueSnapshot.pendingActivityID = "eyes.distant-gaze"

    let restarted = SchedulerEngine.reset(dueSnapshot, now: completionTime, intervalMinutes: 20)
    expect(restarted.state == .counting, "completion restarts the scheduler in counting state")
    expect(restarted.nextDueAt == completionTime.addingTimeInterval(1_200), "completion schedules the next break for the full interval")
    expect(restarted.pendingActivityID == nil, "completion clears the previous pending task")
}

@MainActor
private func checkProgressHistory() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let yesterday = calendar.date(from: DateComponents(year: 2026, month: 8, day: 23, hour: 12))!
    let today = calendar.date(from: DateComponents(year: 2026, month: 8, day: 24, hour: 12))!
    var previousDay = DailyProgress(localDate: DateKey.localDay(for: yesterday, calendar: calendar))
    previousDay.completedCount = 4
    previousDay.points = 48
    var state = ProgressState(today: previousDay)

    ProgressEngine.rollDayIfNeeded(now: today, state: &state, calendar: calendar)
    expect(state.dailyHistory.count == 1, "day rollover retains the previous daily summary")
    expect(state.dailyHistory.first?.completedCount == 4, "weekly history retains completed-break counts")
    expect(state.today.localDate == DateKey.localDay(for: today, calendar: calendar), "day rollover starts a fresh current day")

    let activity = ActivityCatalog.all[0]
    for offset in 0..<55 {
        ProgressEngine.recordCompletion(
            activity: activity,
            points: 10,
            now: today.addingTimeInterval(TimeInterval(offset)),
            state: &state
        )
    }
    expect(state.recentCompletions.count == 50, "task history keeps the latest 50 completions")

    let encoded = try! JSONEncoder().encode(state)
    var legacyObject = try! JSONSerialization.jsonObject(with: encoded) as! [String: Any]
    legacyObject.removeValue(forKey: "dailyHistory")
    legacyObject.removeValue(forKey: "recentCompletions")
    let legacyData = try! JSONSerialization.data(withJSONObject: legacyObject)
    let decoded = try! JSONDecoder().decode(ProgressState.self, from: legacyData)
    expect(decoded.dailyHistory.isEmpty && decoded.recentCompletions.isEmpty, "older saved progress loads without history fields")
}

@MainActor
private func checkPopupColorCompatibility() {
    let settings = AppSettings()
    expect(settings.popupColorMode == .category, "new installs match popup colors to task categories")

    let encoded = try! JSONEncoder().encode(settings)
    var legacyObject = try! JSONSerialization.jsonObject(with: encoded) as! [String: Any]
    legacyObject.removeValue(forKey: "popupColorMode")
    legacyObject.removeValue(forKey: "customActivities")
    let legacyData = try! JSONSerialization.data(withJSONObject: legacyObject)
    let decoded = try! JSONDecoder().decode(AppSettings.self, from: legacyData)
    expect(
        decoded.popupColorMode == nil && decoded.customActivities == nil,
        "older saved settings load without optional new preferences"
    )
}

@MainActor
private func checkSchedulerCompatibility() {
    let encoded = try! JSONEncoder().encode(SchedulerSnapshot())
    var legacyObject = try! JSONSerialization.jsonObject(with: encoded) as! [String: Any]
    legacyObject.removeValue(forKey: "presentedCount")
    legacyObject.removeValue(forKey: "presentedByCategory")
    legacyObject.removeValue(forKey: "lastPresentedCategoryID")
    legacyObject.removeValue(forKey: "lastPresentedSequenceByCategory")
    let legacyData = try! JSONSerialization.data(withJSONObject: legacyObject)
    let decoded = try! JSONDecoder().decode(SchedulerSnapshot.self, from: legacyData)
    expect(decoded.presentedCount == 0 && decoded.presentedByCategory.isEmpty, "older saved schedulers load with fresh presentation tracking")
}

checkCatalog()
checkMovementModes()
checkCustomActivities()
checkCategoryCadence()
checkLongRunCategoryMix()
checkHydrationCooldown()
checkRandomizedTaskOrder()
checkPoints()
checkSleepShift()
checkTimerRestart()
checkProgressHistory()
checkPopupColorCompatibility()
checkSchedulerCompatibility()

if failureCount > 0 {
    print("\n\(failureCount) check(s) failed")
    exit(1)
}

print("\nAll core checks passed")
