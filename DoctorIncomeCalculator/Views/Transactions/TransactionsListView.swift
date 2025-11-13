import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case thisYear = "This Year"
    }

    var userTransactions: [Transaction] {
        guard let userId = authManager.currentUser?.id else { return [] }
        var filtered = allTransactions.filter { $0.user?.id == userId }

        // Apply date filter
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {
        case .all:
            break
        case .thisMonth:
            filtered = filtered.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
        case .lastMonth:
            if let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) {
                filtered = filtered.filter { transaction in
                    calendar.isDate(transaction.date, equalTo: lastMonth, toGranularity: .month)
                }
            }
        case .thisYear:
            filtered = filtered.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .year)
            }
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.employer?.name.localizedCaseInsensitiveContains(searchText) ?? false ||
                transaction.patientName?.localizedCaseInsensitiveContains(searchText) ?? false ||
                transaction.transactionDescription?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }

        return filtered
    }

    var totalAmount: Double {
        userTransactions.reduce(0) { $0 + $1.amount }
    }

    var totalNetIncome: Double {
        userTransactions.reduce(0) { $0 + $1.netIncome }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Summary
                HStack(spacing: 20) {
                    VStack {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f PLN", totalAmount))
                            .font(.headline)
                    }

                    Divider()

                    VStack {
                        Text("Net Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f PLN", totalNetIncome))
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    Divider()

                    VStack {
                        Text("Count")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(userTransactions.count)")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                // Transactions List
                List {
                    ForEach(userTransactions) { transaction in
                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: $searchText, prompt: "Search transactions")
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
            .overlay {
                if userTransactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "dollarsign.circle",
                        description: Text("Add your first transaction to start tracking income")
                    )
                }
            }
        }
    }

    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(userTransactions[index])
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(transaction.employer?.name ?? "Unknown Employer")
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f PLN", transaction.amount))
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            HStack {
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let patientName = transaction.patientName {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(patientName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(Int(transaction.percent))%")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)

                Text(String(format: "%.2f PLN", transaction.netIncome))
                    .font(.caption)
                    .foregroundColor(.green)
            }

            if let description = transaction.transactionDescription, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    TransactionsListView()
        .environmentObject(AuthenticationManager())
}
