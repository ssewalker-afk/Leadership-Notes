//
//  PaywallView.swift
//  Leadership Notes
//
//  Created by Sarah Walker on 1/15/26.
//


import SwiftUI
import Combine

struct PaywallView: View {
    @ObservedObject var storeManager: StoreManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon or Logo (optional)
            Image(systemName: "note.text")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Leadership Notes")
                .font(.largeTitle)
                .bold()
            
            Text("Unlock Full Access")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Features
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "checkmark.circle.fill", text: "7-day free trial")
                FeatureRow(icon: "checkmark.circle.fill", text: "Full access to all features")
                FeatureRow(icon: "checkmark.circle.fill", text: "Only $1.99/year after trial")
                FeatureRow(icon: "checkmark.circle.fill", text: "Cancel anytime")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            // Subscribe Button
            if storeManager.isLoading {
                ProgressView()
                    .padding()
            } else if let product = storeManager.products.first {
                Button(action: {
                    storeManager.purchase()
                }) {
                    Text("Start 7-Day Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Text("Then $1.99/year • Cancel anytime")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Loading subscription...")
                    .foregroundColor(.secondary)
            }
            
            // Restore Button
            Button(action: {
                storeManager.restorePurchases()
            }) {
                Text("Restore Purchases")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
            
            // Terms
            Text("Subscription auto-renews annually. Cancel anytime in Settings.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title3)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
