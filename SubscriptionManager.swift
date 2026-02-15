import SwiftUI
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .unknown
    @Published private(set) var products: [Product] = []
    
    private var updateListenerTask: Task<Void, Never>?
    
    // Your product ID from App Store Connect
    // Format: com.yourcompany.leadershipnotes.monthly
    private let productID = "Leadership_Notes_Monthly"
    
    enum SubscriptionStatus {
        case unknown
        case subscribed
        case notSubscribed
        case inFreeTrial
        case expired
    }
    
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        do {
            let loadedProducts = try await Product.products(for: [productID])
            self.products = loadedProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    func purchase() async throws {
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Verify the transaction
            let transaction = try checkVerified(verification)
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            // Finish the transaction
            await transaction.finish()
            
        case .userCancelled:
            throw PurchaseError.userCancelled
            
        case .pending:
            throw PurchaseError.pending
            
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        // In StoreKit 2, just update the subscription status
        // It will check all current entitlements automatically
        await updateSubscriptionStatus()
    }
    
    // MARK: - Check Subscription Status
    func updateSubscriptionStatus() async {
        var status: SubscriptionStatus = .notSubscribed
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if the product ID matches
                if transaction.productID == productID {
                    // Check if subscription is active
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            // Check if in trial period
                            if transaction.offerType == .introductory {
                                status = .inFreeTrial
                            } else {
                                status = .subscribed
                            }
                        } else {
                            status = .expired
                        }
                    } else {
                        status = .subscribed
                    }
                }
                
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        self.subscriptionStatus = status
    }
    
    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerifiedNonisolated(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // Nonisolated version for use in detached tasks
    private nonisolated func checkVerifiedNonisolated<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helper Properties
    var isSubscribed: Bool {
        subscriptionStatus == .subscribed || subscriptionStatus == .inFreeTrial
    }
    
    var monthlyProduct: Product? {
        products.first
    }
    
    var displayPrice: String {
        monthlyProduct?.displayPrice ?? "$0.99"
    }
}

// MARK: - Purchase Errors
enum PurchaseError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case verificationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found. Please try again."
        case .userCancelled:
            return "Purchase cancelled."
        case .pending:
            return "Purchase is pending. Please check back later."
        case .verificationFailed:
            return "Purchase verification failed."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
