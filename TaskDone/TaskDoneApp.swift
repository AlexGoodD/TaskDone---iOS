//
//  TaskDoneApp.swift
//  TaskDone
//
//  Created by Alejandro on 11/12/24.
//

import SwiftUI

@main
struct TaskDoneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
