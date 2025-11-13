import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @Query private var allTransactions: [Transaction]

    var userTransactions: [Transaction] {
        guard let userId = authManager.currentUser?.id else { return [] }
        return allTransactions.filter { $0.user?.id == userId }
    }

    var totalIncome: Double {
        userTransactions.reduce(0) { $0 + $1.amount }
    }

    var totalNetIncome: Double {
        userTransactions.reduce(0) { $0 + $1.netIncome }
    }

    var totalDeductions: Double {
        userTransactions.reduce(0) { $0 + $1.deductedAmount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    if let user = authManager.currentUser {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Welcome back,")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }

                    // Summary Cards
                    VStack(spacing: 15) {
                        SummaryCard(
                            title: "Total Income",
                            value: totalIncome,
                            icon: "dollarsign.circle.fill",
                            color: .blue
                        )

                        SummaryCard(
                            title: "Net Income",
                            value: totalNetIncome,
                            icon: "arrow.down.circle.fill",
                            color: .green
                        )

                        SummaryCard(
                            title: "Total Deductions",
                            value: totalDeductions,
                            icon: "minus.circle.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // Recent Transactions
                    if !userTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Transactions")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(Array(userTransactions.sorted(by: { $0.date > $1.date }).prefix(5))) { transaction in
                                TransactionRow(transaction: transaction)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }

                    // Income Chart
                    if !userTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Income Overview")
                                .font(.headline)
                                .padding(.horizontal)

                            IncomeChartView(transactions: userTransactions)
                                .frame(height: 200)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f PLN", value))
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct IncomeChartView: View {
    let transactions: [Transaction]

    private var monthlyData: [(month: String, income: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.dateComponents([.year, .month], from: transaction.date)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"

        return grouped.map { (components, transactions) in
            let date = calendar.date(from: components) ?? Date()
            let month = dateFormatter.string(from: date)
            let income = transactions.reduce(0) { $0 + $1.amount }
            return (month: month, income: income)
        }
        .sorted { first, second in
            guard let date1 = dateFormatter.date(from: first.month),
                  let date2 = dateFormatter.date(from: second.month) else {
                return false
            }
            return date1 < date2
        }
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(monthlyData, id: \.month) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Income", item.income)
                    )
                    .foregroundStyle(.blue.gradient)
                }
            }
        } else {
            VStack {
                Text("Chart requires iOS 16+")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
}
