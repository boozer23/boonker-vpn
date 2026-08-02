import Foundation

struct AuthService {
    let api: BoonkerAPI
    let tokenStore = SecureTokenStore()

    func login(email: String, password: String) async throws {
        let url = api.baseURL.appendingPathComponent("v1/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])
        let (data, response) = try await api.session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw BoonkerAPIError.invalidResponse }
        guard http.statusCode != 401 else { throw BoonkerAPIError.unauthorized }
        guard (200..<300).contains(http.statusCode) else { throw BoonkerAPIError.invalidResponse }
        let result = try JSONDecoder().decode(LoginResponse.self, from: data)
        try tokenStore.save(result.accessToken)
    }

    func restoreSession() -> Bool {
        guard let token = try? tokenStore.read() else { return false }
        return !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func logout() { tokenStore.delete() }
}

private struct LoginResponse: Codable {
    let accessToken: String
}
