import SwiftUI
import MandarinCore

struct PaywallView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Keep Mandarin visible in your day.")
                        .font(.largeTitle.bold())
                    Text("Free stays useful. Premium opens unlimited reviews, all widget modes, wallpaper study mode, advanced stats, and full deck access.")
                        .foregroundStyle(.secondary)
                    ForEach(model.products) { product in
                        Button {
                            Task { await model.purchase(productId: product.id) }
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(product.title).font(.headline)
                                Text(product.subtitle).foregroundStyle(.secondary)
                                Text(product.displayPrice).font(.title3.bold())
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.driftCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        PaywallFeatureRow(title: "Unlimited reviews", detail: "No daily cap once you want longer sessions.")
                        PaywallFeatureRow(title: "All widgets", detail: "Home and Lock Screen modes for passive recall.")
                        PaywallFeatureRow(title: "Wallpaper study mode", detail: "Save a manual learning wallpaper.")
                        PaywallFeatureRow(title: "Advanced progress", detail: "Tone weakness and mastery views.")
                    }
                    Button("Restore purchases") {
                        Task { await model.restorePurchases() }
                    }
                    Link("Terms of use", destination: URL(string: "https://example.com/terms")!)
                    Link("Privacy policy", destination: URL(string: "https://example.com/privacy")!)
                }
                .padding()
            }
            .navigationTitle("Premium")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
