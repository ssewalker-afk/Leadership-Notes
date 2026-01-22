//
//  AddEmployeeView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEmployeeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var jobTitle = ""
    @State private var department = ""
    @State private var hireDate: Date?
    @State private var birthday: Date?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?
    @State private var showHireDate = false
    @State private var showBirthday = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                Form {
                    Section {
                        // Profile Photo
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.backgroundTertiary)
                                            .frame(width: 100, height: 100)
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(AppTheme.textMuted)
                                    }
                                }
                                
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    Text(profileImageData == nil ? "Add Photo" : "Change Photo")
                                        .font(AppTheme.interFont(size: 14, weight: .medium))
                                        .foregroundStyle(AppTheme.accentPurple)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        TextField("First Name", text: $firstName)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        TextField("Last Name", text: $lastName)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Basic Information")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        TextField("Email", text: $email)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        TextField("Phone Number", text: $phoneNumber)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    } header: {
                        Text("Contact Information")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        TextField("Job Title", text: $jobTitle)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        TextField("Department", text: $department)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                    } header: {
                        Text("Job Details")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    Section {
                        Toggle("Set Hire Date", isOn: $showHireDate)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .tint(AppTheme.accentPurple)
                        
                        if showHireDate {
                            DatePicker("Hire Date", selection: Binding(
                                get: { hireDate ?? Date() },
                                set: { hireDate = $0 }
                            ), displayedComponents: [.date])
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        }
                        
                        Toggle("Set Birthday", isOn: $showBirthday)
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .tint(AppTheme.accentPurple)
                        
                        if showBirthday {
                            DatePicker("Birthday", selection: Binding(
                                get: { birthday ?? Date() },
                                set: { birthday = $0 }
                            ), displayedComponents: [.date])
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                        }
                    } header: {
                        Text("Important Dates")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Employee")
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
                        saveEmployee()
                    }
                    .foregroundStyle(AppTheme.accentPurple)
                    .fontWeight(.semibold)
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
        }
    }
    
    private func saveEmployee() {
        let employee = Employee(
            firstName: firstName,
            lastName: lastName,
            email: email.isEmpty ? nil : email,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            jobTitle: jobTitle.isEmpty ? nil : jobTitle,
            department: department.isEmpty ? nil : department,
            hireDate: showHireDate ? hireDate : nil,
            birthday: showBirthday ? birthday : nil,
            profileImageData: profileImageData
        )
        
        modelContext.insert(employee)
        dismiss()
    }
}

#Preview {
    AddEmployeeView()
        .modelContainer(for: [Employee.self])
}
