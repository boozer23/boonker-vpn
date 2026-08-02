import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String: NSObject]?) async throws {
        guard let configuration = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration,
              let address = configuration["address"] as? String,
              let dns = configuration["dns"] as? String,
              let privateKey = configuration["privateKey"] as? String,
              let serverPublicKey = configuration["serverPublicKey"] as? String,
              let server = configuration["server"] as? String,
              !privateKey.isEmpty,
              privateKey != "pending",
              !serverPublicKey.isEmpty,
              !server.isEmpty else {
            throw NSError(domain: "BoonkerVPN", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing tunnel configuration"])
        }

        // Do not install a default route until a real WireGuard engine is
        // attached. A placeholder tunnel would otherwise black-hole traffic.
        throw NSError(
            domain: "BoonkerVPN",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "WireGuard engine is not configured yet"]
        )

        // WireGuard userspace engine will be attached here next. Until then,
        // the provider fails closed instead of creating a black-hole tunnel.
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        cancelTunnelWithError(nil)
    }
}
