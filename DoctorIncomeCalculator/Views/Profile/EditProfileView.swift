import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User

    @State private var name: String
    @State private var email: String
    @State private var city: String
    @State private var street: String
    @State private var buildingNumber: String
    @State private var apiToken: String
    @State private var domain: String
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var errorMessage = ""
    @State private var showError = false

    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
        _city = State(initialValue: user.city ?? "")
        _street = State(initialValue: user.street ?? "")
        _buildingNumber = State(initialValue: user.buildingNumber ?? "")
        _apiToken = State(initialValue: user.apiToken ?? "")
        _domain = State(initialValue: user.domain ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disabled(true) // Email cannot be changed
                }

                Section("Business Information") {
                    Text("NIP: \(user.nip)")
                        .foregroundColor(.secondary)
                    Text("REGON: \(user.regon)")
                        .foregroundColor(.secondary)
                }

                Section("Address") {
                    TextField("City", text: $city)
                    TextField("Street", text: $street)
                    TextField("Building Number", text: $buildingNumber)
                }

                Section("Fakturownia Integration") {
                    TextField("API Token", text: $apiToken)
                    TextField("Domain", text: $domain)
                        .autocapitalization(.none)
                }

                Section("Change Password") {
                    SecureField("Current Password", text: $currentPassword)
                        .textContentType(.password)

                    SecureField("New Password", text: $newPassword)
                        .textContentType(.newPassword)

                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }

                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Edit Profile")
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

    private func saveChanges() {
        // Validate password change if attempted
        if !currentPassword.isEmpty || !newPassword.isEmpty || !confirmPassword.isEmpty {
            if currentPassword.isEmpty {
                errorMessage = "Please enter your current password"
                showError = true
                return
            }

            if !user.verifyPassword(currentPassword) {
                errorMessage = "Current password is incorrect"
                showError = true
                return
            }

            if newPassword != confirmPassword {
                errorMessage = "New passwords do not match"
                showError = true
                return
            }

            if newPassword.isEmpty {
                errorMessage = "New password cannot be empty"
                showError = true
                return
            }

            user.updatePassword(newPassword)
        }

        // Update user information
        user.name = name
        user.city = city.isEmpty ? nil : city
        user.street = street.isEmpty ? nil : street
        user.buildingNumber = buildingNumber.isEmpty ? nil : buildingNumber
        user.apiToken = apiToken.isEmpty ? nil : apiToken
        user.domain = domain.isEmpty ? nil : domain
        user.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showError = true
        }
    }
}
