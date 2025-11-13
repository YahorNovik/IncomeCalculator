import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            EmployersListView()
                .tabItem {
                    Label("Employers", systemImage: "building.2.fill")
                }

            TransactionsListView()
                .tabItem {
                    Label("Transactions", systemImage: "dollarsign.circle.fill")
                }

            InvoicesListView()
                .tabItem {
                    Label("Invoices", systemImage: "doc.text.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
}
