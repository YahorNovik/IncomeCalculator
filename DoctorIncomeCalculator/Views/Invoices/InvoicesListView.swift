import SwiftUI
import SwiftData

struct InvoicesListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Invoice.sellDate, order: .reverse) private var allInvoices: [Invoice]

    @State private var showingAddInvoice = false
    @State private var searchText = ""

    var userInvoices: [Invoice] {
        guard let userId = authManager.currentUser?.id else { return [] }
        var filtered = allInvoices.filter { $0.user?.id == userId }

        if !searchText.isEmpty {
            filtered = filtered.filter { invoice in
                invoice.number?.localizedCaseInsensitiveContains(searchText) ?? false ||
                invoice.employer?.name.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }

        return filtered
    }

    var totalValue: Double {
        userInvoices.compactMap { $0.price }.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary
                HStack(spacing: 20) {
                    VStack {
                        Text("Total Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f PLN", totalValue))
                            .font(.headline)
                    }

                    Divider()

                    VStack {
                        Text("Count")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(userInvoices.count)")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                // Invoices List
                List {
                    ForEach(userInvoices) { invoice in
                        NavigationLink(destination: InvoiceDetailView(invoice: invoice)) {
                            InvoiceRow(invoice: invoice)
                        }
                    }
                    .onDelete(perform: deleteInvoices)
                }
            }
            .navigationTitle("Invoices")
            .searchable(text: $searchText, prompt: "Search invoices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddInvoice = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddInvoice) {
                AddInvoiceView()
            }
            .overlay {
                if userInvoices.isEmpty {
                    ContentUnavailableView(
                        "No Invoices",
                        systemImage: "doc.text",
                        description: Text("Add your first invoice to start tracking")
                    )
                }
            }
        }
    }

    private func deleteInvoices(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(userInvoices[index])
        }
    }
}

struct InvoiceRow: View {
    let invoice: Invoice

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(invoice.number ?? "No Number")
                    .font(.headline)

                Spacer()

                if let price = invoice.price {
                    Text(String(format: "%.2f PLN", price))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }

            HStack {
                if let sellDate = invoice.sellDate {
                    Text(sellDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let employer = invoice.employer {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(employer.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    InvoicesListView()
        .environmentObject(AuthenticationManager())
}
