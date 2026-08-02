import Foundation

struct ServerLocationDTO: Codable, Identifiable, Hashable {
    let id: String
    let country: String
    let countryCode: String
    let flag: String
    let cities: [ServerNodeDTO]
}

struct ServerNodeDTO: Codable, Identifiable, Hashable {
    let id: String
    let city: String
    let node: String
    let pingMS: Int
    let loadPercent: Int
    let endpoint: String
    let serverPublicKey: String
}

struct TunnelConfigurationDTO: Codable, Equatable {
    let nodeID: String
    let address: String
    let dns: [String]
    let server: String
    let serverPublicKey: String
    let allowedIPs: [String]
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case nodeID = "nodeId"
        case address, dns, server, serverPublicKey, allowedIPs, expiresAt
    }
}

private struct TunnelConfigurationRequest: Encodable {
    let nodeID: String
    let publicKey: String

    enum CodingKeys: String, CodingKey {
        case nodeID = "nodeId"
        case publicKey
    }
}

enum BoonkerAPIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case premiumRequired
    case serverUnavailable
    case configurationMissing

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response."
        case .unauthorized: "Your session has expired."
        case .premiumRequired: "This location requires a Premium plan."
        case .serverUnavailable: "The server is temporarily unavailable."
        case .configurationMissing: "The VPN service is not configured yet."
        }
    }
}

struct BoonkerAPI {
    let baseURL: URL
    var session: URLSession = .shared

    static func configured(bundle: Bundle = .main) -> BoonkerAPI? {
        guard let value = bundle.object(forInfoDictionaryKey: "BoonkerAPIBaseURL") as? String,
              let url = URL(string: value),
              let scheme = url.scheme,
              ["https", "http"].contains(scheme),
              url.host != nil else {
            return nil
        }

        return BoonkerAPI(baseURL: url)
    }

    func locations(token: String?) async throws -> [ServerLocationDTO] {
        let url = baseURL.appendingPathComponent("v1/locations")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw BoonkerAPIError.invalidResponse }
        switch http.statusCode {
        case 200..<300: break
        case 401: throw BoonkerAPIError.unauthorized
        case 500...599: throw BoonkerAPIError.serverUnavailable
        default: throw BoonkerAPIError.invalidResponse
        }
        return try JSONDecoder().decode([ServerLocationDTO].self, from: data)
    }

    func tunnelConfiguration(nodeID: String, publicKey: String, token: String) async throws -> TunnelConfigurationDTO {
        let url = baseURL.appendingPathComponent("v1/tunnels/config")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(TunnelConfigurationRequest(nodeID: nodeID, publicKey: publicKey))

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw BoonkerAPIError.invalidResponse }
        switch http.statusCode {
        case 200..<300: break
        case 401: throw BoonkerAPIError.unauthorized
        case 403: throw BoonkerAPIError.premiumRequired
        case 404, 500...599: throw BoonkerAPIError.serverUnavailable
        default: throw BoonkerAPIError.invalidResponse
        }
        return try JSONDecoder().decode(TunnelConfigurationDTO.self, from: data)
    }
}
