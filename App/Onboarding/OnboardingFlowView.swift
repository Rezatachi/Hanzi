import SwiftUI
import MandarinCore

struct OnboardingFlowView: View {
    @EnvironmentObject private var model: AppModel
    @State private var step = 0
    @State private var reminderPreset: ReminderPreset = .none

    var body: some View {
        ZStack {
            Color.driftCardBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ProgressView(value: Double(step + 1), total: 8)
                            .tint(.driftAccentPrimary)
                        Group {
                            switch step {
                            case 0: welcome
                            case 1: goals
                            case 2: level
                            case 3: characterMode
                            case 4: pinyin
                            case 5: dailyGoal
                            case 6: reminders
                            default: firstCard
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 96)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                HStack {
                    if step > 0 {
                        Button("Back") { step -= 1 }
                    }
                    Spacer()
                    Button(step == 7 ? "Start learning" : "Continue") {
                        Task {
                            if step == 6 { await model.requestReminderPermission(preset: reminderPreset) }
                            if step == 7 {
                                await model.completeOnboarding()
                            } else {
                                step += 1
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.driftAccentPrimary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .background(Color.driftCardBackground)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mandarin, one glance at a time.")
                .font(.largeTitle.bold())
            Text("Build recognition through small daily moments. Characters, tones, and real sentences stay visible without pressure.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var goals: some View {
        selectionScreen(title: "What do you want Mandarin for?", subtitle: "Pick the path that feels useful now.") {
            ForEach(LearningGoal.allCases) { goal in
                optionRow(title: goal.rawValue.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression).capitalized, isSelected: model.profile.goals.contains(goal)) {
                    if model.profile.goals.contains(goal) {
                        model.profile.goals.removeAll { $0 == goal }
                    } else {
                        model.profile.goals.append(goal)
                    }
                }
            }
        }
    }

    private var level: some View {
        selectionScreen(title: "Where are you starting?", subtitle: "We’ll tune the queue and examples.") {
            ForEach(MandarinLevel.allCases) { level in
                optionRow(title: level.title, isSelected: model.profile.mandarinLevel == level) {
                    model.profile.mandarinLevel = level
                }
            }
        }
    }

    private var characterMode: some View {
        selectionScreen(title: "Which characters do you want to see?", subtitle: "You can change this later.") {
            ForEach(CharacterMode.allCases) { mode in
                optionRow(title: mode.title, isSelected: model.profile.selectedCharacterMode == mode) {
                    model.profile.selectedCharacterMode = mode
                }
            }
        }
    }

    private var pinyin: some View {
        selectionScreen(title: "How should pinyin appear?", subtitle: "Tone-first design still keeps it accessible.") {
            ForEach(PinyinVisibility.allCases) { visibility in
                optionRow(title: visibility.rawValue.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression).capitalized, isSelected: model.profile.pinyinVisibility == visibility) {
                    model.profile.pinyinVisibility = visibility
                }
            }
        }
    }

    private var dailyGoal: some View {
        selectionScreen(title: "Set a daily pace.", subtitle: "Small and steady works.") {
            ForEach([1, 3, 5, 10], id: \.self) { count in
                optionRow(title: "\(count) card\(count > 1 ? "s" : "") a day", isSelected: model.profile.dailyGoal == count) {
                    model.profile.dailyGoal = count
                }
            }
        }
    }

    private var reminders: some View {
        selectionScreen(title: "Would reminders help?", subtitle: "One quiet reminder. No spam.") {
            ForEach(ReminderPreset.allCases) { preset in
                optionRow(title: preset.rawValue.capitalized, isSelected: reminderPreset == preset) {
                    reminderPreset = preset
                }
            }
        }
    }

    private var firstCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Here’s today’s first card.")
                .font(.title2.bold())
            if let entry = model.entries.first {
                MandarinCardView(entry: entry, characterMode: model.profile.selectedCharacterMode)
            }
            Text("Widgets and wallpaper come next, once the card already feels useful.")
                .foregroundStyle(.secondary)
        }
    }

    private func selectionScreen<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title2.bold())
            Text(subtitle).foregroundStyle(.secondary)
            content()
        }
    }

    private func optionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundStyle(.primary)
                Spacer()
                if isSelected { Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.driftAccentPrimary) }
            }
            .padding()
            .background(Color.driftCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
