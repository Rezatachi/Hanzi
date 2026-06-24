import SwiftUI
import MandarinCore

struct WallpaperGeneratorView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var style: WallpaperStyle = .minimalPaper
    @State private var count = 3
    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Picker("Style", selection: $style) {
                        ForEach(WallpaperStyle.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Stepper("Cards \(count)", value: $count, in: 1...6)
                    if let image = renderedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    Text("Save this image, then set it as your wallpaper in iOS Settings or Photos.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Render") { render() }
                            .buttonStyle(.borderedProminent)
                            .tint(.driftAccentPrimary)
                        if let image = renderedImage {
                            ShareLink(item: Image(uiImage: image), preview: SharePreview("Mandarin Drift Wallpaper", image: Image(uiImage: image))) {
                                Text("Share")
                            }
                            Button("Save") {
                                Task { try? await model.wallpaperRenderer.saveToPhotos(image) }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Wallpaper")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task { render() }
        }
    }

    private func render() {
        let cards = Array(([model.featuredEntry()].compactMap { $0 } + model.relatedEntries()).prefix(count))
        let layout = WallpaperLayout(title: model.currentPlan?.sceneTitle ?? "Mandarin Drift", subtitle: model.currentPlan?.sceneDescription ?? "Daily scene", cards: cards, style: style)
        renderedImage = model.wallpaperRenderer.render(layout: layout, size: CGSize(width: 1179, height: 2556))
    }
}
