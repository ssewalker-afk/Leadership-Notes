//
//  FilterView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedCategory: EntryCategory?
    @Binding var selectedEmployee: Employee?
    let employees: [Employee]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Category", selection: $selectedCategory) {
                            Text("All Categories").tag(nil as EntryCategory?)
                            ForEach(EntryCategory.allCases) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category as EntryCategory?)
                            }
                        }
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Filter by Category")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        Picker("Employee", selection: $selectedEmployee) {
                            Text("All Employees").tag(nil as Employee?)
                            ForEach(employees) { employee in
                                Text(employee.fullName).tag(employee as Employee?)
                            }
                        }
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Filter by Employee")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        Button {
                            selectedCategory = nil
                            selectedEmployee = nil
                        } label: {
                            Text("Clear All Filters")
                                .font(AppTheme.interFont(size: 16, weight: .medium))
                                .foregroundStyle(AppTheme.accentPink)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accentPurple)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    FilterView(
        selectedCategory: .constant(nil),
        selectedEmployee: .constant(nil),
        employees: []
    )
}
