import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var nip = ""
    @State private var regon = ""
    @State private var city = ""
    @State private var street = ""
    @State private var buildingNumber = ""

    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Information") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }

                Section("Personal Information") {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)

                    TextField("NIP (10 digits)", text: $nip)
                        .keyboardType(.numberPad)
                        .onChange(of: nip) { _, newValue in
                            nip = String(newValue.prefix(10).filter { $0.isNumber })
                        }

                    TextField("REGON (9 digits)", text: $regon)
                        .keyboardType(.numberPad)
                        .onChange(of: regon) { _, newValue in
                            regon = String(newValue.prefix(9).filter { $0.isNumber })
                        }
                }

                Section("Address (Optional)") {
                    TextField("City", text: $city)
                    TextField("Street", text: $street)
                    TextField("Building Number", text: $buildingNumber)
                }

                Section {
                    Button(action: handleRegister) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Registration Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !name.isEmpty &&
        nip.count == 10 &&
        regon.count == 9
    }

    private func handleRegister() {
        let result = authManager.register(
            email: email,
            password: password,
            name: name,
            nip: nip,
            regon: regon,
            city: city.isEmpty ? nil : city,
            street: street.isEmpty ? nil : street,
            buildingNumber: buildingNumber.isEmpty ? nil : buildingNumber,
            modelContext: modelContext
        )

        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationManager())
}
