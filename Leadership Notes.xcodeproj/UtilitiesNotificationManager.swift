//
//  NotificationManager.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import UserNotifications
import SwiftData

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        Task {
            await checkAuthorization()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleFollowUpNotification(for entry: CoachingEntry, daysInAdvance: Int) async {
        guard isAuthorized,
              let followUpDate = entry.followUpDate,
              !entry.isFollowUpComplete else { return }
        
        let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: followUpDate) ?? followUpDate
        
        // Only schedule if in the future
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Follow-up Reminder"
        content.body = "Follow up on: \(entry.title)"
        if let employeeName = entry.employee?.fullName {
            content.subtitle = "Employee: \(employeeName)"
        }
        content.sound = .default
        content.categoryIdentifier = "FOLLOWUP"
        content.userInfo = ["entryID": entry.id.uuidString]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "followup-\(entry.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling follow-up notification: \(error)")
        }
    }
    
    func scheduleBirthdayNotification(for employee: Employee, daysInAdvance: Int) async {
        guard isAuthorized,
              let birthday = employee.birthday,
              let upcomingBirthday = employee.upcomingBirthday else { return }
        
        let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: upcomingBirthday) ?? upcomingBirthday
        
        // Only schedule if in the future
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Birthday Reminder"
        content.body = "\(employee.fullName)'s birthday is coming up!"
        content.subtitle = upcomingBirthday.formatted(date: .abbreviated, time: .omitted)
        content.sound = .default
        content.categoryIdentifier = "BIRTHDAY"
        content.userInfo = ["employeeID": employee.id.uuidString]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: notificationDate)
        var trigger = dateComponents
        trigger.hour = 9  // 9 AM
        trigger.minute = 0
        
        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "birthday-\(employee.id.uuidString)",
            content: content,
            trigger: calendarTrigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling birthday notification: \(error)")
        }
    }
    
    func scheduleAnniversaryNotification(for employee: Employee, daysInAdvance: Int) async {
        guard isAuthorized,
              let hireDate = employee.hireDate,
              let upcomingAnniversary = employee.upcomingAnniversary else { return }
        
        let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: upcomingAnniversary) ?? upcomingAnniversary
        
        // Only schedule if in the future
        guard notificationDate > Date() else { return }
        
        let yearsEmployed = employee.yearsEmployed ?? 0
        
        let content = UNMutableNotificationContent()
        content.title = "Work Anniversary"
        content.body = "\(employee.fullName)'s \(yearsEmployed)-year anniversary is coming up!"
        content.subtitle = upcomingAnniversary.formatted(date: .abbreviated, time: .omitted)
        content.sound = .default
        content.categoryIdentifier = "ANNIVERSARY"
        content.userInfo = ["employeeID": employee.id.uuidString]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: notificationDate)
        var trigger = dateComponents
        trigger.hour = 9  // 9 AM
        trigger.minute = 0
        
        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "anniversary-\(employee.id.uuidString)",
            content: content,
            trigger: calendarTrigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling anniversary notification: \(error)")
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelFollowUpNotification(for entry: CoachingEntry) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["followup-\(entry.id.uuidString)"])
    }
    
    func cancelBirthdayNotification(for employee: Employee) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["birthday-\(employee.id.uuidString)"])
    }
    
    func cancelAnniversaryNotification(for employee: Employee) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["anniversary-\(employee.id.uuidString)"])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Reschedule All
    
    func rescheduleAllNotifications(entries: [CoachingEntry], employees: [Employee], settings: NotificationSettings) async {
        // Cancel all existing
        cancelAllNotifications()
        
        guard settings.notificationsEnabled else { return }
        
        // Reschedule follow-ups
        for entry in entries {
            await scheduleFollowUpNotification(for: entry, daysInAdvance: settings.followUpReminderDays)
        }
        
        // Reschedule birthdays
        for employee in employees {
            if employee.birthday != nil {
                await scheduleBirthdayNotification(for: employee, daysInAdvance: settings.birthdayReminderDays)
            }
            
            if employee.hireDate != nil {
                await scheduleAnniversaryNotification(for: employee, daysInAdvance: settings.anniversaryReminderDays)
            }
        }
    }
    
    // MARK: - Get Pending
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}

// MARK: - Notification Settings

struct NotificationSettings {
    var notificationsEnabled: Bool
    var followUpReminderDays: Int
    var birthdayReminderDays: Int
    var anniversaryReminderDays: Int
    
    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.followUpReminderDays = UserDefaults.standard.integer(forKey: "followUpReminderDays")
        self.birthdayReminderDays = UserDefaults.standard.integer(forKey: "birthdayReminderDays")
        self.anniversaryReminderDays = UserDefaults.standard.integer(forKey: "anniversaryReminderDays")
        
        // Set defaults if not previously set
        if followUpReminderDays == 0 { followUpReminderDays = 1 }
        if birthdayReminderDays == 0 { birthdayReminderDays = 7 }
        if anniversaryReminderDays == 0 { anniversaryReminderDays = 7 }
    }
}
