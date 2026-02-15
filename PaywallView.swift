import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    let theme: ThemeColors = ThemeColors.colors(for: .light)
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "2d6a4f"),
                    Color(hex: "40916c"),
                    Color(hex: "52b788")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button (only show if already subscribed)
                if subscriptionManager.isSubscribed {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Icon and Title
                        VStack(spacing: 12) {
                            Text("📋")
                                .font(.system(size: 80))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text("Leadership Notes")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.white)
                            
                            Text("Professional coaching documentation")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Features
                        VStack(spacing: 16) {
                            FeatureRow(
                                icon: "⚡",
                                title: "Quick Entry",
                                description: "Log incidents in seconds"
                            )
                            
                            FeatureRow(
                                icon: "📋",
                                title: "Complete History",
                                description: "Search and filter all entries"
                            )
                            
                            FeatureRow(
                                icon: "📊",
                                title: "Professional Reports",
                                description: "Generate reports instantly"
                            )
                            
                            FeatureRow(
                                icon: "🔒",
                                title: "100% Private",
                                description: "All data stays on your device"
                            )
                            
                            FeatureRow(
                                icon: "👥",
                                title: "Team Management",
                                description: "Track multiple teams and dates"
                            )
                            
                            FeatureRow(
                                icon: "💾",
                                title: "Backup & Export",
                                description: "Full control of your data"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Pricing Card
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("Start Your Free Trial")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("7 days free, then \(subscriptionManager.displayPrice)/month")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("Cancel anytime")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 20)
                            
                            // Subscribe Button
                            Button(action: { purchaseSubscription() }) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Start Free Trial")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                }
                                .foregroundColor(Color(hex: "2d6a4f"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                            .disabled(isPurchasing || subscriptionManager.monthlyProduct == nil)
                            .padding(.horizontal, 20)
                            
                            // Restore Button
                            Button(action: { restorePurchases() }) {
                                HStack {
                                    if isRestoring {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Restore Purchases")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.vertical, 12)
                            }
                            .disabled(isRestoring)
                            
                            // Fine print
                            VStack(spacing: 8) {
                                Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                
                                HStack(spacing: 16) {
                                    Link("Privacy Policy", destination: URL(string: "https://ssewalker-afk.github.io/Leadership-Notes/privacy-policy.html")!)
                                    Text("•")
                                    Link("Terms of Service", destination: URL(string: "https://ssewalker-afk.github.io/Leadership-Notes/terms-of-service.html")!)
                                }
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Actions
    private func purchaseSubscription() {
        isPurchasing = true
        
        Task {
            do {
                try await subscriptionManager.purchase()
                isPurchasing = false
                // Dismiss on success
                if subscriptionManager.isSubscribed {
                    dismiss()
                }
            } catch {
                isPurchasing = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func restorePurchases() {
        isRestoring = true
        
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                isRestoring = false
                
                if subscriptionManager.isSubscribed {
                    dismiss()
                } else {
                    errorMessage = "No previous purchases found."
                    showError = true
                }
            } catch {
                isRestoring = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 32))
                .frame(width: 50, height: 50)
                .background(.white.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    PaywallView(subscriptionManager: SubscriptionManager())
}
