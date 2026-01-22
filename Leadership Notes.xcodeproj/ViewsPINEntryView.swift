//
//  PINEntryView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct PINEntryView: View {
    @EnvironmentObject var appState: AppState
    @State private var enteredPIN = ""
    @State private var showError = false
    
    private let pinLength = 4
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon/Logo
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                    }
                    
                    Text("Coaching Log")
                        .font(AppTheme.interFont(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("Enter your PIN to continue")
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                // PIN Dots
                HStack(spacing: 20) {
                    ForEach(0..<pinLength, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPIN.count ? AppTheme.accentPurple : AppTheme.backgroundSecondary)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.accentPurple, lineWidth: 2)
                            )
                    }
                }
                .padding(.vertical, 20)
                
                if showError {
                    Text("Incorrect PIN")
                        .font(AppTheme.interFont(size: 14, weight: .medium))
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Number Pad
                VStack(spacing: 16) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 16) {
                            ForEach(1...3, id: \.self) { col in
                                let number = row * 3 + col
                                PINButton(number: "\(number)") {
                                    addDigit(number)
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 16) {
                        PINButton(number: "", systemImage: "delete.left") {
                            removeDigit()
                        }
                        
                        PINButton(number: "0") {
                            addDigit(0)
                        }
                        
                        Color.clear
                            .frame(width: 80, height: 80)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
    }
    
    private func addDigit(_ digit: Int) {
        guard enteredPIN.count < pinLength else { return }
        
        enteredPIN += "\(digit)"
        showError = false
        
        if enteredPIN.count == pinLength {
            verifyPIN()
        }
    }
    
    private func removeDigit() {
        if !enteredPIN.isEmpty {
            enteredPIN.removeLast()
            showError = false
        }
    }
    
    private func verifyPIN() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if appState.verifyPIN(enteredPIN) {
                appState.unlock()
            } else {
                withAnimation {
                    showError = true
                }
                enteredPIN = ""
            }
        }
    }
}

struct PINButton: View {
    let number: String
    var systemImage: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppTheme.backgroundSecondary)
                    .frame(width: 80, height: 80)
                
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(AppTheme.textPrimary)
                } else if !number.isEmpty {
                    Text(number)
                        .font(AppTheme.interFont(size: 28, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
        .disabled(number.isEmpty && systemImage == nil)
    }
}

#Preview {
    PINEntryView()
        .environmentObject(AppState())
}
