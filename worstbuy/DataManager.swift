import Foundation

class DataManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var isLoading = false
    
    static let shared = DataManager()
    
    private init() {
        loadProducts()
    }
    
    func loadProducts() {
        isLoading = true
        
        guard let url = Bundle.main.url(forResource: "products", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load products.json")
            createMockProducts()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            products = try decoder.decode([Product].self, from: data)
            featuredProducts = products.filter { $0.isFeatured }
        } catch {
            print("Error decoding products: \(error)")
            createMockProducts()
        }
        
        isLoading = false
    }
    
    func getProducts(for category: ProductCategory) -> [Product] {
        return products.filter { $0.category == category }
    }
    
    func searchProducts(query: String) -> [Product] {
        if query.isEmpty {
            return products
        }
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(query) ||
            product.brand.localizedCaseInsensitiveContains(query) ||
            product.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func sortProducts(_ products: [Product], by sortOption: SortOption) -> [Product] {
        switch sortOption {
        case .featured:
            return products.sorted { $0.isFeatured && !$1.isFeatured }
        case .priceLowHigh:
            return products.sorted { $0.price < $1.price }
        case .priceHighLow:
            return products.sorted { $0.price > $1.price }
        case .rating:
            return products.sorted { $0.rating > $1.rating }
        case .newest:
            // Intentional bug: sometimes returns products in reverse order
            return Int.random(in: 1...5) == 1 ? products.reversed() : products
        }
    }
    
    private func createMockProducts() {
        products = []
    }
}