import SwiftUI
import SwiftData

struct EditInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var invoice: Invoice
    @Query private var allEmployers: [Employer]

    @State private var selectedEmployer: Employer?
    @State private var number: String
    @State private var sellDate: Date
    @State private var price: String

    @State private var errorMessage = ""
    @State private var showError = false

    init(invoice: Invoice) {
        self.invoice = invoice
        _selectedEmployer = State(initialValue: invoice.employer)
        _number = State(initialValue: invoice.number ?? "")
        _sellDate = State(initialValue: invoice.sellDate ?? Date())
        _price = State(initialValue: invoice.price != nil ? String(format: "%.2f", invoice.price!) : "")
    }

    var userEmployers: [Employer] {
        guard let userId = invoice.user?.id else { return [] }
        return allEmployers.filter { $0.user?.id == userId }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice Information") {
                    TextField("Invoice Number", text: $number)

                    DatePicker("Sell Date", selection: $sellDate, displayedComponents: .date)

                    TextField("Price (PLN)", text: $price)
                        .keyboardType(.decimalPad)

                    Picker("Employer", selection: $selectedEmployer) {
                        Text("Select Employer").tag(nil as Employer?)
                        ForEach(userEmployers.sorted(by: { $0.name < $1.name })) { employer in
                            Text(employer.name).tag(employer as Employer?)
                        }
                    }
                }

                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Edit Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isFormValid: Bool {
        selectedEmployer != nil && !number.isEmpty
    }

    private func saveChanges() {
        guard let employer = selectedEmployer else {
            errorMessage = "Please select an employer"
            showError = true
            return
        }

        let priceValue = Double(price.replacingOccurrences(of: ",", with: "."))

        invoice.number = number.isEmpty ? nil : number
        invoice.sellDate = sellDate
        invoice.price = priceValue
        invoice.employer = employer
        invoice.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showError = true
        }
    }
}
