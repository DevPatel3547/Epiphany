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
                        FeatureRow(
                            icon: "list.bullet.rectangle",
                            title: "Browse by Category",
                            description: "Explore thoughts by genre"
                        )
                        FeatureRow(
                            icon: "paintpalette.fill",
                            title: "7 Premium Themes",
                            description: "Beautiful exclusive colors"
                        )
                        FeatureRow(
                            icon: "bell.badge.fill",
                            title: "Unlimited Notifications",
                            description: "Set as many reminders as you want"
                        )
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Faster Widget Updates",
                            description: "Refresh every hour vs every 4 hours"
                        )
                        FeatureRow(
                            icon: "sparkles",
                            title: "Early Access",
                            description: "Get new features first"
                        )
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
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .disabled(isPurchasing)
                            
                            Text("7-day free trial, then \(product.displayPrice)/month")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Text("Cancel anytime. Auto-renews monthly.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func purchase(_ product: Product) {
        isPurchasing = true
        
        Task {
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
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(SubscriptionManager.shared)
}
