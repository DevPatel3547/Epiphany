//
//  SaveThoughtControl.swift
//  EpiphanyWidget
//
//  Control Center / Lock Screen / Action button control that saves the
//  thought currently on the widget, without opening the app.
//

import AppIntents
import SwiftUI
import WidgetKit

struct SaveThoughtControl: ControlWidget {
    static let kind = "com.thefool.Epiphany.SaveThoughtControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: SaveCurrentThoughtIntent()) {
                Label("Save Thought", systemImage: "heart")
            }
        }
        .displayName("Save Thought")
        .description("Save the thought on your Epiphany widget to Favorites.")
    }
}
