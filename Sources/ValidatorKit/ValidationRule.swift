//
//  ValidatorKit
//
//  Created by RahulMac on 12/03/26.
//

import Foundation

// MARK: - ValidationRule

/// A single validation rule that checks a string value and returns an error message if it fails.
public protocol ValidationRule {
    func validate(_ value: String) -> String?  // Returns nil if valid, error message if not
}

// MARK: - Built-in Rules

// MARK: Required

/// Fails if the value is empty or whitespace only.
public struct RequiredRule: ValidationRule {
    private let message: String

    public init(message: String = "This field is required") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? message : nil
    }
}

// MARK: Email

/// Fails if the value is not a valid email address.
public struct EmailRule: ValidationRule {
    private let message: String

    public init(message: String = "Enter a valid email address") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value) ? nil : message
    }
}

// MARK: MinLength

/// Fails if the value has fewer characters than `min`.
public struct MinLengthRule: ValidationRule {
    private let min: Int
    private let message: String

    public init(_ min: Int, message: String? = nil) {
        self.min     = min
        self.message = message ?? "Must be at least \(min) characters"
    }

    public func validate(_ value: String) -> String? {
        value.count < min ? message : nil
    }
}

// MARK: MaxLength

/// Fails if the value has more characters than `max`.
public struct MaxLengthRule: ValidationRule {
    private let max: Int
    private let message: String

    public init(_ max: Int, message: String? = nil) {
        self.max     = max
        self.message = message ?? "Must be no more than \(max) characters"
    }

    public func validate(_ value: String) -> String? {
        value.count > max ? message : nil
    }
}

// MARK: Matches

/// Fails if the value does not match another value (e.g. confirm password).
public struct MatchesRule: ValidationRule {
    private let other: String
    private let message: String

    public init(_ other: String, message: String = "Values do not match") {
        self.other   = other
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        value == other ? nil : message
    }
}

// MARK: ContainsNumber

/// Fails if the value does not contain at least one number.
public struct ContainsNumberRule: ValidationRule {
    private let message: String

    public init(message: String = "Must contain at least one number") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        value.rangeOfCharacter(from: .decimalDigits) != nil ? nil : message
    }
}

// MARK: ContainsUppercase

/// Fails if the value does not contain at least one uppercase letter.
public struct ContainsUppercaseRule: ValidationRule {
    private let message: String

    public init(message: String = "Must contain at least one uppercase letter") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        value.rangeOfCharacter(from: .uppercaseLetters) != nil ? nil : message
    }
}

// MARK: ContainsSpecialCharacter

/// Fails if the value does not contain at least one special character.
public struct ContainsSpecialCharacterRule: ValidationRule {
    private let message: String

    public init(message: String = "Must contain at least one special character") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        let special = CharacterSet.alphanumerics.union(.whitespaces).inverted
        return value.rangeOfCharacter(from: special) != nil ? nil : message
    }
}

// MARK: PhoneNumber

/// Fails if the value does not look like a phone number (digits, spaces, +, -, ()).
public struct PhoneNumberRule: ValidationRule {
    private let message: String

    public init(message: String = "Enter a valid phone number") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        let regex = #"^[\+]?[\d\s\-\(\)]{7,15}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value) ? nil : message
    }
}

// MARK: URL

/// Fails if the value is not a valid URL.
public struct URLRule: ValidationRule {
    private let message: String

    public init(message: String = "Enter a valid URL") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        guard let url = URL(string: value),
              url.scheme != nil,
              url.host != nil else { return message }
        return nil
    }
}

// MARK: Regex

/// Fails if the value does not match the provided regular expression.
public struct RegexRule: ValidationRule {
    private let pattern: String
    private let message: String

    public init(pattern: String, message: String = "Invalid format") {
        self.pattern = pattern
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: value) ? nil : message
    }
}

// MARK: Custom

/// Validates using a closure — for one-off rules that don't need a separate type.
public struct CustomRule: ValidationRule {
    private let rule: (String) -> String?

    /// - Parameter rule: Return nil if valid, or an error message string if invalid.
    public init(_ rule: @escaping (String) -> String?) {
        self.rule = rule
    }

    public func validate(_ value: String) -> String? {
        rule(value)
    }
}

// MARK: - Rule Shorthand

/// Convenience namespace so you can write `.required` instead of `RequiredRule()`.
public extension ValidationRule where Self == RequiredRule {
    static var required: RequiredRule { RequiredRule() }
}

public extension ValidationRule where Self == EmailRule {
    static var email: EmailRule { EmailRule() }
}

public extension ValidationRule where Self == ContainsNumberRule {
    static var containsNumber: ContainsNumberRule { ContainsNumberRule() }
}

public extension ValidationRule where Self == ContainsUppercaseRule {
    static var containsUppercase: ContainsUppercaseRule { ContainsUppercaseRule() }
}

public extension ValidationRule where Self == ContainsSpecialCharacterRule {
    static var containsSpecialCharacter: ContainsSpecialCharacterRule { ContainsSpecialCharacterRule() }
}

public extension ValidationRule where Self == PhoneNumberRule {
    static var phoneNumber: PhoneNumberRule { PhoneNumberRule() }
}

public extension ValidationRule where Self == URLRule {
    static var url: URLRule { URLRule() }
}

public extension MinLengthRule {
    static func minLength(_ min: Int, message: String? = nil) -> MinLengthRule {
        MinLengthRule(min, message: message)
    }
}

public extension MaxLengthRule {
    static func maxLength(_ max: Int, message: String? = nil) -> MaxLengthRule {
        MaxLengthRule(max, message: message)
    }
}

public extension MatchesRule {
    static func matches(_ other: String, message: String = "Values do not match") -> MatchesRule {
        MatchesRule(other, message: message)
    }
}

public extension RegexRule {
    static func regex(_ pattern: String, message: String = "Invalid format") -> RegexRule {
        RegexRule(pattern: pattern, message: message)
    }
}

public extension CustomRule {
    static func custom(_ rule: @escaping (String) -> String?) -> CustomRule {
        CustomRule(rule)
    }
}
