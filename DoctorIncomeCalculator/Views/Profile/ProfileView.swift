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
            ScrollView {
                VStack(spacing: 20) {
                    if let user = profileManager.currentUser {
                        // PERSONAL INFORMATION Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("PERSONAL INFORMATION")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)

                            VStack(spacing: 0) {
                                InfoRow(label: "Name", value: user.name)
                                Divider()
                                    .padding(.leading, 20)
                                InfoRow(label: "Email", value: user.email)
                                if let nip = user.nip {
                                    Divider()
                                        .padding(.leading, 20)
                                    InfoRow(label: "NIP", value: nip)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }

                        // ACCOUNT Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("ACCOUNT")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)

                            VStack(spacing: 0) {
                                InfoRow(label: "Member Since", value: user.createdAt.formatted(date: .long, time: .omitted))
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }

                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: { isEditingProfile = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                    Text("Edit Profile")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                            }

                            Button(action: { biometricAuth.logout() }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.blue)
                                    Text("Lock App")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Delete Account Button
                        VStack(spacing: 0) {
                            Button(action: { showingDeleteConfirmation = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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

// Info Row Component - matching web app
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProfileManager())
        .environmentObject(BiometricAuthManager())
}
