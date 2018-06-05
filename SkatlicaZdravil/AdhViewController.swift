//
//  AdhViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 29/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class AdhViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var peopleId: UILabel!
    @IBOutlet weak var adh: UILabel!
    @IBOutlet weak var due: UITableView!
    
    var people1: People?
    let usersData:UserDefaults = UserDefaults.standard
    let calendar = Calendar.current
    var dueData = [Int]()
    var zdravila = [Zdravilo]()
    var zdravilaId: String?
    var takenId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.img.image = UIImage(named: (people1?.img)!)
        self.name.text = people1?.name
        self.peopleId.text = "Id: " + (people1?.patientId)!
        self.adh.text = "100 %"
        zdravilaId = (people1?.patientId)! + "_zdravila"
        takenId = (people1?.patientId)! + "_taken"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let taken = usersData.value(forKey: "taken") as? [String: Bool]
        let decoded  = usersData.object(forKey: zdravilaId!) as! Data
        zdravila = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Zdravilo]
        let currentTime = Date()
        let hour = calendar.component(.hour, from: currentTime)
        
        dueData = [Int]()
        var duePills = 0
        for i in zdravila {
            let hour1 = calendar.component(.hour, from: i.time[0])
            if (hour1 < hour) {
                duePills = duePills+1
                if (taken![String(i.id)] == false) {
                    dueData.append(i.id)
                }
            }
        }
        due.reloadData()
        var adherenca = 100
        if (duePills != 0) {
            adherenca = 100 - ((dueData.count * 100)/duePills)
        }
        self.adh.text = String(adherenca) + " %"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "zdravilaPacienta") {
            let destViewController = segue.destination as? ZdraviloTableViewController
            destViewController!.zdravila = (people1?.zdravila)!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dueData.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "duePill") as! DueTableViewCell
        let id = dueData[indexPath.row]
        for i in zdravila {
            if i.id == id {
                let times = DateFormatter()
                times.dateFormat = "HH:mm"
                cell.pillName.text = i.name
                cell.pillTime.text = times.string(from: i.time[0])
            }
        }
        return cell
    }

}
