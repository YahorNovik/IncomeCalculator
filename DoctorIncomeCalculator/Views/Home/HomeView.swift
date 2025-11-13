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
    @State private var showDetailedDashboard = false
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

    // Calculate income for current month
    var currentMonthIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let filtered = userTransactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }
        return filtered.reduce(0) { $0 + $1.netIncome }
    }

    // Calculate income for previous month
    var previousMonthIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return 0 }
        let filtered = userTransactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: previousMonth, toGranularity: .month)
        }
        return filtered.reduce(0) { $0 + $1.netIncome }
    }

    // Calculate income for full year
    var fullYearIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let filtered = userTransactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .year)
        }
        return filtered.reduce(0) { $0 + $1.netIncome }
    }

    // Calculate income by employer
    func incomeByEmployer() -> [(employer: Employer, income: Double)] {
        let calendar = Calendar.current
        let now = Date()

        return userEmployers.compactMap { employer in
            let transactions = userTransactions.filter { transaction in
                transaction.employer?.id == employer.id &&
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .year)
            }
            let income = transactions.reduce(0) { $0 + $1.netIncome }
            return (employer: employer, income: income)
        }
        .filter { $0.income > 0 }
        .sorted { $0.income > $1.income }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    if let user = profileManager.currentUser {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Witaj,")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    // Add Transaction Button
                    Button(action: { showingAddTransaction = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                            Text(LocalizedStrings.addTransaction)
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Period Income Cards
                    VStack(spacing: 15) {
                        PeriodIncomeCard(
                            title: LocalizedStrings.currentMonth,
                            income: currentMonthIncome,
                            icon: "calendar",
                            color: .blue,
                            action: {
                                selectedPeriod = .currentMonth
                                navigateToTransactions = true
                            }
                        )

                        PeriodIncomeCard(
                            title: LocalizedStrings.previousMonth,
                            income: previousMonthIncome,
                            icon: "calendar.badge.clock",
                            color: .green,
                            action: {
                                selectedPeriod = .previousMonth
                                navigateToTransactions = true
                            }
                        )

                        PeriodIncomeCard(
                            title: LocalizedStrings.fullYear,
                            income: fullYearIncome,
                            icon: "chart.bar.fill",
                            color: .purple,
                            action: {
                                selectedPeriod = .fullYear
                                navigateToTransactions = true
                            }
                        )
                    }
                    .padding(.horizontal)

                    // Detailed Dashboard Section
                    if !userEmployers.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Button(action: {
                                withAnimation {
                                    showDetailedDashboard.toggle()
                                }
                            }) {
                                HStack {
                                    Text(LocalizedStrings.detailedDashboard)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: showDetailedDashboard ? "chevron.down" : "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }

                            if showDetailedDashboard {
                                VStack(spacing: 12) {
                                    Text(LocalizedStrings.byEmployer)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    let employerIncomes = incomeByEmployer()
                                    if employerIncomes.isEmpty {
                                        Text(LocalizedStrings.noData)
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(employerIncomes, id: \.employer.id) { item in
                                            EmployerIncomeRow(
                                                employerName: item.employer.name,
                                                income: item.income
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(LocalizedStrings.dashboard)
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .navigationDestination(isPresented: $navigateToTransactions) {
                if let period = selectedPeriod {
                    FilteredTransactionsView(periodFilter: period)
                }
            }
        }
    }
}

// Period Income Card Component
struct PeriodIncomeCard: View {
    let title: String
    let income: Double
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(LocalizedStrings.formatCurrency(income))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Employer Income Row Component
struct EmployerIncomeRow: View {
    let employerName: String
    let income: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(employerName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()

            Text(LocalizedStrings.formatCurrency(income))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Filtered Transactions View
struct FilteredTransactionsView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Query private var allTransactions: [Transaction]
    let periodFilter: PeriodFilter

    var filteredTransactions: [Transaction] {
        guard let userId = profileManager.currentUser?.id else { return [] }
        let userTransactions = allTransactions.filter { $0.user?.id == userId }

        let calendar = Calendar.current
        let now = Date()

        switch periodFilter {
        case .currentMonth:
            return userTransactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
        case .previousMonth:
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            return userTransactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: previousMonth, toGranularity: .month)
            }
        case .fullYear:
            return userTransactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .year)
            }
        }
    }

    var totalIncome: Double {
        filteredTransactions.reduce(0) { $0 + $1.netIncome }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Summary Card
                VStack(spacing: 8) {
                    Text(LocalizedStrings.netIncome)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(LocalizedStrings.formatCurrency(totalIncome))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Transactions List
                if filteredTransactions.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text(LocalizedStrings.noTransactions)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    VStack(spacing: 10) {
                        ForEach(filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                            NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                                TransactionRowCompact(transaction: transaction)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(periodFilter.displayName)
        .navigationBarTitleDisplayMode(.large)
    }
}

// Compact Transaction Row for Lists
struct TransactionRowCompact: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let employer = transaction.employer {
                    Text(employer.name)
                        .font(.headline)
                }
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(LocalizedStrings.formatCurrency(transaction.netIncome))
                    .font(.headline)
                    .foregroundColor(.green)
                Text(LocalizedStrings.formatPercent(transaction.percent))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProfileManager())
}
