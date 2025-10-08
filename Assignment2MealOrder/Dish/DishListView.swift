//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025.
//

import SwiftUI
import CoreData

// MARK: - DishListView
// Displays all saved dishes from Core Data in a list.
// Supports multi-selection, deletion, and editing of individual dishes.
struct DishListView: View {
    // Access the Core Data context from the environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // Provides dismiss action for closing this view (when presented modally)
    @Environment(\.dismiss) private var dismiss
    
    // Tracks whether the list is in edit mode (needed for multi-select/delete)
    @Environment(\.editMode) private var editMode
    
    // Fetch all Dish entities from Core Data
    // Note: no sort descriptors here, sorting is handled manually in `sortedDishes`
    @FetchRequest(
        entity: Dish.entity(),
        sortDescriptors: []
    ) var dishes: FetchedResults<Dish>
    
    // Holds the dish currently selected for editing (opens EditDishView)
    @State private var selectedDish: Dish?
    
    // Tracks multiple selected dishes (for batch deletion)
    @State private var selection = Set<NSManagedObjectID>()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            // List supports multi-selection via binding to `selection`
            List(selection: $selection) {
                // Iterate over sorted dishes, using objectID as unique identifier
                ForEach(sortedDishes, id: \.objectID) { dish in
                    VStack(alignment: .leading, spacing: 8) {
                        // Display dish details with bold labels
                        Text("Dish ID: ").bold() + Text(String(format: "%.0f", dish.dishID))
                        Text("Dish Name: ").bold() + Text(dish.dishName ?? "Unknown")
                        Text("Dish Type: ").bold() + Text(dish.dishType ?? "Unknown")
                        Text("Ingredients: ").bold() + Text(dish.ingredients ?? "Unknown")
                        Text("Price: ").bold() + Text(String(format: "$%.2f", dish.price))
                        
                        // Show dish image if available
                        if let imageData = dish.image,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle()) // Makes the whole row tappable
                    .onTapGesture {
                        // Only open the edit sheet if not in edit mode
                        if editMode?.wrappedValue != .active {
                            selectedDish = dish
                        }
                    }
                }
            }
            .navigationTitle("Dishes")
            .toolbar {
                // Back button on the left
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
                // Edit and Delete buttons on the right
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Built-in EditButton toggles edit mode (shows checkboxes)
                    EditButton()
                    
                    // Show "Delete Selected" only if something is selected
                    if !selection.isEmpty {
                        Button("Delete Selected") {
                            deleteSelected()
                        }
                    }
                }
            }
            // Present the edit sheet when a dish is tapped
            .sheet(item: $selectedDish) { dish in
                EditDishView(dish: dish, context: viewContext)
            }
        }
    }
    
    // MARK: - Sorting
    // Computed property to sort dishes by type order (Entree → Main → Drink)
    private var sortedDishes: [Dish] {
        let orderList = ["Entree", "Main", "Drink"]
        return dishes.sorted {
            let firstIndex = orderList.firstIndex(of: $0.dishType ?? "") ?? Int.max
            let secondIndex = orderList.firstIndex(of: $1.dishType ?? "") ?? Int.max
            return firstIndex < secondIndex
        }
    }
    
    // MARK: - Delete
    // Deletes all dishes currently selected in multi-select mode
    private func deleteSelected() {
        for id in selection {
            if let dish = dishes.first(where: { $0.objectID == id }) {
                viewContext.delete(dish)
            }
        }
        // Save changes to Core Data
        try? viewContext.save()
        // Clear the selection set
        selection.removeAll()
    }
}
