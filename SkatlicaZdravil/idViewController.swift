//
//  idViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 05/06/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications
import SwiftHTTP

class idViewController: UIViewController {

    var idd: String?
    @IBOutlet weak var id: UITextField!
    let usersData:UserDefaults = UserDefaults.standard
    var zdravilaNeurejena = [Zdravilo]()
    let calendar = Calendar.current
    let httpRequest = "http://openep.thinkmed.marand.si:8191/rest/api/discharge/"
    let summary = "summary?patientId="
    let list = "list?patientId="
    let pills: [String: String] = ["Aspirin": "aspirin", "Ibuprofen": "ibuprofen", "Medocodene 30mg/500mg effervescent tablets (Mylan)": "medocodene", "Morphine 10mg tablets": "morphine10", "Morphine 5mg capsules": "morphine5", "Warfarin": "warfarin", "Paracetamol 500 mg tablet": "paracetamol500", "Paracetamol 125mg suppositories": "paracetamol125"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func vnosId(_ sender: Any) {
        let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
        self.idd = id.text
        var patientId = "2"
        var controlId = "a1"
        var isPatient = true
        let a = idd![(idd?.startIndex)!]
        if a == "a" {
            //skrbnik
            controlId = idd!
            isPatient = false
            usersData.set(patientId, forKey: "patientId")
            usersData.set(controlId, forKey: "controlId")
            usersData.set(isPatient, forKey: "isPatient")
            usersData.synchronize()
            self.performSegue(withIdentifier: "skrbnik", sender: self)
        }
        else {
            //pacient
            patientId = idd!
            
            if (patientId == "444") {
                let request = httpRequest + list + patientId
                HTTP.GET(request) { response in
                    if let err = response.error {
                        print("error: \(err.localizedDescription)")
                        return
                    }
                    let data = response.data
                    var json = [String: Any]()
                    var array = [[String: Any]]()
                    var human = [String: Any]()
                    human["id"] = patientId
                    human["name"] = "Petra Novak"
                    human["img"] = "female"
                    human["zdravila"] = self.convert(data1: data)
                    array.append(human)
                    json["starejsi"] = array
                    var jsonForma = JSON(json)
                    print(jsonForma)
                    self.merge(json: jsonForma)
                    self.readDatabase(patientId: patientId, controlId: controlId, isPatient: isPatient)
                    
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "pacient", sender: self)
                    }
                }
            }
            else {
                readDatabase(patientId: patientId, controlId: controlId, isPatient: isPatient)
                
                self.performSegue(withIdentifier: "pacient", sender: self)
            }
        }
        usersData.set(patientId, forKey: "patientId")
        usersData.set(controlId, forKey: "controlId")
        usersData.set(isPatient, forKey: "isPatient")
        usersData.synchronize()
        
    }
    
    func readDatabase(patientId: String, controlId: String, isPatient: Bool) {
        do {
            let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
            let database = try Data(contentsOf: dataPath!)
            let data = try JSON(data: database)
            var takenBase = [String : Bool]()
            let overdue = [Int]()
            var indeeks = 0
            for (_, object) in data["starejsi"] {
                if (object["id"].stringValue == patientId) {
                    for (_, data) in object["zdravila"] {
                        indeeks = dataToZdravilo(data: data, ind: indeeks)
                    }
                }
            }
            for l in 0...indeeks {
                takenBase[String(l)] = false
            }
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: zdravilaNeurejena)
            usersData.set(encodedData, forKey: "zdravila")
            usersData.set(takenBase, forKey: "taken")
            usersData.set(overdue, forKey: "overdue")
            let jutro = zdravilaRazporedi(timeStart: 6, timeEnd: 9)
            let dopoldne = zdravilaRazporedi(timeStart: 9, timeEnd: 12)
            let popoldne = zdravilaRazporedi(timeStart: 12, timeEnd: 18)
            let vecer = zdravilaRazporedi(timeStart: 18, timeEnd: 24)
            usersData.set(jutro, forKey: "jutro")
            usersData.set(dopoldne, forKey: "dopoldne")
            usersData.set(popoldne, forKey: "popoldne")
            usersData.set(vecer, forKey: "vecer")
            usersData.set(patientId, forKey: "patientId")
            usersData.set(controlId, forKey: "controlId")
            usersData.set(isPatient, forKey: "isPatient")
            usersData.synchronize()
            configureReminders()
            
        } catch {
            print("Unable to read the database.")
        }
    }
    
    func convert(data1:Data) -> Any {
        let dataPath = Bundle.main.url(forResource: "json2", withExtension: "json")
        do {
            let database = try Data(contentsOf: dataPath!)
            let data = try JSON(data: database)
            let dates = DateFormatter()
            dates.dateFormat = "dd.MM.yyyy"
            let today = Date()
            let year:TimeInterval = 60.0 * 60.0 * 24 * 365
            let oneYear = Date(timeInterval: year, since: today)
            var zdravila = [[String: Any]]()
            for (_, object) in data["items"] { //cez zdravila
                var zdravilo = [String: Any]()
                let name = object["prescription", "medication", "name"].stringValue
                let lala = name.components(separatedBy: " ")
                zdravilo["name"] = lala[0]
                zdravilo["pill_img"] = pills[name]! + "_pill"
                zdravilo["box_img"] = pills[name]! + "_box"
                zdravilo["startDate"] = dates.string(from: today)
                zdravilo["endDate"] = dates.string(from: oneYear)
                zdravilo["dose"] = object["prescription", "dose", "items", 0, "display"].stringValue
                zdravilo["form"] = object["prescription", "doseForm"].stringValue
                zdravilo["frequency"] = "dnevno"
                var arr = [String]()
                //arr.append(object["prescription", "additionalInstructions", "display"].stringValue)
                
                var arrTime = [String]()
                var timing = object["prescription", "timingDirections", "display"]
                if (timing == "2X per day") {
                    arrTime.append("09:00")
                    arrTime.append("15:00")
                }
                else if (timing == "2X per day - When needed") {
                    arrTime.append("09:00")
                    arrTime.append("15:00")
                    arr.append("po potrebi")
                }
                else if (timing == "3X per day") {
                    arrTime.append("08:00")
                    arrTime.append("12:00")
                    arrTime.append("16:00")
                }
                zdravilo["time"] = arrTime
                
                zdravilo["additionalRules"] = arr
                zdravilo["motivation"] = object["prescription", "indication", "display"].stringValue
                zdravila.append(zdravilo)
            }
            /*var jsonForma = JSON()
             jsonForma.arrayObject = zdravila
             print(jsonForma)*/
            return zdravila
        } catch {
            print("Unable to read the database.")
            return ""
        }
    }
    
    func merge(json: JSON) {
        let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
        do {
            let database = try Data(contentsOf: dataPath!)
            var data = try JSON(data: database)
            let updated = try data.merge(with: json)
            print(data)
            do {
                try data.rawData().write(to: dataPath!)
            }
            
        } catch {
            print("Unable to read the database.")
        }
    }
    
    func zdravilaRazporedi(timeStart: Int, timeEnd: Int) -> [Int] {
        var result = [Int]()
        for i in zdravilaNeurejena {
            let currentDay = Date()
            if (i.lasting.contains(currentDay)) {
                let hour = calendar.component(.hour, from: i.time[0])
                if (hour >= timeStart && hour < timeEnd) {
                    let copy = i.id //copy() as! Zdravilo
                    result.append(copy)
                }
            }
        }
        return result
    }
    
    func dataToZdravilo(data: JSON, ind: Int) -> Int {
        var indeeks = ind
        var additional: [String] = []
        for (_, o2) in data["additionalRules"] {
            additional.append(o2.stringValue)
        }
        for (_, o) in data["time"] {
            let zdravilo = Zdravilo(id: indeeks, name: data["name"].stringValue, pill_img: data["pill_img"].stringValue, box_img: data["box_img"].stringValue, startDate: data["startDate"].stringValue, endDate: data["endDate"].stringValue, dose: data["dose"].stringValue, form: data["form"].stringValue, time: [o.stringValue], frequency: data["frequency"].stringValue, additionalRules: additional)
            indeeks = indeeks + 1
            self.zdravilaNeurejena.append(zdravilo)
        }
        return indeeks
    }
    
    func configureReminders() {
        let userId = usersData.value(forKey: "patientId") as? String
        let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
        do {
            let database = try Data(contentsOf: dataPath!)
            let data1 = try JSON(data: database)
            var indeeks = 0
            for (_, object) in data1["starejsi"] {
                if (object["id"].stringValue == userId) {
                    for (_, data) in object["zdravila"] {
                        for (_, o) in data["time"] {
                            
                            let content = UNMutableNotificationContent()
                            content.title   = "Vzemi " + data["name"].stringValue + " " + data["dose"].stringValue + " " + data["form"].stringValue
                            content.body = data["motivation"].stringValue
                            content.sound = UNNotificationSound.default()
                            content.categoryIdentifier = "TIMER"
                            let img = UIImage(named: data["pill_img"].stringValue)
                            
                            if let attachement = UNNotificationAttachment.create(identifier: "img", image: img!, options: nil) {
                                content.attachments = [attachement]
                            }
                            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())//timeIntervalSinceNow: 86400))
                            let times = DateFormatter()
                            times.dateFormat = "HH:mm"
                            let converted: Date = times.date(from: o.stringValue)!
                            print(o.stringValue)
                            var dateComponents2 = Calendar.current.dateComponents([.hour, .minute], from: converted)
                            dateComponents.hour = dateComponents2.hour
                            dateComponents.minute = dateComponents2.minute
                            
                            var trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            var request = UNNotificationRequest(identifier: String(indeeks), content: content, trigger: trigger)
                            print(request)
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                            
                            
                            //Skrbnik notification
                            
                            content.title   = "Zamujeno zdravilo"
                            content.body = object["name"].stringValue + " ni vzel(a) zdravila: " + data["name"].stringValue + " ob " + o.stringValue
                            content.categoryIdentifier = "GENERAL"
                            content.attachments = []
                            dateComponents.minute = dateComponents.minute! + 1
                            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            let idd = "a"+String(indeeks)
                            request = UNNotificationRequest(identifier: idd, content: content, trigger: trigger)
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                            
                            indeeks = indeeks + 1
                        }
                    }
                }
            }
            
        } catch {
            print("Unable to read the database.")
        }
    }
}
