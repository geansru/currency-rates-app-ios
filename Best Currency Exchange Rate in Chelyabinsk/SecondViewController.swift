//
//  SecondViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    let path = "https://dwq4do82y8xi7.cloudfront.net/widgetembed/?symbol=FX_IDC%3AUSDRUB&interval=3&saveimage=0&toolbarbg=f1f3f6&studies=&hideideas=1&theme=White&style=1&timezone=Europe%2FMoscow&studies_overrides=%7B%7D&overrides=%7B%7D&enabled_features=%5B%5D&disabled_features=%5B%5D&locale=ru&utmsource=www.sberometer.ru&utmmedium=www.sberometer.ru/forex-now.php"
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        title = "Мгновенный курс доллара на Forex"
        webView.delegate = self
    }

    func load() {
        if let url = NSURL(string: path) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
}

extension SecondViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let desc = request.URL?.description {
            if desc == path {
                return true
            } else {
                println(desc)
            }
        }
        return false
    }
}