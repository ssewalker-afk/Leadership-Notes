//
//  NotesView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PersonalNote.modifiedDate, order: .reverse) private var notes: [PersonalNote]
    
    @State private var showingAddNote = false
    @State private var searchText = ""
    
    var filteredNotes: [PersonalNote] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var pinnedNotes: [PersonalNote] {
        filteredNotes.filter { $0.isPinned }
    }
    
    var unpinnedNotes: [PersonalNote] {
        filteredNotes.filter { !$0.isPinned }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                if filteredNotes.isEmpty {
                    emptyState
                } else {
                    notesList
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.accentPurple)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search notes...")
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
            }
        }
    }
    
    private var notesList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if !pinnedNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pinned")
                            .font(AppTheme.interFont(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.textMuted)
                            .textCase(.uppercase)
                            .padding(.horizontal)
                        
                        ForEach(pinnedNotes) { note in
                            NavigationLink(destination: NoteDetailView(note: note)) {
                                NoteCard(note: note)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                if !unpinnedNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        if !pinnedNotes.isEmpty {
                            Text("All Notes")
                                .font(AppTheme.interFont(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.textMuted)
                                .textCase(.uppercase)
                                .padding(.horizontal)
                        }
                        
                        ForEach(unpinnedNotes) { note in
                            NavigationLink(destination: NoteDetailView(note: note)) {
                                NoteCard(note: note)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.textMuted)
            
            Text("No Notes Yet")
                .font(AppTheme.interFont(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Create personal notes to keep track of important information.")
                .font(AppTheme.interFont(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddNote = true
            } label: {
                Label("Create Note", systemImage: "plus")
                    .font(AppTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoteCard: View {
    let note: PersonalNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(AppTheme.interFont(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.accentPink)
                }
            }
            
            Text(note.content)
                .font(AppTheme.interFont(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(3)
            
            Text(note.modifiedDate.formatted(date: .abbreviated, time: .shortened))
                .font(AppTheme.interFont(size: 12))
                .foregroundStyle(AppTheme.textMuted)
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

#Preview {
    NotesView()
        .environmentObject(AppState())
        .modelContainer(for: [PersonalNote.self])
}
