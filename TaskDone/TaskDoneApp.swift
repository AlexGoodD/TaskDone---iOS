//
//  TaskDoneApp.swift
//  TaskDone
//
//  Created by Alejandro on 11/12/24.
//

import SwiftUI

@main
struct TaskDoneApp: App {
    let persistenceController: PersistenceController
    @StateObject private var viewModel = TaskViewModel()

    init() {
        #if DEBUG
        // Usa un contexto in-memory para depuración
        persistenceController = PersistenceController(inMemory: true)
        #else
        persistenceController = PersistenceController.shared
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewModel)
        }
    }
}