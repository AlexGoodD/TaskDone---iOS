//
//  TaskDone_App.swift
//  TaskDone!
//
//  Created by Alejandro on 28/08/24.
//

import SwiftUI

@main
struct TaskDone_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
