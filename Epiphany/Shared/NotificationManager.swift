//
//  NotificationManager.swift
//  Epiphany
//
//  Manages local notifications for daily thoughts
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    @Published var scheduledTimes: [DateComponents] = []
    
    init() {
        Task {
            await checkAuthorization()
            loadScheduledTimes()
        }
    }
    
    func requestAuthorization() async {
        do {
            isAuthorized = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            if isAuthorized {
                await scheduleDefaultNotifications()
            }
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func scheduleDefaultNotifications() async {
        // Default to 9 AM daily
        let components = DateComponents(hour: 9, minute: 0)
        await scheduleNotification(at: components)
    }
    
    func scheduleNotification(at time: DateComponents) async {
        let content = UNMutableNotificationContent()
        content.title = "Today's Thought"
        
        // Get a random thought for the notification
        if let thought = DataManager.shared.getRandomThought() {
            content.body = thought.text
        } else {
            content.body = "Tap to see your daily shower thought"
        }
        
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-thought-\(time.hour ?? 0)-\(time.minute ?? 0)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            
            // Save to scheduled times
            if !scheduledTimes.contains(where: { $0.hour == time.hour && $0.minute == time.minute }) {
                scheduledTimes.append(time)
                saveScheduledTimes()
            }
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    func removeNotification(at time: DateComponents) {
        let identifier = "daily-thought-\(time.hour ?? 0)-\(time.minute ?? 0)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        scheduledTimes.removeAll { $0.hour == time.hour && $0.minute == time.minute }
        saveScheduledTimes()
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduledTimes.removeAll()
        saveScheduledTimes()
    }
    
    private func saveScheduledTimes() {
        if let encoded = try? JSONEncoder().encode(scheduledTimes) {
            AppGroup.shared?.set(encoded, forKey: AppGroup.Keys.notificationTimes)
        }
    }
    
    private func loadScheduledTimes() {
        if let data = AppGroup.shared?.data(forKey: AppGroup.Keys.notificationTimes),
           let times = try? JSONDecoder().decode([DateComponents].self, from: data) {
            scheduledTimes = times
        }
    }
}
