import SwiftUI
import SwiftData

struct AddInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @Query private var allEmployers: [Employer]

    @State private var selectedEmployer: Employer?
    @State private var number = ""
    @State private var sellDate = Date()
    @State private var price = ""
    @State private var fakturowniaId = ""

    @State private var errorMessage = ""
    @State private var showError = false

    var userEmployers: [Employer] {
        guard let userId = authManager.currentUser?.id else { return [] }
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

                Section("Fakturownia Integration (Optional)") {
                    TextField("Fakturownia ID", text: $fakturowniaId)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button(action: saveInvoice) {
                        Text("Save Invoice")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Invoice")
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

    private func saveInvoice() {
        guard let user = authManager.currentUser,
              let employer = selectedEmployer else {
            errorMessage = "Please select an employer"
            showError = true
            return
        }

        let priceValue = Double(price.replacingOccurrences(of: ",", with: "."))

        let invoice = Invoice(
            fakturowniaId: fakturowniaId.isEmpty ? nil : fakturowniaId,
            number: number.isEmpty ? nil : number,
            sellDate: sellDate,
            price: priceValue,
            employer: employer,
            user: user
        )

        modelContext.insert(invoice)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save invoice: \(error.localizedDescription)"
            showError = true
        }
    }
}

#Preview {
    AddInvoiceView()
        .environmentObject(AuthenticationManager())
}
