import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showingSettings = false
    @State private var showingOrderHistory = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Demo User")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("demo@worstbuy.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Member since 2024")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Quick Stats
                Section("Shopping Stats") {
                    HStack {
                        VStack {
                            Text("\(cartManager.itemCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Items in Cart")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("$\(cartManager.totalPrice, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Cart Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("3")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Past Orders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Account Options
                Section("Account") {
                    NavigationLink(destination: OrderHistoryView()) {
                        Label("Order History", systemImage: "bag")
                    }
                    
                    NavigationLink(destination: AddressBookView()) {
                        Label("Address Book", systemImage: "location")
                    }
                    
                    NavigationLink(destination: PaymentMethodsView()) {
                        Label("Payment Methods", systemImage: "creditcard")
                    }
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .foregroundColor(.primary)
                    }
                }
                
                // Support Options
                Section("Support") {
                    Button {
                        // Contact support
                    } label: {
                        Label("Contact Support", systemImage: "questionmark.circle")
                            .foregroundColor(.primary)
                    }
                    
                    Button {
                        // FAQ
                    } label: {
                        Label("FAQ", systemImage: "book")
                            .foregroundColor(.primary)
                    }
                    
                    Button {
                        // Report bug
                    } label: {
                        Label("Report a Bug", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.primary)
                    }
                }
                
                // Debug Options (intentionally buggy)
                Section("Debug") {
                    Button("Clear Cart Data") {
                        cartManager.clearCart()
                    }
                    .foregroundColor(.red)
                    
                    Button("Trigger Crash") {
                        // Intentional crash for testing
                        fatalError("Debug crash triggered")
                    }
                    .foregroundColor(.red)
                    
                    Button("Corrupt Data") {
                        // Intentionally corrupt cart data
                        UserDefaults.standard.set("invalid_data", forKey: "shopping_cart")
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct OrderHistoryView: View {
    let mockOrders = [
        ("WB12345", "Nov 1, 2024", "$299.99", "Delivered"),
        ("WB12346", "Oct 28, 2024", "$149.99", "Shipped"),
        ("WB12347", "Oct 15, 2024", "$799.99", "Delivered")
    ]
    
    var body: some View {
        List {
            ForEach(mockOrders, id: \.0) { order in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Order #\(order.0)")
                            .font(.headline)
                        Spacer()
                        Text(order.3)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(order.3 == "Delivered" ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Text(order.1)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(order.2)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddressBookView: View {
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text("Home")
                    .font(.headline)
                Text("123 Main St")
                Text("Anytown, CA 12345")
            }
            .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Work")
                    .font(.headline)
                Text("456 Business Blvd")
                Text("Corporate City, NY 67890")
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Address Book")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaymentMethodsView: View {
    var body: some View {
        List {
            HStack {
                Image(systemName: "creditcard")
                    .foregroundColor(.red)
                VStack(alignment: .leading) {
                    Text("Visa •••• 1234")
                        .font(.subheadline)
                    Text("Expires 12/26")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Default")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            HStack {
                Image(systemName: "applelogo")
                    .foregroundColor(.red)
                Text("Apple Pay")
                    .font(.subheadline)
                Spacer()
            }
        }
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationsEnabled = true
    @State private var locationEnabled = false
    @State private var biometricsEnabled = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Location Services", isOn: $locationEnabled)
                    Toggle("Use Face ID", isOn: $biometricsEnabled)
                }
                
                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Beta)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Clear Cache") {
                        // Clear app cache
                    }
                    
                    Button("Reset App") {
                        // Reset app to defaults
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://worstbuy.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://worstbuy.com/terms")!)
                    Button("Rate App") {
                        // Rate app
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(CartManager())
}