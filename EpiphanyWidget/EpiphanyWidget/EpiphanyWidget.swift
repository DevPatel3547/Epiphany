//
//  EpiphanyWidget.swift
//  EpiphanyWidget
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    typealias Entry = ThoughtEntry
    
    func placeholder(in context: Context) -> ThoughtEntry {
        ThoughtEntry(
            date: Date(),
            thought: Thought(id: "placeholder", text: "Your daily shower thought", category: "General"),
            theme: getCurrentTheme()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ThoughtEntry) -> ()) {
        let thought = getRandomThoughtSync() ?? Thought(id: "1", text: "The quieter you become, the more you can hear", category: "Philosophy")
        let entry = ThoughtEntry(
            date: Date(),
            thought: thought,
            theme: getCurrentTheme()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThoughtEntry>) -> ()) {
        var entries: [ThoughtEntry] = []
        let currentDate = Date()
        
        let isPremium = AppGroup.shared?.bool(forKey: AppGroup.Keys.isPremium) ?? false
        let interval = isPremium ? 3600 : 14400
        
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset * interval, to: currentDate)!
            
            if let thought = getRandomThoughtSync() {
                let entry = ThoughtEntry(
                    date: entryDate,
                    thought: thought,
                    theme: getCurrentTheme()
                )
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getCurrentTheme() -> AppTheme {
        let themeID = AppGroup.shared?.string(forKey: AppGroup.Keys.selectedThemeID) ?? "dark"
        return AppTheme.defaultThemes.first { $0.id == themeID } ?? AppTheme.defaultThemes[1]
    }
    
    private func getRandomThoughtSync() -> Thought? {
        let thoughts = [
            Thought(id: "1", text: "If you wait for the waiter, you become the waiter", category: "Philosophy"),
            Thought(id: "2", text: "The word 'queue' is just Q followed by 4 silent letters", category: "Language"),
            Thought(id: "3", text: "Your future self is watching you through memories", category: "Existential"),
            Thought(id: "4", text: "Clapping is hitting yourself because you like something", category: "Everyday"),
            Thought(id: "5", text: "The brain named itself", category: "Science"),
            Thought(id: "6", text: "Nothing is on fire, fire is on things", category: "Science"),
            Thought(id: "7", text: "We're all just walking each other home", category: "Philosophy"),
            Thought(id: "8", text: "Your skeleton is always wet", category: "Science"),
            Thought(id: "9", text: "Reading is staring at a dead tree and hallucinating", category: "Philosophy"),
            Thought(id: "10", text: "Coffee is just bean soup", category: "Everyday"),
            Thought(id: "11", text: "Positive mind, positive vibes, positive life", category: "Motivation"),
            Thought(id: "12", text: "The quieter you become, the more you can hear", category: "Philosophy")
        ]
        return thoughts.randomElement()
    }
}

struct ThoughtEntry: TimelineEntry {
    let date: Date
    let thought: Thought
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
            
            if family != .systemSmall {
                Text(entry.thought.category.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(entry.theme.textUIColor.opacity(0.25))
                    .padding(.bottom, 20)
            }
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
        .description("Daily shower thoughts")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    EpiphanyWidget()
} timeline: {
    ThoughtEntry(
        date: .now,
        thought: Thought(id: "1", text: "Positive mind, positive vibes, positive life", category: "Motivation"),
        theme: AppTheme.defaultThemes[1]
    )
}
