//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025.
//

import SwiftUI
import CoreData

// MARK: - OrderCreateView
// This view allows the user to create a new order.
// It collects order details, lets the user select dishes, calculates the total,
// and saves the order into Core Data.
struct OrderCreateView: View {
    // Access Core Data context for saving orders
    @Environment(\.managedObjectContext) private var viewContext
    // Dismiss action for closing the sheet
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all dishes from Core Data, sorted by dishType
    @FetchRequest(
        entity: Dish.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Dish.dishType, ascending: true)]
    ) var dishes: FetchedResults<Dish>
    
    // MARK: - State variables
    @State private var orderID = ""                  // Order ID (numeric string)
    @State private var diningOption = "Dine In"      // Default dining option
    @State private var tableNumber = ""              // Table number (for dine-in only)
    @State private var selectedDishes: Set<Dish> = []// Tracks selected dishes
    @State private var showList = false              // Controls showing order list
    @State private var showSaveAlert = false         // Controls save confirmation alert
    
    // Options for dining type
    let diningOptions = ["Dine In", "Take Away"]
    // Categories for grouping dishes
    let dishTypes = ["Entree", "Main", "Drink"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // Section: Order details
                Section(header: Text("Order Details")) {
                    TextField("Order ID", text: $orderID)
                        .keyboardType(.numberPad)
                    
                    // Picker for dining option
                    Picker("Dining Option", selection: $diningOption) {
                        ForEach(diningOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Table number (only enabled for Dine In)
                    TextField("Table Number", text: $tableNumber)
                        .keyboardType(.numberPad)
                        .disabled(diningOption == "Take Away")
                        .opacity(diningOption == "Take Away" ? 0.5 : 1.0)
                }
                
                // Section: Dish selection grouped by type
                ForEach(dishTypes, id: \.self) { type in
                    Section(header: Text(type)) {
                        ForEach(dishes.filter { $0.dishType == type }, id: \.objectID) { dish in
                            // Toggle for selecting/unselecting a dish
                            Toggle(isOn: Binding(
                                get: { selectedDishes.contains(dish) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedDishes.insert(dish)
                                    } else {
                                        selectedDishes.remove(dish)
                                    }
                                }
                            )) {
                                // Dish details
                                VStack(alignment: .leading) {
                                    Text(dish.dishName ?? "Unknown")
                                        .font(.headline)
                                    Text(String(format: "$%.2f", dish.price))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Section: Summary and actions
                Section {
                    // Display total price
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(totalPrice, specifier: "%.2f")")
                            .font(.headline)
                    }
                    
                    // Place order button
                    Button("Place Order") {
                        saveOrder()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(!isFormValid) // Disabled until form is valid
                    
                    // View orders button
                    Button("View Orders") {
                        showList = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
            }
            .navigationTitle("New Order")
            .toolbar {
                // Close button in navigation bar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            // Present order list in a sheet
            .sheet(isPresented: $showList) {
                OrderListView()
                    .environment(\.managedObjectContext, viewContext)
            }
            // Confirmation alert after saving
            .alert("Order Saved", isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your order has been placed successfully.")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // Calculate total price of selected dishes
    private var totalPrice: Double {
        selectedDishes.reduce(0) { $0 + $1.price }
    }
    
    // Validate form inputs
    private var isFormValid: Bool {
        guard !orderID.isEmpty,
              Double(orderID) != nil, // Order ID must be numeric
              diningOption == "Take Away" || !tableNumber.isEmpty else {
            return false
        }
        return !selectedDishes.isEmpty // At least one dish must be selected
    }
    
    // MARK: - Save Order
    private func saveOrder() {
        // Create new Order entity
        let newOrder = Order(context: viewContext)
        newOrder.orderID = Double(orderID) ?? 0.0
        newOrder.diningOption = diningOption
        newOrder.status = "Pending"   // Default status
        newOrder.createdAt = Date()   // Timestamp
        
        // Save table number only for dine-in
        if diningOption == "Dine In" {
            newOrder.tableNumber = Int16(tableNumber) ?? 0
        }
        
        // Add selected dishes to the order
        for dish in selectedDishes {
            newOrder.addToDishes(dish)
        }
        
        do {
            // Save to Core Data
            try viewContext.save()
            
            // Reset form fields for next order
            orderID = ""
            diningOption = "Dine In"
            tableNumber = ""
            selectedDishes = []
            
            // Show confirmation alert
            showSaveAlert = true
        } catch {
            // Log error if save fails
            print("Error saving order: \(error.localizedDescription)")
        }
    }
}
