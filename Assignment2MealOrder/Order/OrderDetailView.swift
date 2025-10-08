//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025.
//

import SwiftUI
import CoreData

// MARK: - OrderDetailView
// Displays the details of a single order, including order info,
// grouped dishes, total price, live processing time, and a delete option.
struct OrderDetailView: View {
    // The order being displayed (observed so UI updates when it changes)
    @ObservedObject var order: Order
    
    // Core Data context for saving/deleting
    @Environment(\.managedObjectContext) private var viewContext
    // Dismiss action to close this view
    @Environment(\.dismiss) private var dismiss
    
    // Live clock for calculating processing time
    @State private var now = Date()
    // Stores frozen processing time once order is marked "Done"
    @State private var frozenInterval: Int?
    
    // Defines the order in which dish types are displayed
    private let dishTypes = ["Entree", "Main", "Drink"]
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: Order Info
                Group {
                    Text("Order #\(Int(order.orderID))")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Dining Option: \(order.diningOption ?? "Unknown")")
                        .font(.headline)
                    
                    // Show table number only for dine-in orders
                    if order.diningOption == "Dine In" {
                        Text("Table Number: \(order.tableNumber)")
                            .font(.headline)
                    }
                    
                    // Status with color coding
                    Text("Status: \(order.status ?? "Pending")")
                        .font(.headline)
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

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                
                Divider()
                
                // MARK: Grouped Dishes
                if let dishes = order.dishes as? Set<Dish>, !dishes.isEmpty {
                    ForEach(dishTypes, id: \.self) { type in
                        let group = dishes.filter { $0.dishType == type }
                        if !group.isEmpty {
                            Section(header: Text(type)
                                .font(.title2)
                                .bold()
                                .padding(.vertical, 4)) {
                                
                                ForEach(Array(group), id: \.objectID) { dish in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(dish.dishName ?? "Unknown")
                                                .font(.headline)
                                            Text(String(format: "$%.2f", dish.price))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                } else {
                    // Fallback if no dishes are linked to the order
                    Text("No dishes in this order.")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // MARK: Total
                HStack {
                    Text("Total:")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Text("$\(orderTotal, specifier: "%.2f")")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                
                Divider()
                
                // MARK: Delete button
                Button(role: .destructive) {
                    deleteOrder()
                } label: {
                    Text("Delete Order")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        // Timer updates every second while order is still pending
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            if order.status != "Done" {
                now = date
            }
        }
    }
    
    // MARK: - Helpers
    
    // Calculate total price of all dishes in the order
    private var orderTotal: Double {
        guard let dishes = order.dishes as? Set<Dish> else { return 0 }
        return dishes.reduce(0) { $0 + $1.price }
    }
    
    // Calculate processing time since order creation
    // If order is "Done", freeze the interval
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

    
    // Delete the order from Core Data and dismiss the view
    private func deleteOrder() {
        viewContext.delete(order)
        do {
            try viewContext.save()
            dismiss()   // Close detail view after deletion
        } catch {
            print("Error deleting order: \(error.localizedDescription)")
        }
    }
}
