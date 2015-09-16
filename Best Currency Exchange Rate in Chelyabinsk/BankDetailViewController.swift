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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
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
        }
    }
}
