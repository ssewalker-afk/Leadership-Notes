//
//  StoreManager.swift
//  Leadership Notes
//
//  Created by Sarah Walker on 1/15/26.
//


import StoreKit
import SwiftUI
import Combine

class StoreManager: NSObject, ObservableObject {
    @Published var isPremium = false
    @Published var products: [SKProduct] = []
    @Published var isLoading = false
    
    private let productID = "com.shawnwalker.leadershipnotes.premium"
    
    override init() {
        super.init()
        
        // DEVELOPMENT MODE: Automatically set premium to true
        #if DEBUG
        isPremium = true
        UserDefaults.standard.set(true, forKey: "isPremium")
        #else
        SKPaymentQueue.default().add(self)
        fetchProducts()
        checkSubscriptionStatus()
        #endif
    }
    
    func fetchProducts() {
        isLoading = true
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
        
        // Timeout after 10 seconds to prevent infinite loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isLoading {
                self.isLoading = false
                print("⚠️ Product fetch timed out - this is normal in development/simulator")
            }
        }
    }
    
    func purchase() {
        guard let product = products.first else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func checkSubscriptionStatus() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            self.isLoading = false
        }
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                UserDefaults.standard.set(true, forKey: "isPremium")
                DispatchQueue.main.async {
                    self.isPremium = true
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
