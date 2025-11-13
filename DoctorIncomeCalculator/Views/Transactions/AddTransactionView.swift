import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var profileManager: UserProfileManager
    @Query private var allEmployers: [Employer]

    @State private var selectedEmployer: Employer?
    @State private var date = Date()
    @State private var amount = ""
    @State private var percent = 40.0
    @State private var patientName = ""
    @State private var transactionDescription = ""

    @State private var errorMessage = ""
    @State private var showError = false

    var userEmployers: [Employer] {
        guard let userId = profileManager.currentUser?.id else { return [] }
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
                    .onChange(of: selectedEmployer) { _, newEmployer in
                        if let employer = newEmployer {
                            percent = employer.defaultPercent
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
                    Button(action: saveTransaction) {
                        Text("Save Transaction")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Transaction")
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
        guard let employer = selectedEmployer,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountValue >= 0 else {
            return false
        }
        return true
    }

    private func saveTransaction() {
        guard let user = profileManager.currentUser,
              let employer = selectedEmployer,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }

        let transaction = Transaction(
            date: date,
            amount: amountValue,
            percent: percent,
            patientName: patientName.isEmpty ? nil : patientName,
            transactionDescription: transactionDescription.isEmpty ? nil : transactionDescription,
            employer: employer,
            user: user
        )

        modelContext.insert(transaction)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
            showError = true
        }
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(UserProfileManager())
}
