import WidgetKit
import MandarinCore

struct WidgetProvider: TimelineProvider {
    private let service = WidgetStateService()

    func placeholder(in context: Context) -> MandarinWidgetEntry {
        MandarinWidgetEntry(date: .now, state: placeholderState)
    }

    func getSnapshot(in context: Context, completion: @escaping (MandarinWidgetEntry) -> Void) {
        let state = (try? service.read()) ?? placeholderState
        completion(MandarinWidgetEntry(date: .now, state: state))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MandarinWidgetEntry>) -> Void) {
        let state = (try? service.read()) ?? placeholderState
        let current = MandarinWidgetEntry(date: .now, state: state)
        let refresh = Calendar.current.nextDate(after: .now, matching: DateComponents(hour: 0, minute: 5), matchingPolicy: .nextTime) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [current], policy: .after(refresh)))
    }

    private var placeholderState: WidgetState {
        WidgetState(
            id: UUID(),
            userId: UUID(),
            lastUpdatedAt: .now,
            featuredEntryId: UUID(),
            simplified: "今天",
            traditional: "今天",
            displayText: "今天",
            pinyin: "jīntiān",
            shortMeaning: "today",
            progressText: "3 due",
            deepLinkURL: "mandarinapp://today",
            widgetMode: .todayCard
        )
    }
}
