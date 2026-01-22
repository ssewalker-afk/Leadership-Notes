//
//  Employee.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class Employee {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String?
    var phoneNumber: String?
    var jobTitle: String?
    var department: String?
    var hireDate: Date?
    var birthday: Date?
    var profileImageData: Data?
    var notes: String?
    var createdDate: Date
    var modifiedDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \CoachingEntry.employee)
    var entries: [CoachingEntry]?
    
    @Relationship(deleteRule: .cascade, inverse: \Goal.employee)
    var goals: [Goal]?
    
    init(
        firstName: String,
        lastName: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        jobTitle: String? = nil,
        department: String? = nil,
        hireDate: Date? = nil,
        birthday: Date? = nil,
        profileImageData: Data? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.jobTitle = jobTitle
        self.department = department
        self.hireDate = hireDate
        self.birthday = birthday
        self.profileImageData = profileImageData
        self.notes = notes
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
    
    var yearsEmployed: Int? {
        guard let hireDate = hireDate else { return nil }
        return Calendar.current.dateComponents([.year], from: hireDate, to: Date()).year
    }
    
    var upcomingBirthday: Date? {
        guard let birthday = birthday else { return nil }
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.month, .day], from: birthday)
        components.year = calendar.component(.year, from: now)
        
        guard var nextBirthday = calendar.date(from: components) else { return nil }
        
        if nextBirthday < now {
            components.year! += 1
            nextBirthday = calendar.date(from: components) ?? nextBirthday
        }
        
        return nextBirthday
    }
    
    var upcomingAnniversary: Date? {
        guard let hireDate = hireDate else { return nil }
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.month, .day], from: hireDate)
        components.year = calendar.component(.year, from: now)
        
        guard var nextAnniversary = calendar.date(from: components) else { return nil }
        
        if nextAnniversary < now {
            components.year! += 1
            nextAnniversary = calendar.date(from: components) ?? nextAnniversary
        }
        
        return nextAnniversary
    }
}
