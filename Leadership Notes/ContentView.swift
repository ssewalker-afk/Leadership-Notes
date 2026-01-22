//
//  ContentView.swift
//  Leadership Notes
//
//  Created by Sarah Walker on 1/14/26.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var storeManager = StoreManager()
    
    var body: some View {
        ZStack {
            if storeManager.isPremium {
                // Show your app content (WebView)
                WebView(url: URL(string: "https://manager-coaching-log-146d9ada.base44.app")!)
            } else {
                // Show paywall
                PaywallView(storeManager: storeManager)
            }
        }
    }
}

// WebView to display your Base44 website
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#Preview {
    ContentView()
}

