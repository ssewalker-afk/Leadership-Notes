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
                        
                        // Divider
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                        
                        // MARK: - 💰 PRICING SECTION (Apple-Compliant)
                        VStack(spacing: 20) {
                            // Headline
                            Text("Leadership Notes Pro")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                            
                            // MAIN PRICE - Largest text on screen
                            Text("\(subscriptionManager.displayPrice) / month")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                            
                            // Secondary - Free trial info (smaller)
                            Text("Includes 7-day free trial")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.85))
                            
                            // Supporting line (smallest)
                            Text("Auto-renews monthly. Cancel anytime.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.bottom, 4)
                            
                            // Subscribe Button - Changed to "Continue"
                            Button(action: { purchaseSubscription() }) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(Color(hex: "2d6a4f"))
                                    } else {
                                        Text("Continue")
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
                            
                            // MARK: - Footer (Apple-Safe Legal Language)
                            VStack(spacing: 12) {
                                // Apple's exact recommended wording
                                VStack(spacing: 6) {
                                    Text("Payment will be charged to your Apple ID at confirmation of purchase.")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Manage or cancel subscriptions in your Apple ID settings.")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                }
                                
                                // Links
                                HStack(spacing: 8) {
                                    Link("Privacy Policy", destination: URL(string: "https://ssewalker-afk.github.io/Leadership-Notes/privacy-policy.html")!)
                                    Text("•")
                                    Link("Terms of Use", destination: URL(string: "https://ssewalker-afk.github.io/Leadership-Notes/terms-of-service.html")!)
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 8)
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
