import SwiftUI
import SwiftData

struct AddEmployerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var name = ""
    @State private var nip = ""
    @State private var city = ""
    @State private var street = ""
    @State private var buildingNumber = ""
    @State private var defaultPercent = 18.0

    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Employer Information") {
                    TextField("Name", text: $name)

                    TextField("NIP (10 digits, optional)", text: $nip)
                        .keyboardType(.numberPad)
                        .onChange(of: nip) { _, newValue in
                            nip = String(newValue.prefix(10).filter { $0.isNumber })
                        }
                }

                Section("Address (Optional)") {
                    TextField("City", text: $city)
                    TextField("Street", text: $street)
                    TextField("Building Number", text: $buildingNumber)
                }

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Default Percentage: \(Int(defaultPercent))%")
                            .font(.headline)

                        Slider(value: $defaultPercent, in: 0...100, step: 1)

                        Text("This is the default tax/commission percentage for transactions with this employer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Default Settings")
                }

                Section {
                    Button(action: saveEmployer) {
                        Text("Save Employer")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Employer")
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
        !name.isEmpty && (nip.isEmpty || nip.count == 10)
    }

    private func saveEmployer() {
        guard let user = authManager.currentUser else {
            errorMessage = "User not found"
            showError = true
            return
        }

        let employer = Employer(
            name: name,
            nip: nip.isEmpty ? nil : nip,
            city: city.isEmpty ? nil : city,
            street: street.isEmpty ? nil : street,
            buildingNumber: buildingNumber.isEmpty ? nil : buildingNumber,
            defaultPercent: defaultPercent,
            user: user
        )

        modelContext.insert(employer)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save employer: \(error.localizedDescription)"
            showError = true
        }
    }
}

#Preview {
    AddEmployerView()
        .environmentObject(AuthenticationManager())
}
