//
//  MomentaryCurrencyEUR.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 20.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class MomentaryCurrencyEUR: EUR {
    
    required init(element: XMLElement) {
        super.init(element: element)
    }
    
    override func parse(element: XMLElement) {
        if let div = element.xpath("div/div/div/a").last { value = super.makeDouble(div.text) }
        if DEBUG {
            print(__FUNCTION__); println(", class MomentaryCurrencyEUR")
            
            println(value.description)
            println()
        }
    }
}