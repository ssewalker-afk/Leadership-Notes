//
//  Goal.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var goalDescription: String?
    var targetDate: Date?
    var createdDate: Date
    var modifiedDate: Date
    var isCompleted: Bool
    var completedDate: Date?
    var progress: Int // 0-100
    
    var employee: Employee?
    
    init(
        title: String,
        goalDescription: String? = nil,
        targetDate: Date? = nil,
        employee: Employee? = nil,
        progress: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.targetDate = targetDate
        self.employee = employee
        self.progress = progress
        self.isCompleted = false
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
    
    var isOverdue: Bool {
        guard let targetDate = targetDate, !isCompleted else {
            return false
        }
        return targetDate < Date()
    }
    
    func complete() {
        isCompleted = true
        completedDate = Date()
        progress = 100
        modifiedDate = Date()
    }
}
