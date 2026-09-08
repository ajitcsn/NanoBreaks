import Foundation

public enum ActivityCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case eyes
    case movement
    case mobility
    case calm
    case hydration
    case brain
    case voice
    case writing
    case rhythm
    case mindfulness
    case affirmations

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .eyes: "Eyes"
        case .movement: "Movement"
        case .mobility: "Mobility"
        case .calm: "Calm"
        case .hydration: "Hydration"
        case .brain: "Brain spark"
        case .voice: "Voice"
        case .writing: "Writing"
        case .rhythm: "Rhythm"
        case .mindfulness: "Mindfulness"
        case .affirmations: "Affirmation"
        }
    }

    public var symbol: String {
        switch self {
        case .eyes: "eye"
        case .movement: "figure.strengthtraining.traditional"
        case .mobility: "figure.flexibility"
        case .calm: "wind"
        case .hydration: "drop"
        case .brain: "lightbulb"
        case .voice: "music.microphone"
        case .writing: "text.cursor"
        case .rhythm: "hands.clap"
        case .mindfulness: "leaf"
        case .affirmations: "quote.bubble"
        }
    }
}

public enum MovementMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case seatedOnly
    case quietOffice
    case standard

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .seatedOnly: "Seated only"
        case .quietOffice: "Quiet office"
        case .standard: "Standard"
        }
    }
}

public enum MixPreset: String, CaseIterable, Codable, Identifiable, Sendable {
    case balanced
    case eyesFirst
    case moveMore
    case calmFocus
    case custom

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .balanced: "Balanced"
        case .eyesFirst: "Eyes first"
        case .moveMore: "Move more"
        case .calmFocus: "Calm focus"
        case .custom: "Custom"
        }
    }

    public var weights: [ActivityCategory: Int] {
        switch self {
        case .balanced, .custom:
            [.eyes: 12, .movement: 10, .mobility: 8, .calm: 9, .hydration: 8, .brain: 9, .voice: 9, .writing: 9, .rhythm: 8, .mindfulness: 9, .affirmations: 9]
        case .eyesFirst:
            [.eyes: 20, .movement: 8, .mobility: 8, .calm: 8, .hydration: 8, .brain: 8, .voice: 8, .writing: 8, .rhythm: 8, .mindfulness: 8, .affirmations: 8]
        case .moveMore:
            [.eyes: 8, .movement: 16, .mobility: 12, .calm: 8, .hydration: 8, .brain: 8, .voice: 8, .writing: 8, .rhythm: 8, .mindfulness: 8, .affirmations: 8]
        case .calmFocus:
            [.eyes: 8, .movement: 8, .mobility: 8, .calm: 16, .hydration: 8, .brain: 8, .voice: 8, .writing: 8, .rhythm: 8, .mindfulness: 12, .affirmations: 8]
        }
    }
}

public enum ActivityFormat: Codable, Equatable, Sendable {
    case timed(seconds: Int)
    case repetitions(count: Int, minimumSeconds: Int)
    case brainSpark(revealAfterSeconds: Int)
    case writing(minimumSeconds: Int)

    public var durationText: String {
        switch self {
        case .timed(let seconds): "\(seconds) sec"
        case .repetitions(let count, _): "\(count) reps"
        case .brainSpark: "Think, then reveal"
        case .writing(let seconds): "Write for \(seconds) sec"
        }
    }

    public var minimumSeconds: Int {
        switch self {
        case .timed(let seconds): seconds
        case .repetitions(_, let seconds): seconds
        case .brainSpark(let seconds): seconds
        case .writing(let seconds): seconds
        }
    }
}

public enum PopupTheme: String, CaseIterable, Codable, Identifiable, Sendable {
    case coral
    case ocean
    case forest
    case plum
    case graphite

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .coral: "Coral"
        case .ocean: "Ocean"
        case .forest: "Forest"
        case .plum: "Plum"
        case .graphite: "Graphite"
        }
    }
}

public enum PopupColorMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case category
    case fixed

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .category: "Match task type"
        case .fixed: "One fixed color"
        }
    }
}

