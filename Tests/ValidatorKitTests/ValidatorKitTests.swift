//
//  ValidatorKit
//
//  Created by RahulMac on 10/03/26.
//

import XCTest
@testable import ValidatorKit

final class ValidatorKitTests: XCTestCase {

    // MARK: - RequiredRule

    func test_required_failsOnEmptyString() {
        XCTAssertNotNil(RequiredRule().validate(""))
    }

    func test_required_failsOnWhitespaceOnly() {
        XCTAssertNotNil(RequiredRule().validate("   "))
    }

    func test_required_passesOnValidInput() {
        XCTAssertNil(RequiredRule().validate("Hello"))
    }

    // MARK: - EmailRule

    func test_email_passesValidEmail() {
        XCTAssertNil(EmailRule().validate("user@example.com"))
    }

    func test_email_failsMissingAt() {
        XCTAssertNotNil(EmailRule().validate("userexample.com"))
    }

    func test_email_failsMissingDomain() {
        XCTAssertNotNil(EmailRule().validate("user@"))
    }

    func test_email_failsEmptyString() {
        XCTAssertNotNil(EmailRule().validate(""))
    }

    func test_email_passesWithSubdomain() {
        XCTAssertNil(EmailRule().validate("user@mail.example.com"))
    }

    // MARK: - MinLengthRule

    func test_minLength_passesExactLength() {
        XCTAssertNil(MinLengthRule(5).validate("Hello"))
    }

    func test_minLength_passesLonger() {
        XCTAssertNil(MinLengthRule(3).validate("Hello"))
    }

    func test_minLength_failsShorter() {
        XCTAssertNotNil(MinLengthRule(8).validate("abc"))
    }

    // MARK: - MaxLengthRule

    func test_maxLength_passesExactLength() {
        XCTAssertNil(MaxLengthRule(5).validate("Hello"))
    }

    func test_maxLength_failsLonger() {
        XCTAssertNotNil(MaxLengthRule(3).validate("Hello"))
    }

    func test_maxLength_passesShorter() {
        XCTAssertNil(MaxLengthRule(10).validate("Hi"))
    }

    // MARK: - MatchesRule

    func test_matches_passesIdenticalStrings() {
        XCTAssertNil(MatchesRule("password123").validate("password123"))
    }

    func test_matches_failsDifferentStrings() {
        XCTAssertNotNil(MatchesRule("password123").validate("Password123"))
    }

    // MARK: - ContainsNumberRule

    func test_containsNumber_passesWithDigit() {
        XCTAssertNil(ContainsNumberRule().validate("abc1"))
    }

    func test_containsNumber_failsWithoutDigit() {
        XCTAssertNotNil(ContainsNumberRule().validate("abcdef"))
    }

    // MARK: - ContainsUppercaseRule

    func test_containsUppercase_passesWithUppercase() {
        XCTAssertNil(ContainsUppercaseRule().validate("helloWorld"))
    }

    func test_containsUppercase_failsAllLowercase() {
        XCTAssertNotNil(ContainsUppercaseRule().validate("helloworld"))
    }

    // MARK: - ContainsSpecialCharacterRule

    func test_specialCharacter_passesWithSymbol() {
        XCTAssertNil(ContainsSpecialCharacterRule().validate("hello!"))
    }

    func test_specialCharacter_failsAlphanumericOnly() {
        XCTAssertNotNil(ContainsSpecialCharacterRule().validate("hello123"))
    }

    // MARK: - PhoneNumberRule

    func test_phone_passesValidNumber() {
        XCTAssertNil(PhoneNumberRule().validate("+91 98765 43210"))
    }

    func test_phone_passesUSFormat() {
        XCTAssertNil(PhoneNumberRule().validate("(555) 123-4567"))
    }

    func test_phone_failsTooShort() {
        XCTAssertNotNil(PhoneNumberRule().validate("123"))
    }

    // MARK: - URLRule

    func test_url_passesValidURL() {
        XCTAssertNil(URLRule().validate("https://www.example.com"))
    }

    func test_url_failsMissingScheme() {
        XCTAssertNotNil(URLRule().validate("www.example.com"))
    }

