import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let price: Double
    let originalPrice: Double?
    let category: ProductCategory
    let brand: String
    let description: String
    let imageURL: String
    let specifications: [String: String]
    let reviews: [Review]
    let rating: Double
    let reviewCount: Int
    let inStock: Bool
    let isFeatured: Bool
}

struct Review: Identifiable, Codable {
    let id: String
    let author: String
    let rating: Int
    let title: String
    let comment: String
    let date: String
}

enum ProductCategory: String, CaseIterable, Codable {
    case laptops = "Laptops"
    case tvs = "TVs"
    case phones = "Phones"
    case gaming = "Gaming Consoles"
    case smartHome = "Smart Home Devices"
    
    var systemImage: String {
        switch self {
        case .laptops: return "laptopcomputer"
        case .tvs: return "tv"
        case .phones: return "iphone"
        case .gaming: return "gamecontroller"
        case .smartHome: return "house"
        }
    }
}

struct CartItem: Identifiable, Codable {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}

struct Order: Identifiable, Codable {
    let id: String
    let items: [CartItem]
    let shippingAddress: ShippingAddress
    let paymentMethod: PaymentMethod
    let total: Double
    let orderDate: Date
    let status: OrderStatus
}

struct ShippingAddress: Codable {
    var name: String = ""
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
}

enum PaymentMethod: String, CaseIterable, Codable {
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case paypal = "PayPal"
    case applePay = "Apple Pay"
}

enum OrderStatus: String, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

enum SortOption: String, CaseIterable {
    case featured = "Featured"
    case priceLowHigh = "Price: Low to High"
    case priceHighLow = "Price: High to Low"
    case rating = "Customer Rating"
    case newest = "Newest"
    
    var systemImage: String {
        switch self {
        case .featured: return "star.fill"
        case .priceLowHigh: return "arrow.up"
        case .priceHighLow: return "arrow.down"
        case .rating: return "heart.fill"
        case .newest: return "clock"
        }
    }
}