//
//  DailyCourseViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class DailyCourseViewController: UITableViewController {

    var courseUSD: Double!
    var courseEUR: Double!
    var template: String = "%.2fР"
    @IBOutlet weak var dailyUSDLabel: UILabel!
    @IBOutlet weak var dailyEURLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Helper

}
