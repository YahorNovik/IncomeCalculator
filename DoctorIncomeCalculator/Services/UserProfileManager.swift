import Foundation
import SwiftData

class UserProfileManager: ObservableObject {
    @Published var currentUser: User?
    @Published var hasCompletedSetup: Bool = false

    private let setupCompleteKey = "hasCompletedSetup"
    private let currentUserIdKey = "currentUserId"

    init() {
        hasCompletedSetup = UserDefaults.standard.bool(forKey: setupCompleteKey)
    }

    func completeSetup(user: User) {
        currentUser = user
        hasCompletedSetup = true
        UserDefaults.standard.set(true, forKey: setupCompleteKey)
        UserDefaults.standard.set(user.id.uuidString, forKey: currentUserIdKey)
    }

    func loadUser(modelContext: ModelContext) {
        guard hasCompletedSetup,
              let userIdString = UserDefaults.standard.string(forKey: currentUserIdKey),
              let userId = UUID(uuidString: userIdString) else {
            return
        }

        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == userId
            }
        )

        do {
            let users = try modelContext.fetch(descriptor)
            currentUser = users.first
        } catch {
            print("Failed to load user: \(error)")
        }
    }

    func resetSetup() {
        currentUser = nil
        hasCompletedSetup = false
        UserDefaults.standard.removeObject(forKey: setupCompleteKey)
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
    }
}
