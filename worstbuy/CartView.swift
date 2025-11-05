import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showingCheckout = false
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if cartManager.items.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("Shopping Cart")
            .toolbar {
                if !cartManager.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Clear Cart", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    cartManager.clearCart()
                }
            } message: {
                Text("Are you sure you want to remove all items from your cart?")
            }
            .sheet(isPresented: $showingCheckout) {
                CheckoutView()
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add some products to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            // Cart Items List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(cartManager.items) { item in
                        CartItemRow(item: item)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Cart Summary
            cartSummaryView
        }
    }
    
    private var cartSummaryView: some View {
        VStack(spacing: 16) {
            // Price Breakdown
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal (\(cartManager.itemCount) items)")
                        .font(.subheadline)
                    Spacer()
                    Text("$\(cartManager.totalPrice, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Shipping")
                        .font(.subheadline)
                    Spacer()
                    Text(cartManager.totalPrice > 50 ? "FREE" : "$9.99")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(cartManager.totalPrice > 50 ? .green : .primary)
                }
                
                if cartManager.totalPrice <= 50 {
                    HStack {
                        Text("Add $\(50 - cartManager.totalPrice, specifier: "%.2f") for free shipping")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(finalTotal, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            // Checkout Button
            Button {
                showingCheckout = true
            } label: {
                Text("Proceed to Checkout")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var finalTotal: Double {
        let shipping = cartManager.totalPrice > 50 ? 0 : 9.99
        let total = cartManager.totalPrice + shipping
        // Intentional bug: occasionally add random tax amount
        if Int.random(in: 1...15) == 1 {
            return total + Double.random(in: 5...25)
        }
        return total
    }
}

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager
    @State private var showingProductDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            Button {
                showingProductDetail = true
            } label: {
                Group {
                    Group {
                        if let uiImage = loadProductImage(item.product.imageURL) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Rectangle()
                                .fill(Color.white)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: item.product.category.systemImage)
                                            .font(.title2)
                                            .foregroundColor(Color(red: 0.0, green: 0.27, blue: 0.71))
                                        Text(item.product.brand)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .background(Color.white)
                .cornerRadius(8)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button {
                    showingProductDetail = true
                } label: {
                    Text(item.product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("$\(item.product.price, specifier: "%.2f") each")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !item.product.inStock {
                    Text("Out of stock")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Quantity and Price
            VStack(alignment: .trailing, spacing: 8) {
                Text("$\(item.totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Quantity Controls
                HStack(spacing: 8) {
                    Button {
                        if item.quantity > 1 {
                            cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                        }
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.title3)
                            .foregroundColor(item.quantity > 1 ? .red : .gray)
                    }
                    .disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(minWidth: 25)
                    
                    Button {
                        cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
                
                Button {
                    cartManager.removeFromCart(item)
                } label: {
                    Text("Remove")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingProductDetail) {
            ProductDetailView(product: item.product)
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
}