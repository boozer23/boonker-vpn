import SwiftUI

struct Server: Identifiable, Hashable {
    let id: String
    let country: String
    let code: String
    let flag: String
    let cities: [City]
    let isFavorite: Bool

    var bestCity: City { cities.min { $0.ping < $1.ping }! }
}

struct City: Identifiable, Hashable {
    let id: String
    let name: String
    let node: String
    let ping: Int
    let load: Int
}

struct ContentView: View {
    private let servers = [
        Server(id: "us", country: "United States", code: "US", flag: "🇺🇸", cities: [City(id: "ny", name: "New York", node: "S1", ping: 24, load: 23), City(id: "chi", name: "Chicago", node: "S2", ping: 31, load: 34)], isFavorite: false),
        Server(id: "gb", country: "United Kingdom", code: "GB", flag: "🇬🇧", cities: [City(id: "lon", name: "London", node: "S1", ping: 28, load: 29), City(id: "man", name: "Manchester", node: "S2", ping: 35, load: 38)], isFavorite: true),
        Server(id: "de", country: "Germany", code: "DE", flag: "🇩🇪", cities: [City(id: "ber", name: "Berlin", node: "S1", ping: 28, load: 23), City(id: "mun", name: "Munich", node: "S2", ping: 32, load: 41), City(id: "fra", name: "Frankfurt", node: "S3", ping: 36, load: 67)], isFavorite: false),
        Server(id: "nl", country: "Netherlands", code: "NL", flag: "🇳🇱", cities: [City(id: "ams", name: "Amsterdam", node: "S1", ping: 34, load: 32), City(id: "rot", name: "Rotterdam", node: "S2", ping: 40, load: 44)], isFavorite: false),
        Server(id: "fr", country: "France", code: "FR", flag: "🇫🇷", cities: [City(id: "par", name: "Paris", node: "S1", ping: 37, load: 36), City(id: "lyo", name: "Lyon", node: "S2", ping: 42, load: 47)], isFavorite: false),
        Server(id: "jp", country: "Japan", code: "JP", flag: "🇯🇵", cities: [City(id: "tok", name: "Tokyo", node: "S1", ping: 57, load: 51), City(id: "osa", name: "Osaka", node: "S2", ping: 61, load: 59)], isFavorite: false)
    ]

    private let ink = Color(red: 0.10, green: 0.14, blue: 0.19)
    private let canvas = Color(red: 0.93, green: 0.95, blue: 0.98)
    private let blue = Color(red: 0.05, green: 0.43, blue: 0.95)
    private let green = Color(red: 0.05, green: 0.55, blue: 0.28)

    @State private var isConnected = false
    @State private var selectedCity = City(id: "mun", name: "Munich", node: "S2", ping: 32, load: 41)
    @State private var expandedServer: String?
    @State private var searchText = ""
    @State private var tab = "All"
    @State private var recent: [String] = []
    @State private var favorites: Set<String> = ["gb"]
    @State private var protection = ["Kill Switch": true, "DNS leak": true, "WebRTC": true, "Trackers": true]
    @State private var isAuthenticated = true
    @State private var showAccount = false
    @State private var bottomTab = "Home"

    private var visibleServers: [Server] {
        servers.filter { server in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty || server.country.localizedCaseInsensitiveContains(query) || server.cities.contains { $0.name.localizedCaseInsensitiveContains(query) }
            let matchesTab = tab == "All" || (tab == "Favorites" && favorites.contains(server.id)) || (tab == "Recent" && recent.contains(server.id))
            return matchesSearch && matchesTab
        }
    }

