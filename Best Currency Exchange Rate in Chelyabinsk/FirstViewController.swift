//
//  FirstViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
//import Kanna

class FirstViewController: UIViewController {

    // MARK: - Properties
    var banks = [Bank]()
    var task: NSURLSessionDataTask!
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var marketSegmantedControl: UISegmentedControl!
    @IBOutlet weak var currencySegmentedControl: UISegmentedControl!
    
    // MARK: - IBActions
    @IBAction func reload(sender: AnyObject) {
        clear()
        let completion: ([AnyObject])->() = { results in
            if let banks = results as? [Bank] {
                self.banks = banks
                self.tableView.reloadData()
            }
        }
        task = Downloader.load(completion)
    }
    
    @IBAction func currencySegmentControlChanged(sender: UISegmentedControl) {
        sortBanks()
    }
    
    @IBAction func marketSegmentControlChanged(sender: UISegmentedControl) {
        sortBanks()
        tableView.reloadData()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 64, right: 0)
        tableView.rowHeight = 88
    }
    
    // MARK: - Helpers
    private func clear() {
        if task != nil { task.cancel() }
        banks = [Bank]()
        tableView.reloadData()
    }
    
    func sortBanks() {
        if !banks.isEmpty {
            banks.sort({ (bank1: Bank, bank2: Bank) -> Bool in
                switch self.currencySegmentedControl.selectedSegmentIndex {
                case 1:
                    switch self.marketSegmantedControl.selectedSegmentIndex {
                    case 1: return bank1.usdSell > bank2.usdSell
                    default: return bank1.usdBuy > bank2.usdBuy
                    }
                case 2:
                    switch self.marketSegmantedControl.selectedSegmentIndex {
                    case 1: return bank1.eurSell > bank2.eurSell
                    default: return bank1.eurBuy > bank2.eurBuy
                    }
                    
                    
                case 3:
                    switch self.marketSegmantedControl.selectedSegmentIndex {
                    case 1: return bank1.eurSell < bank2.eurSell
                    default: return bank1.eurBuy < bank2.eurBuy
                    }

                    
                default:
                    switch self.marketSegmantedControl.selectedSegmentIndex {
                    case 1: return bank1.usdSell < bank2.usdSell
                    default: return bank1.usdBuy < bank2.usdBuy
                    }
                }
                
            })
            tableView.reloadData()
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showBank":
                if let cell = sender as? UITableViewCell {
                    if let indexPath = tableView.indexPathForCell(cell) {
                        let bank = banks[indexPath.row]
                        if let controller = segue.destinationViewController as? BankDetailViewController {
                            controller.bank = bank
                        }
                    } else {
                        println("Cann't get indexPath for UITableViewCell")
                    }
                } else {
                    println("Unknown type of sender in \(__FUNCTION__)")
                }
            default:
                println("Unknown identifier: \(identifier)")
                break
            }
        }
    }
}

extension FirstViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
extension FirstViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell: UITableViewCell
        if let aux = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell {
            cell = aux
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifier)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        let bank = banks[indexPath.row]
        makeTitle(bank, label: cell.textLabel!)
        makeSubTitle(bank, label: cell.detailTextLabel!)
        return cell
    }
    
    // MARK: UITableViewDataSource Helper
    func makeTitle(bank: Bank, label: UILabel) {
        let name = bank.name.uppercaseString
        let address = bank.address.capitalizedString
        label.text = String(format: "%@\n(%@)", name, address)
    }
    
    func makeSubTitle(bank: Bank, label: UILabel) {
        label.text = bank.subtitle!
    }
    
    func getformatUSDString(bank: Bank) -> String {
        switch marketSegmantedControl.selectedSegmentIndex {
        case 1:
            let format = "Покупка USD %.2f"
            return String(format: format, bank.usdBuy)
        default:
            let format = "Продажа USD %.2f"
            return String(format: format, bank.usdSell)
        }
        
    }
    
    func getformatEURString(bank: Bank) -> String {
        switch marketSegmantedControl.selectedSegmentIndex {
        case 1:
            let format = "Покупка EUR %.2f"
            return String(format: format, bank.eurBuy)
        default:
            let format = "Продажа EUR %.2f"
            return String(format: format, bank.eurSell)
        }
        
    }
}
