//
//  BankDetailViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class BankDetailViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var usdBuyLabel: UILabel!
    @IBOutlet weak var usdSellLabel: UILabel!
    @IBOutlet weak var eurBuyLabel: UILabel!
    @IBOutlet weak var eurSellLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phonesLabel: UILabel!
    @IBOutlet weak var workingHoursLabel: UILabel!
    // MARK: Properties
    var bank: Bank! {
        didSet {
            if isViewLoaded() {
                updateUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            let title = "Позвонить в банк"
            let message = "Вы действительно хотите позвонить в \(bank.name)?"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let cancel = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel, handler: nil)
            for phone in self.bank.phones {
                let aux1 = phone.componentsSeparatedByString(" ")[0]
                let aux2 = aux1.componentsSeparatedByString("-")
                let aux3 = "".join(aux2)
                let path = "tel://8351\(aux3)"
                if let url = NSURL(string: path) {
                    

                    let ok = UIAlertAction(title: "\(phone)", style: UIAlertActionStyle.Default, handler: { _ in
                        println(path)
                        let application:UIApplication = UIApplication.sharedApplication()
                        if (application.canOpenURL(url)) {
                            application.openURL(url)
                        } else {
                            println("Cann't open URL")
                        }
                    })
                    alert.addAction(ok)
                }
            }
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: nil)
        default: break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Map":
                if let nav_controller = segue.destinationViewController as? UINavigationController {
                    if let controller = nav_controller.topViewController as? MapViewController {
                        println(__FUNCTION__)
                        controller.banks = [bank]
                        controller.showMultipleBanks = false
                    }
                }
            case "showWebDetails":
                if let controller = segue.destinationViewController as? BankDetailsWebViewController {
                    controller.path = bank.uri
                }
            default: "Unknown identifier: \(identifier)"
            }
        }
    }
    
    // MARK: - Helpers
    private func setCourse(course: Double, label: UILabel) {
        let value = String(format: "%.2f", course)
        label.text = value
    }
    
    private func setCourses() {
        setCourse(bank.usdBuy, label: usdBuyLabel)
        setCourse(bank.usdSell, label: usdSellLabel)
        setCourse(bank.eurBuy, label: eurBuyLabel)
        setCourse(bank.eurSell, label: eurSellLabel)
    }
    
    func updateUI() {
        if let bank = bank {
            setCourses()
            addressLabel.text = bank.address
            workingHoursLabel.text = bank.workingHours
            title = bank.name
            phonesLabel.text = ", ".join(bank.phones)
        }
    }
}
