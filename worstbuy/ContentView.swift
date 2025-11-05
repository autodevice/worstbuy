//
//  ContentView.swift
//  worstbuy
//
//  Created by Billy on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cartManager = CartManager()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            CartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                    if cartManager.items.count > 0 {
                        Text("\(cartManager.items.count)")
                    }
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .environmentObject(cartManager)
        .accentColor(Color(red: 0.0, green: 0.27, blue: 0.71))
    }
}

#Preview {
    ContentView()
}
