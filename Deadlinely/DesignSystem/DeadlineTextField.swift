import SwiftUI

struct DeadlineTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: prompt)
            .font(AppFont.body())
            .foregroundStyle(Theme.textPrimary)
            .tint(.duoBlue)
            .padding(14)
            .background(fieldBackground)
            .overlay(fieldBorder)
            .preferredColorScheme(.light)
            .accessibilityIdentifier(AccessibilityID.editorTitle)
    }

    private var prompt: Text {
        Text(placeholder)
            .font(AppFont.body())
            .foregroundStyle(Theme.textSecondary)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
            .fill(Color.white)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
            .stroke(Theme.border, lineWidth: Theme.strokeWidth)
    }
}

/// Graphical due-date picker for the editor sheet; always light styling on a white card.
struct EditorDatePickerCard: View {
    @Binding var date: Date

    var body: some View {
        DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(.duoBlue)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(Theme.border, lineWidth: Theme.strokeWidth)
            )
            .preferredColorScheme(.light)
    }
}

struct EditorRemindersCard: View {
    @Binding var reminderDayBefore: Bool
    @Binding var reminderMorningOf: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            reminderToggle("1 day before", isOn: $reminderDayBefore)
            Divider().overlay(Theme.border)
            reminderToggle("Morning of", isOn: $reminderMorningOf)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .stroke(Theme.border, lineWidth: Theme.strokeWidth)
        )
        .preferredColorScheme(.light)
    }

    private func reminderToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(AppFont.body())
                .foregroundStyle(Theme.textPrimary)
        }
        .tint(.duoBlue)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

struct OnboardingDateField: View {
    @Binding var date: Date
    var tint: Color = .duoBlue

    var body: some View {
        HStack {
            Text("Due date")
                .font(AppFont.body(15))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(tint)
                .foregroundStyle(Theme.textPrimary)
                .preferredColorScheme(.light)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .stroke(Theme.border, lineWidth: Theme.strokeWidth)
        )
    }
}

struct OnboardingCompactPreview: View {
    let value: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text("until go-time")
                    .font(AppFont.caption())
                    .foregroundStyle(Theme.textSecondary)
                Text(subtitle)
                    .font(AppFont.body(14))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: Theme.strokeWidth)
        )
    }
}
