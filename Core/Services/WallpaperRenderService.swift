import Photos
import SwiftUI
import UIKit

public enum WallpaperStyle: String, CaseIterable, Codable, Sendable, Identifiable {
    case minimalPaper
    case ink
    case dark
    case grid
    case redAccent

    public var id: String { rawValue }
}

public struct WallpaperLayout: Sendable, Equatable {
    public let title: String
    public let subtitle: String
    public let cards: [HanziEntry]
    public let style: WallpaperStyle

    public init(title: String, subtitle: String, cards: [HanziEntry], style: WallpaperStyle) {
        self.title = title
        self.subtitle = subtitle
        self.cards = cards
        self.style = style
    }
}

public protocol WallpaperRendering: Sendable {
    @MainActor func render(layout: WallpaperLayout, size: CGSize) -> UIImage
    @MainActor func saveToPhotos(_ image: UIImage) async throws
}

public struct WallpaperRenderService: WallpaperRendering {
    public init() {}

    @MainActor
    public func render(layout: WallpaperLayout, size: CGSize) -> UIImage {
        let renderer = ImageRenderer(content: WallpaperCanvas(layout: layout, size: size))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }

    @MainActor
    public func saveToPhotos(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}

public struct WallpaperCanvas: View {
    let layout: WallpaperLayout
    let size: CGSize

    public init(layout: WallpaperLayout, size: CGSize) {
        self.layout = layout
        self.size = size
    }

    public var body: some View {
        ZStack {
            background
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: size.height * 0.16)
                Text(layout.title)
                    .font(.system(size: 28, weight: .semibold))
                Text(layout.subtitle)
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                VStack(spacing: 14) {
                    ForEach(Array(layout.cards.enumerated()), id: \.element.id) { _, card in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(card.simplified)
                                .font(.system(size: 42, weight: .medium, design: .rounded))
                            Text(card.pinyin)
                                .font(.system(size: 18, weight: .medium))
                            Text(card.shortDefinition)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(.ultraThinMaterial.opacity(layout.style == .dark ? 0.3 : 0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                Spacer()
            }
            .padding(28)
        }
        .frame(width: size.width, height: size.height)
    }

    @ViewBuilder
    private var background: some View {
        switch layout.style {
        case .minimalPaper:
            Color(red: 0.97, green: 0.95, blue: 0.91)
        case .ink:
            LinearGradient(colors: [Color(red: 0.94, green: 0.93, blue: 0.89), Color(red: 0.88, green: 0.87, blue: 0.83)], startPoint: .top, endPoint: .bottom)
        case .dark:
            Color(red: 0.1, green: 0.1, blue: 0.12)
        case .grid:
            Color(red: 0.95, green: 0.94, blue: 0.9).overlay(gridLines)
        case .redAccent:
            LinearGradient(colors: [Color(red: 0.98, green: 0.95, blue: 0.93), Color(red: 0.82, green: 0.18, blue: 0.18).opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var gridLines: some View {
        GeometryReader { proxy in
            Path { path in
                stride(from: 0, through: proxy.size.width, by: 36).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                }
                stride(from: 0, through: proxy.size.height, by: 36).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                }
            }
            .stroke(Color.black.opacity(0.05), lineWidth: 1)
        }
    }
}
