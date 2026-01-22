//
//  EntryTemplate.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class EntryTemplate {
    var id: UUID
    var name: String
    var category: String
    var templateContent: String
    var createdDate: Date
    
    init(
        name: String,
        category: String,
        templateContent: String
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.templateContent = templateContent
        self.createdDate = Date()
    }
}
