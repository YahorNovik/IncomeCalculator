import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var biometricAuth: BiometricAuthManager

    @State private var currentStep = 0
    @State private var name = ""
    @State private var nip = ""
    @State private var city = ""
    @State private var street = ""
    @State private var buildingNumber = ""

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)

                Spacer()

                // Content based on step
                Group {
                    switch currentStep {
                    case 0:
                        WelcomeStep()
                    case 1:
                        ProfileSetupStep(name: $name, nip: $nip, city: $city, street: $street, buildingNumber: $buildingNumber)
                    case 2:
                        SecuritySetupStep()
                    default:
                        EmptyView()
                    }
                }

                Spacer()

                // Navigation buttons
                VStack(spacing: 15) {
                    if currentStep == 0 {
                        Button(action: { currentStep += 1 }) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else if currentStep == 1 {
                        Button(action: { currentStep += 1 }) {
                            Text("Continue")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(name.isEmpty)

                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    } else if currentStep == 2 {
                        Button(action: completeSetup) {
                            Text("Complete Setup")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .alert("Setup Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func completeSetup() {
        // Create user profile
        let user = User(
            email: "\(UUID().uuidString)@local.app", // Dummy email for local storage
            password: UUID().uuidString, // Random password (not used for auth)
            name: name,
            nip: nip.isEmpty ? nil : nip,
            city: city.isEmpty ? nil : city,
            street: street.isEmpty ? nil : street,
            buildingNumber: buildingNumber.isEmpty ? nil : buildingNumber
        )

        modelContext.insert(user)

        do {
            try modelContext.save()
            profileManager.completeSetup(user: user)
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            showError = true
        }
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)

            Text("Welcome to\nDoctor Income")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Track your medical practice income from multiple employers, all stored privately on your device.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct ProfileSetupStep: View {
    @Binding var name: String
    @Binding var nip: String
    @Binding var city: String
    @Binding var street: String
    @Binding var buildingNumber: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.bold)

            Text("This information stays on your device")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(spacing: 15) {
                TextField("Full Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)

                TextField("Tax ID (optional)", text: $nip)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onChange(of: nip) { _, newValue in
                        nip = String(newValue.prefix(10).filter { $0.isNumber })
                    }

                Divider()

                Text("Address (Optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("City", text: $city)
                    .textFieldStyle(.roundedBorder)

                TextField("Street", text: $street)
                    .textFieldStyle(.roundedBorder)

                TextField("Building Number", text: $buildingNumber)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 30)
        }
    }
}

struct SecuritySetupStep: View {
    @EnvironmentObject var biometricAuth: BiometricAuthManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: biometricAuth.biometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            Text("Secure Your Data")
                .font(.title2)
                .fontWeight(.bold)

            if biometricAuth.biometricType != .none {
                Text("Use \(biometricAuth.biometricType.description) to secure your income data")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            } else {
                Text("Use your device passcode to secure your income data")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "lock.fill", text: "All data stored locally")
                FeatureRow(icon: "eye.slash.fill", text: "No cloud sync, complete privacy")
                FeatureRow(icon: "iphone", text: "Only accessible on this device")
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserProfileManager())
        .environmentObject(BiometricAuthManager())
}
