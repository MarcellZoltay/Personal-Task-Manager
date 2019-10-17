//
//  TaskEditorViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 09..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit

class TaskEditorViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var projectPicker: UIPickerView!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var noteTextView: UITextView!
    
    private var projectNames = [String]()
    var saveTaskAction: ((Task, Int) -> Void)!
    var editedTask: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let projects = DataManager.shared.getProjects()
        projects.forEach { projectNames.append($0.title) }
        
        taskNameTextField.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        
        projectPicker.dataSource = self
        projectPicker.delegate = self
        
        if let task = editedTask {
            taskNameTextField.text = task.title
            dateTimePicker.date = task.date
            noteTextView.text = task.note
            
            if let projectIndex = projects.index(where: { $0 === task.project }) {
                projectPicker.selectRow(projectIndex, inComponent: 0, animated: false)
            }
        }
    }
    
    @objc func textFieldIsNotEmpty(sender: UITextField) {
        if projectNames.count > 0 {
            let hasLastSpace = sender.text?.hasSuffix(" ")
            sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
            
            if let taskName = taskNameTextField.text, !taskName.isEmpty
            {
                if hasLastSpace! {
                    sender.text?.append(" ")
                }
                addButton.isEnabled = true
            }
            else {
                addButton.isEnabled = false
            }
        }
    }

    @IBAction func addTapped(_ sender: Any) {
        if let action = saveTaskAction {
            
            let taskTitle = taskNameTextField.text!.trimmingCharacters(in: .whitespaces)
            let taskNote = noteTextView.text?.trimmingCharacters(in: .whitespaces)
            
            if editedTask == nil {
                let task = Task(context: DataManager.managedContext)
                task.title = taskTitle
                task.date = dateTimePicker.date
                task.note = taskNote
                action(task, projectPicker.selectedRow(inComponent: 0))
            }
            else {
                editedTask!.title = taskTitle
                editedTask!.date = dateTimePicker.date
                editedTask!.note = taskNote
                action(editedTask!, projectPicker.selectedRow(inComponent: 0))
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TaskEditorViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return projectNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return projectNames[row]
    }
}

extension TaskEditorViewController: UIPickerViewDelegate {}
