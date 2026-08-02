import Foundation
import StoreKit

@MainActor
final class SubscriptionService: ObservableObject {
    static let productIDs = ["com.boonker.pro.monthly", "com.boonker.pro.yearly"]
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium = false
    @Published var errorMessage: String?

    func load() async {
        do {
            products = try await Product.products(for: Self.productIDs).sorted { $0.price < $1.price }
            await refreshEntitlements()
        } catch {
            errorMessage = "Plans are temporarily unavailable."
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified = verification {
                isPremium = true
            }
        } catch {
            errorMessage = "Purchase could not be completed."
        }
    }

    func restore() async {
        await refreshEntitlements()
    }

    #if DEBUG
    func activateDemoPlan() {
        isPremium = true
        errorMessage = nil
    }
    #endif

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, Self.productIDs.contains(transaction.productID) {
                isPremium = true
            }
        }
    }
}
