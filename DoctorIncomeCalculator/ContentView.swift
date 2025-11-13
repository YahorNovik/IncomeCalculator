import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var biometricAuth: BiometricAuthManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if !profileManager.hasCompletedSetup {
                // First time setup
                OnboardingView()
            } else if !biometricAuth.isAuthenticated {
                // Returning user - require biometric auth
                BiometricLockView()
            } else {
                // Authenticated - show main app
                MainTabView()
            }
        }
        .onAppear {
            if profileManager.hasCompletedSetup {
                profileManager.loadUser(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserProfileManager())
        .environmentObject(BiometricAuthManager())
}
