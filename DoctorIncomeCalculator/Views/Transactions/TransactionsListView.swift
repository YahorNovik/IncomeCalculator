import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all

    enum TransactionFilter: String, CaseIterable {
        case all = "Wszystkie"
        case thisMonth = "Bieżący miesiąc"
        case lastMonth = "Poprzedni miesiąc"
        case thisYear = "Cały rok"
    }

    var userTransactions: [Transaction] {
        guard let userId = profileManager.currentUser?.id else { return [] }
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
                        Text(LocalizedStrings.grossIncome)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(LocalizedStrings.formatCurrency(totalAmount))
                            .font(.headline)
                    }

                    Divider()

                    VStack {
                        Text(LocalizedStrings.netIncome)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(LocalizedStrings.formatCurrency(totalNetIncome))
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    Divider()

                    VStack {
                        Text("Liczba")
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
            .navigationTitle(LocalizedStrings.transactions)
            .searchable(text: $searchText, prompt: LocalizedStrings.search)
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
                        LocalizedStrings.noTransactions,
                        systemImage: "dollarsign.circle",
                        description: Text("Dodaj swoją pierwszą transakcję, aby rozpocząć śledzenie dochodów")
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
                Text(transaction.employer?.name ?? "Nieznany pracodawca")
                    .font(.headline)

                Spacer()

                Text(LocalizedStrings.formatCurrency(transaction.amount))
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

                Text(LocalizedStrings.formatPercent(transaction.percent))
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)

                Text(LocalizedStrings.formatCurrency(transaction.netIncome))
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
        .environmentObject(UserProfileManager())
}
