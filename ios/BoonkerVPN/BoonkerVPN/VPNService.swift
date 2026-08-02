import Foundation
import NetworkExtension

enum VPNConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case failed(String)
}

struct VPNEndpoint: Equatable {
    let country: String
    let city: String
    let node: String
    let host: String
    let publicKey: String
    let address: String
}

@MainActor
final class VPNService: ObservableObject {
    @Published private(set) var state: VPNConnectionState = .disconnected
    @Published private(set) var endpoint: VPNEndpoint?

    private var manager: NETunnelProviderManager?

    func connect(to endpoint: VPNEndpoint) async {
        guard state != .connected, state != .connecting else { return }
        self.endpoint = endpoint
        state = .connecting

        do {
            let manager = try await loadManager()
            self.manager = manager
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.providerBundleIdentifier = "com.boonker.vpn.PacketTunnel"
            tunnelProtocol.providerConfiguration = [
                "address": endpoint.address,
                "dns": "1.1.1.1",
                "server": endpoint.host,
                "serverPublicKey": endpoint.publicKey,
                "privateKey": "pending"
            ]
            manager.protocolConfiguration = tunnelProtocol
            manager.isEnabled = true
            try await manager.saveToPreferences()
            try manager.connection.startVPNTunnel()
            state = .connected
        } catch {
            // The app target is deliberately honest until the Packet Tunnel
            // Provider is added and receives a real WireGuard configuration.
            state = .failed(error.localizedDescription)
        }
    }

    func disconnect() {
        guard state == .connected else {
            state = .disconnected
            return
        }
        state = .disconnecting
        manager?.connection.stopVPNTunnel()
        state = .disconnected
    }

    func refreshStatus() async {
        do {
            let manager = try await loadManager()
            self.manager = manager
            switch manager.connection.status {
            case .connected, .reasserting: state = .connected
            case .connecting: state = .connecting
            case .disconnecting: state = .disconnecting
            case .invalid, .disconnected: state = .disconnected
            @unknown default: state = .disconnected
            }
        } catch {
            state = .disconnected
        }
    }

    private func loadManager() async throws -> NETunnelProviderManager {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        if let existing = managers.first { return existing }

        let created = NETunnelProviderManager()
        created.localizedDescription = "Boonker VPN"
        created.protocolConfiguration = NETunnelProviderProtocol()
        created.isEnabled = true
        try await created.saveToPreferences()
        return created
    }
}
