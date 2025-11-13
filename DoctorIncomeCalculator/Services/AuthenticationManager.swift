import Foundation
import SwiftUI
import SwiftData

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    private let userIdKey = "currentUserId"

    func login(email: String, password: String, modelContext: ModelContext) -> Result<User, AuthError> {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.email == email
            }
        )

        do {
            let users = try modelContext.fetch(descriptor)
            guard let user = users.first else {
                return .failure(.userNotFound)
            }

            if user.verifyPassword(password) {
                currentUser = user
                isAuthenticated = true
                saveCurrentUserId(user.id)
                return .success(user)
            } else {
                return .failure(.incorrectPassword)
            }
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }

    func register(email: String, password: String, name: String, nip: String? = nil,
                  city: String? = nil, street: String? = nil, buildingNumber: String? = nil,
                  modelContext: ModelContext) -> Result<User, AuthError> {
        // Validate NIP if provided (10 digits)
        if let nip = nip, !nip.isEmpty {
            guard nip.count == 10, nip.allSatisfy({ $0.isNumber }) else {
                return .failure(.invalidNIP)
            }
        }

        // Validate email
        guard email.contains("@") && email.contains(".") else {
            return .failure(.invalidEmail)
        }

        // Check if email already exists
        let emailDescriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.email == email
            }
        )

        do {
            let existingUsers = try modelContext.fetch(emailDescriptor)
            if !existingUsers.isEmpty {
                return .failure(.emailAlreadyExists)
            }
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }

        // Create new user
        let newUser = User(email: email, password: password, name: name, nip: nip,
                          city: city, street: street, buildingNumber: buildingNumber)

        modelContext.insert(newUser)

        do {
            try modelContext.save()
            currentUser = newUser
            isAuthenticated = true
            saveCurrentUserId(newUser.id)
            return .success(newUser)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        clearCurrentUserId()
    }

    func restoreSession(modelContext: ModelContext) {
        guard let userId = getCurrentUserId() else { return }

        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == userId
            }
        )

        do {
            let users = try modelContext.fetch(descriptor)
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
            } else {
                clearCurrentUserId()
            }
        } catch {
            clearCurrentUserId()
        }
    }

    private func saveCurrentUserId(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: userIdKey)
    }

    private func getCurrentUserId() -> UUID? {
        guard let idString = UserDefaults.standard.string(forKey: userIdKey) else {
            return nil
        }
        return UUID(uuidString: idString)
    }

    private func clearCurrentUserId() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}

enum AuthError: LocalizedError {
    case userNotFound
    case incorrectPassword
    case invalidEmail
    case invalidNIP
    case emailAlreadyExists
    case databaseError(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .incorrectPassword:
            return "Incorrect password"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidNIP:
            return "NIP must be exactly 10 digits"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}
