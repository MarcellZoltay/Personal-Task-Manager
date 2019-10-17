//
//  TaskDetailViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 14..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit

class TaskDetailViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var completedSwitch: UISwitch!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    var task: Task!
    var saveTaskAction: ((Task, Int) -> Void)!
    var deleteTaskAction: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = task.title
        completedSwitch.isOn = task.completed
        projectTitleLabel.text = task.project?.title
        noteTextView.text = task.note
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        timeLabel.text = dateFormatter.string(for: task.date)
    }

    @IBAction func completedValueChanged(_ sender: UISwitch) {
        task.completed = sender.isOn
    }
    @IBAction func editTapped(_ sender: UIButton) {
        let navigationController = (self.storyboard?.instantiateViewController(withIdentifier: "TaskEditorNavigationController") as! UINavigationController)
        navigationController.modalPresentationStyle = .popover
        
        let taskEditorViewController = navigationController.topViewController as! TaskEditorViewController
        
        taskEditorViewController.editedTask = self.task
        taskEditorViewController.title = "Edit Task"
        taskEditorViewController.addButton.title = "Save"
        taskEditorViewController.addButton.isEnabled = true
        taskEditorViewController.saveTaskAction = { (_ task: Task, index: Int) in
            self.saveTaskAction(task, index)
            
            self.titleLabel.text = task.title
            self.projectTitleLabel.text = task.project!.title
            self.noteTextView.text = task.note
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            self.timeLabel.text = dateFormatter.string(for: task.date)
        }
        
        if let taskEditorPopoverController = navigationController.popoverPresentationController {
            taskEditorPopoverController.sourceView = self.view
            taskEditorPopoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            taskEditorPopoverController.permittedArrowDirections = []
        }
        
        self.present(navigationController, animated: true, completion: nil)
    }
    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteTaskAction()
        navigationController?.popViewController(animated: true)
    }
}
