import SwiftUI

struct HelpView: View {
    var body: some View {
        List {
            Section("Widgets") {
                Text("Widgets mirror the shared App Group state. Open the app once to refresh today’s card.")
            }
            Section("Pronunciation") {
                Text("Pronunciation uses native iOS Mandarin text-to-speech voices. It is generated TTS, not recorded studio audio.")
            }
            Section("Subscription") {
                Text("Restore purchases is available from the paywall. Core learning stays available without an account.")
            }
            Section("Support") {
                Text("support@example.com")
            }
        }
        .navigationTitle("Help")
    }
}
