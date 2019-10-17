//
//  StatisticsViewController.swift
//  PersonalTaskManager
//
//  Created by MacOS on 2018. 11. 17..
//  Copyright © 2018. MacOS. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {

    enum TimeIntervarType{
        case monthly
        case weekly
    }
    
    @IBOutlet weak var timeIntervalSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    
    let legendLabels = ["All", "Completed", "Overdue"]
    
    var timeIntervalType: TimeIntervarType = .monthly
    var monthOffset = 0
    var weekOffset = 0
    var actualChartData: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setChartAppearance()
        setData()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateChart()
    }
    
    private func setChartAppearance() {
        barChartView.noDataText = "You need to provide data for the chart."
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawLabelsEnabled = false
        
        let leftYAxis = barChartView.leftAxis
        leftYAxis.axisMinimum = 0
        leftYAxis.labelFont = NSUIFont.systemFont(ofSize: 12)
        let rightYAxis = barChartView.rightAxis
        rightYAxis.axisMinimum = 0
        rightYAxis.labelFont = NSUIFont.systemFont(ofSize: 12)
        
        let legend = barChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .top
        legend.font = NSUIFont.systemFont(ofSize: 16)
        legend.formSize = CGFloat(integerLiteral: 16)
        legend.xEntrySpace = 15.0
        
        barChartView.pinchZoomEnabled = false
        barChartView.dragEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlightPerTapEnabled = false
    }
    private func setChartData(){

        let entryAllTasks = BarChartDataEntry(x: 0, y: actualChartData[0])
        let entryCompletedTasks = BarChartDataEntry(x: 1, y: actualChartData[1])
        let entryOverdueTasks = BarChartDataEntry(x: 2, y: actualChartData[2])
        
        
        let dataSetAllTasks = BarChartDataSet(values: [entryAllTasks], label: legendLabels[0]);
        dataSetAllTasks.colors = [.blue]
        dataSetAllTasks.valueFormatter = self
        dataSetAllTasks.valueFont = NSUIFont.systemFont(ofSize: 16, weight: .bold)
        
        let dataSetCompletedTasks = BarChartDataSet(values: [entryCompletedTasks], label: legendLabels[1]);
        dataSetCompletedTasks.colors = [.green]
        dataSetCompletedTasks.valueFormatter = self
        dataSetCompletedTasks.valueFont = NSUIFont.systemFont(ofSize: 16, weight: .bold)
        
        let dataSetOverdueTasks = BarChartDataSet(values: [entryOverdueTasks], label: legendLabels[2]);
        dataSetOverdueTasks.colors = [.red]
        dataSetOverdueTasks.valueFormatter = self
        dataSetOverdueTasks.valueFont = NSUIFont.systemFont(ofSize: 16, weight: .bold)
        
        
        let data = BarChartData(dataSets: [dataSetAllTasks, dataSetCompletedTasks, dataSetOverdueTasks])
        barChartView.data = data
    }
    
    private func setData() {
        switch timeIntervalType {
        case .monthly:
            setValues(componentToCompare: .month, offset: monthOffset)
        case .weekly:
            setValues(componentToCompare: .weekOfYear, offset: weekOffset)
        }
    }
    private func setValues(componentToCompare: Calendar.Component, offset: Int) {
        let todayDate = Date()
        let calendar = Calendar.current
        
        let calculatedDate = calendar.date(byAdding: componentToCompare, value: offset, to: todayDate, wrappingComponents: false)
        
        var all = 0, completed = 0, overdue = 0
        let projects = DataManager.shared.getProjects()
        projects.forEach {
            let tasks = $0.getTasks()
            tasks.forEach {
                if calendar.compare($0.date, to: calculatedDate!, toGranularity: componentToCompare) == .orderedSame {
                    all += 1
                    
                    if $0.completed { completed += 1 }
                    if $0.overdue { overdue += 1 }
                }
            }
        }
        
        actualChartData = [Double(all), Double(completed), Double(overdue)]
        
        dateLabel.text = setLabelText(date: calculatedDate!)
    }
    private func setLabelText(date: Date) -> String {
        let formatter = DateFormatter()
        
        switch timeIntervalType {
        case .monthly:
            formatter.dateFormat = "yyyy. MMMM"
            return formatter.string(for: date)!
        case .weekly:
            formatter.dateFormat = "yyyy.\n w."
            return formatter.string(for: date)! + " week"
        }
    }
    
    @IBAction func handleTimeIntervalValueChanged(_ sender: UISegmentedControl) {
        switch timeIntervalSegmentedControl.selectedSegmentIndex {
        case 0:
            timeIntervalType = .monthly
        case 1:
            timeIntervalType = .weekly
        default: break
        }
        
        updateChart()
    }
    @IBAction func handleSwipeRight(_ sender: UISwipeGestureRecognizer) {
        switch timeIntervalType {
        case .monthly:
            monthOffset -= 1
        case .weekly:
            weekOffset -= 1
        }
        
        updateChart()
    }
    @IBAction func handleSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        switch timeIntervalType {
        case .monthly:
            monthOffset +=  1
        case .weekly:
            weekOffset +=  1
        }
        
        updateChart()
    }
    
    private func updateChart() {
        barChartView.clear()
        setData()
        setChartData()
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
}

extension StatisticsViewController: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(format:"%.0f", value)
    }
}
