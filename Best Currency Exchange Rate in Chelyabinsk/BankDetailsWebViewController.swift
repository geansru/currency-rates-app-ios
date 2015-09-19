//
//  BanDetailsWebViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class BankDetailsWebViewController: UIViewController {
    
    var path: String!
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    private func load() {
        if let path = path {
            if let url = NSURL(string: path) {
                let request: NSURLRequest = NSURLRequest(URL: url)
                webView.loadRequest(request)
            }
        }
    }
}

extension BankDetailsWebViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}