//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025.
//

import SwiftUI
import CoreData

// MARK: - EditDishView
// This view allows editing of an existing Dish entity.
// It preloads the dish’s current values into form fields,
// lets the user update them, and saves changes back to Core Data.
struct EditDishView: View {
    // The Dish object being edited, observed so UI updates when properties change
    @ObservedObject var dish: Dish
    
    // Core Data context used to save or delete the dish
    var context: NSManagedObjectContext
    
    // Environment dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Local State
    // Local copies of dish properties bound to form fields
    @State private var dishID: String = ""
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var ingredients: String = ""
    @State private var price: String = ""
    
    // State for handling image selection
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    // Available dish types for the picker
    let dishTypes = ["Entree", "Main", "Drink"]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // Section: Dish details
                Section(header: Text("Dish Details")) {
                    TextField("Dish ID", text: $dishID)
                        .keyboardType(.numberPad) // numeric keyboard
                    
                    TextField("Dish Name", text: $name)
                    
                    // Picker for dish type
                    Picker("Dish Type", selection: $type) {
                        ForEach(dishTypes, id: \.self) { dishType in
                            Text(dishType)
                        }
                    }
                    
                    TextField("Ingredients", text: $ingredients)
                    
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad) // decimal keyboard
                }
                
                // Section: Dish image
                Section(header: Text("Dish Image")) {
                    // Show either the newly selected image or the saved image from Core Data
                    if let imageToShow = selectedImage ?? (dish.image.flatMap { UIImage(data: $0) }) {
                        Image(uiImage: imageToShow)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                    } else {
                        // Placeholder if no image exists
                        Text("No image available")
                            .foregroundColor(.secondary)
                    }
                    
                    // Button to open the image picker
                    Button("Change Image") {
                        showImagePicker = true
                    }
                }
            }
            .navigationTitle("Edit Dish")
            .toolbar {
                // Cancel button on the left
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                // Delete and Save buttons on the right
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Delete: removes the dish from Core Data
                    Button("Delete") {
                        context.delete(dish)
                        try? context.save()
                        dismiss()
                    }
                    // Save: updates the dish with new values
                    Button("Save") {
                        // Update dish properties from form fields
                        dish.dishID = Double(dishID) ?? dish.dishID
                        dish.dishName = name
                        dish.dishType = type
                        dish.ingredients = ingredients
                        dish.price = Double(price) ?? dish.price
                        
                        // Save selected image if one exists
                        if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
                            dish.image = imageData
                        }
                        
                        // Save changes to Core Data
                        try? context.save()
                        dismiss()
                    }
                }
            }
            // Present the image picker when triggered
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            // Populate form fields with existing dish data when the view appears
            .onAppear {
                // Preload values from the dish into local state
                dishID = String(format: "%.0f", dish.dishID)
                name = dish.dishName ?? ""
                type = dish.dishType ?? dishTypes.first!
                ingredients = dish.ingredients ?? ""
                price = String(format: "%.2f", dish.price)
                
                // Preload the saved image into selectedImage
                if let imageData = dish.image {
                    selectedImage = UIImage(data: imageData)
                }
            }
        }
    }
}
