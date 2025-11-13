import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext

    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // App Logo/Icon
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                    .padding(.bottom, 20)

                Text("Doctor Income Calculator")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Track your medical practice income")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)

                // Login Form
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    Button(action: handleLogin) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 30)

                Button("Don't have an account? Register") {
                    showingRegister = true
                }
                .padding(.top, 20)

                Spacer()
            }
            .alert("Login Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
        }
    }

    private func handleLogin() {
        let result = authManager.login(email: email, password: password, modelContext: modelContext)

        switch result {
        case .success:
            // Successfully logged in, authManager updates isAuthenticated
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
