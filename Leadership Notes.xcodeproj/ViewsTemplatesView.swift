//
//  TemplatesView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \EntryTemplate.createdDate, order: .reverse) private var templates: [EntryTemplate]
    
    @State private var showingAddTemplate = false
    @State private var selectedTemplate: EntryTemplate?
    @State private var showingDeleteConfirmation = false
    @State private var templateToDelete: EntryTemplate?
    
    var onSelectTemplate: ((EntryTemplate) -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                if templates.isEmpty {
                    emptyState
                } else {
                    templatesList
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTemplate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.accentPurple)
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddTemplateView()
            }
            .confirmationDialog("Delete Template", isPresented: $showingDeleteConfirmation, presenting: templateToDelete) { template in
                Button("Delete", role: .destructive) {
                    deleteTemplate(template)
                }
                Button("Cancel", role: .cancel) {}
            } message: { template in
                Text("Are you sure you want to delete '\(template.name)'?")
            }
        }
    }
    
    private var templatesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(templates) { template in
                    TemplateCard(template: template) {
                        if let onSelect = onSelectTemplate {
                            onSelect(template)
                            dismiss()
                        }
                    } onDelete: {
                        templateToDelete = template
                        showingDeleteConfirmation = true
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.textMuted)
            
            Text("No Templates Yet")
                .font(AppTheme.interFont(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Create templates to quickly fill in common coaching entries.")
                .font(AppTheme.interFont(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddTemplate = true
            } label: {
                Label("Create Template", systemImage: "plus")
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
    
    private func deleteTemplate(_ template: EntryTemplate) {
        modelContext.delete(template)
    }
}

struct TemplateCard: View {
    let template: EntryTemplate
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var categoryEnum: EntryCategory? {
        EntryCategory.allCases.first { $0.rawValue == template.category }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(template.name)
                        .font(AppTheme.interFont(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                CategoryBadge(category: template.category)
                
                Text(template.templateContent)
                    .font(AppTheme.interFont(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(3)
                
                Text("Created \(template.createdDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(AppTheme.interFont(size: 12))
                    .foregroundStyle(AppTheme.textMuted)
            }
            .padding()
            .background(AppTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TemplatesView()
        .modelContainer(for: [EntryTemplate.self])
}