    func test_url_failsEmptyString() {
        XCTAssertNotNil(URLRule().validate(""))
    }

    // MARK: - CustomRule

    func test_custom_passesWhenClosureReturnsNil() {
        let rule = CustomRule { $0 == "valid" ? nil : "Invalid" }
        XCTAssertNil(rule.validate("valid"))
    }

    func test_custom_failsWhenClosureReturnsMessage() {
        let rule = CustomRule { $0 == "valid" ? nil : "Invalid" }
        XCTAssertEqual(rule.validate("wrong"), "Invalid")
    }

    // MARK: - RegexRule

    func test_regex_passesMatchingPattern() {
        let rule = RegexRule(pattern: #"^\d{4}$"#, message: "Must be 4 digits")
        XCTAssertNil(rule.validate("1234"))
    }

    func test_regex_failsNonMatchingPattern() {
        let rule = RegexRule(pattern: #"^\d{4}$"#, message: "Must be 4 digits")
        XCTAssertNotNil(rule.validate("12345"))
    }

    // MARK: - FieldValidator

    @MainActor func test_fieldValidator_isValidByDefault() {
        let validator = FieldValidator(rules: RequiredRule())
        XCTAssertTrue(validator.isValid)
        XCTAssertFalse(validator.isDirty)
    }

    @MainActor func test_fieldValidator_setsErrorOnFailure() {
        let validator = FieldValidator(rules: RequiredRule())
        validator.validate("")
        XCTAssertNotNil(validator.errorMessage)
        XCTAssertFalse(validator.isValid)
        XCTAssertTrue(validator.isDirty)
    }

    @MainActor func test_fieldValidator_clearsErrorOnSuccess() {
        let validator = FieldValidator(rules: RequiredRule())
        validator.validate("")
        validator.validate("hello")
        XCTAssertNil(validator.errorMessage)
        XCTAssertTrue(validator.isValid)
    }

    @MainActor func test_fieldValidator_reset_clearsState() {
        let validator = FieldValidator(rules: RequiredRule())
        validator.validate("")
        validator.reset()
        XCTAssertNil(validator.errorMessage)
        XCTAssertTrue(validator.isValid)
        XCTAssertFalse(validator.isDirty)
    }

    @MainActor func test_fieldValidator_stopsAtFirstFailingRule() {
        let validator = FieldValidator(rules: RequiredRule(), EmailRule())
        let result = validator.validate("")
        XCTAssertFalse(result)
        XCTAssertEqual(validator.errorMessage, "This field is required")
    }

    // MARK: - FormValidator

    @MainActor func test_formValidator_returnsTrueWhenAllPass() {
        let form       = FormValidator()
        let validator1 = FieldValidator(rules: RequiredRule())
        let validator2 = FieldValidator(rules: EmailRule())

        let result = form.validateAll(fields: [
            ("Hello", validator1),
            ("user@example.com", validator2)
        ])

        XCTAssertTrue(result)
        XCTAssertTrue(form.isFormValid)
    }

    @MainActor func test_formValidator_returnsFalseWhenAnyFail() {
        let form       = FormValidator()
        let validator1 = FieldValidator(rules: RequiredRule())
        let validator2 = FieldValidator(rules: EmailRule())

        let result = form.validateAll(fields: [
            ("Hello", validator1),
            ("notanemail", validator2)
        ])

        XCTAssertFalse(result)
        XCTAssertFalse(form.isFormValid)
    }

    // MARK: - PasswordStrength

    func test_passwordStrength_emptyIsEmpty() {
        XCTAssertEqual(PasswordStrength.evaluate(""), .empty)
    }

    func test_passwordStrength_shortIsWeak() {
        XCTAssertEqual(PasswordStrength.evaluate("abc"), .weak)
    }

    func test_passwordStrength_strongPassword() {
        let strength = PasswordStrength.evaluate("MyP@ssw0rd!")
        XCTAssertTrue(strength == .strong || strength == .veryStrong)
    }

    func test_passwordStrength_labelsAreNotEmpty() {
        let strengths: [PasswordStrength] = [.weak, .fair, .strong, .veryStrong]
        strengths.forEach { XCTAssertFalse($0.label.isEmpty) }
    }
}
