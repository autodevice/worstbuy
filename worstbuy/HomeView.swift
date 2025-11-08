import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedCategory: ProductCategory? = nil
    @State private var showingProductDetail = false
    @State private var selectedProduct: Product?
    @Binding var selectedTab: Int
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredProducts: [Product] {
        if let category = selectedCategory {
            return dataManager.getProducts(for: category)
        }
        return dataManager.products
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Blue Header
                customHeaderView
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Featured Deals Banner
                        if !dataManager.featuredProducts.isEmpty {
                            featuredDealsSection
                        }
                        
                        // Category Filter
                        categoryFilterSection
                        
                        // Products Grid
                        productsGridSection
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                dataManager.loadProducts()
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
    
    private var customHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                // WorstBuy Logo
                HStack(spacing: 4) {
                    Text("WORST BUY")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                        .cornerRadius(2)
                }
                
                Spacer()
                
                // Header Icons
                HStack(spacing: 16) {
                    Button {} label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Button {} label: {
                        Image(systemName: "bell")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Button {
                        selectedTab = 2
                    } label: {
                        Image(systemName: "cart")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    Text("Search WorstBuy")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "mic")
                        .foregroundColor(.gray)
                    
                    Image(systemName: "qrcode.viewfinder")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(
            Color(red: 0.0, green: 0.27, blue: 0.71) // Best Buy blue
        )
    }
    
    private var featuredDealsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Trending now")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(dataManager.featuredProducts.prefix(3)) { product in
                        FeaturedProductCard(product: product) {
                            selectedProduct = product
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shop by Category")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryChip(
                        title: "All",
                        icon: "house",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue,
                            icon: category.systemImage,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var productsGridSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(selectedCategory?.rawValue ?? "All Products")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(filteredProducts.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if dataManager.isLoading {
                ProgressView("Loading products...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if filteredProducts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("No products found")
                        .font(.headline)
                    Text("Try selecting a different category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(filteredProducts) { product in
                        ProductCard(product: product) {
                            selectedProduct = product
                        }
                    }
                }
            }
        }
    }
    
    // Helper function to get category icons
    
}

func getProductIcon(for category: ProductCategory) -> String {
    return category.systemImage
}

func loadProductImage(_ imageName: String) -> UIImage? {
    // Load from Assets.xcassets using the asset name
    return UIImage(named: imageName)
}

struct FeaturedProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var savingsAmount: String {
        if let originalPrice = product.originalPrice {
            let savings = originalPrice - product.price
            return "Save $\(Int(savings))"
        }
        return ""
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    // Try to load local image, fall back to placeholder
                    Group {
                        // Load real product images
                        Group {
                            if let uiImage = loadProductImage(product.imageURL) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                // Fallback placeholder
                                Rectangle()
                                    .fill(Color.white)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: getProductIcon(for: product.category))
                                                .font(.title)
                                                .foregroundColor(Color(red: 0.0, green: 0.27, blue: 0.71))
                                            Text(product.brand)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                            Text(product.name)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .padding(12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(height: 120)
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    // Save badge
                    if let originalPrice = product.originalPrice {
                        Text(savingsAmount)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                            .padding(8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let originalPrice = product.originalPrice {
                            Text("$\(originalPrice, specifier: "%.2f")")
                                .font(.caption)
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("\(product.rating, specifier: "%.1f")")
                                .font(.caption)
                        }
                        Text("(\(product.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.0, green: 0.27, blue: 0.71) : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    @EnvironmentObject var cartManager: CartManager
    
    var savingsAmount: String {
        if let originalPrice = product.originalPrice {
            let savings = originalPrice - product.price
            return "Save $\(Int(savings))"
        }
        return ""
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    // Try to load local image, fall back to placeholder
                    Group {
                        // Load real product images
                        Group {
                            if let uiImage = loadProductImage(product.imageURL) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                // Fallback placeholder
                                Rectangle()
                                    .fill(Color.white)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: getProductIcon(for: product.category))
                                                .font(.title)
                                                .foregroundColor(Color(red: 0.0, green: 0.27, blue: 0.71))
                                            Text(product.brand)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                            Text(product.name)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .padding(12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(height: 120)
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    // Save badge
                    if let originalPrice = product.originalPrice {
                        Text(savingsAmount)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                            .padding(8)
                    }
                    
                    // Out of stock badge (top right)
                    if !product.inStock {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Out of Stock")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if let originalPrice = product.originalPrice {
                                Text("$\(originalPrice, specifier: "%.2f")")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                            }
                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button {
                            if product.inStock {
                                cartManager.addToCart(product)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(product.inStock ? Color(red: 0.0, green: 0.27, blue: 0.71) : .gray)
                                .font(.title2)
                        }
                        .disabled(!product.inStock)
                    }
                    
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("\(product.rating, specifier: "%.1f")")
                                .font(.caption)
                        }
                        Text("(\(product.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(CartManager())
}
