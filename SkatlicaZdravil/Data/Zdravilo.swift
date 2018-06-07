//
//  Zdravilo.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 17/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class Zdravilo: NSObject, NSCopying, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(pill_img, forKey: "pill_img")
        aCoder.encode(box_img, forKey: "box_img")
        aCoder.encode(lasting, forKey: "lasting")
        aCoder.encode(dose, forKey: "dose")
        aCoder.encode(form, forKey: "form")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(frequency, forKey: "frequency")
        aCoder.encode(additionalRules, forKey: "additionalRules")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let pill_img = aDecoder.decodeObject(forKey: "pill_img") as! String
        let box_img = aDecoder.decodeObject(forKey: "box_img") as! String
        let lasting = aDecoder.decodeObject(forKey: "lasting") as! DateInterval
        let dose = aDecoder.decodeObject(forKey: "dose") as! String
        let form = aDecoder.decodeObject(forKey: "form") as! String
        let time = aDecoder.decodeObject(forKey: "time") as! [Date]
        let frequency = aDecoder.decodeObject(forKey: "frequency") as! String
        let additionalRules = aDecoder.decodeObject(forKey: "additionalRules") as! [String]
        self.init(id: id, name: name, pill_img: pill_img, box_img: box_img, lasting: lasting, dose: dose, form: form, time: time, frequency: frequency, additionalRules: additionalRules)
    }
    
    
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
        let copy = Zdravilo(id: id, name: name, pill_img: pill_img, box_img: box_img, startDate: start, endDate: end, dose: dose, form: form, time: timeStr, frequency: frequency, additionalRules: additionalRules)
        return copy
    }
    
    
    //MARK: Properties
    var id: Int
    var name: String
    var pill_img: String
    var box_img: String
    var lasting: DateInterval
    var dose: String
    var form: String
    var time: [Date]
    var frequency: String
    var additionalRules: [String]
    
    //MARK: Initialization
    init(id: Int, name: String, pill_img: String, box_img: String, startDate: String, endDate: String, dose: String, form: String, time: [String], frequency: String, additionalRules: [String] = []) {
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
        self.id = id
        self.name = name
        self.pill_img = pill_img
        self.box_img = box_img
        self.lasting = DateInterval(start: start!, end: end!)
        self.dose = dose
        self.form = form
        self.time = newTime
        self.frequency = frequency
        self.additionalRules = additionalRules
    }
    
    init(id: Int, name: String, pill_img: String, box_img: String, lasting: DateInterval, dose: String, form: String, time: [Date], frequency: String, additionalRules: [String] = []) {
        
        self.id = id
        self.name = name
        self.pill_img = pill_img
        self.box_img = box_img
        self.lasting = lasting
        self.dose = dose
        self.form = form
        self.time = time
        self.frequency = frequency
        self.additionalRules = additionalRules
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
