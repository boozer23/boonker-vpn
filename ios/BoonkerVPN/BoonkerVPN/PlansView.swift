import StoreKit
import SwiftUI

struct PlansView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptions = SubscriptionService()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Keep your whole network open.").font(.title2.bold())
                Text("Premium adds every location, faster routes and advanced protection.").foregroundStyle(.secondary)
                if subscriptions.products.isEmpty {
                    #if DEBUG
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Local demo mode", systemImage: "wrench.and.screwdriver")
                            .font(.headline)
                        Text("App Store products are not configured yet. You can complete the full purchase flow locally.")
                            .font(.subheadline).foregroundStyle(.secondary)
                        demoPlan(title: "Boonker Pro Monthly", price: "$4.99 / month")
                        demoPlan(title: "Boonker Pro Yearly", price: "$39.99 / year")
                    }
                    #else
                    ProgressView("Loading plans...").frame(maxWidth: .infinity, minHeight: 120)
                    #endif
                } else {
                    ForEach(subscriptions.products) { product in
                        Button { Task { await subscriptions.purchase(product) } } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) { Text(product.displayName).font(.headline); Text(product.description).font(.caption).foregroundStyle(.secondary) }
                                Spacer(); Text(product.displayPrice).font(.headline)
                            }.padding(16).background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }.buttonStyle(.plain)
                    }
                }
                if let errorMessage = subscriptions.errorMessage { Text(errorMessage).font(.footnote).foregroundStyle(.red) }
                Button("Restore purchases") { Task { await subscriptions.restore() } }.buttonStyle(.bordered)
                Spacer()
            }.padding(20)
            .navigationTitle("Boonker Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .task { await subscriptions.load() }
    }

    #if DEBUG
    private func demoPlan(title: String, price: String) -> some View {
        Button {
            subscriptions.activateDemoPlan()
            dismiss()
        } label: {
            HStack { VStack(alignment: .leading, spacing: 4) { Text(title).font(.headline); Text("Unlock every location and advanced protection").font(.caption).foregroundStyle(.secondary) }; Spacer(); Text(price).font(.subheadline.weight(.semibold)) }
                .padding(16)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }.buttonStyle(.plain)
    }
    #endif
}
