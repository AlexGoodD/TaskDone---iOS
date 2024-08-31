import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskDone_")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        if inMemory {
            let viewContext = container.viewContext
            addSampleData(context: viewContext)
        }
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Aquí se agregan los datos de ejemplo
        result.addSampleData(context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    private func addSampleData(context: NSManagedObjectContext) {
        let task1 = Task(context: context)
        task1.title = "Comprar víveres"
        task1.taskDescription = "Comprar leche, pan y huevos."
        task1.creationDate = Date()
        task1.dueDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())
        task1.isCompleted = false

        let task2 = Task(context: context)
        task2.title = "Enviar correo"
        task2.taskDescription = "Enviar el reporte de ventas del mes."
        task2.creationDate = Date()
        task2.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        task2.isCompleted = false

        let task3 = Task(context: context)
        task3.title = "Revisar coche"
        task3.taskDescription = "Llevar el coche al taller para la revisión anual."
        task3.creationDate = Date()
        task3.dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        task3.isCompleted = false

        let task4 = Task(context: context)
        task4.title = "Leer libro"
        task4.taskDescription = "Terminar de leer 'El nombre del viento'."
        task4.creationDate = Date()
        task4.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        task4.isCompleted = true
    }
}
