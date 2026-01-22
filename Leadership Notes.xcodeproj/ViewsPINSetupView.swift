//
//  PINSetupView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct PINSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var enteredPIN = ""
    @State private var confirmPIN = ""
    @State private var isConfirming = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let pinLength = 4
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.primaryGradient)
                        
                        Text(isConfirming ? "Confirm PIN" : "Set PIN")
                            .font(AppTheme.interFont(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text(isConfirming ? "Enter your PIN again" : "Enter a 4-digit PIN")
                            .font(AppTheme.interFont(size: 16))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    // PIN Dots
                    HStack(spacing: 20) {
                        ForEach(0..<pinLength, id: \.self) { index in
                            let currentPIN = isConfirming ? confirmPIN : enteredPIN
                            Circle()
                                .fill(index < currentPIN.count ? AppTheme.accentPurple : AppTheme.backgroundSecondary)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.accentPurple, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.vertical, 20)
                    
                    if showError {
                        Text(errorMessage)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
    
    private func addDigit(_ digit: Int) {
        if isConfirming {
            guard confirmPIN.count < pinLength else { return }
            confirmPIN += "\(digit)"
            showError = false
            
            if confirmPIN.count == pinLength {
                verifyAndSavePIN()
            }
        } else {
            guard enteredPIN.count < pinLength else { return }
            enteredPIN += "\(digit)"
            showError = false
            
            if enteredPIN.count == pinLength {
                isConfirming = true
            }
        }
    }
    
    private func removeDigit() {
        if isConfirming {
            if !confirmPIN.isEmpty {
                confirmPIN.removeLast()
                showError = false
            }
        } else {
            if !enteredPIN.isEmpty {
                enteredPIN.removeLast()
                showError = false
            }
        }
    }
    
    private func verifyAndSavePIN() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if enteredPIN == confirmPIN {
                appState.setPIN(enteredPIN)
                dismiss()
            } else {
                withAnimation {
                    showError = true
                    errorMessage = "PINs don't match"
                }
                confirmPIN = ""
                enteredPIN = ""
                isConfirming = false
            }
        }
    }
}

#Preview {
    PINSetupView()
        .environmentObject(AppState())
}
