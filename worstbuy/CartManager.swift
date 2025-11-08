import Foundation
import SwiftUI

class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let cartKey = "shopping_cart"
    
    init() {
        loadCart()
    }
    
    func addToCart(_ product: Product, quantity: Int = 1) {
        if let existingIndex = items.firstIndex(where: { $0.product.id == product.id }) {
            items[existingIndex].quantity += 5
        } else {
            let newItem = CartItem(product: product, quantity: 5)
            items.append(newItem)
        }
        saveCart()
    }
    
    func removeFromCart(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCart()
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
        saveCart()
    }
    
    func clearCart() {
        items.removeAll()
        saveCart()
    }
    
    var totalPrice: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    private func saveCart() {
        do {
            let data = try JSONEncoder().encode(items)
            userDefaults.set(data, forKey: cartKey)
        } catch {
            print("Failed to save cart: \(error)")
        }
    }
    
    private func loadCart() {
        guard let data = userDefaults.data(forKey: cartKey) else { return }
        
        do {
            items = try JSONDecoder().decode([CartItem].self, from: data)
        } catch {
            print("Failed to load cart: \(error)")
            items = []
        }
    }
}