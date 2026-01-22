//
//  IconGenerator.swift
//  CoachingLog
//
//  Created on 1/20/26.
//
//  INSTRUCTIONS:
//  1. Create a new macOS Command Line Tool project in Xcode
//  2. Replace main.swift with this code
//  3. Run the project (⌘R)
//  4. Find the generated icon on your Desktop
//  5. Drag the icon into Assets.xcassets → AppIcon
//

import Foundation
import AppKit

func generateAppIcon() {
    let size = CGSize(width: 1024, height: 1024)
    let image = NSImage(size: size)
    
    image.lockFocus()
    
    // Background gradient (dark blue to purple)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.043, green: 0.071, blue: 0.125, alpha: 1.0), // #0b1220
        NSColor(red: 0.486, green: 0.227, blue: 0.929, alpha: 1.0)  // #7C3AED
    ])!
    
    // Draw circular gradient background
    let path = NSBezierPath(ovalIn: NSRect(origin: .zero, size: size))
    gradient.draw(in: path, angle: 135) // Diagonal gradient
    
    // Add SF Symbol icon
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: 500, weight: .medium)
    let symbol = NSImage(systemSymbolName: "list.clipboard.fill", accessibilityDescription: nil)
        ?.withSymbolConfiguration(symbolConfig)
    
    if let symbol = symbol {
        // Center the symbol
        let symbolSize: CGFloat = 600
        let symbolRect = NSRect(
            x: (size.width - symbolSize) / 2,
            y: (size.height - symbolSize) / 2,
            width: symbolSize,
            height: symbolSize
        )
        
        // Draw white symbol with slight transparency
        NSColor.white.withAlphaComponent(0.95).set()
        symbol.draw(in: symbolRect)
    }
    
    image.unlockFocus()
    
    // Save to desktop
    if let tiffData = image.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let fileURL = desktopURL.appendingPathComponent("CoachingLogAppIcon.png")
        
        try? pngData.write(to: fileURL)
        print("✅ App icon saved to: \(fileURL.path)")
        print("📱 Drag this file into Assets.xcassets → AppIcon in Xcode")
    }
}

// Run the generator
generateAppIcon()
