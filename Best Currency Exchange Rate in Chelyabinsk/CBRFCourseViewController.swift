//
//  CBRFCourseViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 20.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class CBRFCourseViewController: UITableViewController {

    // MARK: Properties
    var currency: CurrentCurrency.Currency = CurrentCurrency.Currency.USD
    var setCBRFPeriod: CurrencySet!
    var startDate: NSDate
    var finishDate: NSDate
    
    // MARK: Constructor
    required init!(coder aDecoder: NSCoder!) {
        
        finishDate = NSDate()
        startDate = NSDate()
        super.init(coder: aDecoder)
        startDate = getMonthAgo()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showDatePickers":
                if let nav_controller = segue.destinationViewController as? UINavigationController {
                    if let controller = nav_controller.topViewController as? SelectPeriodViewController {
                        controller.startDate = startDate
                        controller.finishDate = finishDate
                        controller.delegate = self
                    }
                }
            default: println("Unknow identifier: \(identifier)")
            }
        } else {
            println("Unknow identifier.")
        }
    }

    // MARK: - TableViewDataSourse
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setCBRFPeriod?.set.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        if let set = setCBRFPeriod?.set { formatStringForCell(cell, indexPath: indexPath) }
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Helpers
    func getCoursePeriod() {
        let d = Downloader()
        d.sourse = DownloaderSourse.CBRFPeriod(startDate: startDate, finishDate: finishDate, code: currency.entityValue)
        let onReady: ([AnyObject])->() = { result in
            if let aux = result as? [CurrencySet] {
                if let aux_set = aux.first { self.setCBRFPeriod = aux_set }
            }
            self.refresh()
        }
        d.download(onReady)
    }
    
    func refresh() {
        if let set = setCBRFPeriod {
            setCBRFPeriod.set.sort({ (c1: Currency, c2: Currency) -> Bool in
                return c1.date.compare(c2.date) == NSComparisonResult.OrderedDescending
            })
            self.tableView.reloadData()
        }
    }
    
    func formatStringForCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let course: Currency = setCBRFPeriod.set[indexPath.row]
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        cell.textLabel?.text = "\(formatter.stringFromDate(course.date))"
        cell.detailTextLabel?.text = "1 \(course.charCode) = \(course.value) RUB"
        let prevIndex = indexPath.row + 1
        if prevIndex < setCBRFPeriod.set.count {
            let prevCourse = setCBRFPeriod.set[prevIndex]
            if prevCourse.value < course.value {
                cell.detailTextLabel?.textColor = UIColor.greenColor()
            } else {
                cell.detailTextLabel?.textColor = UIColor.redColor()
            }
        }
    }
    
    func getMonthAgo() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let date = finishDate ?? NSDate()
        
        let components = NSDateComponents()
        components.month = -1
        return calendar.dateByAddingComponents(components, toDate: date, options: nil)!
    }

    private func debug(set: CurrencySet) { for c in set.set { println(c.desc()) } }
}

extension CBRFCourseViewController: SelectPeriodViewControllerDelegate {
    func didCancel(controller: SelectPeriodViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func didFinishPickingDate(controller: SelectPeriodViewController, forDates startDate: NSDate, endDate: NSDate) {
        self.startDate = startDate
        self.finishDate = endDate
        getCoursePeriod()
        refresh()
        dismissViewControllerAnimated(true, completion: nil)
    }
}