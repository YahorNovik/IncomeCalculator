import SwiftUI
import SwiftData

struct EditEmployerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var employer: Employer

    @State private var name: String
    @State private var nip: String
    @State private var city: String
    @State private var street: String
    @State private var buildingNumber: String
    @State private var defaultPercent: Double

    @State private var errorMessage = ""
    @State private var showError = false

    init(employer: Employer) {
        self.employer = employer
        _name = State(initialValue: employer.name)
        _nip = State(initialValue: employer.nip ?? "")
        _city = State(initialValue: employer.city ?? "")
        _street = State(initialValue: employer.street ?? "")
        _buildingNumber = State(initialValue: employer.buildingNumber ?? "")
        _defaultPercent = State(initialValue: employer.defaultPercent)
    }

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
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Edit Employer")
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

    private func saveChanges() {
        employer.name = name
        employer.nip = nip.isEmpty ? nil : nip
        employer.city = city.isEmpty ? nil : city
        employer.street = street.isEmpty ? nil : street
        employer.buildingNumber = buildingNumber.isEmpty ? nil : buildingNumber
        employer.defaultPercent = defaultPercent
        employer.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showError = true
        }
    }
}
