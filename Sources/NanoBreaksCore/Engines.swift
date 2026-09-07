import Foundation

public enum SchedulerEngine {
    public static func started(now: Date, intervalMinutes: Int) -> SchedulerSnapshot {
        var snapshot = SchedulerSnapshot()
        snapshot.state = .counting
        snapshot.nextDueAt = now.addingTimeInterval(TimeInterval(intervalMinutes * 60))
        return snapshot
    }

    public static func isDue(_ snapshot: SchedulerSnapshot, now: Date) -> Bool {
        guard snapshot.state == .counting || snapshot.state == .snoozed,
              let nextDueAt = snapshot.nextDueAt else { return false }
        return now >= nextDueAt
    }

    public static func snoozed(_ snapshot: SchedulerSnapshot, now: Date, minutes: Int = 5) -> SchedulerSnapshot {
        var copy = snapshot
        copy.state = .snoozed
        copy.nextDueAt = now.addingTimeInterval(TimeInterval(minutes * 60))
        return copy
    }

    public static func reset(_ snapshot: SchedulerSnapshot, now: Date, intervalMinutes: Int) -> SchedulerSnapshot {
        var copy = snapshot
        copy.state = .counting
        copy.nextDueAt = now.addingTimeInterval(TimeInterval(intervalMinutes * 60))
        copy.pauseUntil = nil
        copy.pendingActivityID = nil
        return copy
    }

    public static func shiftedAfterInactivity(
        _ snapshot: SchedulerSnapshot,
        inactiveDuration: TimeInterval,
        resumedAt: Date
    ) -> SchedulerSnapshot {
        var copy = snapshot
        if let due = copy.nextDueAt {
            copy.nextDueAt = due.addingTimeInterval(max(0, inactiveDuration))
        }
        return copy
    }
}

public enum ActivitySelectionEngine {
    public static func select(
        catalog: [ActivityDefinition] = ActivityCatalog.all,
        settings: AppSettings,
        progress: DailyProgress,
        scheduler: SchedulerSnapshot,
        now: Date,
        seed: Int? = nil
    ) -> ActivityDefinition? {
        var eligible = catalog.filter {
            settings.enabledCategories.contains($0.category) &&
            !settings.hiddenActivityIDs.contains($0.id) &&
            $0.movementModes.contains(settings.movementMode)
        }

        guard !eligible.isEmpty else { return nil }
        let entropy = seed ?? Int.random(in: 0...Int.max)

        let categories = Set(eligible.map(\.category))
        let capped = categories.filter { category in
            if category == .hydration,
               let last = scheduler.lastCompletedAtByCategory[.hydration],
               now.timeIntervalSince(last) < 2 * 60 * 60 { return false }
            if category == .brain, progress.completedByCategory[.brain, default: 0] >= 3 { return false }
            return true
        }
        let availableCategories = capped.isEmpty ? categories : capped

        var choices = availableCategories
        if choices.count >= 3, let last = scheduler.lastPresentedCategoryID {
            choices.remove(last)
        }
        let chosenCategory = fairCategory(
            in: choices.isEmpty ? availableCategories : choices,
            settings: settings,
            scheduler: scheduler,
            entropy: entropy
        )

        eligible = eligible.filter { $0.category == chosenCategory }
        let unseen = eligible.filter { !scheduler.seenActivityIDsByCategory[chosenCategory, default: []].contains($0.id) }
        let unseenOrAll = unseen.isEmpty ? eligible : unseen
        let withoutImmediateRepeat = unseenOrAll.filter {
            $0.id != scheduler.pendingActivityID && $0.id != scheduler.lastCompletedActivityID
        }
        let pool = withoutImmediateRepeat.isEmpty ? unseenOrAll : withoutImmediateRepeat
        guard !pool.isEmpty else { return nil }
        let activityEntropy = entropy &* 1_103_515_245 &+ 12_345
        return pool[positiveModulo(activityEntropy, pool.count)]
    }

