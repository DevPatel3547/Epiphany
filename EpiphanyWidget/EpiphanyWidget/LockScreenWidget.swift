//
//  LockScreenWidget.swift
//  EpiphanyWidget
//
//  Lock Screen widget implementation
//

import WidgetKit
import SwiftUI

struct EpiphanyLockScreenWidget: Widget {
    let kind: String = "EpiphanyLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Epiphany Lock")
        .description("Shower thoughts on your lock screen")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .fill(entry.theme.backgroundUIColor)
                
                VStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(entry.theme.accentUIColor)
                    Text("Think")
                        .font(.caption2)
                        .foregroundColor(entry.theme.textUIColor)
                }
            }
            
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.thought.category)
                    .font(.caption2.bold())
                    .foregroundColor(entry.theme.accentUIColor)
                
                Text(entry.thought.text)
                    .font(.caption2)
                    .foregroundColor(entry.theme.textUIColor)
                    .lineLimit(3)
            }
            
        case .accessoryInline:
            Text(entry.thought.text)
                .font(.caption2)
                .lineLimit(1)
            
        default:
            EmptyView()
        }
    }
}
