//
//  Courses.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class Courses {
    
    var courses: [Course] = [Course]()
    var startDate: NSDate = NSDate()
    var endDate: NSDate = NSDate()
    func parse(nodes: XMLElement, sourse: Downloader.Sourse) {
        switch sourse {
        case .CBRFDaily:
            parseCurrentCourse(nodes)
        case .CBRFPeriod:
            parseArh(nodes)
        default: println("Unknown sourse type: \(sourse)")
        }
    }
    
    private func parseCurrentCourse(nodes: XMLElement) {
        
    }
    
    private func parseArh(nodes: XMLElement) {

    }
}