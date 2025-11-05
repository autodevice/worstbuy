import SwiftUI

struct SearchView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var cartManager: CartManager
    @State private var searchText = ""
    @State private var selectedCategory: ProductCategory? = nil
    @State private var sortOption: SortOption = .featured
    @State private var showingFilters = false
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 5000
    @State private var selectedProduct: Product?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredProducts: [Product] {
        var products = dataManager.searchProducts(query: searchText)
        
        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }
        
        products = products.filter { product in
            product.price >= minPrice && product.price <= maxPrice
        }
        
        let sortedProducts = dataManager.sortProducts(products, by: sortOption)
        
        // Intentional bug: sometimes filter returns empty results for valid searches
        if !searchText.isEmpty && searchText.count > 3 && Int.random(in: 1...25) == 1 {
            return []
        }
        
        return sortedProducts
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Header
                searchHeaderSection
                
                // Results
                resultsSection
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
        .sheet(isPresented: $showingFilters) {
            FiltersView(
                selectedCategory: $selectedCategory,
                minPrice: $minPrice,
                maxPrice: $maxPrice,
                sortOption: $sortOption
            )
        }
    }
    
    private var searchHeaderSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search products...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button {
                    showingFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            
            // Active Filters
            if selectedCategory != nil || minPrice > 0 || maxPrice < 5000 {
                activeFiltersSection
            }
            
            // Sort Options
            sortOptionsSection
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var activeFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = selectedCategory {
                    FilterChip(title: category.rawValue, isActive: true) {
                        selectedCategory = nil
                    }
                }
                
                if minPrice > 0 || maxPrice < 5000 {
                    FilterChip(title: "$\(Int(minPrice))-$\(Int(maxPrice))", isActive: true) {
                        minPrice = 0
                        maxPrice = 5000
                    }
                }
                
                Button("Clear All") {
                    selectedCategory = nil
                    minPrice = 0
                    maxPrice = 5000
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal)
        }
    }
    
    private var sortOptionsSection: some View {
        HStack {
            Text("Sort by:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(sortOption.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(filteredProducts.count) results")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !searchText.isEmpty {
                    Text("for \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            if filteredProducts.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product) {
                                selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No products found")
                .font(.title2)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                if !searchText.isEmpty {
                    Text("Try searching for something else")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Start typing to search for products")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if selectedCategory != nil || minPrice > 0 || maxPrice < 5000 {
                    Button("Clear filters") {
                        selectedCategory = nil
                        minPrice = 0
                        maxPrice = 5000
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive ? Color.red : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
    }
}

struct FiltersView: View {
    @Binding var selectedCategory: ProductCategory?
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    @Binding var sortOption: SortOption
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(ProductCategory?.none)
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(ProductCategory?.some(category))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Price Range") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("$\(Int(minPrice))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(Int(maxPrice))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Slider(value: $minPrice, in: 0...4999, step: 50)
                            Text("to")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $maxPrice, in: (minPrice + 1)...5000, step: 50)
                        }
                    }
                }
                
                Section("Sort By") {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        HStack {
                            Image(systemName: option.systemImage)
                                .foregroundColor(.red)
                            Text(option.rawValue)
                            Spacer()
                            if sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.red)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            sortOption = option
                        }
                    }
                }
                
                Section {
                    Button("Reset All Filters") {
                        selectedCategory = nil
                        minPrice = 0
                        maxPrice = 5000
                        sortOption = .featured
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(CartManager())
}