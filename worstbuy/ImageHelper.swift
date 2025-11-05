import UIKit
import SwiftUI

extension UIImage {
    static func createPlaceholder(text: String, size: CGSize = CGSize(width: 300, height: 300), backgroundColor: UIColor = .systemGray6, textColor: UIColor = .systemGray) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let stringRect = CGRect(x: 20, y: size.height/2 - 20, width: size.width - 40, height: 40)
            attributedString.draw(in: stringRect)
        }
    }
}

// Helper to get better product names for image loading
func getImageNameForProduct(id: String) -> String? {
    let imageMap: [String: String] = [
        "laptop-1": "macbook-pro-16",
        "laptop-2": "dell-xps-13", 
        "laptop-3": "thinkpad-x1-carbon",
        "laptop-4": "hp-spectre-x360",
        "laptop-5": "asus-rog-zephyrus",
        "tv-1": "samsung-65-qled-4k"
    ]
    return imageMap[id]
}