import Foundation
import LocalAuthentication
import SwiftUI

class BiometricAuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var biometricType: BiometricType = .none

    private let context = LAContext()

    enum BiometricType {
        case none
        case faceID
        case touchID

        var description: String {
            switch self {
            case .none: return "None"
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            }
        }
    }

    init() {
        checkBiometricType()
    }

    func checkBiometricType() {
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricType = .none
            return
        }

        switch context.biometryType {
        case .faceID:
            biometricType = .faceID
        case .touchID:
            biometricType = .touchID
        case .opticID:
            biometricType = .faceID // Treat Optic ID like Face ID
        case .none:
            biometricType = .none
        @unknown default:
            biometricType = .none
        }
    }

    func authenticate(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback to device passcode
            authenticateWithPasscode(completion: completion)
            return
        }

        let reason = "Authenticate to access your income data"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }
    }

    func authenticateWithPasscode(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let reason = "Authenticate to access your income data"

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }
    }

    func logout() {
        isAuthenticated = false
    }
}
