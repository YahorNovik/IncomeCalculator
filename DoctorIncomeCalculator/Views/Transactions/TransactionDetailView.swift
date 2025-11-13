import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var transaction: Transaction

    @State private var isEditing = false

    var body: some View {
        List {
            Section("Transaction Information") {
                InfoRow(label: "Date", value: transaction.date.formatted(date: .long, time: .omitted))
                InfoRow(label: "Amount", value: String(format: "%.2f PLN", transaction.amount))
                InfoRow(label: "Percentage", value: "\(Int(transaction.percent))%")
            }

            Section("Employer") {
                if let employer = transaction.employer {
                    NavigationLink(destination: EmployerDetailView(employer: employer)) {
                        Text(employer.name)
                    }
                } else {
                    Text("Unknown Employer")
                        .foregroundColor(.secondary)
                }
            }

            if let patientName = transaction.patientName {
                Section("Patient") {
                    Text(patientName)
                }
            }

            if let description = transaction.transactionDescription, !description.isEmpty {
                Section("Description") {
                    Text(description)
                }
            }

            Section("Calculations") {
                HStack {
                    Text("Gross Amount")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.2f PLN", transaction.amount))
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Deduction (\(Int(transaction.percent))%)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.2f PLN", transaction.deductedAmount))
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Net Income")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "%.2f PLN", transaction.netIncome))
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }

            Section("Metadata") {
                InfoRow(label: "Created", value: transaction.createdAt.formatted(date: .long, time: .shortened))
                InfoRow(label: "Last Updated", value: transaction.updatedAt.formatted(date: .long, time: .shortened))
            }
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditTransactionView(transaction: transaction)
        }
    }
}
