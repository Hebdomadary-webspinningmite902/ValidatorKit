//
//  ValidatorKit
//
//  Created by RahulMac on 12/03/26.
//

import SwiftUI

// MARK: - PasswordStrength

public enum PasswordStrength {
    case empty
    case weak
    case fair
    case strong
    case veryStrong

    public var label: String {
        switch self {
        case .empty:      return ""
        case .weak:       return "Weak"
        case .fair:       return "Fair"
        case .strong:     return "Strong"
        case .veryStrong: return "Very Strong"
        }
    }

    public var color: Color {
        switch self {
        case .empty:      return .clear
        case .weak:       return .red
        case .fair:       return .orange
        case .strong:     return .blue
        case .veryStrong: return .green
        }
    }

    var strenth: Int {
        switch self {
        case .empty:      return 0
        case .weak:       return 1
        case .fair:       return 2
        case .strong:     return 3
        case .veryStrong: return 4
        }
    }

    /// Calculates the password strength for a given string.
    public static func evaluate(_ password: String) -> PasswordStrength {
        guard !password.isEmpty else { return .empty }

        var strenth = 0
        if password.count >= 8  { strenth += 1 }
        if password.count >= 12 { strenth += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil    { strenth += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil  { strenth += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil  { strenth += 1 }
        let special = CharacterSet.alphanumerics.union(.whitespaces).inverted
        if password.rangeOfCharacter(from: special) != nil            { strenth += 1 }

        switch strenth {
        case 0...1: return .weak
        case 2...3: return .fair
        case 4...5: return .strong
        default:    return .veryStrong
        }
    }
}

// MARK: - PasswordStrengthView

public struct PasswordStrengthView: View {

    @Binding var password: String

    public init(password: Binding<String>) {
        self._password = password
    }

    private var strength: PasswordStrength {
        PasswordStrength.evaluate(password)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Segmented strength bar
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { segment in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(segmentColor(for: segment))
                        .frame(height: 4)
                }
            }

            // Label
            if strength != .empty {
                Text(strength.label)
                    .font(.caption)
                    .foregroundStyle(strength.color)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: strength.strenth)
    }

    private func segmentColor(for segment: Int) -> Color {
        segment <= strength.strenth ? strength.color : Color(.systemGray5)
    }
}