    private static func fairCategory(
        in categories: Set<ActivityCategory>,
        settings: AppSettings,
        scheduler: SchedulerSnapshot,
        entropy: Int
    ) -> ActivityCategory {
        let ordered = ActivityCategory.allCases.filter(categories.contains)
        guard !ordered.isEmpty else { return .eyes }
        let weights = settings.mixPreset.weights
        let weightTotal = max(1, ordered.reduce(0) { $0 + max(1, weights[$1, default: 1]) })

        let overdue = ordered.filter { category in
            let weight = max(1, weights[category, default: 1])
            let maximumGap = max(2, weightTotal / weight)
            let lastSequence = scheduler.lastPresentedSequenceByCategory[category, default: 0]
            return scheduler.presentedCount - lastSequence >= maximumGap - 1
        }
        if !overdue.isEmpty {
            let mostOverdue = overdue.max { left, right in
                overdueRatio(left, weights: weights, weightTotal: weightTotal, scheduler: scheduler) <
                overdueRatio(right, weights: weights, weightTotal: weightTotal, scheduler: scheduler)
            }!
            let tied = overdue.filter {
                abs(
                    overdueRatio($0, weights: weights, weightTotal: weightTotal, scheduler: scheduler) -
                    overdueRatio(mostOverdue, weights: weights, weightTotal: weightTotal, scheduler: scheduler)
                ) < 0.000_1
            }
            return tied[positiveModulo(entropy, tied.count)]
        }

        let totalPresented = ordered.reduce(0) {
            $0 + scheduler.presentedByCategory[$1, default: 0]
        }
        let debts = Dictionary(uniqueKeysWithValues: ordered.map { category in
            let expected = Double(totalPresented + 1) * Double(max(1, weights[category, default: 1])) / Double(weightTotal)
            return (category, expected - Double(scheduler.presentedByCategory[category, default: 0]))
        })
        let maximumDebt = debts.values.max() ?? 0
        let nearLeaders = ordered.filter { debts[$0, default: 0] >= maximumDebt - 0.15 }
        return nearLeaders[positiveModulo(entropy, nearLeaders.count)]
    }

    private static func overdueRatio(
        _ category: ActivityCategory,
        weights: [ActivityCategory: Int],
        weightTotal: Int,
        scheduler: SchedulerSnapshot
    ) -> Double {
        let weight = max(1, weights[category, default: 1])
        let maximumGap = max(2, weightTotal / weight)
        let lastSequence = scheduler.lastPresentedSequenceByCategory[category, default: 0]
        return Double(scheduler.presentedCount - lastSequence + 1) / Double(maximumGap)
    }

    private static func positiveModulo(_ value: Int, _ modulus: Int) -> Int {
        Int(value.magnitude % UInt(modulus))
    }

}

public struct CompletionAward: Equatable, Sendable {
    public let points: Int
    public let varietyBonus: Bool
}

public enum ProgressEngine {
    public static func complete(
        category: ActivityCategory,
        startedOnTime: Bool,
        now: Date,
        settings: AppSettings,
        state: inout ProgressState,
        calendar: Calendar = .autoupdatingCurrent
    ) -> CompletionAward {
        rollDayIfNeeded(now: now, state: &state, calendar: calendar)
        let variety = !state.today.awardedVarietyBonusCategories.contains(category)
        let points = 10 + (startedOnTime ? 2 : 0) + (variety ? 2 : 0)

        state.today.points += points
        state.today.completedCount += 1
        state.today.completedByCategory[category, default: 0] += 1
        state.today.goalReached = state.today.points >= settings.dailyPointGoal
        state.today.awardedVarietyBonusCategories.insert(category)
        state.lifetimeCompleted += 1
        state.lifetimeByCategory[category, default: 0] += 1

        if state.today.completedCount == 3 {
            let todayKey = DateKey.localDay(for: now, calendar: calendar)
            let previousKey = previousActiveDay(before: now, activeDays: settings.activeDays, calendar: calendar)
            state.currentStreak = state.lastStreakDate == previousKey ? state.currentStreak + 1 : 1
            state.longestStreak = max(state.longestStreak, state.currentStreak)
            state.lastStreakDate = todayKey
        }
        return CompletionAward(points: points, varietyBonus: variety)
    }

    public static func rollDayIfNeeded(
        now: Date,
        state: inout ProgressState,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let key = DateKey.localDay(for: now, calendar: calendar)
        if state.today.localDate != key {
            if hasActivity(state.today) {
                state.dailyHistory.removeAll { $0.localDate == state.today.localDate }
                state.dailyHistory.append(state.today)
                state.dailyHistory.sort { $0.localDate < $1.localDate }
                state.dailyHistory = Array(state.dailyHistory.suffix(35))
            }
            state.today = DailyProgress(localDate: key)
        }
    }

    public static func recordCompletion(
        activity: ActivityDefinition,
        points: Int,
        now: Date,
        state: inout ProgressState
    ) {
        state.recentCompletions.append(TaskCompletionRecord(
            activityID: activity.id,
            title: activity.title,
            category: activity.category,
            points: points,
            completedAt: now
        ))
        state.recentCompletions = Array(state.recentCompletions.suffix(50))
    }

    private static func hasActivity(_ day: DailyProgress) -> Bool {
        day.completedCount > 0 || day.skippedCount > 0 || day.snoozedCount > 0 || day.swappedCount > 0
    }

    private static func previousActiveDay(before date: Date, activeDays: Set<Int>, calendar: Calendar) -> String? {
        var candidate = date
        for _ in 0..<8 {
            guard let day = calendar.date(byAdding: .day, value: -1, to: candidate) else { return nil }
            candidate = day
            if activeDays.contains(calendar.component(.weekday, from: day)) {
                return DateKey.localDay(for: day, calendar: calendar)
            }
        }
        return nil
    }
}
