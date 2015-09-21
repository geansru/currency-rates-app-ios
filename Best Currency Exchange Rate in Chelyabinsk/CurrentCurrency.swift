//
//  EUR.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 20.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class CurrentCurrency: Currency {
    enum Currency {
        case USD
        case EUR
        
        var entityValue: String {
            switch self {
            case .EUR: return "R01239"
            default: return "R01235"
            }
        }
    }
    
    override init(element: XMLElement) {
        super.init(element: element)
        super.nominal = 1
        parse(element)
        //        if !DEBUG { println(super.description()) }
    }
    
    func parse(element: XMLElement) {
        /*
        <Record Date="02.03.2001" Id="R01235"><Nominal>1</Nominal><Value>28,6200</Value></Record>
        */
        
        if let aux = element["Date"] {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            if let date = dateFormatter.dateFromString(aux) { super.date = date }
        }
        if let aux = element.xpath("Value").text { super.value = super.makeDouble(aux) }
    }
}