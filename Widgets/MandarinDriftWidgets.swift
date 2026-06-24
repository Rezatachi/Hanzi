import SwiftUI
import WidgetKit
import MandarinCore

@main
struct MandarinDriftWidgetsBundle: WidgetBundle {
    var body: some Widget {
        MandarinDriftWidget()
    }
}

struct MandarinDriftWidget: Widget {
    let kind = "MandarinDriftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetFamilyView(entry: entry)
        }
        .configurationDisplayName("Mandarin Drift")
        .description("Daily Mandarin at a glance.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge])
    }
}

private struct WidgetFamilyView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MandarinWidgetEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            AccessoryInlineWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularWidgetView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularWidgetView(entry: entry)
        case .systemSmall:
            SystemSmallWidgetView(entry: entry)
        case .systemMedium:
            SystemMediumWidgetView(entry: entry)
        default:
            SystemLargeWidgetView(entry: entry)
        }
    }
}
