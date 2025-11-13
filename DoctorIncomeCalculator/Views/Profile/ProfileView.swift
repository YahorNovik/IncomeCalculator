import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext

    @State private var isEditingProfile = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                if let user = authManager.currentUser {
                    Section("Personal Information") {
                        InfoRow(label: "Name", value: user.name)
                        InfoRow(label: "Email", value: user.email)
                        InfoRow(label: "NIP", value: user.nip)
                        InfoRow(label: "REGON", value: user.regon)
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

                    Section("Fakturownia Integration") {
                        if let apiToken = user.apiToken, !apiToken.isEmpty {
                            InfoRow(label: "API Token", value: "••••••••")
                        } else {
                            Text("Not configured")
                                .foregroundColor(.secondary)
                        }

                        if let domain = user.domain, !domain.isEmpty {
                            InfoRow(label: "Domain", value: domain)
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

                    Button(action: { authManager.logout() }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Logout")
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
                if let user = authManager.currentUser {
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
        guard let user = authManager.currentUser else { return }

        modelContext.delete(user)

        do {
            try modelContext.save()
            authManager.logout()
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
}