    var body: some View {
        Group {
            if !isAuthenticated {
                LoginView { withAnimation { isAuthenticated = true } }
                    .ignoresSafeArea()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            header
                            connectionCard
                            serverSection
                            metrics
                            protectionSection
                            premiumCard
                        }
                        .frame(maxWidth: 560)
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .padding(.bottom, 88)
                    }
                    .background(canvas.ignoresSafeArea())
                    .safeAreaInset(edge: .bottom, spacing: 0) { bottomNavigation }
                    .onChange(of: searchText) { _, value in
                        if !value.isEmpty { withAnimation { proxy.scrollTo("servers", anchor: .top) } }
                    }
                }
            }
        }
        .tint(blue)
        .sheet(isPresented: $showAccount) {
            AccountView {
                isAuthenticated = false
                showAccount = false
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                Text("boonker").font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(ink).lineLimit(1)
                Text("Your private internet bunker.").font(.caption).foregroundStyle(ink.opacity(0.62)).lineLimit(1).minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            headerButton("circle.lefthalf.filled", "Theme") { }
            headerButton("gearshape", "Settings") { showAccount = true }
            headerButton("diamond.fill", "Premium") { }
        }
        .padding(.horizontal, 4)
    }

    private func headerButton(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 16, weight: .semibold))
                Text(title).font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(title == "Premium" ? blue : ink.opacity(0.78))
            .frame(width: 46, height: 48)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(ink.opacity(0.12)))
        }
        .buttonStyle(.plain)
    }

    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                HStack(spacing: 9) {
                    Circle().fill(isConnected ? green : .red).frame(width: 12, height: 12)
                    Text(isConnected ? "Connected" : "Disconnected").font(.headline.weight(.semibold)).foregroundStyle(isConnected ? green : .red)
                }
                Spacer()
                Button { toggleConnection() } label: {
                    Image(systemName: "power").font(.title3.weight(.medium)).frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .background(Color.white, in: Circle())
                .overlay(Circle().stroke(isConnected ? green : blue, lineWidth: 2))
                .accessibilityLabel(isConnected ? "Disconnect" : "Connect")
            }
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current IP").font(.caption).foregroundStyle(ink.opacity(0.60))
                    Text(isConnected ? "45.67.89.123" : "Hidden").font(.system(size: 25, weight: .semibold, design: .monospaced)).lineLimit(1).minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider().frame(height: 46)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Protocol").font(.caption).foregroundStyle(ink.opacity(0.60))
                    HStack(spacing: 6) {
                        Text("WireGuard")
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        badge("UDP", color: green)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(ink.opacity(0.08)))
    }

    private var serverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text("Choose a server").font(.title2.bold()).foregroundStyle(ink)
            }
            HStack(spacing: 8) {
                TextField("Search country or city", text: $searchText).textFieldStyle(.roundedBorder)
                Button("Best ping →") { chooseBestPing() }.buttonStyle(.bordered)
            }
            Picker("Server filter", selection: $tab) {
                Text("All").tag("All")
                Text("Favorites").tag("Favorites")
                Text("Recent").tag("Recent")
            }
            .pickerStyle(.segmented)
            VStack(spacing: 0) {
                ForEach(visibleServers) { server in serverRow(server) }
                if visibleServers.isEmpty { Text(tab == "Favorites" ? "No favorite servers yet." : tab == "Recent" ? "No recent servers yet." : "No servers match your search.").font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical, 22) }
            }
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(ink.opacity(0.08)))
        .id("servers")
    }

    private func serverRow(_ server: Server) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(server.flag).font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(server.country).font(.headline).foregroundStyle(ink).lineLimit(1)
                    Text(server.cities.map { "\($0.name) / \($0.node)" }.joined(separator: " · ")).font(.caption2.monospaced()).foregroundStyle(ink.opacity(0.55)).lineLimit(1).minimumScaleFactor(0.7)
                }
                Spacer(minLength: 4)
                Text("\(server.bestCity.ping) ms").font(.caption.monospaced()).foregroundStyle(server.bestCity.ping > 35 ? .orange : green)
                Button { favorites.formSymmetricDifference([server.id]) } label: { Image(systemName: favorites.contains(server.id) ? "star.fill" : "star").foregroundStyle(favorites.contains(server.id) ? blue : .secondary) }.buttonStyle(.plain)
                Button { withAnimation(.easeInOut(duration: 0.2)) { expandedServer = expandedServer == server.id ? nil : server.id } } label: { Image(systemName: expandedServer == server.id ? "chevron.up" : "chevron.down").frame(width: 24, height: 34) }.buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture { choose(server.bestCity, in: server) }
            .padding(.vertical, 10)
            if expandedServer == server.id {
                ForEach(server.cities) { city in cityRow(city, server: server) }
            }
            Divider()
        }
    }

    private func cityRow(_ city: City, server: Server) -> some View {
        Button { choose(city, in: server) } label: {
            HStack {
                Text(city.name).font(.subheadline.weight(.medium)).foregroundStyle(ink)
                badge(city.node, color: ink.opacity(0.35))
                Spacer()
                Text("\(city.ping) ms").font(.caption.monospaced()).foregroundStyle(city.ping > 35 ? .orange : green)
                Image(systemName: selectedCity.id == city.id ? "largecircle.fill.circle" : "circle").foregroundStyle(selectedCity.id == city.id ? blue : .secondary)
            }
            .padding(.leading, 34)
            .padding(.vertical, 9)
            .background(selectedCity.id == city.id ? blue.opacity(0.07) : .clear)
        }
        .buttonStyle(.plain)
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            metric("Download", isConnected ? "112.4" : "0", "Mbps", .blue)
            metric("Upload", isConnected ? "18.7" : "0", "Mbps", .orange)
            metric("Ping", isConnected ? "\(selectedCity.ping)" : "--", "ms", green)
            metric("Data protected", isConnected ? "2.48" : "0", "GB", .blue)
        }
    }

    private func metric(_ label: String, _ value: String, _ unit: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(ink.opacity(0.60))
            HStack(alignment: .lastTextBaseline, spacing: 4) { Text(value).font(.title3.bold()).foregroundStyle(ink); Text(unit).font(.caption).foregroundStyle(ink.opacity(0.62)) }
            HStack(alignment: .bottom, spacing: 3) { ForEach(0..<12, id: \.self) { index in RoundedRectangle(cornerRadius: 2).fill(color.opacity(0.35 + Double(index % 3) * 0.15)).frame(height: CGFloat(4 + (index * 7) % 12)) } }
        }
        .frame(maxWidth: .infinity, minHeight: 105, alignment: .leading)
        .padding(13)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ink.opacity(0.08)))
    }

    private var protectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PROTECTION").font(.caption.monospaced()).foregroundStyle(ink.opacity(0.55))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                protectionCard("Kill Switch", "shield", "Kill Switch")
                protectionCard("DNS Leak Protection", "globe", "DNS leak")
                protectionCard("WebRTC Block", "network", "WebRTC")
                protectionCard("Ad & Tracker Block", "hand.raised", "Trackers")
            }
        }
    }

    private func protectionCard(_ title: String, _ icon: String, _ key: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.headline).foregroundStyle(ink.opacity(0.75))
            Text(title).font(.caption).foregroundStyle(ink).lineLimit(2).minimumScaleFactor(0.75)
            Spacer(minLength: 2)
            Toggle("", isOn: Binding(get: { protection[key] ?? false }, set: { protection[key] = $0 })).labelsHidden().tint(green).scaleEffect(0.75)
        }
        .padding(.horizontal, 11)
        .frame(minHeight: 58)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ink.opacity(0.08)))
    }

    private var premiumCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "diamond.fill").font(.title3).foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Boonker Premium").font(.headline).foregroundStyle(ink)
                Text("Unlock all locations and faster routes.").font(.caption).foregroundStyle(ink.opacity(0.60)).lineLimit(2)
            }
            Spacer()
            Button("Upgrade") {}.buttonStyle(.borderedProminent)
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(ink.opacity(0.08)))
    }

    private var bottomNavigation: some View {
        HStack {
            bottomTabButton("house", "Home")
            bottomTabButton("server.rack", "Servers")
            bottomTabButton("shield", "Protection")
            bottomTabButton("chart.bar.xaxis", "Stats")
            bottomTabButton("person.crop.circle", "Account")
        }
        .padding(.horizontal, 8)
        .padding(.top, 7)
        .padding(.bottom, 5)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider() }
    }

    private func bottomTabButton(_ icon: String, _ title: String) -> some View {
        Button {
            bottomTab = title
            if title == "Account" { showAccount = true }
            if title == "Servers" { withAnimation { expandedServer = nil } }
        } label: {
            VStack(spacing: 3) { Image(systemName: icon).font(.headline); Text(title).font(.caption2) }
                .foregroundStyle(bottomTab == title ? blue : ink.opacity(0.58))
                .frame(maxWidth: .infinity, minHeight: 42)
        }
        .buttonStyle(.plain)
    }

    private func badge(_ value: String, color: Color) -> some View {
        Text(value).font(.caption2.monospaced()).foregroundStyle(color).padding(.horizontal, 5).padding(.vertical, 3).overlay(RoundedRectangle(cornerRadius: 5).stroke(color, lineWidth: 1))
    }

    private func choose(_ city: City, in server: Server) { selectedCity = city; recent.removeAll { $0 == server.id }; recent.insert(server.id, at: 0); expandedServer = nil }
    private func chooseBestPing() { guard let server = servers.min(by: { $0.bestCity.ping < $1.bestCity.ping }) else { return }; choose(server.bestCity, in: server) }
    private func toggleConnection() { withAnimation(.easeInOut(duration: 0.25)) { isConnected.toggle() } }
}
