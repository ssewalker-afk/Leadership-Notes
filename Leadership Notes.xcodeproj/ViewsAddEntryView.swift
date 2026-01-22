//
//  AddEntryView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query(sort: \Employee.lastName) private var employees: [Employee]
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedEmployee: Employee?
    @State private var selectedCategory: EntryCategory = .coaching
    @State private var date = Date()
    @State private var hasFollowUp = false
    @State private var followUpDate = Date()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []
    @State private var tags: String = ""
    @State private var showingTemplates = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                Form {
                    Section {
                        Button {
                            showingTemplates = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .foregroundStyle(AppTheme.accentCyan)
                                Text("Use Template")
                                    .font(AppTheme.interFont(size: 16, weight: .medium))
                                    .foregroundStyle(AppTheme.accentCyan)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                        }
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        TextField("Title", text: $title)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Picker("Employee", selection: $selectedEmployee) {
                            Text("Select Employee").tag(nil as Employee?)
                            ForEach(employees) { employee in
                                Text(employee.fullName).tag(employee as Employee?)
                            }
                        }
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
                        
                        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Basic Information")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        TextEditor(text: $content)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                    } header: {
                        Text("Content")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        TextField("Tags (comma separated)", text: $tags)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                            Label("Add Photos", systemImage: "photo")
                                .font(AppTheme.interFont(size: 16))
                                .foregroundStyle(AppTheme.accentPurple)
                        }
                        
                        if !imageData.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(imageData.enumerated()), id: \.offset) { index, data in
                                        if let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .overlay(alignment: .topTrailing) {
                                                    Button {
                                                        imageData.remove(at: index)
                                                    } label: {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundStyle(.white, .red)
                                                            .font(.system(size: 20))
                                                    }
                                                    .offset(x: 5, y: -5)
                                                }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    } header: {
                        Text("Additional Details")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        Toggle("Set Follow-up", isOn: $hasFollowUp)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .tint(AppTheme.accentPurple)
                        
                        if hasFollowUp {
                            DatePicker("Follow-up Date", selection: $followUpDate, displayedComponents: [.date])
                                .font(AppTheme.interFont(size: 16))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    } header: {
                        Text("Reminders")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Entry")
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
                        saveEntry()
                    }
                    .foregroundStyle(AppTheme.accentPurple)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .onChange(of: selectedPhotos) { _, newItems in
                Task {
                    imageData.removeAll()
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            imageData.append(data)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTemplates) {
                TemplatesView { template in
                    applyTemplate(template)
                }
            }
        }
    }
    
    private func applyTemplate(_ template: EntryTemplate) {
        content = template.templateContent
        if let category = EntryCategory.allCases.first(where: { $0.rawValue == template.category }) {
            selectedCategory = category
        }
    }
    
    private func saveEntry() {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let entry = CoachingEntry(
            title: title,
            content: content,
            category: selectedCategory.rawValue,
            date: date,
            employee: selectedEmployee,
            imageData: imageData.isEmpty ? nil : imageData,
            tags: tagArray.isEmpty ? nil : tagArray,
            followUpDate: hasFollowUp ? followUpDate : nil
        )
        
        modelContext.insert(entry)
        
        // Schedule notification if follow-up is set
        if hasFollowUp, let followUpDate = entry.followUpDate {
            Task {
                let settings = NotificationSettings()
                await appState.notificationManager.scheduleFollowUpNotification(
                    for: entry,
                    daysInAdvance: settings.followUpReminderDays
                )
            }
        }
        
        dismiss()
    }
}

#Preview {
    AddEntryView()
        .modelContainer(for: [Employee.self, CoachingEntry.self])
}
