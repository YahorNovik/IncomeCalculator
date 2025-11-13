import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            authManager.restoreSession(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
