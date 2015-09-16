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
    @IBAction func reload(sender: AnyObject) {
        clear()
        load()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        load()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 64, right: 0)
    }
    
    // MARK: - Helpers
    private func load() {
        let d = Downloader()
        let completion: ([AnyObject])->() = { results in
            if let banks = results as? [Bank] {
                self.banks = banks
                self.tableView.reloadData()
            }
        }
        task = d.download(completion)
    }
    
    private func clear() {
        if task != nil { task.cancel() }
        banks = [Bank]()
        tableView.reloadData()
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

extension FirstViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
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
        let index = indexPath.row.description
        cell.textLabel?.text = index + ". " + bank.name
        cell.detailTextLabel?.text = bank.address
        return cell
    }
}
