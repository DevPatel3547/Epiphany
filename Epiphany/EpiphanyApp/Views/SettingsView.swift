//
//  SettingsView.swift
//  Epiphany
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var showPaywall = false
    @State private var showAddTime = false
    
    var body: some View {
        NavigationStack {
            List {
                // Subscription
                Section("Subscription") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(subscriptionManager.isPremium ? "Premium" : "Free")
                            .foregroundColor(.secondary)
                    }
                    
                    if !subscriptionManager.isPremium {
                        Button("Upgrade to Premium") {
                            showPaywall = true
                        }
                    } else {
                        Button("Manage Subscription") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                }
                
                // Notifications
                Section("Notifications") {
                    if notificationManager.isAuthorized {
                        ForEach(notificationManager.scheduledTimes, id: \.self) { time in
                            HStack {
                                Text(formatTime(time))
                                Spacer()
                                Button {
                                    notificationManager.removeNotification(at: time)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Button("Add Time") {
                            showAddTime = true
                        }
                    } else {
                        Button("Enable Notifications") {
                            Task {
                                await notificationManager.requestAuthorization()
                            }
                        }
                    }
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showAddTime) {
                AddNotificationTimeView()
            }
        }
    }
    
    private func formatTime(_ components: DateComponents) -> String {
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}

struct AddNotificationTimeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Spacer()
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
                        Task {
                            await notificationManager.scheduleNotification(at: components)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
