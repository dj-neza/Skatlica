//
//  AdhViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 29/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class AdhViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var peopleId: UILabel!
    @IBOutlet weak var adh: UILabel!
    
    var people1: People?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.img.image = UIImage(named: (people1?.img)!)
        self.name.text = people1?.name
        self.peopleId.text = "Id: " + (people1?.patientId)!
        self.adh.text = "100 %"
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

}
