//
//  idViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 05/06/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import SwiftyJSON

class idViewController: UIViewController {

    var idd: String?
    @IBOutlet weak var id: UITextField!
    let usersData:UserDefaults = UserDefaults.standard
    var zdravilaNeurejena = [Zdravilo]()
    let calendar = Calendar.current
    
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
        print(a)
        if a == "a" {
            //skrbnik
            controlId = idd!
            isPatient = false
            
            self.performSegue(withIdentifier: "skrbnik", sender: self)
        }
        else {
            //pacient
            patientId = idd!
            
            do {
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
                
            } catch {
                print("Unable to read the database.")
            }
            
            self.performSegue(withIdentifier: "pacient", sender: self)
        }
        usersData.set(patientId, forKey: "patientId")
        usersData.set(controlId, forKey: "controlId")
        usersData.set(isPatient, forKey: "isPatient")
        usersData.synchronize()
        
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
            let zdravilo = Zdravilo(id: indeeks, name: data["name"].stringValue, pill_img: data["pill_img"].stringValue, box_img: data["box_img"].stringValue, startDate: data["startDate"].stringValue, endDate: data["endDate"].stringValue, dose: data["dose"].floatValue, form: data["form"].stringValue, time: [o.stringValue], frequency: data["frequency"].stringValue, additionalRules: additional)
            indeeks = indeeks + 1
            self.zdravilaNeurejena.append(zdravilo)
        }
        return indeeks
    }
}
