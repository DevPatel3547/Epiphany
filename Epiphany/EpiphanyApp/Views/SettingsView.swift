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
                            // Check notification limit
                            let limit = notificationManager.notificationLimit
                            if notificationManager.scheduledTimes.count >= limit {
                                if !subscriptionManager.isPremium {
                                    // Show paywall for free users at limit
                                    showPaywall = true
                                }
                            } else {
                                showAddTime = true
                            }
                        }
                        
                        // Show limit indicator
                        Text("Notifications: \(notificationManager.scheduledTimes.count)/\(notificationManager.notificationLimit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !subscriptionManager.isPremium {
                            Text("Free tier: Up to 3 notifications per day")
                                .font(.caption2)
                                .foregroundColor(.orange)
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
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
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
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        if let date = Calendar.current.date(from: dateComponents) {
            return formatter.string(from: date)
        }
        
        return "\(hour):\(String(format: "%02d", minute))"
    }
}

struct AddNotificationTimeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var selectedHour = 9
    @State private var selectedMinute = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Add Notification Time")
                    .font(.title2.bold())
                    .padding(.top)
                
                HStack {
                    Picker("Hour", selection: $selectedHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)")
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    
                    Text(":")
                        .font(.title)
                    
                    Picker("Minute", selection: $selectedMinute) {
                        ForEach(0..<60) { minute in
                            Text(String(format: "%02d", minute))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }
                
                Button {
                    var components = DateComponents()
                    components.hour = selectedHour
                    components.minute = selectedMinute
                    
                    Task {
                        await notificationManager.scheduleNotification(at: components)
                        dismiss()
                    }
                } label: {
                    Text("Add Notification")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(NotificationManager.shared)
}
