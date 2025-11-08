//
//  ContentView.swift
//  worstbuy
//
//  Created by Billy on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cartManager = CartManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            CartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                    if cartManager.items.count > 0 {
                        Text("\(cartManager.items.count)")
                    }
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .environmentObject(cartManager)
        .accentColor(Color(red: 0.0, green: 0.27, blue: 0.71))
    }
}

#Preview {
    ContentView()
}
