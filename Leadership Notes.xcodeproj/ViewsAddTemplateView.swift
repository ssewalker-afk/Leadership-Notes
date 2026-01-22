//
//  AddTemplateView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct AddTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var selectedCategory: EntryCategory = .coaching
    @State private var templateContent = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Template Name", text: $name)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(EntryCategory.allCases) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Template Information")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        TextEditor(text: $templateContent)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                    } header: {
                        Text("Template Content")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    } footer: {
                        Text("This content will be pre-filled when creating a new entry from this template.")
                            .font(AppTheme.interFont(size: 12))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .foregroundStyle(AppTheme.accentPurple)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || templateContent.isEmpty)
                }
            }
        }
    }
    
    private func saveTemplate() {
        let template = EntryTemplate(
            name: name,
            category: selectedCategory.rawValue,
            templateContent: templateContent
        )
        
        modelContext.insert(template)
        dismiss()
    }
}

#Preview {
    AddTemplateView()
        .modelContainer(for: [EntryTemplate.self])
}
