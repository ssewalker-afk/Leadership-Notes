//
//  PersonalNote.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class PersonalNote {
    var id: UUID
    var title: String
    var content: String
    var createdDate: Date
    var modifiedDate: Date
    var isPinned: Bool
    
    init(
        title: String,
        content: String,
        isPinned: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.isPinned = isPinned
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}
