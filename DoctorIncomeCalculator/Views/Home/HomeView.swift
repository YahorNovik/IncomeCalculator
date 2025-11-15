import SwiftUI
import SwiftData

// Period filter for transactions
enum PeriodFilter: String, Identifiable {
    case currentMonth
    case previousMonth
    case fullYear

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .currentMonth:
            return LocalizedStrings.currentMonth
        case .previousMonth:
            return LocalizedStrings.previousMonth
        case .fullYear:
            return LocalizedStrings.fullYear
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.modelContext) private var modelContext
    @Query private var allTransactions: [Transaction]
    @Query private var allEmployers: [Employer]

    @State private var showingAddTransaction = false
    @State private var selectedPeriod: PeriodFilter? = nil
    @State private var navigateToTransactions = false

    var userTransactions: [Transaction] {
        guard let userId = profileManager.currentUser?.id else { return [] }
        return allTransactions.filter { $0.user?.id == userId }
    }

    var userEmployers: [Employer] {
        guard let userId = profileManager.currentUser?.id else { return [] }
        return allEmployers.filter { $0.user?.id == userId }
    }

    // Total income (gross)
    var totalIncome: Double {
        userTransactions.reduce(0) { $0 + $1.amount }
    }

    // Net income
    var totalNetIncome: Double {
        userTransactions.reduce(0) { $0 + $1.netIncome }
    }

    // Total deductions
    var totalDeductions: Double {
        userTransactions.reduce(0) { $0 + $1.deductedAmount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section - matching web app
                    if let user = profileManager.currentUser {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(user.name)
                                .font(.system(size: 32, weight: .bold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }

                    // Summary Cards - matching web app design
                    VStack(spacing: 16) {
                        SummaryCard(
                            icon: "dollarsign",
                            iconColor: .blue,
                            title: "Total Income",
                            value: totalIncome
                        )

                        SummaryCard(
                            icon: "arrow.down",
                            iconColor: .green,
                            title: "Net Income",
                            value: totalNetIncome
                        )

                        SummaryCard(
                            icon: "minus",
                            iconColor: .orange,
                            title: "Total Deductions",
                            value: totalDeductions
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
    }
}

// Summary Card Component - matching web app
struct SummaryCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: Double

    var body: some View {
        HStack(spacing: 16) {
            // Circular icon on left
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(LocalizedStrings.formatCurrency(value))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProfileManager())
}
