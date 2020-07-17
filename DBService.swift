import Foundation
import CoreData

struct CreationError: LocalizedError {
    var recoverySuggestion: String? {
        return "Check if the Entity exists"
    }
    var errorDescription: String? {
        return "Putting Element in the Entity \(entityName) failed"
    }
    private let entityName: String

    init(_ entityName: String) {
        self.entityName = entityName
    }
}

class DBService {
    static private let dataModelName = "YOUR_MODEL_NAME"
    private lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(identifier: "YOUR_BUNDLE_ID")
        let modelUrl = bundle!.url(
            forResource: DBService.dataModelName,
            withExtension: "momd"
        )
        let objectModel = NSManagedObjectModel(contentsOf: modelUrl!)
        let persistentContainer = NSPersistentContainer(
            name: DBService.dataModelName,
            managedObjectModel: objectModel!
        )
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                logError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
    private let caller: String

    init(_ caller: String) {
        self.caller = caller
    }

    func create<T: NSManagedObject>(of entity: T.Type) throws -> T {
        let context = persistentContainer.viewContext
        let entityName = String(describing: entity)
        guard let entity = NSEntityDescription.entity(
                forEntityName: entityName,
                in: context
            ) else {
            throw CreationError(entityName)
        }
        let object = T(entity: entity, insertInto: context)
        return object
    }

    func get<T: NSManagedObject>(
        of entity: T.Type,
        with predicate: NSPredicate?
    ) -> T? {
        let request = makeRequest(entity: entity, with: predicate)
        let context = persistentContainer.viewContext
        do {
            let result = try context.fetch(request)
            return result.first
        } catch {
            logError("Failed to get object from entity. Error: \(error)")
        }
        return nil
    }

    func query<T: NSManagedObject>(
        entity: T.Type,
        with predicate: NSPredicate?
    ) -> [T] {
        let request = makeRequest(entity: entity, with: predicate)
        let context = persistentContainer.viewContext
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            logError("Failed quering objects from entity. Error: \(error)")
        }
        return []
    }

    func delete<T: NSManagedObject>(_ object: T) {
        let context = persistentContainer.viewContext
        context.delete(object)
    }

    func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nsError = error as NSError
                logError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        return false
    }

    private func makeRequest<T: NSManagedObject>(
        entity: T.Type,
        with predicate: NSPredicate?
    ) -> NSFetchRequest<T> {
        let entityName = String(describing: entity)
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        return request
    }
}