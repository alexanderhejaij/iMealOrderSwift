import SwiftUI

// MARK: - AdminDashboard
// This is the main admin landing screen.
// It provides navigation to create/view dishes and orders, and a logout option.
struct AdminDashboard: View {
    // Environment dismiss action to close the dashboard (logout)
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State for sheet presentations
    @State private var showCreateDish = false   // Controls Create Dish sheet
    @State private var showDishList = false     // Controls View Dishes sheet
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
                        .foregroundColor(.blue)
                    
                    Text("Admin Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // MARK: Create Dish button
                Button(action: { showCreateDish = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Create a Dish")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                
                // MARK: View Dishes button
                Button(action: { showDishList = true }) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .font(.title2)
                        Text("View Dishes")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                
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
                DishCreateView()
            }
            .sheet(isPresented: $showDishList) {
                DishListView()
            }
            .sheet(isPresented: $showCreateOrder) {
                OrderCreateView()
            }
            .sheet(isPresented: $showOrderList) {
                OrderListView() // To be implemented similar to DishListView
            }
        }
    }
}
