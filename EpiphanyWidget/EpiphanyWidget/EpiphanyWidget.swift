//
//  EpiphanyWidget.swift
//  EpiphanyWidget
//

import AppIntents
import WidgetKit
import SwiftUI
import SwiftData

/// Value snapshot of a `Thought`, safe to hand to WidgetKit outside the model context.
struct ThoughtSnapshot: Hashable {
    let id: String
    let text: String
    let category: String
    let isFavorite: Bool

    init(id: String, text: String, category: String, isFavorite: Bool = false) {
        self.id = id
        self.text = text
        self.category = category
        self.isFavorite = isFavorite
    }

    init(_ thought: Thought) {
        self.init(id: thought.id, text: thought.text, category: thought.category, isFavorite: thought.isFavorite)
    }

    static let placeholder = ThoughtSnapshot(id: "placeholder", text: "The quieter you become, the more you can hear", category: "Philosophy")
}

/// Reads thoughts from the SwiftData store in the shared App Group container,
/// so the widget shows (and saves to) the same data as the app, even if the app
/// has never been foregrounded.
struct Provider: TimelineProvider {
    typealias Entry = ThoughtEntry

    func placeholder(in context: Context) -> ThoughtEntry {
        ThoughtEntry(date: Date(), thought: .placeholder, theme: Self.currentTheme())
    }

    func getSnapshot(in context: Context, completion: @escaping (ThoughtEntry) -> ()) {
        Task { @MainActor in
            let thought = await Self.loadThoughts(count: 1).first ?? .placeholder
            completion(ThoughtEntry(date: Date(), thought: thought, theme: Self.currentTheme()))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThoughtEntry>) -> ()) {
        Task { @MainActor in
            let isPremium = AppGroup.shared?.bool(forKey: AppGroup.Keys.isPremium) ?? false
            let interval = isPremium ? 3600 : 14400
            let theme = Self.currentTheme()
            let currentDate = Date()

            let thoughts = await Self.loadThoughts(count: 24)
            var entries = thoughts.enumerated().map { offset, thought in
                ThoughtEntry(
                    date: Calendar.current.date(byAdding: .second, value: offset * interval, to: currentDate)!,
                    thought: thought,
                    theme: theme
                )
            }
            if entries.isEmpty {
                entries = [ThoughtEntry(date: currentDate, thought: .placeholder, theme: theme)]
            }
            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }

    /// First thought is the one currently pinned to the widget (so a tapped heart
    /// stays on screen); the rest are random picks from the shared store.
    @MainActor
    private static func loadThoughts(count: Int) async -> [ThoughtSnapshot] {
        let data = DataManager.shared
        await data.loadInitialThoughtsIfNeeded()

        let all = data.fetchAllThoughts()
        guard !all.isEmpty else { return [] }

        let first = data.currentWidgetThought ?? all.randomElement()!
        data.setCurrentWidgetThought(first)

        var picks = [ThoughtSnapshot(first)]
        for thought in all.shuffled() where picks.count < count && thought.id != first.id {
            picks.append(ThoughtSnapshot(thought))
        }
        return picks
    }

    static func currentTheme() -> AppTheme {
        let themeID = AppGroup.shared?.string(forKey: AppGroup.Keys.selectedThemeID) ?? "dark"
        return AppTheme.defaultThemes.first { $0.id == themeID } ?? AppTheme.defaultThemes[1]
    }
}

struct ThoughtEntry: TimelineEntry {
    let date: Date
    let thought: ThoughtSnapshot
    let theme: AppTheme
}

struct EpiphanyWidgetEntryView: View {
    var entry: ThoughtEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text(entry.thought.text)
                .font(fontForFamily(family))
                .fontWeight(.medium)
                .foregroundColor(entry.theme.textUIColor)
                .multilineTextAlignment(.center)
                .lineSpacing(lineSpacingForFamily(family))
                .padding(.horizontal, paddingForFamily(family))
                .minimumScaleFactor(0.7)
            
            Spacer()
            
            HStack {
                // Interactive (iOS 17+): runs the intent in the widget extension,
                // writing to the shared SwiftData store without opening the app.
                Button(intent: ToggleFavoriteThoughtIntent(thoughtID: entry.thought.id)) {
                    Image(systemName: entry.thought.isFavorite ? "heart.fill" : "heart")
                }
                .accessibilityLabel(entry.thought.isFavorite ? "Remove from Favorites" : "Save to Favorites")
                
                Spacer()
                
                if family != .systemSmall {
                    Text(entry.thought.category.uppercased())
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(entry.theme.textUIColor.opacity(0.25))
                    
                    Spacer()
                }
                
                Button(intent: NextThoughtIntent()) {
                    Image(systemName: "arrow.forward")
                }
                .accessibilityLabel("Next thought")
            }
            .buttonStyle(.plain)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(entry.theme.accentUIColor)
            .padding(.horizontal, family == .systemSmall ? 4 : 12)
            .padding(.bottom, family == .systemSmall ? 0 : 8)
        }
        .widgetURL(URL(string: "epiphany://thought/\(entry.thought.id)"))
    }
    
    private func fontForFamily(_ family: WidgetFamily) -> Font {
        switch family {
        case .systemSmall:
            return .system(size: 17, weight: .medium, design: .rounded)
        case .systemMedium:
            return .system(size: 22, weight: .medium, design: .rounded)
        case .systemLarge:
            return .system(size: 30, weight: .medium, design: .rounded)
        default:
            return .body
        }
    }
    
    private func lineSpacingForFamily(_ family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall:
            return 5
        case .systemMedium:
            return 7
        case .systemLarge:
            return 10
        default:
            return 6
        }
    }
    
    private func paddingForFamily(_ family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall:
            return 16
        case .systemMedium:
            return 28
        case .systemLarge:
            return 40
        default:
            return 20
        }
    }
}

struct EpiphanyWidget: Widget {
    let kind: String = "EpiphanyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EpiphanyWidgetEntryView(entry: entry)
                .containerBackground(entry.theme.backgroundUIColor, for: .widget)
        }
        .configurationDisplayName("Epiphany")
        .description("Daily shower thoughts. Tap the heart to save one without opening the app.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    EpiphanyWidget()
} timeline: {
    ThoughtEntry(
        date: .now,
        thought: ThoughtSnapshot(id: "1", text: "Positive mind, positive vibes, positive life", category: "Motivation"),
        theme: AppTheme.defaultThemes[1]
    )
}
