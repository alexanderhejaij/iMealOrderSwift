import SwiftUI

@main
struct Assignment2MealOrderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LoginScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
