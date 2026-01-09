//
//  WelcomeView.swift
//  Epiphany
//
//  First launch onboarding
//

import SwiftUI
import StoreKit

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Welcome to Epiphany")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Daily shower thoughts for inspiration")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 40)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "list.bullet", title: "Browse by Category", description: "Filter thoughts by genre")
                        FeatureRow(icon: "paintpalette.fill", title: "7 Premium Themes", description: "Beautiful exclusive colors")
                        FeatureRow(icon: "bell.fill", title: "Unlimited Notifications", description: "Set as many reminders as you want")
                        FeatureRow(icon: "arrow.triangle.2.circlepath", title: "Faster Widget Updates", description: "Refresh every hour")
                    }
                    .padding(.horizontal)
                    
                    // Product or Loading
                    if subscriptionManager.products.isEmpty {
                        // Loading state
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                            
                            Text("Loading subscription options...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    } else if let product = subscriptionManager.products.first {
                        VStack(spacing: 12) {
                            Text(product.displayPrice)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            Text("per month")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button {
                                purchase(product)
                            } label: {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Text("Start 7-Day Free Trial")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .disabled(isPurchasing)
                            
                            Text("Then \(product.displayPrice)/month. Cancel anytime.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    // Continue without premium
                    Button {
                        markOnboardingComplete()
                        dismiss()
                    } label: {
                        Text("Continue with Free Version")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .underline()
                    }
                    .padding(.top, 8)
                    
                    // Terms
                    VStack(spacing: 8) {
                        Text("Auto-renewable subscription")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                        
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 16)
                    
                    // DEBUG button
                    #if DEBUG
                    Button {
                        AppGroup.shared?.set(true, forKey: AppGroup.Keys.isPremium)
                        subscriptionManager.isPremium = true
                        markOnboardingComplete()
                        dismiss()
                    } label: {
                        Text("🔓 Enable Premium (DEBUG)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 20)
                    #endif
                    
                    Spacer().frame(height: 40)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        markOnboardingComplete()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear {
            Task {
                await subscriptionManager.loadProducts()
            }
        }
    }
    
    private func purchase(_ product: Product) {
        isPurchasing = true
        
        Task {
            do {
                _ = try await subscriptionManager.purchase(product)
                markOnboardingComplete()
                dismiss()
            } catch {
                print("Purchase failed: \(error)")
            }
            isPurchasing = false
        }
    }
    
    private func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}

// NOTE: FeatureRow is already defined in PaywallView.swift
// Don't redefine it here - just use it

#Preview {
    WelcomeView()
        .environmentObject(SubscriptionManager.shared)
}
