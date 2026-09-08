import AppKit
import Combine
import ServiceManagement
import NanoBreaksCore

enum BreakPhase: Equatable {
    case due
    case active
    case completed
}

struct WeeklyBreakCount: Identifiable {
    let localDate: String
    let date: Date
    let count: Int
    let isToday: Bool

    var id: String { localDate }
}

private let automaticStartDelaySeconds = 5

private enum SystemSuspensionReason: Hashable {
    case sleep
    case lockedSession
}

@MainActor
final class AppModel: NSObject, ObservableObject {
    @Published var settings: AppSettings
    @Published var progress: ProgressState
    @Published var scheduler: SchedulerSnapshot
    @Published var currentActivity: ActivityDefinition?
    @Published var breakPhase = BreakPhase.due
    @Published var autoStartCountdown = automaticStartDelaySeconds
    @Published var remainingSeconds = 0
    @Published var revealAvailable = false
    @Published var writingText = ""
    @Published var lastAward = 0
    @Published var lastHiddenActivity: ActivityDefinition?
    @Published var launchAtLoginError: String?
    @Published private(set) var clockNow = Date()

    private let store = PersistenceStore()
    private var tickTimer: Timer?
    private var activityTimer: Timer?
    private var suspensionStartedAt: Date?
    private var suspensionReasons: Set<SystemSuspensionReason> = []
    private var reminderAppearedAt: Date?
    private var currentStartedOnTime = false
    private var panelController: ReminderPanelController!
    private var onboardingController: OnboardingWindowController!
    private var hotKeyManager: PopupHotKeyManager!

    override init() {
        let now = Date()
        if let saved = store.load() {
            var loadedSettings = saved.settings
            if saved.schemaVersion < 2 {
                loadedSettings.enabledCategories.formUnion([.voice, .writing, .rhythm])
            }
            if saved.schemaVersion < 3 {
                loadedSettings.enabledCategories.formUnion([.mindfulness, .affirmations])
                loadedSettings.popupTheme = .coral
            }
            if saved.schemaVersion < 5 {
                loadedSettings.popupColorMode = .category
            }
            settings = loadedSettings
            progress = saved.progress
            scheduler = saved.scheduler
        } else {
            let initialSettings = AppSettings()
            settings = initialSettings
            progress = ProgressState(today: DailyProgress(localDate: DateKey.localDay(for: now)))
            scheduler = SchedulerEngine.started(now: now, intervalMinutes: initialSettings.reminderIntervalMinutes)
        }

        super.init()

        ProgressEngine.rollDayIfNeeded(now: now, state: &progress)
        if scheduler.state == .inactive || scheduler.nextDueAt == nil {
            scheduler = SchedulerEngine.started(now: now, intervalMinutes: settings.reminderIntervalMinutes)
        } else if scheduler.state == .due {
            scheduler.state = .counting
            scheduler.nextDueAt = now.addingTimeInterval(60)
            scheduler.pendingActivityID = nil
        }
        alignNextBreakToSchedule(after: now)

        panelController = ReminderPanelController(model: self)
        onboardingController = OnboardingWindowController(model: self)
        hotKeyManager = PopupHotKeyManager { [weak self] hotKey in
            switch hotKey {
            case .swap: self?.swapCurrentActivity()
            case .eyes: self?.showEyeActivity()
            case .next: self?.nextTask()
            case .complete: self?.completeCurrentActivityNow()
            }
        }
        observeSystemLifecycle()
        startTicking()
        save()

        if !settings.onboardingComplete {
            DispatchQueue.main.async { [weak self] in self?.onboardingController.show() }
        }
    }

