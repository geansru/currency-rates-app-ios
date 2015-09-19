//
//  Banks.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation
import CoreLocation
class Banks {
    var banks = [Bank]()
    init(table: XMLElement) {
        parseData(table)
    }
    
    private func parseData(table: XMLElement) {
        let rows = table.css("tr")
        var counter = 0
        for row in rows {
            let bank = Bank(row: row)
            if !bank.isEmpty() {
                banks.append(bank)
                bank.makeCoordinates()
            }
        }
    }
}