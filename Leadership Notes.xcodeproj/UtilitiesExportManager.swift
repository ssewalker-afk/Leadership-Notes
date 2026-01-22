//
//  ExportManager.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import Foundation
import UIKit
import PDFKit
import UniformTypeIdentifiers

@MainActor
class ExportManager {
    
    // MARK: - CSV Export
    
    static func exportToCSV(entries: [CoachingEntry]) -> URL? {
        var csvText = "Date,Employee,Title,Category,Content,Tags,Follow-up Date,Created Date\n"
        
        for entry in entries {
            let date = entry.date.formatted(date: .numeric, time: .shortened)
            let employee = entry.employee?.fullName ?? "N/A"
            let title = escapeCSVField(entry.title)
            let category = entry.category
            let content = escapeCSVField(entry.content)
            let tags = entry.tags?.joined(separator: "; ") ?? ""
            let followUp = entry.followUpDate?.formatted(date: .numeric, time: .omitted) ?? ""
            let created = entry.createdDate.formatted(date: .numeric, time: .shortened)
            
            csvText += "\(date),\(employee),\(title),\(category),\(content),\(tags),\(followUp),\(created)\n"
        }
        
        return saveToTemporaryFile(content: csvText, filename: "CoachingLog_\(timestamp()).csv")
    }
    
    // MARK: - PDF Export
    
    static func exportToPDF(entries: [CoachingEntry], employees: [Employee]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Coaching Log",
            kCGPDFContextAuthor: "Coaching Log App",
            kCGPDFContextTitle: "Coaching Log Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var yPosition: CGFloat = 60
            let margin: CGFloat = 40
            let usableWidth = pageWidth - (2 * margin)
            
            context.beginPage()
            
            // Title
            drawText(
                "Coaching Log Report",
                at: CGPoint(x: margin, y: yPosition),
                font: .boldSystemFont(ofSize: 24),
                color: .black,
                maxWidth: usableWidth
            )
            yPosition += 40
            
            // Metadata
            drawText(
                "Generated: \(Date().formatted(date: .long, time: .shortened))",
                at: CGPoint(x: margin, y: yPosition),
                font: .systemFont(ofSize: 12),
                color: .gray,
                maxWidth: usableWidth
            )
            yPosition += 20
            
            drawText(
                "Total Entries: \(entries.count) | Total Employees: \(employees.count)",
                at: CGPoint(x: margin, y: yPosition),
                font: .systemFont(ofSize: 12),
                color: .gray,
                maxWidth: usableWidth
            )
            yPosition += 40
            
            // Entries
            for entry in entries {
                // Check if we need a new page
                if yPosition > pageHeight - 150 {
                    context.beginPage()
                    yPosition = 60
                }
                
                // Entry Header
                drawText(
                    entry.title,
                    at: CGPoint(x: margin, y: yPosition),
                    font: .boldSystemFont(ofSize: 16),
                    color: .black,
                    maxWidth: usableWidth
                )
                yPosition += 25
                
                // Entry Metadata
                let metadataText = "\(entry.date.formatted(date: .abbreviated, time: .shortened)) | \(entry.employee?.fullName ?? "N/A") | \(entry.category)"
                drawText(
                    metadataText,
                    at: CGPoint(x: margin, y: yPosition),
                    font: .systemFont(ofSize: 11),
                    color: .darkGray,
                    maxWidth: usableWidth
                )
                yPosition += 20
                
                // Entry Content
                let contentHeight = drawText(
                    entry.content,
                    at: CGPoint(x: margin, y: yPosition),
                    font: .systemFont(ofSize: 12),
                    color: .black,
                    maxWidth: usableWidth,
                    maxLines: 10
                )
                yPosition += contentHeight + 10
                
                // Tags
                if let tags = entry.tags, !tags.isEmpty {
                    drawText(
                        "Tags: \(tags.joined(separator: ", "))",
                        at: CGPoint(x: margin, y: yPosition),
                        font: .italicSystemFont(ofSize: 10),
                        color: .gray,
                        maxWidth: usableWidth
                    )
                    yPosition += 15
                }
                
                // Separator
                drawLine(
                    from: CGPoint(x: margin, y: yPosition),
                    to: CGPoint(x: pageWidth - margin, y: yPosition),
                    color: .lightGray
                )
                yPosition += 30
            }
        }
        
        return saveToTemporaryFile(data: data, filename: "CoachingLog_\(timestamp()).pdf")
    }
    
    // MARK: - Helper Functions
    
    private static func escapeCSVField(_ field: String) -> String {
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            return "\"\(escaped)\""
        }
        return escaped
    }
    
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    private static func saveToTemporaryFile(content: String, filename: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    private static func saveToTemporaryFile(data: Data, filename: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    @discardableResult
    private static func drawText(
        _ text: String,
        at point: CGPoint,
        font: UIFont,
        color: UIColor,
        maxWidth: CGFloat,
        maxLines: Int? = nil
    ) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = maxLines != nil ? .byTruncatingTail : .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textRect = CGRect(x: point.x, y: point.y, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        attributedText.draw(in: textRect)
        
        let boundingRect = attributedText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return boundingRect.height
    }
    
    private static func drawLine(from: CGPoint, to: CGPoint, color: UIColor) {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        path.lineWidth = 0.5
        color.setStroke()
        path.stroke()
    }
}
