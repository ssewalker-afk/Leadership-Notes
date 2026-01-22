//
//  AppState.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isLocked: Bool = false
    @Published var hasSetPIN: Bool = false
    @Published var currentTab: Tab = .coachingLog
    @Published var notifications: [AppNotification] = []
    
    let notificationManager = NotificationManager.shared
    
    enum Tab: String, CaseIterable {
        case coachingLog = "Coaching Log"
        case reports = "Reports"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .coachingLog: return "list.clipboard"
            case .reports: return "chart.bar"
            case .settings: return "gear"
            }
        }
    }
    
    init() {
        loadPINStatus()
        checkLockStatus()
        
        Task {
            await notificationManager.checkAuthorization()
        }
    }
    
    private func loadPINStatus() {
        hasSetPIN = UserDefaults.standard.string(forKey: "app_pin") != nil
    }
    
    private func checkLockStatus() {
        isLocked = hasSetPIN
    }
    
    func unlock() {
        isLocked = false
    }
    
    func lock() {
        if hasSetPIN {
            isLocked = true
        }
    }
    
    func setPIN(_ pin: String) {
        UserDefaults.standard.set(pin, forKey: "app_pin")
        hasSetPIN = true
    }
    
    func removePIN() {
        UserDefaults.standard.removeObject(forKey: "app_pin")
        hasSetPIN = false
        isLocked = false
    }
    
    func verifyPIN(_ pin: String) -> Bool {
        guard let storedPIN = UserDefaults.standard.string(forKey: "app_pin") else {
            return false
        }
        return pin == storedPIN
    }
    
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
    }
    
    func clearNotification(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let type: NotificationType
    
    enum NotificationType {
        case reminder
        case birthday
        case anniversary
        case followUp
    }
}
