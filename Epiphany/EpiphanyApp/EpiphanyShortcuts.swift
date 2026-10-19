//
//  EpiphanyShortcuts.swift
//  Epiphany
//
//  Exposes the capture intents to Siri, Spotlight, Shortcuts and the Action button.
//

import AppIntents

struct EpiphanyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CaptureThoughtIntent(),
            phrases: [
                "Capture a thought in \(.applicationName)",
                "Save a thought to \(.applicationName)"
            ],
            shortTitle: "Capture Thought",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: SaveCurrentThoughtIntent(),
            phrases: ["Save this \(.applicationName) thought"],
            shortTitle: "Save Current Thought",
            systemImageName: "heart"
        )
        AppShortcut(
            intent: NextThoughtIntent(),
            phrases: ["Next \(.applicationName) thought"],
            shortTitle: "Next Thought",
            systemImageName: "arrow.forward"
        )
    }
}
