//
//  Downloader.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class Downloader {
    
    var url: NSURL!
    //"http://www.cbr.ru/currency_base/daily.aspx?date_req=15.09.2015"
    //http://www.cbr.ru/scripts/XML_daily.asp
    private var dataTask:  NSURLSessionDataTask!
    init() {
        url = NSURL(string: "http://chelfin.ru/exchange/exchange.html")
    }

    init(url: NSURL!) {
        self.url = url
    }
    
    deinit {
        if dataTask != nil { dataTask.cancel() }
    }
    
    private func parseBanksData(data: NSData, completion: ([AnyObject])->()){
        if let html = NSString(data: data, encoding: NSWindowsCP1251StringEncoding) {
            if let doc = HTML(html: html as! String, encoding: NSWindowsCP1251StringEncoding) {
                println(doc.title)
                // Search for nodes by XPath
                for table in doc.xpath("//table") {
                    if let cls = table.className {
                        if cls == "table_sales table_border_right" {
                            let banks: Banks = Banks(table: table)
                            dispatch_async(dispatch_get_main_queue()) {
//                                println("Count: \(banks.banks.count)")
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
        dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let error = error {
                println(error)
                abort()
            }
            if let response = response as? NSHTTPURLResponse {
                if response.statusCode != 200 { println("Error: \(response.statusCode)") }
            }
            if let data = data {
                self.parseBanksData(data, completion: completion)
            } else {
                println("Received data parameter is nil")
            }
        })
        
        dataTask.resume()
        return dataTask
    }
}