    var nextBreakText: String {
        if currentActivity != nil, breakPhase != .completed { return "Break ready now" }
        if scheduler.state == .paused {
            if let pauseUntil = scheduler.pauseUntil {
                return "Paused until \(pauseUntil.formatted(date: .omitted, time: .shortened))"
            }
            return "Paused"
        }
        let now = clockNow
        if !isWithinActiveSchedule(now), let nextStart = nextActiveStart(after: now) {
            return scheduleStartText(for: nextStart, relativeTo: now)
        }
        guard let due = scheduler.nextDueAt else { return "Not scheduled" }
        let seconds = max(0, Int(due.timeIntervalSince(now).rounded(.up)))
        return String(format: "Next break in %02d:%02d", seconds / 60, seconds % 60)
    }

    var menuBarLabel: String {
        if currentActivity != nil, breakPhase != .completed { return "Now" }
        if scheduler.state == .paused { return "Paused" }
        if !isWithinActiveSchedule(clockNow) { return "Off" }
        guard settings.menuBarCountdownEnabled, let due = scheduler.nextDueAt else { return "20" }
        let minutes = max(0, Int(ceil(due.timeIntervalSince(clockNow) / 60)))
        return "\(minutes)m"
    }

    var categoryProgress: Set<ActivityCategory> {
        Set(progress.today.completedByCategory.compactMap { $0.value > 0 ? $0.key : nil })
    }

