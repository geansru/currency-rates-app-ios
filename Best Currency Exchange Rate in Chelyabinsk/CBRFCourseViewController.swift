//
//  CBRFCourseViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 20.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class CBRFCourseViewController: UITableViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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

    // MARK: Properties
    var currency: CurrentCurrency.Currency = CurrentCurrency.Currency.USD
    var setCBRFPeriod: CurrencySet!
    
    // MARK: - Helpers
    func getCoursePeriod() {
        let d = Downloader()
        d.sourse = DownloaderSourse.CBRFPeriod(startDate: getMonthAgo(), finishDate: NSDate(), code: currency.entityValue)
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
    
    private func getMonthAgo() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let date = NSDate()
        
        let components = NSDateComponents()
        components.month = -1
        return calendar.dateByAddingComponents(components, toDate: date, options: nil)!
    }

    private func debug(set: CurrencySet) { for c in set.set { println(c.desc()) } }
}
