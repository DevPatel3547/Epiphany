//
//  EpiphanyWidgetBundle.swift
//  EpiphanyWidget
//

import WidgetKit
import SwiftUI

@main
struct EpiphanyWidgetBundle: WidgetBundle {
    var body: some Widget {
        EpiphanyWidget()
        EpiphanyLockScreenWidget()
        SaveThoughtControl()
    }
}
