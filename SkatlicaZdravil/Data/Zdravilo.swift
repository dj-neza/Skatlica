//
//  Zdravilo.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 17/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class Zdravilo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let dates = DateFormatter()
        dates.dateFormat = "dd.MM.yyyy"
        let start = dates.string(from: lasting.start)
        let end = dates.string(from: lasting.end)
        let times = DateFormatter()
        times.dateFormat = "HH:mm"
        //times.timeZone = TimeZone(abbreviation: "GMT")
        var timeStr = [String]()
        for i in time {
            timeStr.append(times.string(from: i))
        }
        let copy = Zdravilo(name: name, pill_img: pill_img, box_img: box_img, startDate: start, endDate: end, dose: dose, form: form, time: timeStr, frequency: frequency, additionalRules: additionalRules, taken: taken)
        return copy
    }
    
    
    //MARK: Properties
    var name: String
    var pill_img: String
    var box_img: String
    var lasting: DateInterval
    var dose: Float
    var form: String
    var time: [Date]
    var frequency: String
    var additionalRules: [String]
    var taken: Bool = false
    
    //MARK: Initialization
    init?(name: String, pill_img: String, box_img: String, startDate: String, endDate: String, dose: Float, form: String, time: [String], frequency: String, additionalRules: [String] = [], taken: Bool = false) {
        /*guard !label.isEmpty else {
            return nil
        }*/
        let dates = DateFormatter()
        dates.dateFormat = "dd.MM.yyyy"
        let start: Date? = dates.date(from: startDate)
        let end: Date? = dates.date(from: endDate)
        
        let times = DateFormatter()
        //times.timeZone = TimeZone(abbreviation: "GMT")
        times.dateFormat = "HH:mm"
        var newTime: [Date] = []
        for i in time {
            let converted: Date? = times.date(from: i)
            newTime.append(converted!)
        }
        
        self.name = name
        self.pill_img = pill_img
        self.box_img = box_img
        self.lasting = DateInterval(start: start!, end: end!)
        self.dose = dose
        self.form = form
        self.time = newTime
        self.frequency = frequency
        self.additionalRules = additionalRules
        self.taken = taken
    }
}

class Zdravila {
    var jutro: [Zdravilo]
    var dopoldne: [Zdravilo]
    var popoldne: [Zdravilo]
    var vecer: [Zdravilo]
    var overdue: [Zdravilo]
    
    init?(jutro: [Zdravilo], dopoldne: [Zdravilo], popoldne: [Zdravilo], vecer: [Zdravilo], overdue: [Zdravilo] = []) {
        self.jutro = jutro
        self.dopoldne = dopoldne
        self.popoldne = popoldne
        self.vecer = vecer
        self.overdue = overdue
    }
}

class People {
    
    //MARK: Properties
    var name: String
    var img: String
    var patientId: String
    var zdravila: [Zdravilo]
    
    //MARK: Initialization
    init?(name: String, img: String, patientId: String, zdravila: [Zdravilo]) {
        /*guard !label.isEmpty else {
         return nil
         }*/
        
        self.name = name
        self.img = img
        self.patientId = patientId
        self.zdravila = zdravila
    }
}

class Control {
    
    var controlId: String
    var pacienti: [People]
    
    //MARK: Initialization
    init?(controlId: String, pacienti: [People]) {
        /*guard !label.isEmpty else {
         return nil
         }*/
        
        self.controlId = controlId
        self.pacienti = pacienti
    }
}
