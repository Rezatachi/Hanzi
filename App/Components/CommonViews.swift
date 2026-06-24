import SwiftUI
import MandarinCore

struct MandarinCardView: View {
    let entry: HanziEntry
    let characterMode: CharacterMode
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                HanziGlyphView(text: displayedText)
                Spacer()
                ToneBadge(entry.hskLevel ?? "Seed")
            }
            PinyinToneView(pinyin: entry.pinyin)
            Text(entry.shortDefinition)
                .font(.title3.weight(.medium))
            Text(entry.usageNote ?? "One useful sentence and one calm reminder.")
                .foregroundStyle(.secondary)
                .font(.callout)
            ExampleSentenceView(
                chinese: characterMode == .traditional ? (entry.exampleChineseTraditional ?? entry.exampleChineseSimplified) : entry.exampleChineseSimplified,
                pinyin: entry.examplePinyin,
                english: entry.exampleEnglish
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.driftCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.driftBorderSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(displayedText), \(entry.pinyin), \(entry.shortDefinition)")
    }

    private var displayedText: String {
        switch characterMode {
        case .simplified: entry.simplified
        case .traditional: entry.traditional
        case .both: "\(entry.simplified) / \(entry.traditional)"
        }
    }
}

struct HanziGlyphView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(DriftTypography.hanziHero)
            .foregroundStyle(Color.driftTextPrimary)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
    }
}

struct PinyinToneView: View {
    let pinyin: String
    var body: some View {
        Text(pinyin)
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.driftAccentPrimary)
            .accessibilityLabel("Pinyin \(pinyin)")
    }
}

struct ExampleSentenceView: View {
    let chinese: String
    let pinyin: String
    let english: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(chinese).font(.body.weight(.medium))
            Text(pinyin).font(.callout).foregroundStyle(.secondary)
            Text(english).font(.callout).foregroundStyle(.secondary)
        }
    }
}

struct AudioButton: View {
    let label: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.driftBackgroundSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct SRSGradeButton: View {
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(tint.opacity(0.14))
                .foregroundStyle(tint)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

struct ProgressRing: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(Color.driftBorderSubtle, lineWidth: 8)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(Color.driftAccentPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption.weight(.bold))
        }
        .frame(width: 56, height: 56)
        .accessibilityLabel("Daily goal \(Int(progress * 100)) percent complete")
    }
}

struct StreakBadge: View {
    let streak: Int
    var body: some View {
        Label("\(streak) day streak", systemImage: "flame")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.driftAccentPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.driftBackgroundSecondary)
            .clipShape(Capsule())
    }
}

struct WidgetPreviewCard: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(subtitle).font(.callout).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.driftCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
    }
}

struct PaywallFeatureRow: View {
    let title: String
    let detail: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.driftAccentSecondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct SettingRow<Accessory: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let accessory: Accessory

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.body.weight(.medium))
                if let subtitle { Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            }
            Spacer()
            accessory
        }
        .padding(.vertical, 6)
    }
}

struct SearchResultRow: View {
    let entry: HanziEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.simplified).font(.title3.weight(.semibold))
            Text(entry.pinyin).font(.subheadline).foregroundStyle(Color.driftAccentPrimary)
            Text(entry.shortDefinition).font(.callout).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct DeckChip: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.driftAccentPrimary.opacity(0.16) : Color.driftBackgroundSecondary)
            .foregroundStyle(isSelected ? Color.driftAccentPrimary : Color.driftTextPrimary)
            .clipShape(Capsule())
    }
}

struct RadicalInfoPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.driftBackgroundSecondary)
            .clipShape(Capsule())
    }
}
