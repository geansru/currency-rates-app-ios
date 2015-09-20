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
        case CBRFPeriod(startDate: NSDate, finishDate: NSDate, code: String)
        case AUDITIT
        
        var entityValue: NSURL! {
            switch self {
            case .Chelfin: return NSURL(string: "http://chelfin.ru/exchange/exchange.html")
            case .CBRFDaily: return NSURL(string: "http://www.cbr.ru/scripts/XML_daily.asp")
            case .CBRFPeriod(let startDate, let finishDate, let code):
                // date boilerplate: 02/03/2001
                // code boilerplate: R01235
                let urlPattern = "http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=%@&date_req2=%@&VAL_NM_RQ=%@"
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                let start = dateFormatter.stringFromDate(startDate)
                let finish = dateFormatter.stringFromDate(finishDate)
                let urlString = String(format: urlPattern, finish, start, code)
                println(urlString)
                return NSURL(string: urlString)
            default: return NSURL(string: "http://chelfin.ru/exchange/exchange.html")
            }
        }
    }
    
    var sourse: Sourse = Sourse.Chelfin
    private var dataTask:  NSURLSessionDataTask!
  
    init() {
    }

    init(sourse: Sourse) {
        self.sourse = sourse
    }
    
    deinit {
        if dataTask != nil { dataTask.cancel() }
    }
    
    // + работает
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
    
    // FIXME: Сделать загрузку курса каждые 15 минут
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
    
    private func parseCBRFData(data: NSData, completion: ([AnyObject])->()) {
        if let doc = XML(xml: data, encoding: NSWindowsCP1251StringEncoding) {
            let nodeSet = doc.xpath("Valute")
            let set = CurrencySet(root: nodeSet)
            dispatch_async(dispatch_get_main_queue()) { completion([set])}
        } else {
            println("Cann't parse NSData to XML. \(__FUNCTION__)")
        }
    }
    
    func download(completion: ([AnyObject])->()) -> NSURLSessionDataTask {
        if let url = sourse.entityValue {
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
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
                    case .CBRFDaily: self.parseCBRFData(data, completion: completion)
                    case .CBRFPeriod(_,_,_):
                        self.parseCBRFData(data, completion: completion)
                    default: println("Unallowed choice of sourse: \(self.sourse)")
                    }
                    
                } else {
                    println("Received data parameter is nil")
                }
            })
            
            dataTask.resume()
            return dataTask
        } else {
            abort()
        }
    }
    
    static func load(completion: ([AnyObject])->()) -> NSURLSessionDataTask {
        let d = Downloader()
        
        return d.download(completion)
    }
    
    static func load(sourse: Downloader.Sourse, completion: ([AnyObject])->()) -> NSURLSessionDataTask {
        let d = Downloader()
        d.sourse = sourse
        return d.download(completion)
    }
}