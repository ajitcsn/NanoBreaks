import SwiftUI
import NanoBreaksCore

struct SettingsView: View {
    @ObservedObject var model: AppModel
    @State private var confirmProgressReset = false
    @State private var confirmFullReset = false
    @State private var customTitle = ""
    @State private var customInstruction = ""
    @State private var customCategory = ActivityCategory.calm
    @State private var customSeconds = 30

    var body: some View {
        TabView {
            general
                .tabItem { Label("General", systemImage: "gear") }
            mix
                .tabItem { Label("Mix", systemImage: "square.grid.2x2") }
            customActivities
                .tabItem { Label("Activities", systemImage: "plus.rectangle.on.rectangle") }
            schedule
                .tabItem { Label("Schedule", systemImage: "calendar") }
            progress
                .tabItem { Label("Progress", systemImage: "chart.bar") }
            about
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .padding(18)
        .frame(width: 620, height: 500)
    }

    private var general: some View {
        Form {
            Picker("Reminder interval", selection: Binding(
                get: { model.settings.reminderIntervalMinutes },
                set: { model.updateInterval($0) }
            )) {
                ForEach(stride(from: 10, through: 120, by: 5).map { $0 }, id: \.self) {
                    Text("\($0) minutes").tag($0)
                }
            }
            Toggle("Completion sound", isOn: Binding(
                get: { model.settings.soundEnabled },
                set: { model.updateSound($0) }
            ))
            Toggle("Show countdown in menu bar", isOn: Binding(
                get: { model.settings.menuBarCountdownEnabled },
                set: { model.updateMenuBarCountdown($0) }
            ))
            Picker("Popup colors", selection: Binding(
                get: { model.popupColorMode },
                set: { model.updatePopupColorMode($0) }
            )) {
                ForEach(PopupColorMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            if model.popupColorMode == .fixed {
                Picker("Fixed color", selection: Binding(
                    get: { model.popupTheme },
                    set: { model.updatePopupTheme($0) }
                )) {
                    ForEach(PopupTheme.allCases) { theme in
                        Text(theme.title).tag(theme)
                    }
                }
            }
            Toggle("Launch at login", isOn: Binding(
                get: { model.settings.launchAtLoginEnabled },
                set: { model.updateLaunchAtLogin($0) }
            ))
            if let error = model.launchAtLoginError {
                Text(error).font(.caption).foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
    }

    private var mix: some View {
        Form {
            Picker("Preset", selection: Binding(
                get: { model.settings.mixPreset },
                set: { model.updatePreset($0) }
            )) {
                ForEach(MixPreset.allCases.filter { $0 != .custom }) { preset in
                    Text(preset.title).tag(preset)
                }
            }

            Picker("Movement setup", selection: Binding(
                get: { model.settings.movementMode },
                set: { model.updateMovementMode($0) }
            )) {
                ForEach(MovementMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Section("Queued task types") {
                ForEach(ActivityCategory.allCases) { category in
                    Toggle(isOn: Binding(
                        get: { model.settings.enabledCategories.contains(category) },
                        set: { model.setCategory(category, enabled: $0) }
                    )) {
                        Label(category.title, systemImage: category.symbol)
                    }
                }
            }

            Text("Only selected types appear in future breaks. At least one stays enabled. Hidden activities: \(model.settings.hiddenActivityIDs.count).")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }

    private var schedule: some View {
        Form {
            Section("Active days") {
                HStack {
                    ForEach(1...7, id: \.self) { weekday in
                        Toggle(dayLabel(weekday), isOn: Binding(
                            get: { model.settings.activeDays.contains(weekday) },
                            set: { model.setActiveDay(weekday, enabled: $0) }
                        ))
                        .toggleStyle(.button)
                    }
                }
            }
            Picker("Start hour", selection: Binding(
                get: { model.settings.activeStartHour },
                set: { model.updateSchedule(startHour: $0) }
            )) {
                ForEach(0..<24, id: \.self) { Text(hourLabel($0)).tag($0) }
            }
            Picker("End hour", selection: Binding(
                get: { model.settings.activeEndHour },
                set: { model.updateSchedule(endHour: $0) }
            )) {
                ForEach(1...24, id: \.self) { Text(hourLabel($0 % 24)).tag($0) }
            }
            Stepper(
                "Daily goal: \(model.settings.dailyPointGoal) points",
                value: Binding(
                    get: { model.settings.dailyPointGoal },
                    set: { model.updateDailyPointGoal($0) }
                ),
                in: 20...200,
                step: 10
            )
            Text("At least one active day stays enabled.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }

    private var customActivities: some View {
        Form {
            Section("Make it yours") {
                TextField("Activity name", text: $customTitle)
                TextField("What should you do?", text: $customInstruction, axis: .vertical)
                    .lineLimit(2...4)
                Picker("Category", selection: $customCategory) {
                    ForEach(ActivityCategory.allCases) { category in
                        Label(category.title, systemImage: category.symbol).tag(category)
                    }
                }
                Stepper("Duration: \(customSeconds) sec", value: $customSeconds, in: 20...60, step: 5)
                Button("Add to rotation") {
                    model.addCustomActivity(
                        title: customTitle,
                        instruction: customInstruction,
                        category: customCategory,
                        seconds: customSeconds
                    )
                    customTitle = ""
                    customInstruction = ""
                    customCategory = .calm
                    customSeconds = 30
                }
                .disabled(
                    customTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    customInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }

            Section("Your activities") {
                if model.customActivities.isEmpty {
                    Text("Add a private prompt for a ritual, stretch, reminder, or tiny reset you already like.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.customActivities) { activity in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Image(systemName: activity.category.symbol)
                                .foregroundStyle(color(for: activity.category))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.title).fontWeight(.medium)
                                Text("\(activity.category.title) · \(activity.seconds) sec")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Remove", role: .destructive) {
                                model.removeCustomActivity(activity)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Text("Custom activities stay on this Mac and use the same category colors, points, swap controls, and fair rotation as built-in activities.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Today").font(.title2.bold())
            Text("\(model.progress.today.points) points · \(model.progress.today.completedCount) completed")
            Text("Current streak: \(model.progress.currentStreak) · Longest: \(model.progress.longestStreak)")
            Text("Lifetime completed: \(model.progress.lifetimeCompleted)")
            Divider()
            Button("Delete progress…", role: .destructive) { confirmProgressReset = true }
            Button("Reset NanoBreaks…", role: .destructive) { confirmFullReset = true }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .alert("Delete all progress?", isPresented: $confirmProgressReset) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { model.resetProgress() }
        } message: {
            Text("Settings will be preserved. This cannot be undone.")
        }
        .alert("Reset NanoBreaks?", isPresented: $confirmFullReset) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { model.resetAll() }
        } message: {
            Text("All settings and progress will be deleted.")
        }
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NanoBreaks").font(.largeTitle.bold())
            Text("small breaks for the mind, body, voice, and psyche")
            Divider()
            Text("NanoBreaks offers general break ideas, not medical care or a fitness program. Choose only activities that are safe for you and your surroundings.")
            Text("Stop if you feel pain, chest discomfort, dizziness, unusual shortness of breath, or worsening symptoms. Seek appropriate medical help for urgent or persistent symptoms.")
            Text("Your settings and progress stay on this Mac. NanoBreaks does not use a camera, account, analytics, or network connection.")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }

    private func dayLabel(_ weekday: Int) -> String {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        return symbols[weekday - 1]
    }
}