    var weeklyBreakCounts: [WeeklyBreakCount] {
        let calendar = Calendar.autoupdatingCurrent
        let startOfToday = calendar.startOfDay(for: clockNow)
        let days = progress.dailyHistory + [progress.today]
        let counts = Dictionary(days.map { ($0.localDate, $0.completedCount) }, uniquingKeysWith: { _, latest in latest })
        return (-6...0).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { return nil }
            let key = DateKey.localDay(for: date, calendar: calendar)
            return WeeklyBreakCount(localDate: key, date: date, count: counts[key, default: 0], isToday: offset == 0)
        }
    }

    var recentTaskHistory: [TaskCompletionRecord] {
        Array(progress.recentCompletions.reversed().prefix(3))
    }

    var popupTheme: PopupTheme { settings.popupTheme ?? .coral }
    var popupColorMode: PopupColorMode { settings.popupColorMode ?? .category }
    var customActivities: [CustomActivity] { settings.customActivities ?? [] }

    var canCompleteCurrentActivity: Bool {
        guard breakPhase == .active, revealAvailable, let activity = currentActivity else { return false }
        if case .writing = activity.format {
            return !writingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    func completeOnboarding() {
        settings.onboardingComplete = true
        settings.movementConsentShown = settings.enabledCategories.contains(.movement)
        scheduler = SchedulerEngine.reset(scheduler, now: Date(), intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: Date())
        save()
        onboardingController.close()
        if settings.launchAtLoginEnabled { updateLaunchAtLogin(true) }
    }

    func takeBreakNow() {
        guard currentActivity == nil else {
            panelController.show()
            return
        }
        showReminder(now: Date())
    }

    func startCurrentActivity() {
        guard let activity = currentActivity, breakPhase == .due else { return }
        activityTimer?.invalidate()
        activityTimer = nil
        breakPhase = .active
        currentStartedOnTime = Date().timeIntervalSince(reminderAppearedAt ?? Date()) <= 60
        remainingSeconds = activity.format.minimumSeconds
        revealAvailable = false
        writingText = ""
        hotKeyManager.deactivate()
        if case .writing = activity.format { panelController.focusForTyping() }
        startActivityTimer()
    }

    func finishCurrentActivity() {
        guard let activity = currentActivity, canCompleteCurrentActivity else { return }
        activityTimer?.invalidate()
        activityTimer = nil
        hotKeyManager.deactivate()

        let now = Date()
        let award = ProgressEngine.complete(
            category: activity.category,
            startedOnTime: currentStartedOnTime,
            now: now,
            settings: settings,
            state: &progress
        )
        ProgressEngine.recordCompletion(activity: activity, points: award.points, now: now, state: &progress)
        lastAward = award.points
        scheduler.lastCompletedActivityID = activity.id
        scheduler.lastCompletedCategoryID = activity.category
        scheduler.lastCompletedAtByCategory[activity.category] = now
        scheduler.seenActivityIDsByCategory[activity.category, default: []].insert(activity.id)
        scheduler = SchedulerEngine.reset(scheduler, now: now, intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: now)
        breakPhase = .completed
        save()

        if settings.soundEnabled { NSSound(named: "Glass")?.play() }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3))
            self?.dismissCompletedBreak()
        }
    }

    func completeCurrentActivityNow() {
        guard canCompleteCurrentActivity else { return }
        finishCurrentActivity()
    }

    func skipCurrentActivity() {
        activityTimer?.invalidate()
        activityTimer = nil
        ProgressEngine.rollDayIfNeeded(now: Date(), state: &progress)
        progress.today.skippedCount += 1
        currentActivity = nil
        let now = Date()
        scheduler = SchedulerEngine.reset(scheduler, now: now, intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: now)
        panelController.close()
        hotKeyManager.deactivate()
        save()
    }

    func snoozeCurrentActivity() {
        activityTimer?.invalidate()
        activityTimer = nil
        ProgressEngine.rollDayIfNeeded(now: Date(), state: &progress)
        progress.today.snoozedCount += 1
        currentActivity = nil
        scheduler = SchedulerEngine.snoozed(scheduler, now: Date())
        panelController.close()
        hotKeyManager.deactivate()
        save()
    }

    func swapCurrentActivity() {
        guard let current = currentActivity else { return }
        activityTimer?.invalidate()
        activityTimer = nil
        ProgressEngine.rollDayIfNeeded(now: Date(), state: &progress)
        progress.today.swappedCount += 1
        scheduler.seenActivityIDsByCategory[current.category, default: []].insert(current.id)
        currentActivity = selectActivity(seed: Int.random(in: 0...Int.max))
        guard let currentActivity else { return }
        recordPresentation(of: currentActivity)
        breakPhase = .due
        autoStartCountdown = automaticStartDelaySeconds
        remainingSeconds = currentActivity.format.minimumSeconds
        revealAvailable = false
        writingText = ""
        scheduler.pendingActivityID = currentActivity.id
        reminderAppearedAt = Date()
        hotKeyManager.activate()
        startCountdownTimer()
        save()
    }

    func showEyeActivity() {
        activityTimer?.invalidate()
        activityTimer = nil
        if currentActivity != nil {
            ProgressEngine.rollDayIfNeeded(now: Date(), state: &progress)
            progress.today.swappedCount += 1
        }
        currentActivity = selectActivity(forcedCategory: .eyes, seed: Int.random(in: 0...Int.max))
            ?? selectionCatalog.first { $0.category == .eyes }
        guard let currentActivity else { return }
        recordPresentation(of: currentActivity)
        breakPhase = .due
        autoStartCountdown = automaticStartDelaySeconds
        remainingSeconds = currentActivity.format.minimumSeconds
        revealAvailable = false
        writingText = ""
        reminderAppearedAt = Date()
        scheduler.state = .due
        scheduler.pendingActivityID = currentActivity.id
        panelController.show()
        hotKeyManager.activate()
        startCountdownTimer()
        save()
    }

    func nextTask() {
        activityTimer?.invalidate()
        activityTimer = nil
        if let current = currentActivity {
            ProgressEngine.rollDayIfNeeded(now: Date(), state: &progress)
            progress.today.skippedCount += 1
            scheduler.seenActivityIDsByCategory[current.category, default: []].insert(current.id)
        }
        currentActivity = nil
        showReminder(now: Date())
    }

    func hideCurrentActivity() {
        guard let current = currentActivity else { return }
        settings.hiddenActivityIDs.insert(current.id)
        if selectActivity() == nil {
            settings.hiddenActivityIDs.remove(current.id)
            return
        }
        lastHiddenActivity = current
        swapCurrentActivity()
    }

    func undoLastHiddenActivity() {
        guard let hidden = lastHiddenActivity else { return }
        settings.hiddenActivityIDs.remove(hidden.id)
        lastHiddenActivity = nil
        save()
    }

    func pause(minutes: Int?) {
        activityTimer?.invalidate()
        activityTimer = nil
        currentActivity = nil
        scheduler.state = .paused
        scheduler.pauseUntil = minutes.map { Date().addingTimeInterval(TimeInterval($0 * 60)) }
        panelController.close()
        hotKeyManager.deactivate()
        save()
    }

    func pauseUntilTomorrow() {
        let calendar = Calendar.autoupdatingCurrent
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let target = calendar.date(bySettingHour: settings.activeStartHour, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        scheduler.state = .paused
        scheduler.pauseUntil = target
        panelController.close()
        hotKeyManager.deactivate()
        save()
    }

    func resume() {
        let now = Date()
        scheduler = SchedulerEngine.reset(scheduler, now: now, intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: now)
        save()
    }

    func updateInterval(_ minutes: Int) {
        settings.reminderIntervalMinutes = minutes
        let now = Date()
        scheduler = SchedulerEngine.reset(scheduler, now: now, intervalMinutes: minutes)
        alignNextBreakToSchedule(after: now)
        save()
    }

    func updatePreset(_ preset: MixPreset) {
        settings.mixPreset = preset
        resetPresentationMix()
        save()
    }

    func addCustomActivity(
        title: String,
        instruction: String,
        category: ActivityCategory,
        seconds: Int
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInstruction = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedInstruction.isEmpty else { return }
        var activities = customActivities
        activities.append(CustomActivity(
            category: category,
            title: trimmedTitle,
            instruction: trimmedInstruction,
            seconds: seconds
        ))
        settings.customActivities = activities
        save()
    }

    func removeCustomActivity(_ activity: CustomActivity) {
        settings.customActivities = customActivities.filter { $0.id != activity.id }
        settings.hiddenActivityIDs.remove(activity.definition.id)
        save()
    }

    func updateMovementMode(_ mode: MovementMode) {
        settings.movementMode = mode
        save()
    }

    func setCategory(_ category: ActivityCategory, enabled: Bool) {
        if enabled {
            settings.enabledCategories.insert(category)
            if category == .movement { settings.movementConsentShown = true }
        } else if settings.enabledCategories.count > 1 {
            settings.enabledCategories.remove(category)
        }
        resetPresentationMix()
        save()
    }

    func updateSound(_ enabled: Bool) {
        settings.soundEnabled = enabled
        save()
    }

    func updateMenuBarCountdown(_ enabled: Bool) {
        settings.menuBarCountdownEnabled = enabled
        save()
    }

    func updatePopupTheme(_ theme: PopupTheme) {
        settings.popupTheme = theme
        save()
    }

    func updatePopupColorMode(_ mode: PopupColorMode) {
        settings.popupColorMode = mode
        save()
    }

    func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            settings.launchAtLoginEnabled = enabled
            launchAtLoginError = nil
            save()
        } catch {
            settings.launchAtLoginEnabled = false
            launchAtLoginError = "Launch at login could not be changed: \(error.localizedDescription)"
        }
    }

    func updateSchedule(startHour: Int? = nil, endHour: Int? = nil) {
        if let startHour {
            settings.activeStartHour = startHour
            if settings.activeEndHour <= startHour { settings.activeEndHour = min(24, startHour + 1) }
        }
        if let endHour {
            settings.activeEndHour = endHour
            if endHour <= settings.activeStartHour { settings.activeStartHour = max(0, endHour - 1) }
        }
        let now = Date()
        scheduler = SchedulerEngine.reset(scheduler, now: now, intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: now)
        save()
    }

    func setActiveDay(_ weekday: Int, enabled: Bool) {
        if enabled {
            settings.activeDays.insert(weekday)
        } else if settings.activeDays.count > 1 {
            settings.activeDays.remove(weekday)
        }
        let now = Date()
        scheduler = SchedulerEngine.reset(scheduler, now: now, intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: now)
        save()
    }

    func updateDailyPointGoal(_ points: Int) {
        settings.dailyPointGoal = points
        progress.today.goalReached = progress.today.points >= points
        save()
    }

    func resetProgress() {
        progress = ProgressState(today: DailyProgress(localDate: DateKey.localDay(for: Date())))
        save()
    }

    func resetAll() {
        store.delete()
        settings = AppSettings()
        progress = ProgressState(today: DailyProgress(localDate: DateKey.localDay(for: Date())))
        scheduler = SchedulerEngine.started(now: Date(), intervalMinutes: settings.reminderIntervalMinutes)
        alignNextBreakToSchedule(after: Date())
        save()
        onboardingController.show()
    }

    private func startTicking() {
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }

    @objc private func tick() {
        guard suspensionReasons.isEmpty else { return }
        let now = Date()
        clockNow = now
        ProgressEngine.rollDayIfNeeded(now: now, state: &progress)

        if scheduler.state == .paused {
            if let pauseUntil = scheduler.pauseUntil, now >= pauseUntil { resume() }
            return
        }
        guard isWithinActiveSchedule(now) else {
            if currentActivity == nil, alignNextBreakToSchedule(after: now) { save() }
            return
        }
        if SchedulerEngine.isDue(scheduler, now: now), currentActivity == nil {
            showReminder(now: now)
        }
    }

    private func showReminder(now: Date) {
        guard let activity = selectActivity() else { return }
        currentActivity = activity
        recordPresentation(of: activity)
        breakPhase = .due
        autoStartCountdown = automaticStartDelaySeconds
        remainingSeconds = activity.format.minimumSeconds
        revealAvailable = false
        lastHiddenActivity = nil
        reminderAppearedAt = now
        scheduler.state = .due
        scheduler.pendingActivityID = activity.id
        panelController.show()
        hotKeyManager.activate()
        startCountdownTimer()
        save()
    }

    private func selectActivity(forcedCategory: ActivityCategory? = nil, seed: Int? = nil) -> ActivityDefinition? {
        var selectionSettings = settings
        if let forcedCategory { selectionSettings.enabledCategories = [forcedCategory] }
        return ActivitySelectionEngine.select(
            catalog: selectionCatalog,
            settings: selectionSettings,
            progress: progress.today,
            scheduler: scheduler,
            now: Date(),
            seed: seed
        )
    }

    private var selectionCatalog: [ActivityDefinition] {
        ActivityCatalog.all + customActivities.map(\.definition)
    }

    private func recordPresentation(of activity: ActivityDefinition) {
        scheduler.presentedCount += 1
        scheduler.presentedByCategory[activity.category, default: 0] += 1
        scheduler.lastPresentedCategoryID = activity.category
        scheduler.lastPresentedSequenceByCategory[activity.category] = scheduler.presentedCount
    }

    private func resetPresentationMix() {
        scheduler.presentedCount = 0
        scheduler.presentedByCategory = [:]
        scheduler.lastPresentedCategoryID = nil
        scheduler.lastPresentedSequenceByCategory = [:]
    }

    private func startActivityTimer() {
        activityTimer?.invalidate()
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(activityTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        activityTimer = timer
    }

    private func startCountdownTimer() {
        activityTimer?.invalidate()
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(countdownTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        activityTimer = timer
    }

    @objc private func countdownTick() {
        guard currentActivity != nil, breakPhase == .due else {
            activityTimer?.invalidate()
            activityTimer = nil
            return
        }
        autoStartCountdown = max(0, autoStartCountdown - 1)
        if autoStartCountdown == 0 { startCurrentActivity() }
    }

    @objc private func activityTick() {
        guard currentActivity != nil, breakPhase == .active else { return }
        remainingSeconds = max(0, remainingSeconds - 1)
        if remainingSeconds == 0 {
            activityTimer?.invalidate()
            activityTimer = nil
            revealAvailable = true
            hotKeyManager.activateCompletion()
        }
    }

    private func dismissCompletedBreak() {
        guard breakPhase == .completed else { return }
        panelController.close()
        hotKeyManager.deactivate()
        currentActivity = nil
        lastAward = 0
    }

    private func observeSystemLifecycle() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self, selector: #selector(systemWillSleep), name: NSWorkspace.willSleepNotification, object: nil)
        center.addObserver(self, selector: #selector(systemDidWake), name: NSWorkspace.didWakeNotification, object: nil)
        center.addObserver(self, selector: #selector(sessionDidLock), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(sessionDidUnlock), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
    }

    @objc private func systemWillSleep() {
        beginSystemSuspension(.sleep)
    }

    @objc private func systemDidWake() {
        endSystemSuspension(.sleep)
    }

    @objc private func sessionDidLock() {
        beginSystemSuspension(.lockedSession)
    }

    @objc private func sessionDidUnlock() {
        endSystemSuspension(.lockedSession)
    }

    private func beginSystemSuspension(_ reason: SystemSuspensionReason) {
        let wasActive = suspensionReasons.isEmpty
        suspensionReasons.insert(reason)
        guard wasActive else { return }

        suspensionStartedAt = Date()
        activityTimer?.invalidate()
        activityTimer = nil
        save()
    }

    private func endSystemSuspension(_ reason: SystemSuspensionReason) {
        suspensionReasons.remove(reason)
        guard suspensionReasons.isEmpty, let started = suspensionStartedAt else { return }

        let now = Date()
        scheduler = SchedulerEngine.shiftedAfterInactivity(
            scheduler,
            inactiveDuration: now.timeIntervalSince(started),
            resumedAt: now
        )
        alignNextBreakToSchedule(after: now)
        suspensionStartedAt = nil

        if currentActivity != nil {
            panelController.show()
            switch breakPhase {
            case .due:
                hotKeyManager.activate()
                startCountdownTimer()
            case .active:
                if revealAvailable {
                    hotKeyManager.activateCompletion()
                } else {
                    startActivityTimer()
                }
            case .completed:
                break
            }
        }
        save()
    }

    private func isWithinActiveSchedule(_ date: Date) -> Bool {
        let calendar = Calendar.autoupdatingCurrent
        let weekday = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        return settings.activeDays.contains(weekday) && hour >= settings.activeStartHour && hour < settings.activeEndHour
    }

    private func nextActiveStart(after date: Date) -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        for offset in 0...8 {
            guard let candidate = calendar.date(byAdding: .day, value: offset, to: date),
                  settings.activeDays.contains(calendar.component(.weekday, from: candidate)),
                  let start = calendar.date(bySettingHour: settings.activeStartHour, minute: 0, second: 0, of: candidate) else { continue }
            if start > date { return start }
        }
        return nil
    }

    @discardableResult
    private func alignNextBreakToSchedule(after date: Date) -> Bool {
        guard scheduler.state != .paused,
              !isWithinActiveSchedule(date),
              let nextStart = nextActiveStart(after: date) else { return false }
        let nextDue = nextStart.addingTimeInterval(TimeInterval(settings.reminderIntervalMinutes * 60))
        guard scheduler.state != .counting || scheduler.nextDueAt != nextDue else { return false }
        scheduler.state = .counting
        scheduler.nextDueAt = nextDue
        scheduler.pauseUntil = nil
        scheduler.pendingActivityID = nil
        return true
    }

    private func scheduleStartText(for start: Date, relativeTo now: Date) -> String {
        let calendar = Calendar.autoupdatingCurrent
        let time = start.formatted(date: .omitted, time: .shortened)
        if calendar.isDate(start, inSameDayAs: now) { return "Schedule starts at \(time)" }
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)
        if let tomorrow, calendar.isDate(start, inSameDayAs: tomorrow) {
            return "Schedule starts tomorrow at \(time)"
        }
        let day = start.formatted(.dateTime.weekday(.abbreviated))
        return "Schedule starts \(day) at \(time)"
    }

    private func save() {
        store.save(PersistedState(settings: settings, progress: progress, scheduler: scheduler))
    }
}
