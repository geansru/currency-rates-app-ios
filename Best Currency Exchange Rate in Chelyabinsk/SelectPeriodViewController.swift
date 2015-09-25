//
//  SelectPeriodViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 21.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

protocol SelectPeriodViewControllerDelegate {
    func didCancel(controller: SelectPeriodViewController)
    func didFinishPickingDate(controller: SelectPeriodViewController, forDates startDate: NSDate, endDate: NSDate)
}

class SelectPeriodViewController: UITableViewController {

    // MARK: Properties
    var delegate: SelectPeriodViewControllerDelegate!
    var startDate: NSDate!
    var finishDate: NSDate!
    // MARK: - @IBOutlet
    @IBOutlet weak var finishDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    // MARK: - @IBOutlet
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        delegate.didCancel(self)
    }
    
    @IBAction func onDone(sender: UIBarButtonItem) {
        let (start, finish) = checkDates()
        delegate.didFinishPickingDate(self, forDates: start, endDate: finish)
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let today = NSDate()
        finishDatePicker.maximumDate = today
        startDatePicker.maximumDate = today
        updateUI()
    }

    // MARK: Helpers
    func updateUI() {
        if let date = startDate { startDatePicker.setDate(date, animated: true) }
        if let date = finishDate { finishDatePicker.setDate(date, animated: true) }
    }
    
    func showAlertDatePickingError() {
        let title = "Не правильно выбраны даты"
        let message = "Начало периода и/или конец периода находятся в будующем. Пожалуйста, выберите правильные даты или нажмите кнопку отмена."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkDates() -> (start: NSDate, finish: NSDate) {
        let start = getStartDate()
        return (start, finishDate ?? getFinishDate())
    }
    
    func getFinishDate() -> NSDate {
        let today = NSDate()
        finishDate = finishDatePicker.date
        let compare = today.compare(finishDate)
        if compare == NSComparisonResult.OrderedAscending { finishDate = today }
        if DEBUG { println("After compare: finishDate = \(finishDate) , today = \(today)") }
        
        if let date = finishDate { finishDatePicker.setDate(date, animated: true) }
        return finishDate
    }
    
    func getStartDate() -> NSDate {
        let finish = getFinishDate()
        startDate = startDatePicker.date
        
        if startDate.compare(finishDate) == NSComparisonResult.OrderedDescending { startDate = finish }
        if DEBUG { println("After compare: startDate = \(finishDate) , finish = \(finishDate)") }
        
        if let date = startDate { startDatePicker.setDate(date, animated: true) }
        return startDate
    }
 }
