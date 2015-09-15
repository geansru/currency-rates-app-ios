//
//  Bank.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class Bank {
    var usdSell: Double = 0.0
    var usdBuy: Double = 0.0
    var eurSell: Double = 0.0
    var eurBuy: Double = 0.0
    var address = ""
    var name = ""
    var uri = ""
    var phones = [String]()
    var workingHours = ""
    
    init() { }
    init(table: XMLElement) {
        parseData(table)
    }
    
    private func makeDouble(text: String!) -> Double {
        var result: Double = 0.0
        if let value = text { result = (text as NSString).doubleValue }
        return result
    }
    private func parseBankRequisites(element: XMLElement) {
        if let text = element.text {
//            println(__FUNCTION__)
            // Get bank name
            let link = element.css("a")
            if let a = link.first {
                uri = a["href"]!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                name = a.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            
            // Get bank address
            let p = element.css("p")
            if let spans = p.first?.css("span") {
                if spans.count == 1 {
                    let whiteSpaces = NSCharacterSet.whitespaceCharacterSet()
                    let crap = NSCharacterSet(charactersInString: "на карте")
                    address = p.text!.stringByTrimmingCharactersInSet(whiteSpaces).stringByTrimmingCharactersInSet(crap)
                } else if spans.count == 2 {
                    if let span = spans.first {
                        address = span.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    }
                }
            }
            println(address)
            
            // Get bank working hours
            if let div = element.css("div").first {
                let whiteSpaces = NSCharacterSet.whitespaceCharacterSet()
                let crap = NSCharacterSet(charactersInString: "Режим работы:")
                workingHours = div.text!.stringByTrimmingCharactersInSet(crap)
                workingHours = workingHours.stringByTrimmingCharactersInSet(whiteSpaces)
            }
            if workingHours.isEmpty {
                workingHours = "Не известно"
            }
            println(workingHours)
        }
    }
    
    private func parseData(table: XMLElement) {
        if let cls = table.className {
            if cls == "table_sales table_border_right" {
                for row in table.css("tr") {
                    for td in row.css("td") {
                        if let td_css_class = td.className {
                            var counter = 0
                            switch td_css_class {
                            case "block_position_center":
                                switch counter {
                                case 0: usdSell = makeDouble(td.text)
                                case 1: usdBuy = makeDouble(td.text)
                                case 2: eurSell = makeDouble(td.text)
                                case 3: eurBuy = makeDouble(td.text)
                                default: break
                                }
                                counter++
                            case "name_bank": parseBankRequisites(td)
                            default: break
                            }
                        }
                    }
                }
            }
        }
    }
    
}