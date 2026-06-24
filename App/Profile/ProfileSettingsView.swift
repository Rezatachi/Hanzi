import SwiftUI
import MandarinCore

struct ProfileSettingsView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var router: AppRouter
    @State private var reminderPreset: ReminderPreset = .none

    var body: some View {
        List {
            Section("Subscription") {
                SettingRow(title: "Status", subtitle: model.subscription.isActive ? "Premium active" : "Free tier") {
                    Button("Manage") { router.activeSheet = .paywall }
                }
            }
            Section("Learning") {
                Picker("Characters", selection: $model.profile.selectedCharacterMode) {
                    ForEach(CharacterMode.allCases) { Text($0.title).tag($0) }
                }
                Picker("Pinyin", selection: $model.profile.pinyinVisibility) {
                    ForEach(PinyinVisibility.allCases) { Text($0.rawValue).tag($0) }
                }
                Stepper("Daily goal \(model.profile.dailyGoal)", value: $model.profile.dailyGoal, in: 1...10)
            }
            Section("Speech") {
                Slider(value: $model.profile.speechRate, in: 0.35...0.55)
                Picker("Voice", selection: Binding(
                    get: { model.profile.ttsVoiceIdentifier ?? "" },
                    set: { model.profile.ttsVoiceIdentifier = $0.isEmpty ? nil : $0 }
                )) {
                    Text("System default").tag("")
                    ForEach(model.speech.availableMandarinVoices()) { voice in
                        Text("\(voice.name) (\(voice.languageCode))").tag(voice.id)
                    }
                }
            }
            Section("Reminders") {
                Picker("Preset", selection: $reminderPreset) {
                    ForEach(ReminderPreset.allCases) { Text($0.rawValue.capitalized).tag($0) }
                }
                Button("Update reminder") {
                    Task { await model.requestReminderPermission(preset: reminderPreset) }
                }
            }
            Section("Tools") {
                Button("Refresh dictionary catalog") {
                    Task { await model.refreshLargeDictionary() }
                }
                Button("Widget settings") { router.activeSheet = .widgetSettings }
                Button("Wallpaper generator") { router.activeSheet = .wallpaper }
                NavigationLink("Saved words") { SavedView() }
                NavigationLink("Help") { HelpView() }
            }
            Section("Privacy") {
                Toggle("Analytics opt-out", isOn: $model.profile.analyticsOptOut)
                Button("Export data") {}
                Button("Delete local data", role: .destructive) {}
            }
        }
        .navigationTitle("Profile")
        .onChange(of: model.profile.selectedCharacterMode) { _, _ in Task { await model.saveProfile() } }
        .onChange(of: model.profile.pinyinVisibility) { _, _ in Task { await model.saveProfile() } }
        .onChange(of: model.profile.dailyGoal) { _, _ in Task { await model.saveProfile() } }
        .onChange(of: model.profile.speechRate) { _, _ in Task { await model.saveProfile() } }
        .onChange(of: model.profile.ttsVoiceIdentifier) { _, _ in Task { await model.saveProfile() } }
        .onChange(of: model.profile.analyticsOptOut) { _, newValue in
            Task {
                if newValue { await model.analytics.optOut() }
                await model.saveProfile()
            }
        }
    }
}
