//
//  ValidatorKit
//
//  Created by RahulMac on 13/03/26.
//

import SwiftUI
import Combine

// MARK: - FieldValidator

@MainActor
public final class FieldValidator: ObservableObject {

    @Published public private(set) var errorMessage: String? = nil
    @Published public private(set) var isValid: Bool = true
    @Published public private(set) var isDirty: Bool = false   // True after the first validation

    private let rules: [any ValidationRule]

    public init(rules: any ValidationRule...) {
        self.rules = rules
    }

    public init(rules: [any ValidationRule]) {
        self.rules = rules
    }

    // MARK: - Public

    /// Validates the value against all rules. Sets errorMessage and isValid accordingly.
    @discardableResult
    public func validate(_ value: String) -> Bool {
        isDirty = true
        for rule in rules {
            if let error = rule.validate(value) {
                errorMessage = error
                isValid      = false
                return false
            }
        }
        errorMessage = nil
        isValid      = true
        return true
    }

    /// Resets the validator back to its initial state.
    public func reset() {
        errorMessage = nil
        isValid      = true
        isDirty      = false
    }
}
