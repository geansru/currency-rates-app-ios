//
//  CurrencySet.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 19.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//
import Foundation
class CurrencySet {
    var set = [Currency]()
    
    
    init(root: XMLNodeSet) {
        parser(root)
    }
    
    private func parser(root: XMLNodeSet) {
        for element in root {
            let valute = Currency(element: element)
            set.append(valute)
        }
    }
    
    private func parseDateFromString(date: String) -> NSDate {
        println(date)
        return NSDate()
    }
    
    func getUSDCourse() -> Double! {
        if let valute = set.filter({ (element: Currency) -> Bool in return element.charCode == "USD" }).first {
            return valute.value
        }
        
        return nil
    }
    
    func getEURCourse() -> Double! {
        if let valute = set.filter({ (element: Currency) -> Bool in return element.charCode == "EUR" }).first {
            return valute.value
        }
        return nil
    }
}