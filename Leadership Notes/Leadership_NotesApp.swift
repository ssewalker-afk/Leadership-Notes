//
//  Leadership_NotesApp.swift
//  Leadership Notes
//
//  Created by Sarah Walker on 1/14/26.
//

import SwiftUI

@main
struct Leadership_NotesApp: App {
    var body: some Scene {
        WindowGroup {
            SimpleContentView()
        }
    }
}

// Simple placeholder until you fix target membership
struct SimpleContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Leadership Notes")
                .font(.largeTitle)
                .bold()
            
            Text("Please add files to target")
                .foregroundColor(.secondary)
            
            Text("Instructions:")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Select all Swift files in Project Navigator")
                Text("2. Open File Inspector (right sidebar)")
                Text("3. Check 'Leadership Notes' under Target Membership")
                Text("4. Rebuild the project")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}

