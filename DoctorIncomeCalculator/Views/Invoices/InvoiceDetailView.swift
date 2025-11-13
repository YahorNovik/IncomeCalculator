import SwiftUI
import SwiftData

struct InvoiceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var invoice: Invoice

    @State private var isEditing = false

    var body: some View {
        List {
            Section("Invoice Information") {
                InfoRow(label: "Number", value: invoice.number ?? "N/A")

                if let sellDate = invoice.sellDate {
                    InfoRow(label: "Sell Date", value: sellDate.formatted(date: .long, time: .omitted))
                }

                if let price = invoice.price {
                    InfoRow(label: "Price", value: String(format: "%.2f PLN", price))
                }
            }

            Section("Employer") {
                if let employer = invoice.employer {
                    NavigationLink(destination: EmployerDetailView(employer: employer)) {
                        Text(employer.name)
                    }
                } else {
                    Text("Unknown Employer")
                        .foregroundColor(.secondary)
                }
            }

            if let fakturowniaId = invoice.fakturowniaId, !fakturowniaId.isEmpty {
                Section("Fakturownia Integration") {
                    InfoRow(label: "Fakturownia ID", value: fakturowniaId)
                }
            }

            Section("Metadata") {
                InfoRow(label: "Created", value: invoice.createdAt.formatted(date: .long, time: .shortened))
                InfoRow(label: "Last Updated", value: invoice.updatedAt.formatted(date: .long, time: .shortened))
            }
        }
        .navigationTitle("Invoice Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditInvoiceView(invoice: invoice)
        }
    }
}
