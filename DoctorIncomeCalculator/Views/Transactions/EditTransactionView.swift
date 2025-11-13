import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var transaction: Transaction
    @Query private var allEmployers: [Employer]

    @State private var selectedEmployer: Employer?
    @State private var date: Date
    @State private var amount: String
    @State private var percent: Double
    @State private var patientName: String
    @State private var transactionDescription: String

    @State private var errorMessage = ""
    @State private var showError = false

    init(transaction: Transaction) {
        self.transaction = transaction
        _selectedEmployer = State(initialValue: transaction.employer)
        _date = State(initialValue: transaction.date)
        _amount = State(initialValue: String(format: "%.2f", transaction.amount))
        _percent = State(initialValue: transaction.percent)
        _patientName = State(initialValue: transaction.patientName ?? "")
        _transactionDescription = State(initialValue: transaction.transactionDescription ?? "")
    }

    var userEmployers: [Employer] {
        guard let userId = transaction.user?.id else { return [] }
        return allEmployers.filter { $0.user?.id == userId }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Picker("Employer", selection: $selectedEmployer) {
                        Text("Select Employer").tag(nil as Employer?)
                        ForEach(userEmployers.sorted(by: { $0.name < $1.name })) { employer in
                            Text(employer.name).tag(employer as Employer?)
                        }
                    }

                    TextField("Amount (PLN)", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section("Additional Information") {
                    TextField("Patient Name (optional)", text: $patientName)

                    TextField("Description (optional)", text: $transactionDescription)
                }

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Percentage: \(Int(percent))%")
                            .font(.headline)

                        Slider(value: $percent, in: 0...100, step: 1)

                        if let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")), amountValue > 0 {
                            HStack {
                                Text("Deduction:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.2f PLN", amountValue * percent / 100))
                                    .foregroundColor(.orange)
                            }

                            HStack {
                                Text("Net Income:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.2f PLN", amountValue * (1 - percent / 100)))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                } header: {
                    Text("Tax/Commission Percentage")
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
            .navigationTitle("Edit Transaction")
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
        guard selectedEmployer != nil,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountValue >= 0 else {
            return false
        }
        return true
    }

    private func saveChanges() {
        guard let employer = selectedEmployer,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }

        transaction.date = date
        transaction.amount = amountValue
        transaction.percent = percent
        transaction.patientName = patientName.isEmpty ? nil : patientName
        transaction.transactionDescription = transactionDescription.isEmpty ? nil : transactionDescription
        transaction.employer = employer
        transaction.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showError = true
        }
    }
}
