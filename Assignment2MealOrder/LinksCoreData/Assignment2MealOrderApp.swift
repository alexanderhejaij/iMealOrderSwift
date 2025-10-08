//
//  Assignment2MealOrderApp.swift
//  Assignment2MealOrder
//
//  Created by Alexander Hejaij on 25/9/2025.
//

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
