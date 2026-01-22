//
//  AddNoteView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var content = ""
    @State private var isPinned = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title Field
                    TextField("Title", text: $title)
                        .font(AppTheme.interFont(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                    
                    Divider()
                        .background(AppTheme.textMuted.opacity(0.3))
                    
                    // Content Editor
                    TextEditor(text: $content)
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(AppTheme.backgroundPrimary)
                        .padding()
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            isPinned.toggle()
                        } label: {
                            Image(systemName: isPinned ? "pin.fill" : "pin")
                                .foregroundStyle(isPinned ? AppTheme.accentPink : AppTheme.textSecondary)
                        }
                        
                        Button("Save") {
                            saveNote()
                        }
                        .foregroundStyle(AppTheme.accentPurple)
                        .fontWeight(.semibold)
                        .disabled(title.isEmpty)
                    }
                }
            }
        }
    }
    
    private func saveNote() {
        let note = PersonalNote(
            title: title,
            content: content,
            isPinned: isPinned
        )
        
        modelContext.insert(note)
        dismiss()
    }
}

#Preview {
    AddNoteView()
        .modelContainer(for: [PersonalNote.self])
}
