import SwiftUI

struct LoginView: View {
    let onAuthenticated: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 8) {
                Text("boonker").font(.system(size: 42, weight: .bold, design: .rounded))
                Text("Your private internet bunker.").font(.title3).foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 14) {
                Text("Sign in").font(.title2.bold())
                TextField("Email", text: $email).textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled().textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password).textContentType(.password).textFieldStyle(.roundedBorder)
                if let errorMessage { Text(errorMessage).font(.footnote).foregroundStyle(.red) }
                Button { signIn() } label: { HStack { Spacer(); if isLoading { ProgressView().tint(.white) } else { Text("Sign in") }; Spacer() } }.buttonStyle(.borderedProminent).disabled(isLoading || email.isEmpty || password.isEmpty)
                Button("Continue in demo mode") { onAuthenticated() }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
            }
            Spacer(minLength: 24)
            Text("By continuing, you agree to the Terms and Privacy Policy.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(Color(.systemGroupedBackground))
    }

    private func signIn() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                guard let api = BoonkerAPI.configured() else {
                    throw BoonkerAPIError.configurationMissing
                }
                let service = AuthService(api: api)
                try await service.login(email: email, password: password)
                onAuthenticated()
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? "Unable to sign in. Check your details and try again."
            }
            isLoading = false
        }
    }
}
