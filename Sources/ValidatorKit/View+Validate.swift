//
//  ValidatorKit
//
//  Created by RahulMac on 13/03/26.
//

import SwiftUI

// MARK: - View+Validate

public extension View {

    /// Validates the bound value against the given rules on every change.
    /// Shows an error message below the view when validation fails.
    ///
    /// Example:
    ///   TextField("Email", text: $email)
    ///       .validate($email, with: emailValidator)
    func validate(_ value: Binding<String>, with validator: FieldValidator) -> some View {
        modifier(ValidationModifier(value: value, validator: validator))
    }
}

// MARK: - ValidationModifier

struct ValidationModifier: ViewModifier {

    @Binding var value: String
    @ObservedObject var validator: FieldValidator

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                )
                .onChange(of: value) { newValue in
                    if validator.isDirty {
                        validator.validate(newValue)
                    }
                }

            if let error = validator.errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: validator.errorMessage)
    }

    private var borderColor: Color {
        guard validator.isDirty else { return .clear }
        return validator.isValid ? .green : .red
    }
}
