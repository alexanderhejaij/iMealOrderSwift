//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025.
//

import SwiftUI
import CoreData

// MARK: - OrderListView
// Displays a list of all orders stored in Core Data.
// Supports deleting orders and navigating into row details.
struct OrderListView: View {
    // Core Data context for saving/deleting
    @Environment(\.managedObjectContext) private var viewContext
    // Dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all orders from Core Data, sorted by orderID
    @FetchRequest(
        entity: Order.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.orderID, ascending: true)]
    ) var orders: FetchedResults<Order>
    
    var body: some View {
        NavigationStack {
            List {
                // Render each order using a custom row view
                ForEach(orders, id: \.objectID) { order in
                    OrderRowView(order: order)
                }
                // Enable swipe-to-delete
                .onDelete(perform: deleteOrders)
            }
            .navigationTitle("Orders")
            .toolbar {
                // Close button on the left
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                // Edit button on the right (enables delete mode)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    // Delete selected orders from Core Data
    private func deleteOrders(at offsets: IndexSet) {
        for index in offsets {
            let order = orders[index]
            viewContext.delete(order)
        }
        try? viewContext.save()
    }
}

// MARK: - OrderRowView
// Displays a single order’s summary inside the list.
// Shows order info, dishes, total, and action buttons (Done, Edit, View).
struct OrderRowView: View {
    // Core Data context for saving updates
    @Environment(\.managedObjectContext) private var viewContext
    // The order being displayed
    @ObservedObject var order: Order
    
    // State for showing the edit sheet
    @State private var showEdit = false
    // Live clock for processing time
    @State private var now = Date()
    // Frozen interval once order is marked Done
    @State private var frozenInterval: Int?
    
    // Sort dishes by type first, then by name
    private var sortedDishes: [Dish] {
        guard let dishes = order.dishes as? Set<Dish> else { return [] }
        return dishes.sorted {
            if $0.dishType == $1.dishType {
                return ($0.dishName ?? "") < ($1.dishName ?? "")
            }
            return ($0.dishType ?? "") < ($1.dishType ?? "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Order details
            Text("Order ID: \(Int(order.orderID))")
                .font(.headline)
            
            Text("Dining Option: \(order.diningOption ?? "Unknown")")
                .font(.subheadline)
            
            if order.diningOption == "Dine In" {
                Text("Table Number: \(order.tableNumber)")
                    .font(.subheadline)
            }
            
            // Status with color coding
            Text("Status: \(order.status ?? "Pending")")
                .font(.subheadline)
                .foregroundColor((order.status ?? "Pending") == "Done" ? .green : .orange)
            
            // Processing time (live until marked Done)
            if let createdAt = order.createdAt {
                Text("Processing Time: \(processingTime(from: createdAt))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Placed at: \(formattedOrderTime(from: createdAt))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            
            // List of dishes in the order
            if !sortedDishes.isEmpty {
                Text("Dishes:")
                    .font(.subheadline)
                    .bold()
                ForEach(sortedDishes, id: \.objectID) { dish in
                    Text("• \(dish.dishName ?? "Unknown") - $\(dish.price, specifier: "%.2f")")
                        .font(.footnote)
                }
            }
            
            // Total price
            Text("Total: $\(orderTotal, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.top, 4)
            
            // Action buttons
            HStack {
                // Mark order as done
                Button("Done Order") {
                    markOrderDone()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                // Edit order in a sheet
                Button("Edit Order") {
                    showEdit = true
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                // Navigate to full order detail view
                NavigationLink(destination: OrderDetailView(order: order)) {
                    Text("View Order")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
        // Present edit sheet
        .sheet(isPresented: $showEdit) {
            OrderEditView(order: order)
                .environment(\.managedObjectContext, viewContext)
        }
        // Timer updates every second while order is still pending
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            if order.status != "Done" {
                now = date
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // Calculate total price of all dishes in the order
    private var orderTotal: Double {
        sortedDishes.reduce(0) { $0 + $1.price }
    }
    
    // MARK: - Actions
    
    // Mark the order as done and freeze processing time
    private func markOrderDone() {
        order.status = "Done"
        if let createdAt = order.createdAt {
            frozenInterval = Int(Date().timeIntervalSince(createdAt))
        }
        try? viewContext.save()
    }
    
    // Calculate processing time since order creation
    // If order is "Done", use frozen interval
    private func processingTime(from createdAt: Date) -> String {
        let interval: Int
        if order.status == "Done", let frozen = frozenInterval {
            interval = frozen
        } else {
            interval = Int(now.timeIntervalSince(createdAt))
        }
        let minutes = interval / 60
        let seconds = interval % 60
        return String(format: "%02dm %02ds", minutes, seconds)
    }
    
    // Formats the order creation time as a local short time string (e.g., "12:03 PM")
    private func formattedOrderTime(from createdAt: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter.string(from: createdAt)
    }

    
    
}
