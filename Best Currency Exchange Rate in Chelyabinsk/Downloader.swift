//
//  Downloader.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class Downloader {
    
    enum Sourse {
        case Chelfin
        case CBRFDaily
        case CBRFPeriod
        case AUDITIT
        
        var entityValue: NSURL! {
            switch self {
            case .Chelfin: return NSURL(string: "http://chelfin.ru/exchange/exchange.html")
            case .CBRFDaily:
                //"http://www.cbr.ru/currency_base/daily.aspx?date_req=15.09.2015"
                return NSURL(string: "http://www.cbr.ru/scripts/XML_daily.asp")
            default: return NSURL(string: "http://chelfin.ru/exchange/exchange.html")
            }
        }
    }
    
    var sourse: Sourse = Sourse.Chelfin
    private var dataTask:  NSURLSessionDataTask!
    let parameters: [Sourse: AnyObject] = [
        Sourse.Chelfin: ["encoding": NSWindowsCP1251StringEncoding, "elementName": "//table", "cssClass": "table_sales table_border_right"],
        Sourse.CBRFDaily: ["encoding": NSWindowsCP1251StringEncoding, "elementName": "//table", "cssClass": "table_sales table_border_right"]
    ]
    init() {
    }

    init(sourse: Sourse) {
        self.sourse = sourse
    }
    
    deinit {
        if dataTask != nil { dataTask.cancel() }
    }
    
    private func parseBanksData(data: NSData, completion: ([AnyObject])->()){
        if let html = NSString(data: data, encoding: NSWindowsCP1251StringEncoding) {
            if let doc = HTML(html: html as! String, encoding: NSWindowsCP1251StringEncoding) {
                if DEBUG { println(doc.title) }
                // Search for nodes by XPath
                for table in doc.xpath("//table") {
                    if let cls = table.className {
                        if cls == "table_sales table_border_right" {
                            let banks: Banks = Banks(table: table)
                            dispatch_async(dispatch_get_main_queue()) {

                                completion(banks.banks)
                            }
                        }
                    }
                }
            }
        } else {
            println("Cann't convert NSData to NSString")
        }
    }
    
    private func parseCoursesData(data: NSData, completion: ([AnyObject])->()){
        if let html = NSString(data: data, encoding: NSWindowsCP1251StringEncoding) {
            if let doc = HTML(html: html as! String, encoding: NSWindowsCP1251StringEncoding) {
                if DEBUG { println(doc.title) }
                // Search for nodes by XPath
                for table in doc.xpath("//div") {
                    if let cls = table.className {
                        if cls == "kurs-header rounded-block" {
                            let banks: Banks = Banks(table: table)
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                completion(banks.banks)
                            }
                        }
                    }
                }
            }
        } else {
            println("Cann't convert NSData to NSString")
        }
    }
    
    func download(completion: ([AnyObject])->()) -> NSURLSessionDataTask {
        
        let session = NSURLSession.sharedSession()
        dataTask = session.dataTaskWithURL(sourse.entityValue!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let error = error {
                println(error)
                abort()
            }
            if let response = response as? NSHTTPURLResponse {
                if response.statusCode != 200 { println("Error: \(response.statusCode)") }
            }
            if let data = data {
                switch self.sourse {
                case .Chelfin: self.parseBanksData(data, completion: completion)
                case .CBRFDaily: self.parseCoursesData(data, completion: completion)
                default: println("Unallowed choice of sourse: \(self.sourse)")
                }
                
            } else {
                println("Received data parameter is nil")
            }
        })
        
        dataTask.resume()
        return dataTask
    }
    
    static func load(completion: ([AnyObject])->()) -> NSURLSessionDataTask {
        let d = Downloader()
        
        return d.download(completion)
    }
}