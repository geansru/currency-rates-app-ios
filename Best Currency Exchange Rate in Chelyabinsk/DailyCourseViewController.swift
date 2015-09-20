//
//  DailyCourseViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class DailyCourseViewController: UITableViewController {

    var setCBRF: CurrencySet!
    @IBOutlet weak var dailyUSDLabel: UILabel!
    @IBOutlet weak var dailyEURLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        getCourse()
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
    
    func updateUI() {
        println(__FUNCTION__)
        dailyUSDLabel.text = setCBRF?.getUSDCourse().description
        dailyEURLabel.text = setCBRF?.getEURCourse().description
    }
    private func getCourse() {
        let d = Downloader()
        d.sourse = Downloader.Sourse.CBRFDaily
        let onReady: ([AnyObject])->() = { result in
            if let aux = result as? [CurrencySet] {
                if let aux_set = aux.first {
                    if DEBUG { println("\(__FUNCTION__): in closure onReady: ")}
                    self.setCBRF = aux_set
                }
            }
            if let set = self.setCBRF { self.updateUI() }
        }
        d.download(onReady)

    }
}
