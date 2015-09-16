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
    init(row: XMLElement) {
        parseRow(row)
    }
    
    private func makeDouble(var text: String!) -> Double {
        var result: Double = 0.0
        text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        text = text?.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let value = text {
//            print("'\(value)' -> ")
            result = (text as NSString).doubleValue
        }
//        println(result)
        return result
    }
    private func parseBankRequisites(element: XMLElement) {
        if let text = element.text {
            let whiteSpaces = NSCharacterSet.whitespaceCharacterSet()
            // Get bank name
            let link = element.css("a")
            if let a = link.first {
                uri = a["href"]!.stringByTrimmingCharactersInSet(whiteSpaces)
                name = a.text!.stringByTrimmingCharactersInSet(whiteSpaces)
            }
//            println(name)
            
            // Get bank address
            let p = element.css("p")
            if let spans = p.first?.css("span") {
                if spans.count == 1 {
                    let crap = NSCharacterSet(charactersInString: "на карте")
                    address = p.text!.stringByTrimmingCharactersInSet(whiteSpaces).stringByTrimmingCharactersInSet(crap)
                } else if spans.count == 2 {
                    if let span = spans.first {
                        address = span.text!.stringByTrimmingCharactersInSet(whiteSpaces)
                    }
                }
            }
//            println(address)
            
            // Get bank working hours
            if let div = element.css("div").first {
                let crap = NSCharacterSet(charactersInString: "Режим работы:")
                workingHours = div.text!.stringByTrimmingCharactersInSet(crap)
                workingHours = workingHours.stringByTrimmingCharactersInSet(whiteSpaces)
            }
            if workingHours.isEmpty {
                workingHours = "Не известно"
            }
        }
    }
    
    private func parseRow(row: XMLElement) {
        let cells = row.css("td")
        var counter = 0
        for td in cells {
            if let td_css_class = td.className {
                
                switch td_css_class {
                case "block_position_center":
                    switch counter {
                    case 0: usdBuy = makeDouble(td.text)
                    case 1: usdSell = makeDouble(td.text)
                    case 2: eurBuy = makeDouble(td.text)
                    case 3: eurSell = makeDouble(td.text); counter = 0
                    default: break
                    }
                    counter++
                case "name_bank": parseBankRequisites(td)
                default: break
                }
            } else {
                println("Unknown cell type:\n\(td.text)")
            }
        }
    }
    
    func isEmpty() -> Bool {
        var empty = false
        if address.isEmpty && name.isEmpty { empty = true }
        
        return empty
    }
}