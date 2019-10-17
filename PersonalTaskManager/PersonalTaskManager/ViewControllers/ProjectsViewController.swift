//
//  ProjectsViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 04..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit

class ProjectsViewController: UITableViewController {

    private let filterNames = ["All tasks", "Today", "Next 7 days"]
    private let sectionHeaderTitles = ["Task filters", "Projects"]
    
    private var projects = [Project]()
    
    private var actualTasksPageViewController: TasksPageViewController!
    private var selectedProjectIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.projects = DataManager.shared.getProjects()
        
        self.clearsSelectionOnViewWillAppear = true

        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filterNames.count
        }
        else {
            return projects.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        var cellTitle: String!
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "TaskFilterCell", for: indexPath)
            cellTitle = filterNames[indexPath.row]
        }
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath)
            cellTitle = projects[indexPath.row].title
        }
        
        cell.textLabel?.text = cellTitle

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaderTitles[section]
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let projectToDelete = projects.remove(at: indexPath.row)
            DataManager.shared.removeProject(projectToDelete)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if (self.splitViewController?.viewControllers.count)! > 1,
                let detailNavigationController = self.splitViewController?.viewControllers[1] as! UINavigationController? {
                
                if selectedProjectIndex == indexPath.row {
                    performSegue(withIdentifier: "ShowTasksFilteredByTime", sender: tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
                    selectedProjectIndex = nil
                }
                else if selectedProjectIndex == nil,
                    let tasksPageViewController = detailNavigationController.viewControllers.first as! TasksPageViewController? {
                    tasksPageViewController.refresh()
                }
                else if let selectedIndex = selectedProjectIndex, indexPath.row < selectedIndex {
                    selectedProjectIndex = selectedIndex - 1
                }
            }
            
        }
        else if editingStyle == .insert {
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.performSegue(withIdentifier: "ShowEditProjectSegue", sender: tableView.cellForRow(at: indexPath))
            tableView.setEditing(false, animated: true)
        })
        editAction.backgroundColor = view.tintColor
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            selectedProjectIndex = indexPath.row
        }
        else {
            selectedProjectIndex = nil
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowAddProjectSegue" {
            let navigationController = segue.destination as! UINavigationController
            navigationController.preferredContentSize = CGSize(width: 0, height: 140)
            
            let projectEditorViewController = navigationController.topViewController as! ProjectEditorViewController
            
            projectEditorViewController.saveProjectAction = { (_ project: Project) in
                self.projects.append(project)
                DataManager.shared.addProject(project)
                self.tableView(self.tableView, commit: .insert, forRowAt: IndexPath(row: self.projects.count-1, section: 1))
            }
        }
        else if segue.identifier == "ShowEditProjectSegue" {
            if let cell = sender as! UITableViewCell?,
               let indexPath = tableView.indexPath(for: cell) {
                
                let editedProject = projects[indexPath.row]
                
                let navigationController = segue.destination as! UINavigationController
                navigationController.preferredContentSize = CGSize(width: 0, height: 140)
                
                let projectEditorViewController = navigationController.topViewController as! ProjectEditorViewController
                
                projectEditorViewController.editedProject = editedProject
                projectEditorViewController.title = "Edit Project"
                projectEditorViewController.addButton.title = "Save"
                projectEditorViewController.saveProjectAction = { (_ project: Project) in
                    self.tableView.reloadData()
                    
                    if (self.splitViewController?.viewControllers.count)! > 1,
                        let detailNavigationController = self.splitViewController?.viewControllers[1] as! UINavigationController?,  self.selectedProjectIndex == indexPath.row {
                        
                        let tasksPageViewController = detailNavigationController.topViewController as! TasksPageViewController
                        
                        tasksPageViewController.navigationItem.title = project.title
                    }
                }
            }
        }
        else if segue.identifier == "ShowTasksFilteredByTime" {
            if let cell = sender as! UITableViewCell? {
                let tasksPageViewController = (segue.destination as! UINavigationController).topViewController as! TasksPageViewController
                
                tasksPageViewController.navigationItem.title = cell.textLabel?.text
                
                tasksPageViewController.projectFilter = { (Project) -> Bool in return true }
                
                if let indexPath = tableView.indexPath(for: cell),
                    indexPath.section == 0 {
                    
                    let row = indexPath.row
                    
                    switch row {
                        case 0:
                            tasksPageViewController.timeFilter = { (t: Task) -> Bool in
                                return true
                            }
                        case 1:
                            tasksPageViewController.timeFilter = { (t: Task) -> Bool in
                                let todayDate = Date()
                                let calendar = Calendar.current
                                let todayDateComponents = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: todayDate)
                            
                                let taskDateComponents = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: t.date)
                                
                                return taskDateComponents.day == todayDateComponents.day
                            }
                        case 2:
                            tasksPageViewController.timeFilter = { (t: Task) -> Bool in
                                let todayDate = Date()
                                let calendar = Calendar.current
                                let todayDateComponents = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: todayDate)
                                
                                let taskDateComponents = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: t.date)
                                
                                return taskDateComponents.day! >= todayDateComponents.day! && taskDateComponents.day! <= todayDateComponents.day! + 7
                            }
                        default:
                            tasksPageViewController.timeFilter = { (t: Task) -> Bool in
                                return true
                            }
                    }
                }
                
            }
        }
        else if segue.identifier == "ShowTasksFilteredByProject" {
            if let cell = sender as! UITableViewCell? {
                let tasksPageViewController = (segue.destination as! UINavigationController).topViewController as! TasksPageViewController
                
                tasksPageViewController.navigationItem.title = cell.textLabel?.text
                
                if let indexPath = tableView.indexPath(for: cell) {
                    tasksPageViewController.projectFilter = { (p: Project) -> Bool in
                        return p === self.projects[indexPath.row]
                    }
                }
                
                tasksPageViewController.timeFilter = { (t: Task) -> Bool in return true }
            }
        }
    }
}
