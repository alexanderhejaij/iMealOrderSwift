//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025
//

import SwiftUI

// MARK: - UserDashboard
// This is the main landing screen for a regular user.
// It allows the user to create orders, view their orders, and log out.
struct UserDashboard: View {
    // Environment dismiss action to close the dashboard (logout)
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State for sheet presentations
    @State private var showCreateDish = false   // (Not typically needed for users, but included here)
    @State private var showDishList = false     // (Not typically needed for users, but included here)
    @State private var showCreateOrder = false  // Controls Create Order sheet
    @State private var showOrderList = false    // Controls View Orders sheet
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                // MARK: Header
                // Displays an icon and the dashboard title
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green) // Green theme for user role
                    
                    Text("User Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // MARK: Create Order button
                Button(action: { showCreateOrder = true }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.title2)
                        Text("Create an Order")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                
                // MARK: View Orders button
                Button(action: { showOrderList = true }) {
                    HStack {
                        Image(systemName: "doc.plaintext.fill")
                            .font(.title2)
                        Text("View Orders")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: Logout button
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.title2)
                        Text("Logout")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            // Hide the default back button to prevent accidental navigation
            .navigationBarBackButtonHidden(true)
            
            // MARK: - Sheets
            // Each button above toggles one of these sheets
            .sheet(isPresented: $showCreateDish) {
                DishCreateView() // (Admin functionality, but included here)
            }
            .sheet(isPresented: $showDishList) {
                DishListView() // (Admin functionality, but included here)
            }
            .sheet(isPresented: $showCreateOrder) {
                OrderCreateView() // User creates a new order
            }
            .sheet(isPresented: $showOrderList) {
                OrderListView() // User views their orders (to be implemented similar to DishListView)
            }
        }
    }
}
