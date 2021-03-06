//
//  Currency.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 19.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class Currency: NSObject {
    
    var numCode: String // = "" //036
    var charCode: String // = "" //AUD
    var nominal: Int // = 1
    var name: String // = "" //Австралийский доллар
    var value: Double // = 0.0 //47,8832
    var date: NSDate // = NSDate()
    
    init(element: XMLElement) {
        
        date = NSDate()
        /*
        <Valute ID="R01010">
            <NumCode>036</NumCode>
            <CharCode>AUD</CharCode>
            <Nominal>1</Nominal>
            <Name>Австралийский доллар</Name>
            <Value>47,8832</Value>
        </Valute>
        */
        if let aux = element.xpath("NumCode").text { numCode = aux } else { numCode = "" }
        if let aux = element.xpath("CharCode").text { charCode = aux } else { charCode = "" }
        if let aux = element.xpath("Name").text { name = aux } else { name = "" }
        if let aux = element.xpath("Nominal").text {
            if let nominal = aux.toInt() { self.nominal = nominal} else { nominal = 1 }
        } else { nominal = 1 }
        value = 0.0
        super.init()
        if let aux = element.xpath("Value").text { value = makeDouble(aux) }
        if DEBUG { println(desc()) }
    }
    
    func desc() -> String {
        return  "numCode: \(numCode)\n" +
                "charCode: \(charCode)\n" +
                "nominal: \(nominal)\n" +
                "name: \(name)\n" +
                "value: \(value)\n"
    }
    
    func makeDouble(var text: String!) -> Double {
        var result: Double = 0.0
        text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        text = text?.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let value = text { result = (text as NSString).doubleValue }
        return result
    }
}