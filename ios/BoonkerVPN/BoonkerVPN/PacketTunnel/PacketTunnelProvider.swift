import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String: NSObject]?) async throws {
        guard let configuration = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration,
              let address = configuration["address"] as? String,
              let dns = configuration["dns"] as? String,
              configuration["privateKey"] as? String != nil,
              configuration["serverPublicKey"] as? String != nil,
              configuration["server"] as? String != nil else {
            throw NSError(domain: "BoonkerVPN", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing tunnel configuration"])
        }

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: [address], subnetMasks: ["255.255.255.255"])
        settings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        settings.dnsSettings = NEDNSSettings(servers: [dns])
        settings.mtu = 1280
        try await setTunnelNetworkSettings(settings)

        // WireGuard userspace engine will be attached here next.
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        cancelTunnelWithError(nil)
    }
}
