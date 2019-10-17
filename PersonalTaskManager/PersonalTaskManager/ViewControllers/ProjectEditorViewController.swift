//
//  ProjectViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 06..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit

class ProjectEditorViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var projectNameTextField: UITextField!
    
    var saveProjectAction: ((Project) -> Void)!
    var editedProject: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        projectNameTextField.text = editedProject?.title        
        projectNameTextField.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
    }
    
    @objc func textFieldIsNotEmpty(sender: UITextField) {
        let hasLastSpace = sender.text?.hasSuffix(" ")
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        if let projectName = projectNameTextField.text, !projectName.isEmpty
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

    @IBAction func addTapped(_ sender: Any) {
        if let action = saveProjectAction {
            
            let projectTitle = projectNameTextField.text!.trimmingCharacters(in: .whitespaces)
            
            if editedProject == nil {
                let project = Project(context: DataManager.managedContext)
                project.title = projectTitle
                action(project)
            }
            else {
                editedProject!.title = projectTitle
                action(editedProject!)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
