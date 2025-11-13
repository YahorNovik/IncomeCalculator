import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var biometricAuth: BiometricAuthManager
    @Environment(\.modelContext) private var modelContext

    @State private var isEditingProfile = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                if let user = profileManager.currentUser {
                    Section("Personal Information") {
                        InfoRow(label: "Name", value: user.name)
                        InfoRow(label: "Email", value: user.email)
                        if let nip = user.nip {
                            InfoRow(label: "NIP", value: nip)
                        }
                    }

                    if user.city != nil || user.street != nil || user.buildingNumber != nil {
                        Section("Address") {
                            if let city = user.city {
                                InfoRow(label: "City", value: city)
                            }
                            if let street = user.street {
                                InfoRow(label: "Street", value: street)
                            }
                            if let buildingNumber = user.buildingNumber {
                                InfoRow(label: "Building Number", value: buildingNumber)
                            }
                        }
                    }

                    Section("Account") {
                        InfoRow(label: "Member Since", value: user.createdAt.formatted(date: .long, time: .omitted))
                    }
                }

                Section {
                    Button(action: { isEditingProfile = true }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                        }
                    }

                    Button(action: { biometricAuth.logout() }) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Lock App")
                        }
                        .foregroundColor(.blue)
                    }
                }

                Section {
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditingProfile) {
                if let user = profileManager.currentUser {
                    EditProfileView(user: user)
                }
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and will delete all your data including employers, transactions, and invoices.")
            }
        }
    }

    private func deleteAccount() {
        guard let user = profileManager.currentUser else { return }

        modelContext.delete(user)

        do {
            try modelContext.save()
            profileManager.resetSetup()
            biometricAuth.logout()
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProfileManager())
        .environmentObject(BiometricAuthManager())
}
