//
//  EpiphanyWidget.swift
//  EpiphanyWidget
//
//  Widget implementation
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    typealias Entry = ThoughtEntry
    
    func placeholder(in context: Context) -> ThoughtEntry {
        ThoughtEntry(
            date: Date(),
            thought: Thought(id: "placeholder", text: "Loading...", category: "General"),
            theme: AppTheme.defaultThemes[0]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ThoughtEntry) -> ()) {
        let thought = getRandomThoughtSync() ?? Thought(id: "1", text: "A shower thought appears here", category: "Philosophy")
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
        
        // Generate entries for next 24 hours
        // Free: Every 4 hours, Premium: Every hour
        let isPremium = AppGroup.shared?.bool(forKey: AppGroup.Keys.isPremium) ?? false
        let interval = isPremium ? 3600 : 14400 // 1 hour vs 4 hours
        
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
        let themeID = AppGroup.shared?.string(forKey: AppGroup.Keys.selectedThemeID) ?? "classic"
        return AppTheme.defaultThemes.first { $0.id == themeID } ?? AppTheme.defaultThemes[0]
    }
    
    private func getRandomThoughtSync() -> Thought? {
        // Simple synchronous random thought for widgets
        // Since widgets run in background, we use a simpler approach
        let thoughts = [
            Thought(id: "1", text: "If you wait for the waiter, you become the waiter", category: "Philosophy"),
            Thought(id: "2", text: "The word 'queue' is just the letter Q followed by 4 silent letters", category: "Language"),
            Thought(id: "3", text: "Your future self is watching you right now through memories", category: "Existential"),
            Thought(id: "4", text: "Clapping is just hitting yourself because you like something", category: "Everyday"),
            Thought(id: "5", text: "The brain named itself", category: "Science")
        ]
        return thoughts.randomElement()
    }
}

struct ThoughtEntry: TimelineEntry {
    let date: Date
    let thought: Thought
    let theme: AppTheme
}

struct EpiphanyWidgetEntryView : View {
    var entry: ThoughtEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            entry.theme.backgroundUIColor
            
            VStack(spacing: 8) {
                if family == .systemLarge {
                    Spacer()
                }
                
                Text(entry.thought.text)
                    .font(fontForFamily(family))
                    .foregroundColor(entry.theme.textUIColor)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(family == .systemSmall ? 3 : nil)
                    .padding()
                
                if family != .systemSmall {
                    Text(entry.thought.category)
                        .font(.caption2)
                        .foregroundColor(entry.theme.accentUIColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(entry.theme.accentUIColor.opacity(0.2)))
                }
                
                if family == .systemLarge {
                    Spacer()
                }
            }
        }
        .widgetURL(URL(string: "epiphany://thought/\(entry.thought.id)"))
    }
    
    private func fontForFamily(_ family: WidgetFamily) -> Font {
        switch family {
        case .systemSmall:
            return .system(size: 14, weight: .medium)
        case .systemMedium:
            return .system(size: 16, weight: .medium)
        case .systemLarge:
            return .system(size: 20, weight: .medium)
        default:
            return .body
        }
    }
}

struct EpiphanyWidget: Widget {
    let kind: String = "EpiphanyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EpiphanyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Epiphany")
        .description("Daily shower thoughts on your home screen")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    EpiphanyWidget()
} timeline: {
    ThoughtEntry(
        date: .now,
        thought: Thought(id: "1", text: "If you wait for the waiter, you become the waiter", category: "Philosophy"),
        theme: AppTheme.defaultThemes[0]
    )
}
