//
//  CoachingEntry.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class CoachingEntry {
    var id: UUID
    var title: String
    var content: String
    var category: String
    var date: Date
    var createdDate: Date
    var modifiedDate: Date
    var imageData: [Data]?
    var tags: [String]?
    var followUpDate: Date?
    var isFollowUpComplete: Bool
    
    var employee: Employee?
    
    init(
        title: String,
        content: String,
        category: String,
        date: Date = Date(),
        employee: Employee? = nil,
        imageData: [Data]? = nil,
        tags: [String]? = nil,
        followUpDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.date = date
        self.employee = employee
        self.imageData = imageData
        self.tags = tags
        self.followUpDate = followUpDate
        self.isFollowUpComplete = false
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
    
    var needsFollowUp: Bool {
        guard let followUpDate = followUpDate, !isFollowUpComplete else {
            return false
        }
        return followUpDate >= Date()
    }
}

// MARK: - Entry Categories
enum EntryCategory: String, CaseIterable, Identifiable {
    case performance = "Performance"
    case coaching = "Coaching"
    case recognition = "Recognition"
    case concern = "Concern"
    case goal = "Goal"
    case oneOnOne = "1:1 Meeting"
    case feedback = "Feedback"
    case training = "Training"
    case other = "Other"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .performance: return "7C3AED"
        case .coaching: return "22D3EE"
        case .recognition: return "10B981"
        case .concern: return "EF4444"
        case .goal: return "F59E0B"
        case .oneOnOne: return "EC4899"
        case .feedback: return "8B5CF6"
        case .training: return "3B82F6"
        case .other: return "6B7280"
        }
    }
    
    var icon: String {
        switch self {
        case .performance: return "chart.line.uptrend.xyaxis"
        case .coaching: return "person.2"
        case .recognition: return "star.fill"
        case .concern: return "exclamationmark.triangle"
        case .goal: return "target"
        case .oneOnOne: return "bubble.left.and.bubble.right"
        case .feedback: return "message"
        case .training: return "book"
        case .other: return "folder"
        }
    }
}
