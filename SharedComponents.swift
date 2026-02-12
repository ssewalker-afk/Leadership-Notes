import SwiftUI

// MARK: - Card View
struct CardView<Content: View>: View {
    let theme: ThemeColors
    let content: Content
    
    init(theme: ThemeColors, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }
    
    var body: some View {
        content
            .background(theme.bgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Section Label
struct SectionLabel: View {
    let text: String
    let theme: ThemeColors
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .foregroundColor(theme.accent)
            .tracking(0.8)
    }
}

// MARK: - Themed Text Field
struct ThemedTextFieldStyle: TextFieldStyle {
    let theme: ThemeColors
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(11)
            .background(theme.bgInput)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.border, lineWidth: 1.5)
            )
    }
}

// MARK: - Person Button
struct PersonButton: View {
    let person: Person
    let isSelected: Bool
    let theme: ThemeColors
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(person.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isSelected ? theme.accent : theme.textSoft)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? theme.accentGlow : theme.bgInput)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? theme.accent : theme.border, lineWidth: isSelected ? 2 : 1)
                )
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let theme: ThemeColors
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(category.icon)
                    .font(.system(size: 15))
                Text(category.label)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(isSelected ? category.colorValue : theme.textSoft)
            .padding(.horizontal, 8)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? category.colorValue.opacity(0.18) : theme.bgInput)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? category.colorValue : theme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: Category
    let small: Bool
    
    init(category: Category, small: Bool = false) {
        self.category = category
        self.small = small
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Text(category.icon)
            Text(category.label)
        }
        .font(.system(size: small ? 11 : 12, weight: .bold))
        .foregroundColor(category.colorValue)
        .padding(.horizontal, small ? 7 : 10)
        .padding(.vertical, small ? 2 : 3)
        .background(category.colorValue.opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(category.colorValue.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Duration Picker
struct DurationPicker: View {
    @Binding var value: Int?
    let settings: DurationSettings
    let theme: ThemeColors
    
    private var options: [Int] {
        Array(stride(from: settings.increment, through: settings.max, by: settings.increment))
    }
    
    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(options, id: \.self) { duration in
                Button(action: { value = duration }) {
                    Text("\(duration)")
                        .font(.system(size: 14, weight: value == duration ? .heavy : .medium))
                        .foregroundColor(value == duration ? theme.accent : theme.textSoft)
                        .frame(width: 52)
                        .padding(.vertical, 10)
                        .background(value == duration ? theme.accentGlow : theme.bgInput)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(value == duration ? theme.accent : theme.border, lineWidth: value == duration ? 2 : 1)
                        )
                }
            }
        }
    }
}

// MARK: - Toggle2
struct Toggle2: View {
    @Binding var value: Bool?
    let labelA: String
    let labelB: String
    let theme: ThemeColors
    
    var body: some View {
        HStack(spacing: 4) {
            toggleButton(isTrue: true, label: labelA)
            toggleButton(isTrue: false, label: labelB)
        }
        .padding(3)
        .background(theme.bgInput)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(theme.border, lineWidth: 1)
        )
    }
    
    private func toggleButton(isTrue: Bool, label: String) -> some View {
        Button(action: { value = isTrue }) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(value == isTrue ? theme.accent : theme.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(value == isTrue ? theme.accentGlow : Color.clear)
                .cornerRadius(8)
        }
    }
}

// MARK: - Flow Layout
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
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Date Formatters
extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func shortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    func shortTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
