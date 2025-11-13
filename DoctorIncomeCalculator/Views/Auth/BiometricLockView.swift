import SwiftUI

struct BiometricLockView: View {
    @EnvironmentObject var biometricAuth: BiometricAuthManager
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: biometricAuth.biometricType == .faceID ? "faceid" :
                  biometricAuth.biometricType == .touchID ? "touchid" : "lock.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)

            Text("Doctor Income")
                .font(.title)
                .fontWeight(.bold)

            Text(biometricAuth.biometricType != .none ?
                 "Authenticate to access your data" :
                 "Use your device passcode to unlock")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: authenticate) {
                HStack {
                    Image(systemName: biometricAuth.biometricType == .faceID ? "faceid" :
                          biometricAuth.biometricType == .touchID ? "touchid" : "lock.open.fill")
                    Text("Unlock")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .onAppear {
            // Auto-trigger authentication on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authenticate()
            }
        }
        .alert("Authentication Failed", isPresented: $showError) {
            Button("Try Again", role: .cancel) {
                authenticate()
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func authenticate() {
        biometricAuth.authenticate { success, error in
            if !success {
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = "Authentication failed. Please try again."
                }
                showError = true
            }
        }
    }
}

#Preview {
    BiometricLockView()
        .environmentObject(BiometricAuthManager())
}
