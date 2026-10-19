//
//  SubscriptionManager.swift
//  Epiphany
//
//  StoreKit 2 subscription management
//

import Foundation
import StoreKit
import Combine
import WidgetKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    
    // Must match the product in App Store Connect and Configuration.storekit
    private let premiumProductID = "com.thefool.Epiphany.premium.monthly"
    
    private var updateListenerTask: Task<Void, Never>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Never> {
        return Task {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    print("Transaction verification failed")
                    continue
                }
                
                await self.updateSubscriptionStatus()
                await transaction.finish()
            }
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: [premiumProductID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw StoreError.failedVerification
            }
            
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    func updateSubscriptionStatus() async {
        var isSubscribed = false
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            // Only a verified, unrevoked, unexpired entitlement unlocks premium.
            if transaction.productID == premiumProductID,
               transaction.revocationDate == nil,
               (transaction.expirationDate ?? .distantFuture) > Date() {
                isSubscribed = true
            }
        }
        
        isPremium = isSubscribed
        
        // Save to App Group for widget access
        AppGroup.shared?.set(isSubscribed, forKey: AppGroup.Keys.isPremium)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }
}

enum StoreError: Error {
    case failedVerification
}
