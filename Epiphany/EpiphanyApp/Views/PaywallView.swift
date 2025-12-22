//
//  PaywallView.swift
//  Epiphany
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle.bold())
                        
                        Text("Get unlimited access to all features")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "paintpalette.fill", title: "All Premium Themes", description: "6 exclusive themes")
                        FeatureRow(icon: "arrow.triangle.2.circlepath", title: "Frequent Widget Updates", description: "Higher refresh rate")
                        FeatureRow(icon: "bell.fill", title: "Unlimited Notifications", description: "Set multiple daily reminders")
                        FeatureRow(icon: "heart.fill", title: "Support Development", description: "Help us create more content")
                    }
                    .padding(.horizontal)
                    
                    // Product
                    if let product = subscriptionManager.products.first {
                        VStack(spacing: 12) {
                            Text(product.displayPrice)
                                .font(.title.bold())
                            Text("per month")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                purchase(product)
                            } label: {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Text("Subscribe Now")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .disabled(isPurchasing)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    // Terms
                    VStack(spacing: 8) {
                        Text("Auto-renewable subscription")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") { }
                            Button("Privacy Policy") { }
                            Button("Restore") {
                                Task {
                                    await subscriptionManager.restorePurchases()
                                }
                            }
                        }
                        .font(.caption)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func purchase(_ product: Product) {
        Task {
            isPurchasing = true
            do {
                _ = try await subscriptionManager.purchase(product)
                dismiss()
            } catch {
                print("Purchase failed: \(error)")
            }
            isPurchasing = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
