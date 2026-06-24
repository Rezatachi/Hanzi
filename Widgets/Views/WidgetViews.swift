import SwiftUI
import WidgetKit

struct AccessoryInlineWidgetView: View {
    let entry: MandarinWidgetEntry
    var body: some View {
        if let state = entry.state {
            Text("\(state.displayText) \(state.pinyin) · \(state.shortMeaning)")
        } else {
            Text("Open Mandarin Drift")
        }
    }
}

struct AccessoryCircularWidgetView: View {
    let entry: MandarinWidgetEntry
    var body: some View {
        ZStack {
            Circle().fill(Color.driftBackgroundSecondary)
            Text(entry.state?.displayText ?? "今")
                .font(.headline)
        }
        .widgetURL(URL(string: entry.state?.deepLinkURL ?? "mandarinapp://today"))
    }
}

struct AccessoryRectangularWidgetView: View {
    let entry: MandarinWidgetEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.state?.displayText ?? "今天")
                .font(.headline)
            Text(entry.state?.pinyin ?? "jīntiān")
                .font(.caption)
            Text(entry.state?.shortMeaning ?? "today")
                .font(.caption2)
        }
        .widgetURL(URL(string: entry.state?.deepLinkURL ?? "mandarinapp://today"))
    }
}

struct SystemSmallWidgetView: View {
    let entry: MandarinWidgetEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.state?.displayText ?? "今天")
                .font(.system(size: 28, weight: .semibold))
            Text(entry.state?.pinyin ?? "jīntiān")
                .foregroundStyle(.secondary)
            Text(entry.state?.shortMeaning ?? "today")
                .font(.caption)
            Spacer()
            Text(entry.state?.progressText ?? "Ready")
                .font(.caption2)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: entry.state?.deepLinkURL ?? "mandarinapp://today"))
    }
}

struct SystemMediumWidgetView: View {
    let entry: MandarinWidgetEntry
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.state?.displayText ?? "今天").font(.system(size: 34, weight: .semibold))
                Text(entry.state?.pinyin ?? "jīntiān").foregroundStyle(.secondary)
                Text(entry.state?.shortMeaning ?? "today").font(.callout)
                Text(entry.state?.progressText ?? "Keep going").font(.caption)
            }
            Spacer()
            Image(systemName: "book.closed")
                .font(.title)
                .foregroundStyle(.red)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: entry.state?.deepLinkURL ?? "mandarinapp://today"))
    }
}

struct SystemLargeWidgetView: View {
    let entry: MandarinWidgetEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily scene").font(.headline)
            Text(entry.state?.displayText ?? "今天").font(.system(size: 42, weight: .semibold))
            Text(entry.state?.pinyin ?? "jīntiān").foregroundStyle(.secondary)
            Text(entry.state?.shortMeaning ?? "today")
            Text(entry.state?.progressText ?? "A quick tone check?")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: entry.state?.deepLinkURL ?? "mandarinapp://today"))
    }
}
