//
//  Project+CoreDataProperties.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 30..
//  Copyright © 2018. MacOS. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var title: String!
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension Project {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

    
    func getTasks() -> [Task] {
        var taskArray = [Task]()
        tasks!.forEach { taskArray.append($0 as! Task) }
        
        return taskArray.sorted(by: { $0.date < $1.date })
    }
    
}
