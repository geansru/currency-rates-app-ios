//
//  Bank.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import CoreLocation
import MapKit


class Bank: NSObject, MKAnnotation {
    var usdSell: Double = 0.0
    var usdBuy: Double = 0.0
    var eurSell: Double = 0.0
    var eurBuy: Double = 0.0
    var address = ""
    var name = ""
    var uri = ""
    var phones = [String]()
    var workingHours = ""
    var placemark: CLPlacemark! {
        didSet {
            coordinate = placemark.location.coordinate
        }
    }
    override init() { }
    init(row: XMLElement) {
        super.init()
        parseRow(row)
    }
    
    // MKAnnotation
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var title: String! {
        if address.isEmpty {
            return "(No Description)"
        } else {
            return address + "\nТелефоны: " + ", ".join(phones)
        }
    }
    
    var subtitle: String! {
        let formatUSDString = "Покупка/Продажа USD %.2f/%.2f"
        let usd = String(format: formatUSDString, usdBuy, usdSell)
        let formatEURString = "Покупка/Продажа EUR %.2f/%.2f"
        let eur = String(format: formatEURString, eurBuy, eurSell)
        let result = String(format: "%@\n%@ ", usd, eur)
        return result
    }
    // Helpers
    
    func makeCoordinates() {
        let geocoder = Geocoder()
        let completion: (CLPlacemark)->() = { placemark in self.placemark = placemark }
        geocoder.startGeocoding(address, completion: completion)
    }
    private func parseAddressString(string: String) -> (String, [String]) {
        var phones_array = [String]()
        var address_result = ""
        
        let aux = string.componentsSeparatedByString(", ")
        if aux.count >= 2 {
            address_result = aux[0]
            let prefix = NSCharacterSet(charactersInString: "8 (351)")
            let whiteSpaces = NSCharacterSet.whitespaceCharacterSet()

            for var i: Int = 1; i < aux.count; i++ {
                var e = aux[i]
                let elements = e.componentsSeparatedByString(" ")
                var element = " ".join(elements[2..<elements.count])
                element = element.stringByTrimmingCharactersInSet(whiteSpaces)
                phones_array.append(element)
            }
        }
        if DEBUG {
            println(address_result)
            println(phones_array)
            println("\n")
        }
        return (address_result, phones_array)
    }
    private func parseAddressNodeSet(p: XMLNodeSet) -> (String, [String]) {
        var phones_array = [String]()
        var address_result = ""
        if let spans = p.first?.css("span") {
            let whiteSpaces = NSCharacterSet.whitespaceCharacterSet()
            if spans.count == 1 {
                let crap = NSCharacterSet(charactersInString: "на карте")
                address_result = p.text!.stringByTrimmingCharactersInSet(whiteSpaces).stringByTrimmingCharactersInSet(crap)
            } else if spans.count == 2 {
                if let span = spans.first {
                    address_result = span.text!.stringByTrimmingCharactersInSet(whiteSpaces)
                }
            }
        }
        if !address_result.isEmpty { return parseAddressString(address_result) }
        
        return (address_result, phones_array)
    }

    private func makeDouble(var text: String!) -> Double {
        var result: Double = 0.0
        text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        text = text?.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let value = text { result = (text as NSString).doubleValue }
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
            
            // Get bank address
            let p = element.css("p")
            let geo = parseAddressNodeSet(p)
            address = geo.0
            phones = geo.1
            
            
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
                    case 3: eurSell = makeDouble(td.text);
                    default: break
                    }
                    counter++
                    if counter > 3 { counter = 0 }
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