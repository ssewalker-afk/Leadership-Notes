//
//  EntryDetailView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: CoachingEntry
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        CategoryBadge(category: entry.category)
                        Spacer()
                        Text(entry.date.formatted(date: .long, time: .shortened))
                            .font(AppTheme.interFont(size: 14))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    
                    Text(entry.title)
                        .font(AppTheme.interFont(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    if let employee = entry.employee {
                        NavigationLink(destination: EmployeeProfileView(employee: employee)) {
                            HStack(spacing: 8) {
                                if let imageData = employee.profileImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.accentPurple)
                                            .frame(width: 32, height: 32)
                                        
                                        Text(employee.initials)
                                            .font(AppTheme.interFont(size: 12, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(employee.fullName)
                                        .font(AppTheme.interFont(size: 16, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    
                                    if let jobTitle = employee.jobTitle {
                                        Text(jobTitle)
                                            .font(AppTheme.interFont(size: 13))
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                            .padding()
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(AppTheme.interFont(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text(entry.content)
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(6)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Images
                if let imageData = entry.imageData, !imageData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attachments")
                            .font(AppTheme.interFont(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(imageData.enumerated()), id: \.offset) { _, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Tags
                if let tags = entry.tags, !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(AppTheme.interFont(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(AppTheme.interFont(size: 13, weight: .medium))
                                    .foregroundStyle(AppTheme.accentCyan)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.accentCyan.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Follow-up
                if let followUpDate = entry.followUpDate {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Follow-up")
                                .font(AppTheme.interFont(size: 18, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            if entry.isFollowUpComplete {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Complete")
                                        .font(AppTheme.interFont(size: 13, weight: .medium))
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundStyle(AppTheme.accentCyan)
                            
                            Text(followUpDate.formatted(date: .long, time: .omitted))
                                .font(AppTheme.interFont(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Created")
                            .font(AppTheme.interFont(size: 13))
                            .foregroundStyle(AppTheme.textMuted)
                        
                        Spacer()
                        
                        Text(entry.createdDate.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTheme.interFont(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    HStack {
                        Text("Last Modified")
                            .font(AppTheme.interFont(size: 13))
                            .foregroundStyle(AppTheme.textMuted)
                        
                        Spacer()
                        
                        Text(entry.modifiedDate.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTheme.interFont(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding()
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(AppTheme.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Entry", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .confirmationDialog("Delete Entry", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
    }
    
    private func deleteEntry() {
        modelContext.delete(entry)
        dismiss()
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX - spacing)
                size.height = currentY + lineHeight
            }
            
            self.size = size
            self.positions = positions
        }
    }
}
