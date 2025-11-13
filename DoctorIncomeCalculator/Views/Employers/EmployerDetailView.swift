import SwiftUI
import SwiftData

struct EmployerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var employer: Employer
    @Query private var allTransactions: [Transaction]

    @State private var isEditing = false

    var employerTransactions: [Transaction] {
        allTransactions.filter { $0.employer?.id == employer.id }
    }

    var totalIncome: Double {
        employerTransactions.reduce(0) { $0 + $1.amount }
    }

    var totalNetIncome: Double {
        employerTransactions.reduce(0) { $0 + $1.netIncome }
    }

    var body: some View {
        List {
            Section("Information") {
                InfoRow(label: "Name", value: employer.name)
                InfoRow(label: "NIP", value: employer.nip)
                if let regon = employer.regon {
                    InfoRow(label: "REGON", value: regon)
                }
                InfoRow(label: "Default Percentage", value: "\(Int(employer.defaultPercent))%")
            }

            if !employer.fullAddress.isEmpty {
                Section("Address") {
                    Text(employer.fullAddress)
                }
            }

            Section("Statistics") {
                InfoRow(label: "Total Transactions", value: "\(employerTransactions.count)")
                InfoRow(label: "Total Income", value: String(format: "%.2f PLN", totalIncome))
                InfoRow(label: "Net Income", value: String(format: "%.2f PLN", totalNetIncome))
            }

            if !employerTransactions.isEmpty {
                Section("Recent Transactions") {
                    ForEach(employerTransactions.sorted(by: { $0.date > $1.date }).prefix(5)) { transaction in
                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
            }
        }
        .navigationTitle(employer.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditEmployerView(employer: employer)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
    }
}
