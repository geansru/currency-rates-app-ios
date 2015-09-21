//
//  EUR.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 20.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class EUR: CurrentCurrency {
    required override init(element: XMLElement) {
        super.init(element: element)
        super.numCode = "978"
        super.charCode = "EUR"
        super.name = "Евро"
    }
}