//
//  TasksViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 07..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit

class TasksViewController: UIViewController {
    
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!
    
    var tasks = [Task]()
    
    var projectFilter: ((Project) -> Bool)?
    var taskFilter: ((Task) -> Bool)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLabel.text = self.title
        
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        tasksTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tasks = getTasks()
        tasksTableView.reloadData()
    }
    
    private func getTasks() -> [Task] {
        
        var tasks = [Task]()
        
        if let filter = projectFilter {
            let projects = DataManager.shared.getProjects().filter { filter($0) }
            projects.forEach {
                tasks.append(contentsOf: $0.getTasks().filter { taskFilter($0) } )
            }
        }
        
        return tasks
    }
    
    func insertTask(task: Task) {
        if projectFilter!(task.project!) {
            tasks.append(task)
            tableView(self.tasksTableView, commit: .insert, forRowAt: IndexPath(row: self.tasks.count-1, section: 0))
        }
    }
    
    func refreshTableView() {
        tasks = getTasks()
        tasksTableView?.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetailSegue" {
            if let cell = sender as! UITableViewCell?, let indexPath = tasksTableView.indexPath(for: cell) {
                let taskDetailViewController = segue.destination as! TaskDetailViewController
                
                let task = tasks[indexPath.row]
                
                taskDetailViewController.task = task
                taskDetailViewController.saveTaskAction = self.saveEditedTask(task:index:)
                taskDetailViewController.deleteTaskAction = { () in
                    self.tableView(self.tasksTableView, commit: .delete, forRowAt: indexPath)
                }
            }
        }
    }
    
    
    // MARK: Gesture recognizer
    @IBAction func handleCellLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: tasksTableView)
        
        guard let indexPath = tasksTableView.indexPathForRow(at: p),
            gestureRecognizer.state == .began,
            let cell = tasksTableView.cellForRow(at: indexPath) else { return }
        
        showAlertPopover(indexPath: indexPath, cell: cell)
    }
    
    private func showAlertPopover(indexPath: IndexPath, cell: UITableViewCell) {
        
        self.becomeFirstResponder()
        
        let alert = UIAlertController(title: "Select One", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: { (action) in
            
            let navigationController = (self.storyboard?.instantiateViewController(withIdentifier: "TaskEditorNavigationController") as! UINavigationController)
            navigationController.modalPresentationStyle = .popover
            
            let taskEditorViewController = navigationController.topViewController as! TaskEditorViewController
            
            let task = self.tasks[indexPath.row]
            taskEditorViewController.editedTask = task
            taskEditorViewController.title = "Edit Task"
            taskEditorViewController.addButton.title = "Save"
            taskEditorViewController.addButton.isEnabled = true
            taskEditorViewController.saveTaskAction = self.saveEditedTask(task:index:)
            
            if let taskEditorPopoverController = navigationController.popoverPresentationController {
                taskEditorPopoverController.sourceView = self.view
                taskEditorPopoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                taskEditorPopoverController.permittedArrowDirections = []
            }
            
            self.present(navigationController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { (action) in
            self.tableView(self.tasksTableView, commit: .delete, forRowAt: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        if let alertPopoverController = alert.popoverPresentationController {
            alertPopoverController.sourceView = cell
            alertPopoverController.sourceRect = CGRect(x: cell.bounds.midX, y: cell.bounds.midY, width: 0, height: 0)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func saveEditedTask(task: Task, index: Int) {
        let projects = DataManager.shared.getProjects()
        if let project = task.project, let projectIndex = projects.index(where: { $0 === project }),
            index != projectIndex {
            projects[projectIndex].removeFromTasks(task)
            projects[index].addToTasks(task)
        }
    }
}

extension TasksViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].title
        cell.detailTextLabel?.text = tasks[indexPath.row].note
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = self.tasks.remove(at: indexPath.row)
            DataManager.shared.removeTask(task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension TasksViewController: UITableViewDelegate {}
