//
//  TasksPageViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 07..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit

class TasksPageViewController: UIPageViewController {

    private var pageTitles = ["All Tasks", "Completed", "Overdue"]
    private var pages = [TasksViewController]()
    
    var projectFilter: ((Project) -> Bool)!
    var timeFilter: ((Task) -> Bool)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pages = createViewControllers()
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        dataSource = self
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .lightGray
        appearance.currentPageIndicatorTintColor = view.tintColor
        appearance.backgroundColor = UIColor.clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scrollView = view.subviews.filter({ $0 is UIScrollView }).first,
            let pageControl = view.subviews.filter({ $0 is UIPageControl }).first {
            scrollView.frame = view.bounds
            view.bringSubviewToFront(pageControl)
        }
    }
    
    func createViewControllers() -> [TasksViewController] {
        let allTasksViewController = storyboard?.instantiateViewController(withIdentifier: "TasksContentViewController") as! TasksViewController
        allTasksViewController.title = "All"
        allTasksViewController.projectFilter = projectFilter
        allTasksViewController.taskFilter = { (t: Task) -> Bool in
            return self.timeFilter(t)
        }
        
        let completedTasksViewController = storyboard?.instantiateViewController(withIdentifier: "TasksContentViewController") as! TasksViewController
        completedTasksViewController.title = "Completed"
        completedTasksViewController.projectFilter = projectFilter
        completedTasksViewController.taskFilter = { (t: Task) -> Bool in
            return self.timeFilter(t) && t.completed
        }
        
        let overdueTasksViewController = storyboard?.instantiateViewController(withIdentifier: "TasksContentViewController") as! TasksViewController
        overdueTasksViewController.title = "Overdue"
        overdueTasksViewController.projectFilter = projectFilter
        overdueTasksViewController.taskFilter = { (t: Task) -> Bool in
            return self.timeFilter(t) && t.overdue && !t.completed
        }
        
        return [allTasksViewController, completedTasksViewController, overdueTasksViewController]
    }
    
    func refresh() {
        pages.forEach{ $0.refreshTableView() }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowAddTaskSegue" {
            let taskEditorViewController = (segue.destination as! UINavigationController).topViewController as! TaskEditorViewController
            
            taskEditorViewController.saveTaskAction = { (_ task: Task, index: Int) in
                DataManager.shared.addTask(task, index: index)
                (self.pages[0]).insertTask(task: task)
            }
        }
    }

}

extension TasksPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! TasksViewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! TasksViewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = pages.firstIndex(of: firstViewController as! TasksViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