public struct ActivityDefinition: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let category: ActivityCategory
    public let title: String
    public let instruction: String
    public let format: ActivityFormat
    public let movementModes: Set<MovementMode>
    public let safetyLine: String?
    public let answer: String?

    public init(
        id: String,
        category: ActivityCategory,
        title: String,
        instruction: String,
        format: ActivityFormat,
        movementModes: Set<MovementMode> = Set(MovementMode.allCases),
        safetyLine: String? = nil,
        answer: String? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.instruction = instruction
        self.format = format
        self.movementModes = movementModes
        self.safetyLine = safetyLine
        self.answer = answer
    }
}

public struct CustomActivity: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let category: ActivityCategory
    public let title: String
    public let instruction: String
    public let seconds: Int

    public init(
        id: UUID = UUID(),
        category: ActivityCategory,
        title: String,
        instruction: String,
        seconds: Int
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.instruction = instruction
        self.seconds = min(60, max(20, seconds))
    }

    public var definition: ActivityDefinition {
        ActivityDefinition(
            id: "custom.\(id.uuidString.lowercased())",
            category: category,
            title: title,
            instruction: instruction,
            format: .timed(seconds: seconds)
        )
    }
}

public struct AppSettings: Codable, Equatable, Sendable {
    public var reminderIntervalMinutes = 20
    public var activeDays: Set<Int> = [2, 3, 4, 5, 6]
    public var activeStartHour = 9
    public var activeEndHour = 18
    public var enabledCategories = Set(ActivityCategory.allCases)
    public var hiddenActivityIDs: Set<String> = []
    public var mixPreset = MixPreset.balanced
    public var movementMode = MovementMode.quietOffice
    public var movementConsentShown = false
    public var soundEnabled = true
    public var menuBarCountdownEnabled = false
    public var launchAtLoginEnabled = true
    public var dailyPointGoal = 60
    public var onboardingComplete = false
    public var popupTheme: PopupTheme? = .coral
    public var popupColorMode: PopupColorMode? = .category
    public var customActivities: [CustomActivity]? = []

    public init() {}
}

public struct DailyProgress: Codable, Equatable, Sendable {
    public var localDate: String
    public var points = 0
    public var completedCount = 0
    public var skippedCount = 0
    public var snoozedCount = 0
    public var swappedCount = 0
    public var completedByCategory: [ActivityCategory: Int] = [:]
    public var awardedVarietyBonusCategories: Set<ActivityCategory> = []
    public var goalReached = false

    public init(localDate: String) {
        self.localDate = localDate
    }
}

public struct TaskCompletionRecord: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let activityID: String
    public let title: String
    public let category: ActivityCategory
    public let points: Int
    public let completedAt: Date

    public init(
        id: UUID = UUID(),
        activityID: String,
        title: String,
        category: ActivityCategory,
        points: Int,
        completedAt: Date
    ) {
        self.id = id
        self.activityID = activityID
        self.title = title
        self.category = category
        self.points = points
        self.completedAt = completedAt
    }
}

public struct ProgressState: Codable, Equatable, Sendable {
    public var today: DailyProgress
    public var currentStreak = 0
    public var longestStreak = 0
    public var lifetimeCompleted = 0
    public var lastStreakDate: String?
    public var lifetimeByCategory: [ActivityCategory: Int] = [:]
    public var dailyHistory: [DailyProgress] = []
    public var recentCompletions: [TaskCompletionRecord] = []

    public init(today: DailyProgress) {
        self.today = today
    }

