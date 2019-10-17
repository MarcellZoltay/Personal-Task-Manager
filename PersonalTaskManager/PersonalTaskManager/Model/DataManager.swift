//
//  DataManager.swift
//  PersonalTaskManager.BLL
//
//  Created by MacOS on 2018. 11. 04..
//  Copyright © 2018. MacOS. All rights reserved.
//

import Foundation
import CoreData

class DataManager{
    
    // MARK: Singleton
    static let shared = DataManager()
    
    private init(){
        fetchData()
    }
    
    
    // MARK: Projects
    private var projects = [Project]()
    
    
    func getProjects() -> [Project] {
        return projects
    }
    func addProject(_ p: Project) {
        projects.append(p)
    }
    func removeProject(_ p: Project) {
        if let projectIndex = projects.index(where: { $0 === p }) {
            projects.remove(at: projectIndex)
            
            persistentContainer.viewContext.delete(p)
        }
    }
    
    
    // MARK: Tasks
    func addTask(_ task: Task, index: Int) {
        projects[index].addToTasks(task)
    }
    func removeTask(_ task: Task) {
        let project = task.project
        project?.removeFromTasks(task)
    }
    
    
    
    // MARK: Fetch data
    
    class var managedContext: NSManagedObjectContext {
        return DataManager.shared.persistentContainer.viewContext
    }
    
    private var fetchedProjectResultsController: NSFetchedResultsController<Project>!
    
    
    private func fetchData(){
        let managedObjectContext = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Project.title), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 30
        fetchRequest.includesSubentities = true
        
        fetchedProjectResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        do {
            try fetchedProjectResultsController.performFetch()
            
            fetchedProjectResultsController.fetchedObjects!.forEach { projects.append($0) }
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PersonalTaskManager")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
