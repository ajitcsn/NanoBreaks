import AppKit
import SwiftUI
import NanoBreaksCore

struct MenuBarView: View {
    @ObservedObject var model: AppModel

    private var completedCategories: [ActivityCategory] {
        ActivityCategory.allCases.filter { model.categoryProgress.contains($0) }
    }

    private var pointsRemaining: Int {
        max(0, model.settings.dailyPointGoal - model.progress.today.points)
    }

    private var hasLiveActivity: Bool {
        model.currentActivity != nil && model.breakPhase != .completed
    }

    private var statusColor: Color {
        if model.scheduler.state == .paused { return .orange }
        if hasLiveActivity { return .green }
        return .blue
    }

    private var statusSymbol: String {
        if model.scheduler.state == .paused { return "pause.fill" }
        if hasLiveActivity { return "figure.mind.and.body" }
        return "timer"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            statusCard
            todayCard
            weeklyCard
            historyCard
            taskTypePicker
            actionArea
            footer
        }
        .padding(12)
        .frame(width: 380)
    }

    private var statusCard: some View {
        HStack(spacing: 11) {
            Image(systemName: statusSymbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(statusColor)
                .frame(width: 31, height: 31)
                .background(statusColor.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(hasLiveActivity ? "Current break" : "NanoBreaks")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(model.nextBreakText)
                    .font(.headline)
                    .monospacedDigit()
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .background(statusColor.opacity(0.09), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(statusColor.opacity(0.18))
        }
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 16) {
                ScoreRing(points: model.progress.today.points, goal: model.settings.dailyPointGoal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("TODAY")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 7) {
                        StatPill(
                            symbol: "checkmark.circle.fill",
                            value: "\(model.progress.today.completedCount)",
                            label: model.progress.today.completedCount == 1 ? "break" : "breaks",
                            color: .green
                        )
                        StatPill(
                            symbol: "flame.fill",
                            value: "\(model.progress.currentStreak)",
                            label: model.progress.currentStreak == 1 ? "day" : "days",
                            color: .orange
                        )
                    }

                    Label(
                        pointsRemaining == 0 ? "Daily goal reached" : "\(pointsRemaining) points to goal",
                        systemImage: pointsRemaining == 0 ? "checkmark.seal.fill" : "flag.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(pointsRemaining == 0 ? .green : .secondary)
                }
            }

            Divider()

            HStack(spacing: 6) {
                Text("Mix")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                if completedCategories.isEmpty {
                    Text("No categories completed yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(completedCategories.prefix(3)) { category in
                        CompactCategoryBadge(category: category)
                    }
                    if completedCategories.count > 3 {
                        Text("+\(completedCategories.count - 3)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(13)
        .panelCard()
    }

    private var weeklyCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Last 7 days", systemImage: "chart.bar.fill")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                let weeklyTotal = model.weeklyBreakCounts.reduce(0) { $0 + $1.count }
                Text("\(weeklyTotal) breaks")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            WeeklyBreakChart(days: model.weeklyBreakCounts)
        }
        .padding(12)
        .panelCard()
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Task history", systemImage: "clock.arrow.circlepath")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Latest 3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if model.recentTaskHistory.isEmpty {
                Text("History begins with your next completed task.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(model.recentTaskHistory.enumerated()), id: \.element.id) { index, record in
                        TaskHistoryRow(record: record, now: model.clockNow)
                        if index < model.recentTaskHistory.count - 1 {
                            Divider().padding(.leading, 32)
                        }
                    }
                }
            }
        }
        .padding(12)
        .panelCard()
    }

    private var taskTypePicker: some View {
        Menu {
            Section("Choose what can be queued") {
                ForEach(ActivityCategory.allCases) { category in
                    Toggle(isOn: Binding(
                        get: { model.settings.enabledCategories.contains(category) },
                        set: { model.setCategory(category, enabled: $0) }
                    )) {
                        Label(category.title, systemImage: category.symbol)
                    }
                    .disabled(
                        model.settings.enabledCategories.count == 1 &&
                        model.settings.enabledCategories.contains(category)
                    )
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.blue)
                Text("Queued task types · \(model.settings.enabledCategories.count)")
                    .fontWeight(.medium)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .help("Choose which activity categories can appear in future breaks")
    }

    private var actionArea: some View {
        VStack(spacing: 7) {
            Button {
                model.takeBreakNow()
            } label: {
                Label("Take a break now", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 7) {
                Button { model.nextTask() } label: {
                    Label("Next task", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                Button { model.showEyeActivity() } label: {
                    Label("Eye break", systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var footer: some View {
        HStack(spacing: 14) {
            if model.scheduler.state == .paused {
                Button { model.resume() } label: {
                    Label("Resume", systemImage: "play.circle")
                }
            } else {
                Menu {
                    Button("For 1 hour") { model.pause(minutes: 60) }
                    Button("Until tomorrow") { model.pauseUntilTomorrow() }
                    Button("Until I resume") { model.pause(minutes: nil) }
                } label: {
                    Label("Pause", systemImage: "pause.circle")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }

            Spacer()

            SettingsLink {
                Label("Settings", systemImage: "gearshape")
            }

            Button { NSApplication.shared.terminate(nil) } label: {
                Label("Quit", systemImage: "power")
            }
        }
        .font(.caption)
        .buttonStyle(.borderless)
        .padding(.horizontal, 2)
    }
}

private struct WeeklyBreakChart: View {
    let days: [WeeklyBreakCount]

    private var maximum: Int {
        max(1, days.map(\.count).max() ?? 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(days) { day in
                VStack(spacing: 4) {
                    Text(day.count == 0 ? "" : "\(day.count)")
                        .font(.system(size: 9, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(day.isToday ? .blue : .secondary)
                        .frame(height: 11)

                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(day.isToday ? Color.blue : Color.mint.opacity(0.72))
                        .frame(height: max(5, 34 * CGFloat(day.count) / CGFloat(maximum)))

                    Text(day.date.formatted(.dateTime.weekday(.narrow)))
                        .font(.caption2.weight(day.isToday ? .bold : .regular))
                        .foregroundStyle(day.isToday ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(day.date.formatted(date: .long, time: .omitted)), \(day.count) completed breaks")
            }
        }
        .frame(height: 64, alignment: .bottom)
    }
}

private struct TaskHistoryRow: View {
    let record: TaskCompletionRecord
    let now: Date

    private var timestamp: String {
        let calendar = Calendar.autoupdatingCurrent
        if calendar.isDate(record.completedAt, inSameDayAs: now) {
            return record.completedAt.formatted(date: .omitted, time: .shortened)
        }
        return record.completedAt.formatted(.dateTime.weekday(.abbreviated).hour().minute())
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: record.category.symbol)
                .font(.caption)
                .foregroundStyle(color(for: record.category))
                .frame(width: 24, height: 24)
                .background(color(for: record.category).opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(record.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                Text("\(record.category.title) · \(timestamp)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            Text("+\(record.points)")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 5)
    }
}

private struct ScoreRing: View {
    let points: Int
    let goal: Int

    private var progress: Double {
        min(1, Double(points) / Double(max(1, goal)))
    }

    var body: some View {
        ZStack {
            Circle().stroke(.secondary.opacity(0.14), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [.blue, .mint, .blue], center: .center),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: -1) {
                Text("\(points)")
                    .font(.title2.bold().monospacedDigit())
                Text("POINTS")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 78, height: 78)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(points) of \(goal) points")
    }
}

private struct StatPill: View {
    let symbol: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol).foregroundStyle(color)
            Text(value).fontWeight(.semibold).monospacedDigit()
            Text(label).foregroundStyle(.secondary)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color.opacity(0.10), in: Capsule())
    }
}

private struct CompactCategoryBadge: View {
    let category: ActivityCategory

    var body: some View {
        Image(systemName: category.symbol)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color(for: category))
            .frame(width: 23, height: 23)
            .background(color(for: category).opacity(0.12), in: Circle())
            .help(category.title)
            .accessibilityLabel("\(category.title) completed today")
    }
}

private extension View {
    func panelCard() -> some View {
        background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