    private enum CodingKeys: String, CodingKey {
        case today
        case currentStreak
        case longestStreak
        case lifetimeCompleted
        case lastStreakDate
        case lifetimeByCategory
        case dailyHistory
        case recentCompletions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        today = try container.decode(DailyProgress.self, forKey: .today)
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        longestStreak = try container.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        lifetimeCompleted = try container.decodeIfPresent(Int.self, forKey: .lifetimeCompleted) ?? 0
        lastStreakDate = try container.decodeIfPresent(String.self, forKey: .lastStreakDate)
        lifetimeByCategory = try container.decodeIfPresent([ActivityCategory: Int].self, forKey: .lifetimeByCategory) ?? [:]
        dailyHistory = try container.decodeIfPresent([DailyProgress].self, forKey: .dailyHistory) ?? []
        recentCompletions = try container.decodeIfPresent([TaskCompletionRecord].self, forKey: .recentCompletions) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(today, forKey: .today)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(longestStreak, forKey: .longestStreak)
        try container.encode(lifetimeCompleted, forKey: .lifetimeCompleted)
        try container.encodeIfPresent(lastStreakDate, forKey: .lastStreakDate)
        try container.encode(lifetimeByCategory, forKey: .lifetimeByCategory)
        try container.encode(dailyHistory, forKey: .dailyHistory)
        try container.encode(recentCompletions, forKey: .recentCompletions)
    }
}

public enum ReminderState: String, Codable, Sendable {
    case inactive
    case counting
    case due
    case snoozed
    case paused
}

public struct SchedulerSnapshot: Codable, Equatable, Sendable {
    public var state = ReminderState.inactive
    public var nextDueAt: Date?
    public var pauseUntil: Date?
    public var pendingActivityID: String?
    public var lastCompletedActivityID: String?
    public var lastCompletedCategoryID: ActivityCategory?
    public var lastCompletedAtByCategory: [ActivityCategory: Date] = [:]
    public var seenActivityIDsByCategory: [ActivityCategory: Set<String>] = [:]
    public var presentedCount = 0
    public var presentedByCategory: [ActivityCategory: Int] = [:]
    public var lastPresentedCategoryID: ActivityCategory?
    public var lastPresentedSequenceByCategory: [ActivityCategory: Int] = [:]

    public init() {}

    private enum CodingKeys: String, CodingKey {
        case state
        case nextDueAt
        case pauseUntil
        case pendingActivityID
        case lastCompletedActivityID
        case lastCompletedCategoryID
        case lastCompletedAtByCategory
        case seenActivityIDsByCategory
        case presentedCount
        case presentedByCategory
        case lastPresentedCategoryID
        case lastPresentedSequenceByCategory
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = try container.decodeIfPresent(ReminderState.self, forKey: .state) ?? .inactive
        nextDueAt = try container.decodeIfPresent(Date.self, forKey: .nextDueAt)
        pauseUntil = try container.decodeIfPresent(Date.self, forKey: .pauseUntil)
        pendingActivityID = try container.decodeIfPresent(String.self, forKey: .pendingActivityID)
        lastCompletedActivityID = try container.decodeIfPresent(String.self, forKey: .lastCompletedActivityID)
        lastCompletedCategoryID = try container.decodeIfPresent(ActivityCategory.self, forKey: .lastCompletedCategoryID)
        lastCompletedAtByCategory = try container.decodeIfPresent([ActivityCategory: Date].self, forKey: .lastCompletedAtByCategory) ?? [:]
        seenActivityIDsByCategory = try container.decodeIfPresent([ActivityCategory: Set<String>].self, forKey: .seenActivityIDsByCategory) ?? [:]
        presentedCount = try container.decodeIfPresent(Int.self, forKey: .presentedCount) ?? 0
        presentedByCategory = try container.decodeIfPresent([ActivityCategory: Int].self, forKey: .presentedByCategory) ?? [:]
        lastPresentedCategoryID = try container.decodeIfPresent(ActivityCategory.self, forKey: .lastPresentedCategoryID)
        lastPresentedSequenceByCategory = try container.decodeIfPresent([ActivityCategory: Int].self, forKey: .lastPresentedSequenceByCategory) ?? [:]
    }
}

public struct PersistedState: Codable, Sendable {
    public var schemaVersion = 6
    public var settings: AppSettings
    public var progress: ProgressState
    public var scheduler: SchedulerSnapshot

    public init(settings: AppSettings, progress: ProgressState, scheduler: SchedulerSnapshot) {
        self.settings = settings
        self.progress = progress
        self.scheduler = scheduler
    }
}

public enum DateKey {
    public static func localDay(for date: Date, calendar: Calendar = .autoupdatingCurrent) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
