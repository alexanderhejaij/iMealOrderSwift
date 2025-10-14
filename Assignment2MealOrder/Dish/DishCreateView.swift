import SwiftUI
import CoreData
import PhotosUI

// MARK: - DishCreateView
// This view allows the user to create a new Dish entity, including details,
// price, ingredients, type, and an optional image.
struct DishCreateView: View {
    // Access to Core Data context for saving new dishes
    @Environment(\.managedObjectContext) private var viewContext
    // Environment dismiss action for closing the modal
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    @State private var dishID = ""          // Dish ID (numeric string)
    @State private var dishName = ""        // Dish name
    @State private var dishType = "Entree"  // Default dish type
    @State private var ingredients = ""     // Ingredients description
    @State private var price = ""           // Price (numeric string)
    
    // MARK: - Image State
    @State private var selectedImage: UIImage?   // Holds chosen image
    @State private var showImagePicker = false   // Controls image picker sheet
    
    // MARK: - Navigation / Alerts
    @State private var showList = false          // Controls dish list sheet
    @State private var showSaveAlert = false     // Controls save confirmation alert
    
    // Available dish types for the segmented picker
    let dishTypes = ["Entree", "Main", "Drink"]
    
    // MARK: - Validation
    // Ensures all fields are filled and numeric values are valid
    private var isFormValid: Bool {
        guard !dishID.isEmpty,
              !dishName.isEmpty,
              !ingredients.isEmpty,
              !price.isEmpty,
              Double(dishID) != nil,
              Double(price) != nil else {
            return false
        }
        return true
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // Section: Dish details
                Section(header: Text("Dish Details")) {
                    TextField("Dish ID", text: $dishID)
                        .keyboardType(.numberPad) // numeric input only
                    
                    TextField("Dish Name", text: $dishName)
                    
                    // Segmented picker for dish type
                    Picker("Dish Type", selection: $dishType) {
                        ForEach(dishTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Ingredients", text: $ingredients)
                    
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad) // decimal input for price
                }
                
                // Section: Image selection
                Section(header: Text("Image")) {
                    if let selectedImage {
                        // Show selected image preview
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                            .padding(.vertical, 4)
                    } else {
                        // Placeholder text if no image chosen
                        Text("No image selected")
                            .foregroundColor(.secondary)
                    }
                    
                    // Button to open image picker
                    Button("Select Image") {
                        showImagePicker = true
                    }
                }
                
                // Section: Actions
                Section {
                    // Save button (disabled until form is valid)
                    Button("Save Dish") {
                        saveDish()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(!isFormValid)
                    
                    // View dishes button (opens DishListView)
                    Button("View Dishes") {
                        showList = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
            }
            .navigationTitle("New Dish") // Title for navigation bar
            .toolbar {
                // Close button in navigation bar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            // Present dish list in a sheet
            .sheet(isPresented: $showList) {
                DishListView()
                    .environment(\.managedObjectContext, viewContext)
            }
            // Present image picker in a sheet
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            // Alert shown after saving a dish
            .alert("Dish Saved", isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your new dish has been added successfully.")
            }
        }
    }
    
    // MARK: - Save Dish
    // Creates a new Dish entity and saves it to Core Data
    private func saveDish() {
        let newDish = Dish(context: viewContext)
        newDish.dishID = Double(dishID) ?? 0.0
        newDish.dishName = dishName
        newDish.dishType = dishType
        newDish.ingredients = ingredients
        newDish.price = Double(price) ?? 0.0
        
        // Save image as JPEG data if selected
        if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            newDish.image = imageData
        }
        
        do {
            // Commit to Core Data
            try viewContext.save()
            
            // Reset form fields after save
            dishID = ""
            dishName = ""
            dishType = "Entree"
            ingredients = ""
            price = ""
            selectedImage = nil
            
            // Show confirmation alert
            showSaveAlert = true
        } catch {
            // Log error if save fails
            print("Error saving Dish: \(error.localizedDescription)")
        }
    }
}
