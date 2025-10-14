import SwiftUI
import CoreData

// MARK: - OrderEditView
// This view allows editing of an existing Order entity.
// It preloads the order’s details, lets the user update them,
// and saves the changes back to Core Data. It also supports deleting the order.
struct OrderEditView: View {
    // The order being edited (observed so UI updates when properties change)
    @ObservedObject var order: Order
    
    // Core Data context for saving/deleting
    @Environment(\.managedObjectContext) private var viewContext
    // Dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all dishes from Core Data, sorted by type
    @FetchRequest(
        entity: Dish.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Dish.dishType, ascending: true)]
    ) var dishes: FetchedResults<Dish>
    
    // MARK: - Local State
    @State private var orderID: String = ""             // Editable order ID
    @State private var diningOption: String = "Dine In" // Dining option
    @State private var tableNumber: String = ""         // Table number (for dine-in only)
    @State private var selectedDishes: Set<Dish> = []   // Tracks selected dishes
    
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
                
                // Section: Summary and Save
                Section {
                    // Show total price of selected dishes
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(totalPrice, specifier: "%.2f")")
                            .font(.headline)
                    }
                    
                    // Save changes button
                    Button("Save Changes") {
                        updateOrder()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(!isFormValid) // Disabled until form is valid
                }
                
                // Section: Delete Order
                Section {
                    Button(role: .destructive) {
                        deleteOrder()
                    } label: {
                        Text("Delete Order")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .navigationTitle("Edit Order")
            .toolbar {
                // Cancel button in navigation bar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            // Load existing order details when view appears
            .onAppear {
                loadOrder()
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
    
    // MARK: - Load Existing Order
    // Preload order details into local state for editing
    private func loadOrder() {
        orderID = String(Int(order.orderID))
        diningOption = order.diningOption ?? "Dine In"
        tableNumber = order.diningOption == "Dine In" ? String(order.tableNumber) : ""
        
        if let dishes = order.dishes as? Set<Dish> {
            selectedDishes = dishes
        }
    }
    
    // MARK: - Update Order
    // Save updated values back into the Core Data order
    private func updateOrder() {
        order.orderID = Double(orderID) ?? order.orderID
        order.diningOption = diningOption
        if diningOption == "Dine In" {
            order.tableNumber = Int16(tableNumber) ?? order.tableNumber
        }
        
        // Replace dishes with new selection
        order.removeFromDishes(order.dishes ?? [])
        for dish in selectedDishes {
            order.addToDishes(dish)
        }
        
        do {
            try viewContext.save()
            dismiss() // Close view after saving
        } catch {
            print("Error updating order: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Order
    // Deletes the order from Core Data
    private func deleteOrder() {
        viewContext.delete(order)
        do {
            try viewContext.save()
            dismiss() // Close view after deletion
        } catch {
            print("Error deleting order: \(error.localizedDescription)")
        }
    }
}

