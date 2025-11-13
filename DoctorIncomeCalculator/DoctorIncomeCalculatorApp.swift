import SwiftUI
import SwiftData

@main
struct DoctorIncomeCalculatorApp: App {
    @StateObject private var authManager = AuthenticationManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Employer.self,
            Transaction.self,
            Invoice.self,
            Product.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .modelContainer(sharedModelContainer)
        }
    }
}
