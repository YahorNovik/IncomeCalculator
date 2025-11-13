import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(LocalizedStrings.tabDashboard, systemImage: "house.fill")
                }

            TransactionsListView()
                .tabItem {
                    Label(LocalizedStrings.tabTransactions, systemImage: "dollarsign.circle.fill")
                }

            EmployersListView()
                .tabItem {
                    Label(LocalizedStrings.tabEmployers, systemImage: "building.2.fill")
                }

            ProfileView()
                .tabItem {
                    Label(LocalizedStrings.tabProfile, systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
}
