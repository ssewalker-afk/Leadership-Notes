import SwiftUI

import SwiftUI

enum MainView {
    case entry, history, reports, team, settings
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
                            .padding(.bottom, 100) // Extra padding for floating tab bar
                    }
                }
                
                Spacer()
            }
            
            // Floating Bottom Navigation
            VStack {
                Spacer()
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
            // MARK: - Development Bypass
            // TODO: Remove before App Store submission!
            #if DEBUG
            // Uncomment the line below to bypass paywall during development
            // showPaywall = false
            // return
            #endif
            
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
                Text("Leadership Notes")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.text)
                
                Text("PRIVATE • ON-DEVICE")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(theme.textMuted)
                    .tracking(0.5)
            }
            
            Spacer()
            
            Button(action: { showMenu.toggle() }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.accent)
                    .frame(width: 36, height: 36)
                    .background(theme.accentGlow)
                    .cornerRadius(8)
            }
            .popover(isPresented: $showMenu) {
                menuView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.bgNav.opacity(0.95))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(theme.border.opacity(0.5)),
            alignment: .bottom
        )
    }
    
    // MARK: - Menu
    private var menuView: some View {
        VStack(spacing: 0) {
            menuItem(icon: "bolt.fill", label: "Entry", view: .entry)
            menuItem(icon: "list.bullet", label: "History", view: .history)
            menuItem(icon: "chart.bar.fill", label: "Reports", view: .reports)
            menuItem(icon: "person.2.fill", label: "Team", view: .team)
            menuItem(icon: "gearshape.fill", label: "Settings", view: .settings)
        }
        .frame(width: 200)
        .background(theme.bgCard)
        .presentationCompactAdaptation(.popover)
    }
    
    private func menuItem(icon: String, label: String, view: MainView) -> some View {
        Button(action: {
            currentView = view
            showMenu = false
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(currentView == view ? theme.accent : theme.textSoft)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 15, weight: currentView == view ? .semibold : .regular))
                Spacer()
                if currentView == view {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.accent)
                }
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
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.warn)
                    Text("\(reminders.count) REMINDER\(reminders.count > 1 ? "S" : "")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.warn)
                }
                
                ForEach(reminders.prefix(4)) { reminder in
                    HStack(spacing: 8) {
                        Image(systemName: reminder.isFollowup ? "target" : "calendar")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.textSoft)
                            .frame(width: 16)
                        Text("**\(reminder.person)** — \(reminder.label)")
                            .font(.system(size: 13))
                            .foregroundColor(theme.textSoft)
                        Spacer()
                        Text(reminder.days == 0 ? "Today" : "\(reminder.days)d")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.warn)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(theme.warn.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.warnBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.warn.opacity(0.2), lineWidth: 1)
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
        case .team:
            PeopleView(store: store, theme: theme, showToast: showToast)
        case .settings:
            SettingsView(store: store, theme: theme, showToast: showToast, subscriptionManager: subscriptionManager)
        }
    }
    
    // MARK: - Bottom Navigation (Floating with Liquid Glass)
    private var bottomNav: some View {
        HStack(spacing: 4) {
            navButton(icon: "bolt.fill", label: "Entry", view: .entry)
            navButton(icon: "list.bullet", label: "History", view: .history)
            navButton(icon: "chart.bar.fill", label: "Reports", view: .reports)
            navButton(icon: "person.2.fill", label: "Team", view: .team)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .glassEffect(.regular.interactive(), in: .capsule)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
    
    private func navButton(icon: String, label: String, view: MainView) -> some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentView = view
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: currentView == view ? .semibold : .regular))
                    .symbolEffect(.bounce, value: currentView == view)
                Text(label)
                    .font(.system(size: 10, weight: currentView == view ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(currentView == view ? theme.accent : theme.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 2)
            .background(
                currentView == view ? 
                    theme.accentGlow.opacity(0.6) : Color.clear
            )
            .cornerRadius(12)
            .contentShape(Rectangle())
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
