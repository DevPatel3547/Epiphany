//
//  ThoughtIntents.swift
//  Epiphany
//
//  App Intents that capture and save thoughts without opening the app.
//  Compiled into both the app and the widget extension: widget buttons and
//  Controls run them in the extension process, writing to the SwiftData
//  store in the shared App Group container.
//

import AppIntents
import WidgetKit

/// Saves (or un-saves) a specific thought to Favorites. Used by the home and Lock Screen widget buttons.
struct ToggleFavoriteThoughtIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Thought"
    static var description = IntentDescription("Save or remove a thought from your Favorites.")
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = false

    @Parameter(title: "Thought ID")
    var thoughtID: String

    init() {}

    init(thoughtID: String) {
        self.thoughtID = thoughtID
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let data = DataManager.shared
        data.toggleFavorite(id: thoughtID)
        // Keep the same thought on screen so the heart visibly flips.
        if let thought = data.getThought(by: thoughtID) {
            data.setCurrentWidgetThought(thought)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

/// Shows a different thought on the widget.
struct NextThoughtIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Thought"
    static var description = IntentDescription("Show a new thought on the Epiphany widget.")
    static var openAppWhenRun: Bool = false

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        let data = DataManager.shared
        await data.loadInitialThoughtsIfNeeded()
        if let thought = data.getRandomThought() {
            data.setCurrentWidgetThought(thought)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

/// Saves whatever thought the widget is currently showing. Backs the Control Center / Lock Screen control.
struct SaveCurrentThoughtIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Current Thought"
    static var description = IntentDescription("Save the thought currently on your Epiphany widget to Favorites.")
    static var openAppWhenRun: Bool = false

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = DataManager.shared
        guard let thought = data.currentWidgetThought else {
            return .result(dialog: "There's no thought on your widget yet.")
        }
        if !thought.isFavorite {
            data.toggleFavorite(id: thought.id)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: "Saved to Favorites.")
    }
}

/// Captures a brand-new thought typed or dictated by the user (Siri, Shortcuts, Action button, Spotlight).
struct CaptureThoughtIntent: AppIntent {
    static var title: LocalizedStringResource = "Capture Thought"
    static var description = IntentDescription("Write down a thought in Epiphany without opening the app.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Thought", requestValueDialog: "What's the thought?")
    var text: String

    init() {}

    init(text: String) {
        self.text = text
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = DataManager.shared
        guard let thought = data.captureThought(text: text) else {
            return .result(dialog: "Nothing to save.")
        }
        data.setCurrentWidgetThought(thought)
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: "Captured.")
    }
}
