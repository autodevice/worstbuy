import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode
    @State private var shippingAddress = ShippingAddress()
    @State private var selectedPaymentMethod: PaymentMethod = .creditCard
    @State private var showingOrderConfirmation = false
    @State private var isProcessingOrder = false
    @State private var orderNumber = ""
    @State private var currentStep = 1
    
    var finalTotal: Double {
        let shipping = cartManager.totalPrice > 50 ? 0 : 9.99
        return cartManager.totalPrice + shipping
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicatorView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        if currentStep == 1 {
                            shippingAddressSection
                        } else if currentStep == 2 {
                            paymentMethodSection
                        } else {
                            orderSummarySection
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Bottom Actions
                bottomActionsView
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingOrderConfirmation) {
            OrderConfirmationView(orderNumber: orderNumber) {
                cartManager.clearCart()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var progressIndicatorView: some View {
        HStack {
            ForEach(1...3, id: \.self) { step in
                HStack {
                    Circle()
                        .fill(step <= currentStep ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("\(step)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(step <= currentStep ? .white : .gray)
                        )
                    
                    if step < 3 {
                        Rectangle()
                            .fill(step < currentStep ? Color.red : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var shippingAddressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shipping Address")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Full Name", text: $shippingAddress.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Street Address", text: $shippingAddress.street)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack(spacing: 12) {
                    TextField("City", text: $shippingAddress.city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("State", text: $shippingAddress.state)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 80)
                }
                
                TextField("ZIP Code", text: $shippingAddress.zipCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            // Quick Address Options
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Button("Home") {
                        fillDemoAddress(type: "home")
                    }
                    .buttonStyle(QuickFillButtonStyle())
                    
                    Button("Work") {
                        fillDemoAddress(type: "work")
                    }
                    .buttonStyle(QuickFillButtonStyle())
                    
                    Button("Demo") {
                        fillDemoAddress(type: "demo")
                    }
                    .buttonStyle(QuickFillButtonStyle())
                }
            }
        }
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    HStack {
                        Image(systemName: getPaymentIcon(for: method))
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text(method.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if selectedPaymentMethod == method {
                            Image(systemName: "checkmark")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedPaymentMethod = method
                    }
                }
            }
            
            if selectedPaymentMethod == .creditCard || selectedPaymentMethod == .debitCard {
                VStack(spacing: 12) {
                    TextField("Card Number", text: .constant("**** **** **** 1234"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                    
                    HStack(spacing: 12) {
                        TextField("MM/YY", text: .constant("12/26"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                        
                        TextField("CVV", text: .constant("123"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                    }
                    
                    Text("Payment information is simulated for demo purposes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.top)
            }
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            // Items
            VStack(spacing: 8) {
                ForEach(cartManager.items) { item in
                    HStack {
                        Text("\(item.quantity)x")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        
                        Text(item.product.name)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("$\(item.totalPrice, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Shipping Address
            VStack(alignment: .leading, spacing: 4) {
                Text("Shipping to:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(shippingAddress.name)
                    .font(.subheadline)
                Text(shippingAddress.street)
                    .font(.subheadline)
                Text("\(shippingAddress.city), \(shippingAddress.state) \(shippingAddress.zipCode)")
                    .font(.subheadline)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Payment Method
            HStack {
                Text("Payment:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack {
                    Image(systemName: getPaymentIcon(for: selectedPaymentMethod))
                        .foregroundColor(.red)
                    Text(selectedPaymentMethod.rawValue)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Price Summary
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal")
                        .font(.subheadline)
                    Spacer()
                    Text("$\(cartManager.totalPrice, specifier: "%.2f")")
                        .font(.subheadline)
                }
                
                HStack {
                    Text("Shipping")
                        .font(.subheadline)
                    Spacer()
                    Text(cartManager.totalPrice > 50 ? "FREE" : "$9.99")
                        .font(.subheadline)
                        .foregroundColor(cartManager.totalPrice > 50 ? .green : .primary)
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
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var bottomActionsView: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button("Previous") {
                    currentStep -= 1
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
            
            Button(currentStep == 3 ? "Place Order" : "Next") {
                if currentStep < 3 {
                    if isStepValid() {
                        currentStep += 1
                    }
                } else {
                    placeOrder()
                }
            }
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isStepValid() ? Color.red : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isStepValid() || isProcessingOrder)
            .overlay(
                Group {
                    if isProcessingOrder {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            )
        }
        .padding()
    }
    
    private func isStepValid() -> Bool {
        switch currentStep {
        case 1:
            return !shippingAddress.name.isEmpty &&
                   !shippingAddress.street.isEmpty &&
                   !shippingAddress.city.isEmpty &&
                   !shippingAddress.state.isEmpty &&
                   !shippingAddress.zipCode.isEmpty
        case 2:
            return true // Payment method is always selected
        case 3:
            return true // Summary is always valid if we got here
        default:
            return false
        }
    }
    
    private func fillDemoAddress(type: String) {
        switch type {
        case "home":
            shippingAddress = ShippingAddress(
                name: "John Doe",
                street: "123 Main St",
                city: "Anytown",
                state: "CA",
                zipCode: "12345"
            )
        case "work":
            shippingAddress = ShippingAddress(
                name: "Jane Smith",
                street: "456 Business Blvd",
                city: "Corporate City",
                state: "NY",
                zipCode: "67890"
            )
        case "demo":
            shippingAddress = ShippingAddress(
                name: "Demo User",
                street: "789 Test Avenue",
                city: "Sample City",
                state: "TX",
                zipCode: "54321"
            )
        default:
            break
        }
    }
    
    private func getPaymentIcon(for method: PaymentMethod) -> String {
        switch method {
        case .creditCard, .debitCard:
            return "creditcard"
        case .paypal:
            return "dollarsign.circle"
        case .applePay:
            return "applelogo"
        }
    }
    
    private func placeOrder() {
        isProcessingOrder = true
        
        // Simulate order processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Generate order number
            orderNumber = generateOrderNumber()
            
            isProcessingOrder = false
            showingOrderConfirmation = true
        }
    }
    
    private func generateOrderNumber() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        // Intentional bug: sometimes generates duplicate order numbers
        if Int.random(in: 1...20) == 1 {
            return "WB12345" // Duplicate order number
        }
        return "WB\(timestamp % 100000)"
    }
}

struct QuickFillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(16)
    }
}

struct OrderConfirmationView: View {
    let orderNumber: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Order Placed!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Order #\(orderNumber)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Thank you for your purchase! You'll receive a confirmation email shortly.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text("Estimated delivery:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                let deliveryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
                Text(deliveryDate, style: .date)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button("Continue Shopping") {
                onDismiss()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartManager())
}