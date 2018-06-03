//
//  ZdraviloTableViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 17/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class ZdraviloTableViewController: UITableViewController {

    //MARK: Properties
    var zdravila = [Zdravilo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //loadZdravila()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zdravila.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ZdraviloTableViewCell", for: indexPath) as? ZdraviloTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProfileTableViewCell.")
        }
        
        let zdravilo = zdravila[indexPath.row]
        cell.pillImg.image = UIImage(named: zdravilo.pill_img)
        cell.pillLabel.text = zdravilo.name
        
        return cell
    }
    
    //MARK: Private Methods
    private func loadZdravila() {
        
        let pill1 = "pill1"
        let pill2 = "pill2"
        let startDate = Date()
        let endDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let startDate1: String = formatter.string(from: startDate)
        let endDate1: String = formatter.string(from: endDate)
        let zdravilo1 = Zdravilo(id: 123, name: "zdravilo123", pill_img: pill1, box_img: pill2, startDate: startDate1, endDate: endDate1, dose: 1.0, form: "pill", time: ["evening"], frequency: "weekly", additionalRules: ["lala", "vzemi ko bos lacen"]) 
        
        zdravila += [zdravilo1]
    }
    
    //MARK: Actions
    @IBAction func unwindToZdravilaList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DodajanjeViewController, let zdravilo = sourceViewController.zdravilo {
            // Add a new meal.
            let newIndexPath = IndexPath(row: zdravila.count, section: 0)
            zdravila.append(zdravilo)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "zdraviloDetails") {
            let indexPath: IndexPath = (tableView?.indexPathForSelectedRow)!
            let destViewController = segue.destination as? PillViewController
            let zdravilo = zdraviloForIndexPath(indexPath)
            destViewController!.zdravilo = zdravilo
        }
    }
    
    func zdraviloForIndexPath(_ indexPath: IndexPath) -> Zdravilo {
        return zdravila[indexPath.row]
    }
    
}
