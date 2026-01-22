//
//  NoteDetailView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var note: PersonalNote
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isEditing {
                    // Edit Mode
                    TextField("Title", text: $note.title)
                        .font(AppTheme.interFont(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                    
                    Divider()
                        .background(AppTheme.textMuted.opacity(0.3))
                    
                    TextEditor(text: $note.content)
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(AppTheme.backgroundPrimary)
                        .padding()
                } else {
                    // View Mode
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(note.title)
                                .font(AppTheme.interFont(size: 28, weight: .bold))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Text(note.modifiedDate.formatted(date: .long, time: .shortened))
                                .font(AppTheme.interFont(size: 14))
                                .foregroundStyle(AppTheme.textMuted)
                            
                            Divider()
                                .background(AppTheme.textMuted.opacity(0.3))
                            
                            Text(note.content)
                                .font(AppTheme.interFont(size: 16))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(6)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        note.isPinned.toggle()
                        note.modifiedDate = Date()
                    } label: {
                        Image(systemName: note.isPinned ? "pin.fill" : "pin")
                            .foregroundStyle(note.isPinned ? AppTheme.accentPink : AppTheme.textSecondary)
                    }
                    
                    Button {
                        if isEditing {
                            note.modifiedDate = Date()
                        }
                        isEditing.toggle()
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                            .foregroundStyle(AppTheme.accentPurple)
                    }
                    
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .confirmationDialog("Delete Note", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
    
    private func deleteNote() {
        modelContext.delete(note)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(note: PersonalNote(title: "Sample Note", content: "This is a sample note content."))
    }
    .modelContainer(for: [PersonalNote.self])
}
