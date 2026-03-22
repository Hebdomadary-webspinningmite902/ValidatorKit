# ValidatorKit

**Chainable, declarative form validation for SwiftUI — zero boilerplate.**

![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift)
![iOS](https://img.shields.io/badge/iOS-16%2B-007AFF?style=flat&logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-native-34C759?style=flat)
![SPM](https://img.shields.io/badge/SPM-compatible-34C759?style=flat)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat)

---

## What is ValidatorKit?

ValidatorKit removes the pain of writing form validation by hand. Instead of if-else chains and scattered error state, you declare your rules once and the framework handles the rest — error messages, visual feedback, submit button state, and password strength.

```swift
// Set up validators
@StateObject var emailValidator    = FieldValidator(rules: .required, .email)
@StateObject var passwordValidator = FieldValidator(rules: .required, .minLength(8), .containsNumber)

// Use ValidatedField for automatic UI
ValidatedField(title: "Email",    text: $email,    validator: emailValidator)
ValidatedField(title: "Password", text: $password, validator: passwordValidator, isSecure: true)
```

---

## Installation

In Xcode go to **File → Add Package Dependencies** and paste:

```
https://github.com/codewithswiftly/ValidatorKit.git
```

Or in `Package.swift`:

```swift
.package(url: "https://github.com/codewithswiftly/ValidatorKit.git", from: "1.0.0")
```

---

## How to Use

### Option 1 — ValidatedField (recommended)

Drop-in replacement for `TextField` with built-in error UI and border feedback.

```swift
import ValidatorKit

struct SignUpView: View {

    @State private var email    = ""
    @State private var password = ""

    @StateObject var emailValidator    = FieldValidator(rules: .required, .email)
    @StateObject var passwordValidator = FieldValidator(rules: .required, .minLength(8), .containsNumber, .containsUppercase)
    @StateObject var form              = FormValidator()

    var body: some View {
        VStack(spacing: 16) {
            ValidatedField(title: "Email",    text: $email,    validator: emailValidator, keyboardType: .emailAddress)
            ValidatedField(title: "Password", text: $password, validator: passwordValidator, isSecure: true)
            PasswordStrengthView(password: $password)

            Button("Create Account") {
                if form.validateAll(fields: [
                    (email, emailValidator),
                    (password, passwordValidator)
                ]) {
                    createAccount()
                }
            }
        }
        .padding()
    }
}
```

### Option 2 — .validate() modifier

Attach validation to any existing TextField without replacing it.

```swift
TextField("Email", text: $email)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(10)
    .validate($email, with: emailValidator)
```

### Option 3 — Manual validation

For full control over when validation fires.

```swift
@StateObject var emailValidator = FieldValidator(rules: .required, .email)

let isValid = emailValidator.validate(email)

if let error = emailValidator.errorMessage {
    Text(error).foregroundStyle(.red)
}
```

---

## Built-in Rules

| Rule | Shorthand | Description |
|---|---|---|
| `RequiredRule` | `.required` | Cannot be empty |
| `EmailRule` | `.email` | Must be a valid email |
| `MinLengthRule` | `.minLength(8)` | Minimum character count |
| `MaxLengthRule` | `.maxLength(20)` | Maximum character count |
| `MatchesRule` | `.matches(other)` | Must equal another string |
| `ContainsNumberRule` | `.containsNumber` | Must have at least one digit |
| `ContainsUppercaseRule` | `.containsUppercase` | Must have an uppercase letter |
| `ContainsSpecialCharacterRule` | `.containsSpecialCharacter` | Must have a symbol |
| `PhoneNumberRule` | `.phoneNumber` | Valid phone number format |
| `URLRule` | `.url` | Valid URL with scheme and host |
| `RegexRule` | `.regex(pattern:message:)` | Custom regex pattern |
| `CustomRule` | `.custom { ... }` | Closure-based one-off rule |

---

## Custom Rules

### Inline with CustomRule

```swift
let noBadWordsRule = CustomRule { value in
    blocklist.contains(value) ? "This username is not allowed" : nil
}

let validator = FieldValidator(rules: .required, noBadWordsRule)
```

### As a struct (reusable)

```swift
struct IndianPhoneRule: ValidationRule {
    func validate(_ value: String) -> String? {
        let regex = #"^[6-9]\d{9}$"#
        let pred  = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: value) ? nil : "Enter a valid 10-digit Indian phone number"
    }
}

let validator = FieldValidator(rules: .required, IndianPhoneRule())
```

---

## Password Strength

```swift
VStack {
    ValidatedField(title: "Password", text: $password, validator: passwordValidator, isSecure: true)
    PasswordStrengthView(password: $password)  // Shows a colour-coded bar: Weak → Fair → Strong → Very Strong
}

// Or check strength manually
let strength = PasswordStrength.evaluate("MyP@ssw0rd!")
print(strength.label)  // "Very Strong"
print(strength.color)  // .green
```

---

## FormValidator

Validates all fields at once when the user taps Submit.

```swift
@StateObject var form = FormValidator()

Button("Submit") {
    if form.validateAll(fields: [
        (email,    emailValidator),
        (password, passwordValidator),
        (phone,    phoneValidator)
    ]) {
        submitForm()   // Only called if every field passes
    }
}
.disabled(!form.isFormValid)
```

---

## Project Structure

```
ValidatorKit/
├── Sources/ValidatorKit/
│   ├── ValidationRule.swift     # Protocol + all built-in rules + shorthands
│   ├── FieldValidator.swift     # ObservableObject for a single field
│   ├── FormValidator.swift      # Coordinates validation across multiple fields
│   ├── View+Validate.swift      # .validate() modifier for existing TextFields
│   └── PasswordStrength.swift   # Strength enum + PasswordStrengthView bar
└── Tests/ValidatorKitTests/
    └── ValidatorKitTests.swift
```

---

## Requirements

- iOS 16+
- Swift 5.9+
- Xcode 15+
- Zero dependencies — pure SwiftUI

---

## License

MIT © 2026 Rahul Das Gupta
