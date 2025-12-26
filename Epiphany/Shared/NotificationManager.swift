//
//  NotificationManager.swift
//  Epiphany
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    @Published var scheduledTimes: [DateComponents] = []
    
    var notificationLimit: Int {
        let isPremium = AppGroup.shared?.bool(forKey: AppGroup.Keys.isPremium) ?? false
        return isPremium ? 999 : 3
    }
    
    private init() {
        Task {
            await checkAuthorizationStatus()
            await loadScheduledNotifications()
        }
    }
    
    func requestAuthorization() async {
        do {
            isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request authorization: \(error)")
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func scheduleNotification(at components: DateComponents) async {
        // Check notification limit (FREE: 3, PREMIUM: unlimited)
        let isPremium = AppGroup.shared?.bool(forKey: AppGroup.Keys.isPremium) ?? false
        
        if !isPremium && scheduledTimes.count >= 3 {
            print("Free tier limit: Maximum 3 notifications per day")
            return
        }
        
        guard isAuthorized else {
            await requestAuthorization()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Epiphany"
        content.body = "Time for your daily shower thought"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "epiphany-\(components.hour ?? 0)-\(components.minute ?? 0)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            scheduledTimes.append(components)
            saveScheduledTimes()
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    func removeNotification(at components: DateComponents) {
        let identifier = "epiphany-\(components.hour ?? 0)-\(components.minute ?? 0)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        scheduledTimes.removeAll { $0.hour == components.hour && $0.minute == components.minute }
        saveScheduledTimes()
    }
    
    private func loadScheduledNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        scheduledTimes = requests.compactMap { request in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }
            return trigger.dateComponents
        }
    }
    
    private func saveScheduledTimes() {
        // Save to UserDefaults for persistence
        if let encoded = try? JSONEncoder().encode(scheduledTimes) {
            UserDefaults.standard.set(encoded, forKey: "scheduledNotificationTimes")
        }
    }
}
