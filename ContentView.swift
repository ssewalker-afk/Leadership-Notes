import SwiftUI

import SwiftUI

enum MainView {
    case entry, history, reports, people, settings
}

struct ContentView: View {
    @StateObject private var store = AppStore()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var currentView: MainView = .entry
    @State private var showMenu = false
    @State private var toastMessage: String?
    @State private var showPaywall = false
    
    var theme: ThemeColors {
        ThemeColors.colors(for: store.theme)
    }
    
    var body: some View {
        ZStack {
            theme.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Content
                ScrollView {
                    VStack(spacing: 14) {
                        // Reminders
                        if currentView == .entry {
                            remindersView
                        }
                        
                        // Main content
                        contentView
                            .padding(.horizontal, 14)
                            .padding(.bottom, 80)
                    }
                }
                
                Spacer()
                
                // Bottom navigation
                bottomNav
            }
            
            // Toast
            if let message = toastMessage {
                VStack {
                    Text(message)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .background(theme.bgCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.borderAccent, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                    Spacer()
                }
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .preferredColorScheme(store.theme == .light ? .light : .dark)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
        .onAppear {
            // Show paywall if not subscribed
            if !subscriptionManager.isSubscribed {
                showPaywall = true
            }
        }
        .onChange(of: subscriptionManager.subscriptionStatus) { oldValue, newValue in
            // Dismiss paywall when subscription becomes active
            if subscriptionManager.isSubscribed {
                showPaywall = false
            } else if newValue == .notSubscribed || newValue == .expired {
                showPaywall = true
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("📋 Leadership Notes")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(theme.accent)
                
                Text("PRIVATE • ON-DEVICE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(theme.textMuted)
                    .tracking(1)
            }
            
            Spacer()
            
            Button(action: { showMenu.toggle() }) {
                Text("🍔")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(theme.accentGlow)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.borderAccent, lineWidth: 1)
                    )
            }
            .popover(isPresented: $showMenu) {
                menuView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.bgNav)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(theme.border),
            alignment: .bottom
        )
    }
    
    // MARK: - Menu
    private var menuView: some View {
        VStack(spacing: 0) {
            menuItem(icon: "⚡", label: "Entry", view: .entry)
            menuItem(icon: "📋", label: "History", view: .history)
            menuItem(icon: "📊", label: "Reports", view: .reports)
            menuItem(icon: "👥", label: "People", view: .people)
            menuItem(icon: "⚙️", label: "Settings", view: .settings)
        }
        .frame(width: 180)
        .background(theme.bgCard)
        .presentationCompactAdaptation(.popover)
    }
    
    private func menuItem(icon: String, label: String, view: MainView) -> some View {
        Button(action: {
            currentView = view
            showMenu = false
        }) {
            HStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 14, weight: currentView == view ? .heavy : .medium))
                Spacer()
            }
            .foregroundColor(currentView == view ? theme.accent : theme.textSoft)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(currentView == view ? theme.accentGlow : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Reminders
    @ViewBuilder
    private var remindersView: some View {
        let reminders = store.reminders()
        if !reminders.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("🔔 \(reminders.count) REMINDER\(reminders.count > 1 ? "S" : "")")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(theme.warn)
                
                ForEach(reminders.prefix(4)) { reminder in
                    Text("\(reminder.isFollowup ? "🎯" : "📅") **\(reminder.person)** — \(reminder.label) (\(reminder.days == 0 ? "Today!" : "\(reminder.days)d"))")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textSoft)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.warnBg)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.warn.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 14)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Content Views
    @ViewBuilder
    private var contentView: some View {
        switch currentView {
        case .entry:
            EntryView(store: store, theme: theme, showToast: showToast)
        case .history:
            HistoryView(store: store, theme: theme, showToast: showToast, navigateToEntry: { navigateToEntry($0) })
        case .reports:
            ReportsView(store: store, theme: theme, showToast: showToast)
        case .people:
            PeopleView(store: store, theme: theme, showToast: showToast)
        case .settings:
            SettingsView(store: store, theme: theme, showToast: showToast, subscriptionManager: subscriptionManager)
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNav: some View {
        HStack {
            navButton(icon: "⚡", label: "Entry", view: .entry)
            navButton(icon: "📋", label: "History", view: .history)
            navButton(icon: "📊", label: "Reports", view: .reports)
            navButton(icon: "👥", label: "People", view: .people)
        }
        .padding(.vertical, 5)
        .padding(.bottom, 8)
        .background(theme.bgNav)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(theme.border),
            alignment: .top
        )
    }
    
    private func navButton(icon: String, label: String, view: MainView) -> some View {
        Button(action: { currentView = view }) {
            VStack(spacing: 1) {
                Text(icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.system(size: 9, weight: .heavy))
            }
            .foregroundColor(currentView == view ? theme.accent : theme.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            toastMessage = nil
        }
    }
    
    private func navigateToEntry(_ entry: Entry) {
        currentView = .entry
    }
}

#Preview {
    ContentView()
}
