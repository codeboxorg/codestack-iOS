//
//  CoreDataStack.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//

import CoreData
import RxSwift

public protocol PersistentStore: AnyObject {
    typealias DBOperation<Result> = (NSManagedObjectContext) throws -> Result
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> Observable<Int>
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> Observable<Swift.Result<[V],Error>>
    
    func update<T>(_ operation: @escaping DBOperation<T>) -> Observable<Swift.Result<T, Error>>
    
    func remove<T>(request: NSFetchRequest<T>) -> Observable<Void>
}

enum StoreType {
    case persistent, inMemory

    func NSStoreType() -> String {
        switch self {
        case .persistent:
            return NSSQLiteStoreType
        case .inMemory:
            return NSInMemoryStoreType
        }
    }
}

public final class CoreDataStack: PersistentStore {
    
    private let container: NSPersistentContainer
    private let isStoreLoaded = BehaviorSubject<Bool>(value: false)
    private let bgQueue = DispatchQueue(label: "coredata")
    
    public init(directory: FileManager.SearchPathDirectory = .documentDirectory,
                domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
                bundle: Bundle,
         version vNumber: UInt) {
        
        let version = Version(vNumber)
        
        let url = bundle.url(forResource: "db_model_v1", withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOf: url!)!
        
        container = NSPersistentContainer(name: version.modelName, managedObjectModel: mom)
        if let url = version.dbFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        bgQueue.async { [weak isStoreLoaded, weak container] in
            container?.loadPersistentStores { (storeDescription, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        isStoreLoaded?.onError(error)
                    } else {
                        container?.viewContext.configureAsReadOnlyContext()
                        isStoreLoaded?.onNext(true)
                    }
                }
            }
        }
    }
    
    public func count<T>(_ fetchRequest: NSFetchRequest<T>) -> Observable<Int> {
        return onStoreIsReady
            .flatMap { [weak container] in
                Observable.create { observer in
                    do {
                        let count = try container?.viewContext.count(for: fetchRequest) ?? 0
                        observer.onNext(count)
                    } catch {
                        observer.onError(error)
                    }
                    return Disposables.create { }
                }
            }
    }
    
    public func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> Observable<Result<[V],Error>> {
        assert(Thread.isMainThread)
        let fetch = Observable<Result<[V],Error>>.create { [weak container] observer in
            guard let context = container?.viewContext else { return Disposables.create { }}
            context.performAndWait {
                do {
                    fetchRequest.returnsObjectsAsFaults = false
                    let managedObjects = try context.fetch(fetchRequest) as [T]
                    
                    let mapped = managedObjects.compactMap {
                        if let mo = $0 as? NSManagedObject {
                            // Turning object into a fault
                            context.refresh(mo, mergeChanges: false)
                        }
                        return try? map($0)
                    }
                    observer.onNext(.success(mapped))
                } catch {
                    observer.onNext(.failure(error))
                }
            }
            return Disposables.create { }
        }
        
        return onStoreIsReady
            .flatMap { fetch }
    }
    
    public func remove<T>(request: NSFetchRequest<T>) -> Observable<Void> {
        Observable<Void>.create { [weak bgQueue, weak container] observer in
            bgQueue?.async {
                guard let context = container?.newBackgroundContext() else { return  }
                do {
                    let fetched = try context.fetch(request)
                    
                    fetched.forEach {
                        context.delete($0 as! NSManagedObject)
                    }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    
                    context.reset()
                    observer.onNext(())
                } catch {
                    context.reset()
                    observer.onError(error)
                }
            }
            
            return Disposables.create { }
        }
        
    }
    
    public func update<T>(_ operation: @escaping DBOperation<T>) -> Observable<Result<T, Error>> {
        let updateObservable =
        Observable<Result<T, Error>>.create { [weak bgQueue, weak container] observer in
            bgQueue?.async {
                guard let context = container?.newBackgroundContext() else { return  }
                context.configureAsUpdateContext()
                context.performAndWait {
                    do {
                        let result = try operation(context)
                        if context.hasChanges {
                            try context.save()
                        }
                        context.reset()
                        observer.onNext(.success(result))
                    } catch {
                        context.reset()
                        observer.onNext(.failure(error))
                    }
                }
            }
            return Disposables.create { }
        }
        
        return onStoreIsReady
            .flatMap { _ in updateObservable }
            .observe(on: MainScheduler.instance)
    }
    
    private var onStoreIsReady: Observable<Void> {
        return isStoreLoaded
            .filter { return $0 }
            .map { _ in }
            .asObservable()
    }
}

// MARK: - Versioning
public extension CoreDataStack.Version {
    static var actual: UInt { 1 }
}

extension CoreDataStack {
    public struct Version {
        private let number: UInt
        
        public init(_ number: UInt) {
            self.number = number
        }
        
        var modelName: String {
            return "db_model_v1"
        }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "db.sql"
        }
    }
}


