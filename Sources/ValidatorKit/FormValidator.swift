//
//  ValidatorKit
//
//  Created by RahulMac on 13/03/26.
//

import SwiftUI

// MARK: - FormValidator

/// Coordinates validation across multiple fields in a form.
/// Validates all fields at once and tells you if the whole form is valid.
///

@MainActor
public final class FormValidator: ObservableObject {

    @Published public private(set) var isFormValid: Bool = false

    // MARK: - Public

    @discardableResult
    public func validateAll(fields: [(value: String, validator: FieldValidator)]) -> Bool {
        let results = fields.map { $0.validator.validate($0.value) }
        isFormValid = results.allSatisfy { $0 }
        return isFormValid
    }

    /// Resets all provided validators back to their initial state.
    public func resetAll(validators: [FieldValidator]) {
        validators.forEach { $0.reset() }
        isFormValid = false
    }

    /// Checks if all validators are currently valid without triggering validation.
    /// Useful for enabling/disabling a submit button reactively.
    public func checkValidity(of validators: [FieldValidator]) -> Bool {
        validators.allSatisfy { $0.isValid && $0.isDirty }
    }
}
