//
//  Reminder.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class Reminder {
    var id: UUID
    var title: String
    var message: String?
    var dueDate: Date
    var isCompleted: Bool
    var createdDate: Date
    var relatedEntryID: UUID?
    var relatedEmployeeID: UUID?
    
    init(
        title: String,
        message: String? = nil,
        dueDate: Date,
        relatedEntryID: UUID? = nil,
        relatedEmployeeID: UUID? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.dueDate = dueDate
        self.isCompleted = false
        self.createdDate = Date()
        self.relatedEntryID = relatedEntryID
        self.relatedEmployeeID = relatedEmployeeID
    }
    
    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
}
