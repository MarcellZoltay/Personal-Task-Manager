//
//  Task+CoreDataProperties.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 30..
//  Copyright © 2018. MacOS. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String?
    @NSManaged private(set) var overdue: Bool
    @NSManaged private var myCompleted: Bool
    @NSManaged private var myDate: Date!
    @NSManaged public var note: String?
    @NSManaged public var project: Project?

    var date: Date {
        get { return myDate }
        set(newDate) {
            myDate = newDate
            
            let today = Date()
            if newDate < today {
                overdue = true
            }
            else {
                overdue = false
            }
        }
    }
    var completed: Bool {
        get { return myCompleted }
        set(value) {
            if value == true {
                myCompleted = value
                overdue = false
            }
            else {
                myCompleted = false
                
                let today = Date()
                if date < today {
                    overdue = true
                }
            }
        }
    }
}
