//
//  CurrencySet.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 19.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//
import Foundation
class CurrencySet {
    var set: [Currency]
    var annotation: String!
    
    init(nodeSet: XMLNodeSet, sourse: DownloaderSourse) {
        set = [Currency]()
        switch sourse {
        case .AUDITIT: parseMomentaryCourse(nodeSet)
        case .CBRFPeriod(_,_,let code):
            switch code {
            case "R01239": parsePeriodEUR(nodeSet)
            default: parsePeriodUSD(nodeSet)
            }
        default: parserDaily(nodeSet); println("DEBUG")
        }
    }
    
    init(nodeSet: XMLNodeSet) {
        set = [Currency]()
        parserDaily(nodeSet)
    }
    
    private func trim(str: String) -> String {
        return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    private func getAnnotation(p: XMLNodeSet) -> String {
        var result = ""
        if let aux = p.text {
            let trimmed = trim(aux)
            let exploded = trimmed.componentsSeparatedByString("\n")
            if let first = exploded.first { result = trim(first) }
            if DEBUG {
//                for e in exploded { println("'\(e)'") }
                println(result)
            }
        }
        return result
    }
    
    func parseMomentaryCourse(nodeSet: XMLNodeSet) {
        // Search for nodes by XPath
        for table in nodeSet {
            if let cls = table.className {
                if cls == "kurs-header rounded-block" {
                    let p = table.xpath("p")
                    annotation = getAnnotation(p)
                    let usd = MomentaryCurrencyUSD(element: table)
                    set.append(usd)
                    let eur = MomentaryCurrencyEUR(element: table)
                    set.append(eur)
                }
            }
        }
    }

    private func parsePeriodEUR(nodeSet: XMLNodeSet) {
        for element in nodeSet {
            let valute = EUR(element: element)
            set.append(valute)
        }
    }
    
    private func parsePeriodUSD(nodeSet: XMLNodeSet) {
        for element in nodeSet {
            let valute = USD(element: element)
            set.append(valute)
        }
    }
    
    private func parserDaily(nodeSet: XMLNodeSet) {
        for element in nodeSet {
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