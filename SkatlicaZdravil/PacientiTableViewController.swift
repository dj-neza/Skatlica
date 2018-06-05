//
//  PacientiTableViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 29/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import SwiftyJSON

class PacientiTableViewController: UITableViewController {

    var people = [People]()
    var zdravilaUD = [Zdravilo]()
    let usersData:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPeople()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ZdraviloTableViewCell", for: indexPath) as? ZdraviloTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProfileTableViewCell.")
        }
        
        let people1 = people[indexPath.row]
        cell.pillImg.image = UIImage(named: people1.img)
        cell.pillLabel.text = people1.name
        
        return cell
    }
    
    //MARK: Private Methods
    private func loadPeople() {
        let userId = usersData.value(forKey: "controlId") as? String
        print(userId)
        let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
        do {
            let database = try Data(contentsOf: dataPath!)
            let data = try JSON(data: database)
            for (_, object) in data["skrbniki"] {
                if (object["id"].stringValue == userId) {
                    for (_, sth) in object["pacienti"] {
                        for (_, clovek) in data["starejsi"] {
                            if (clovek["id"].stringValue == sth.stringValue) {
                                let dude = dataToPeople(data: clovek)
                                self.people.append(dude)
                            }
                        }
                    }
                }
            }
        } catch {
            print("Unable to read the database.")
        }
        
        /*let img = "human"
        guard let people1 = People(name: "Joze", img: img, patientId: "1234", zdravila: []) else {
            fatalError("Unable to create profile")
        }
        
        people += [people1]*/
    }
    
    func dataToPeople(data: JSON) -> People {
        var zdravila = [Zdravilo]()
        zdravilaUD = [Zdravilo]()
        var takenBase = [String : Bool]()
        var indeeks = 0
        var ind = 0
        for (_, zd) in data["zdravila"] {
            let zdravilo = dataToZdravilo(data: zd, ind: indeeks)
            ind = dataToZdravilo2(data: zd, ind: ind)
            indeeks = indeeks + 1
            zdravila.append(zdravilo)
        }
        for l in 0...ind {
            takenBase[String(l)] = false
        }
        let idd = data["id"].stringValue + "_zdravila"
        let idd2 = data["id"].stringValue + "_taken"
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: zdravilaUD)
        usersData.set(encodedData, forKey: idd)
        usersData.set(takenBase, forKey: idd2)
        usersData.synchronize()
        print(zdravila)
        print(zdravilaUD)
        let result = People(name: data["name"].stringValue, img: data["img"].stringValue, patientId: data["id"].stringValue, zdravila: zdravila)
        return result!
    }
    func dataToZdravilo(data: JSON, ind: Int) -> Zdravilo {
        var time: [String] = []
        for (_, o) in data["time"] {
            time.append(o.stringValue)
        }
        var additional: [String] = []
        for (_, o2) in data["additionalRules"] {
            additional.append(o2.stringValue)
        }
        let result = Zdravilo(id: ind, name: data["name"].stringValue, pill_img: data["pill_img"].stringValue, box_img: data["box_img"].stringValue, startDate: data["startDate"].stringValue, endDate: data["endDate"].stringValue, dose: data["dose"].floatValue, form: data["form"].stringValue, time: time, frequency: data["frequency"].stringValue, additionalRules: additional)
        return result
    }
    func dataToZdravilo2(data: JSON, ind: Int) -> Int {
        var indeeks = ind
        var additional: [String] = []
        for (_, o2) in data["additionalRules"] {
            additional.append(o2.stringValue)
        }
        for (_, o) in data["time"] {
            let zdravilo = Zdravilo(id: indeeks, name: data["name"].stringValue, pill_img: data["pill_img"].stringValue, box_img: data["box_img"].stringValue, startDate: data["startDate"].stringValue, endDate: data["endDate"].stringValue, dose: data["dose"].floatValue, form: data["form"].stringValue, time: [o.stringValue], frequency: data["frequency"].stringValue, additionalRules: additional)
            indeeks = indeeks + 1
            self.zdravilaUD.append(zdravilo)
        }
        return indeeks
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "patientZdravila") {
            let indexPath: IndexPath = (tableView?.indexPathForSelectedRow)!
            let destViewController = segue.destination as? AdhViewController
            let people1 = peopleForIndexPath(indexPath)
            destViewController!.people1 = people1
        }
    }
    
    func peopleForIndexPath(_ indexPath: IndexPath) -> People {
        return people[indexPath.row]
    }

}

