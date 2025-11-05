import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode
    @State private var quantity = 1
    @State private var showingReviews = false
    @State private var addedToCart = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Product Image
                    productImageSection
                    
                    // Product Info
                    productInfoSection
                    
                    // Specifications
                    specificationsSection
                    
                    // Reviews Section
                    reviewsSection
                    
                    // Add to Cart Button
                    addToCartSection
                }
                .padding()
            }
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var productImageSection: some View {
        Group {
            Group {
                if let uiImage = loadProductImage(product.imageURL) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: product.category.systemImage)
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(red: 0.0, green: 0.27, blue: 0.71))
                                Text(product.brand)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(product.name)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .frame(height: 250)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
    
    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(product.brand)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(product.name)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                if let originalPrice = product.originalPrice {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Was $\(originalPrice, specifier: "%.2f")")
                            .font(.subheadline)
                            .strikethrough()
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                            let savings = originalPrice - product.price
                            let percentage = (savings / originalPrice) * 100
                            
                            Text("Save \(percentage, specifier: "%.0f")%")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                } else {
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(product.rating.rounded()) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    Text("\(product.rating, specifier: "%.1f") (\(product.reviewCount) reviews)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !product.inStock {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Currently out of stock")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text(product.description)
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    private var specificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(product.specifications.keys.sorted()), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(product.specifications[key] ?? "")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Customer Reviews")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !product.reviews.isEmpty {
                    Button("See All") {
                        showingReviews = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            
            if product.reviews.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No reviews yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Be the first to review this product")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                ForEach(product.reviews.prefix(2)) { review in
                    ReviewCard(review: review)
                }
            }
        }
        .sheet(isPresented: $showingReviews) {
            ReviewsListView(product: product)
        }
    }
    
    private var addToCartSection: some View {
        VStack(spacing: 16) {
            if product.inStock {
                HStack {
                    Text("Quantity:")
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button {
                            if quantity > 1 { quantity -= 1 }
                        } label: {
                            Image(systemName: "minus.circle")
                                .font(.title2)
                                .foregroundColor(quantity > 1 ? .red : .gray)
                        }
                        .disabled(quantity <= 1)
                        
                        Text("\(quantity)")
                            .font(.headline)
                            .frame(minWidth: 30)
                        
                        Button {
                            quantity += 1
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button {
                    cartManager.addToCart(product, quantity: quantity)
                    addedToCart = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        addedToCart = false
                    }
                } label: {
                    HStack {
                        Image(systemName: addedToCart ? "checkmark" : "cart.fill")
                        Text(addedToCart ? "Added to Cart!" : "Add to Cart - $\(product.price * Double(quantity), specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(addedToCart ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(addedToCart)
                .animation(.easeInOut(duration: 0.3), value: addedToCart)
            } else {
                Button {
                    // Notify when back in stock functionality
                } label: {
                    HStack {
                        Image(systemName: "bell")
                        Text("Notify When Available")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.author)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Text(review.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(review.comment)
                .font(.body)
                .lineLimit(3)
            
            Text(review.date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ReviewsListView: View {
    let product: Product
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List(product.reviews) { review in
                ReviewCard(review: review)
                    .listRowSeparator(.hidden)
            }
            .navigationTitle("Reviews")
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
    ProductDetailView(product: Product(
        id: "test",
        name: "Test Product",
        price: 99.99,
        originalPrice: 149.99,
        category: .laptops,
        brand: "TestBrand",
        description: "This is a test product description.",
        imageURL: "https://via.placeholder.com/300x300",
        specifications: ["CPU": "Test Processor", "RAM": "8GB"],
        reviews: [],
        rating: 4.5,
        reviewCount: 123,
        inStock: true,
        isFeatured: false
    ))
    .environmentObject(CartManager())
}