//
//  DailyCourseViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class DailyCourseViewController: UITableViewController {
    
    enum Status {
        case Initial
        case Loading
        case NoResult
        case Finish(text: String)
        
        var entityValue: String {
            switch self {
            case .Initial: return "Пока не обновлялось"
            case .NoResult: return "Не удалось загрузить курсы валют.\nПопробуйте еще раз позже."
            case .Loading: return "Загружается"
            case .Finish(let text): return "\(text)"
            }
        }
    }
    
    // MARK: - Properties
    var setCBRF: CurrencySet!
    var setAuditIt: CurrencySet!
    var momentaryCourseDataTask: NSURLSessionDataTask!
    var dailyCourseDataTask: NSURLSessionDataTask!
    var statusMomentary = Status.Initial {
        didSet {
            statusMomentaryLabel.text = statusMomentary.entityValue
        }
    }
    
    // MARK: - @IBOutlets
    @IBOutlet weak var dailyUSDLabel: UILabel!
    @IBOutlet weak var dailyEURLabel: UILabel!
    @IBOutlet weak var momentaryUSDLabel: UILabel!
    @IBOutlet weak var momentaryEURLabel: UILabel!
    @IBOutlet weak var statusMomentaryLabel: UILabel!
    
    // MARK: - @IBAction
    @IBAction func refreshButton(sender: AnyObject) {
        refresh()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            
            switch identifier {
            case "usd":
                if let controller = segue.destinationViewController as? CBRFCourseViewController {
                    controller.currency = CurrentCurrency.Currency.USD
                    controller.getCoursePeriod()
                }
            case "eur":
                if let controller = segue.destinationViewController as? CBRFCourseViewController {
                    controller.currency = CurrentCurrency.Currency.EUR
                    controller.getCoursePeriod()
                }
            default: println("Unknown identifier: \(identifier)")
            }
        }
    }
    
    // MARK: Helper
    func debug(set: CurrencySet) { for e in set.set { println(e.desc()) } }
    func refresh() {
        updateUI()
        getCourse()
        getMomentaryCourse()
    }
    
    private func formatLabelWithDouble(label: UILabel!, value: Double!) {
        label?.text = String(format: "%.2f", value ?? 0)
    }
    
    private func formatMomentaryLabelWithDouble(label: UILabel!, value: Double!, daily: Double!) {
        var text: String
        let course = String(format: "%.2f", value ?? 0)
        if value == nil {
            text = course
        } else {
            if let daily = daily {
                let dailyInt = Int(daily * 100)
                let momentaryInt = Int(value * 100)
                let deltaInt = momentaryInt - dailyInt
                var delta: String
                if deltaInt >= 0 {
                    delta = String(format: "+%d", deltaInt)
                    label.textColor = UIColor.greenColor()
                } else {
                    delta = String(format: "%d", deltaInt)
                    label.textColor = UIColor.redColor()
                }
                text = String(format: "%@ (%@)", course, delta)
            } else {
                text = course
            }
        }
        label?.text = text
    }
    
    func updateUI() {
        let dailyUSD = setCBRF?.getUSDCourse()
        formatLabelWithDouble(dailyUSDLabel, value: dailyUSD)
        formatMomentaryLabelWithDouble(momentaryUSDLabel, value: setAuditIt?.getUSDCourse(), daily: dailyUSD)
        let dailyEUR = setCBRF?.getEURCourse()
        formatLabelWithDouble(dailyEURLabel, value: dailyEUR)
        formatMomentaryLabelWithDouble(momentaryEURLabel, value: setAuditIt?.getEURCourse(), daily: dailyEUR)
    }
    
    private func getMomentaryCourse() {
        momentaryCourseDataTask?.cancel()
        statusMomentary = .Loading
        let d = Downloader()
        d.sourse = DownloaderSourse.AUDITIT
        let onReady: ([AnyObject])->() = { result in
            if let aux = result as? [CurrencySet] {
                if let aux_set = aux.first {
                    self.setAuditIt = aux_set
                    self.statusMomentary = Status.Finish(text: self.setAuditIt.annotation ?? "")
                } else {
                    self.statusMomentary = .NoResult
                }
            } else {
                self.statusMomentary = .NoResult
            }
            if let set = self.setAuditIt { self.updateUI() }
            self.momentaryCourseDataTask = nil
        }
        momentaryCourseDataTask = d.download(onReady)
    }
    
    private func getCourse() {
        dailyCourseDataTask?.cancel()
        let d = Downloader()
        d.sourse = DownloaderSourse.CBRFDaily
        let onReady: ([AnyObject])->() = { result in
            if let aux = result as? [CurrencySet] {
                if let aux_set = aux.first { self.setCBRF = aux_set }
            }
            if let set = self.setCBRF { self.updateUI() }
            self.dailyCourseDataTask = nil
        }
        dailyCourseDataTask = d.download(onReady)
    }
    
    
    
}
