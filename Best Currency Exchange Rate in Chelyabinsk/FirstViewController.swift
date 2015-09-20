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

    enum SortingCases {
        case BuyUSD([Bank])
        case SellUSD([Bank])
        case BuyEUR([Bank])
        case SellEUR([Bank])
        
        var entityValue: [Bank] {
            switch self {
            case .BuyEUR(var list):
                list.sort({ (b1: Bank, b2: Bank) -> Bool in return b1.eurSell < b2.eurSell })
                return list
            case .SellEUR(var list):
                list.sort({ (b1: Bank, b2: Bank) -> Bool in return b1.eurBuy > b2.eurBuy })
                return list
            case .BuyUSD(var list) :
                list.sort({ (b1: Bank, b2: Bank) -> Bool in return  b1.usdSell < b2.usdSell })
                return list
            case .SellUSD(var list):
                list.sort({ (b1: Bank, b2: Bank) -> Bool in return b1.usdBuy > b2.usdBuy })
                return list
            }
        }
    }
    
    // MARK: - Properties
    var banks = [Bank]()
    var task: NSURLSessionDataTask!
    var sortingCase: SortingCases!
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencySegmentedControl: UISegmentedControl!
    
    // MARK: - IBActions
    @IBAction func reload(sender: AnyObject) {
        clear()
        let completion: ([AnyObject])->() = { results in
            if let banks = results as? [Bank] {
                self.banks = banks
                self.sortBanks()
            }
        }
        task = Downloader.load(completion)
    }
    
    @IBAction func currencySegmentControlChanged(sender: UISegmentedControl) {
        sortBanks()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Домой"
//        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 64, right: 0)
        tableView.rowHeight = 64
        sortingCase = SortingCases.BuyUSD(banks)
        reloadAfterSorting()
    }
    
    // MARK: - Helpers
    private func clear() {
        if task != nil { task.cancel() }
        banks = [Bank]()
        tableView.reloadData()
    }
    
    func reloadAfterSorting() {
        banks = sortingCase.entityValue
        tableView.reloadData()
    }
    
    func sortBanks() {
        switch currencySegmentedControl.selectedSegmentIndex {
        case 0: // Пользователь хочет купить USD
            sortingCase = SortingCases.BuyUSD(banks)
            reloadAfterSorting()
        case 1: // Пользователь хочет продать USD
            sortingCase = SortingCases.SellUSD(banks)
            reloadAfterSorting()
        case 2: // Пользователь хочет купить EUR
            sortingCase = SortingCases.BuyEUR(banks)
            reloadAfterSorting()
        case 3: // Пользователь хочет продать USD
            sortingCase = SortingCases.SellEUR(banks)
            reloadAfterSorting()
        default: println("Unknown case. (currencySegmentedControl): \(currencySegmentedControl)")
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
        label.text = getformatString(bank)
    }
    
    func getformatString(bank: Bank) -> String {
        switch currencySegmentedControl.selectedSegmentIndex {
        case 0:
            let format = "1 USD = %.2fP"
            return String(format: format, bank.usdSell)
        case 1:
            let format = "1 USD = %.2fP"
            return String(format: format, bank.usdBuy)
        case 2:
            let format = "1 EUR = %.2fP"
            return String(format: format, bank.eurSell)
        case 3:
            let format = "1 EUR = %.2fP"
            return String(format: format, bank.eurBuy)
        default: println("Unknown selectedSegment: \(currencySegmentedControl.selectedSegmentIndex)")
        }
        return ""
    }
    
}
