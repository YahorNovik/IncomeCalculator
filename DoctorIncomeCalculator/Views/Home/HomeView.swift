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
    @State private var showMonthlyOverview = true
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
                VStack(spacing: 16) {
                    // Add Transaction Button - top right in web, here as prominent action
                    Button(action: { showingAddTransaction = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text(LocalizedStrings.addTransaction)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Monthly Overview - Collapsible like web app
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showMonthlyOverview.toggle()
                            }
                        }) {
                            HStack {
                                Text("Podsumowanie miesięczne")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: showMonthlyOverview ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if showMonthlyOverview {
                            VStack(spacing: 12) {
                                Divider()

                                // Total Earnings - prominent display
                                VStack(spacing: 4) {
                                    Text("Całkowite zarobki")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(LocalizedStrings.formatCurrency(currentMonthIncome))
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 8)

                                Divider()

                                // Additional metrics
                                HStack(spacing: 20) {
                                    VStack(spacing: 4) {
                                        Text("Liczba transakcji")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        let currentMonthTransactions = userTransactions.filter { transaction in
                                            Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .month)
                                        }
                                        Text("\(currentMonthTransactions.count)")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }

                                    Spacer()

                                    VStack(spacing: 4) {
                                        Text("Łączna kwota")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        let totalAmount = currentMonthTransactions.reduce(0) { $0 + $1.amount }
                                        Text(LocalizedStrings.formatCurrency(totalAmount))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(.bottom, 8)
                            }
                            .padding(.horizontal, 16)
                            .background(Color.white)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 16)

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

                    // By Employer Section - like web app
                    if !userEmployers.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showDetailedDashboard.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Według pracodawcy")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: showDetailedDashboard ? "chevron.down" : "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if showDetailedDashboard {
                                VStack(spacing: 8) {
                                    Divider()

                                    let employerIncomes = incomeByEmployer()
                                    if employerIncomes.isEmpty {
                                        Text(LocalizedStrings.noData)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(employerIncomes, id: \.employer.id) { item in
                                            HStack {
                                                Text(item.employer.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                Text(LocalizedStrings.formatCurrency(item.income))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.green)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)

                                            if item.employer.id != employerIncomes.last?.employer.id {
                                                Divider()
                                                    .padding(.leading, 16)
                                            }
                                        }
                                    }
                                }
                                .background(Color.white)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(LocalizedStrings.dashboard)
            .navigationBarTitleDisplayMode(.large)
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

// Period Income Card Component - matching web design
struct PeriodIncomeCard: View {
    let title: String
    let income: Double
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(LocalizedStrings.formatCurrency(income))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Filtered Transactions View - matching web design
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
            VStack(spacing: 16) {
                // Summary Card - matching web design
                VStack(spacing: 8) {
                    Text(LocalizedStrings.netIncome)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(LocalizedStrings.formatCurrency(totalIncome))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 16)
                .padding(.top, 8)

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
                    VStack(spacing: 8) {
                        ForEach(filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                            NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                                TransactionRowCompact(transaction: transaction)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(periodFilter.displayName)
        .navigationBarTitleDisplayMode(.large)
    }
}

// Compact Transaction Row - matching web card design
struct TransactionRowCompact: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let employer = transaction.employer {
                    Text(employer.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(LocalizedStrings.formatCurrency(transaction.netIncome))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                Text(LocalizedStrings.formatPercent(transaction.percent))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProfileManager())
}
