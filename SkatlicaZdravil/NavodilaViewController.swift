//
//  NavodilaViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 25/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class NavodilaViewController: UIViewController {

    
    @IBOutlet weak var pill_name: UILabel!
    @IBOutlet weak var pill_dates: UILabel!
    @IBOutlet weak var dose_unit: UILabel!
    @IBOutlet weak var frequency: UILabel!
    @IBOutlet weak var pill_time: UILabel!
    @IBOutlet weak var additionalRules: UITextView!
    @IBOutlet weak var pill_img: UIImageView!
    @IBOutlet weak var box_img: UIImageView!
    
    var zdravilo: Zdravilo?
    //var zdravila = Zdravila(jutro: [], dopoldne: [], popoldne: [], vecer: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dates = DateFormatter()
        dates.dateFormat = "dd.MM.yyyy"
        let start = dates.string(from: (zdravilo?.lasting.start)!)
        let end = dates.string(from: (zdravilo?.lasting.end)!)
        
        let times = DateFormatter()
        times.dateFormat = "HH:mm"
        //times.timeZone = TimeZone(abbreviation: "GMT")
        var timeStr = [String]()
        for i in (zdravilo?.time)! {
            timeStr.append(times.string(from: i))
        }
        
        self.pill_name.text = zdravilo?.name
        self.pill_dates.text = start + " - " + end
        self.dose_unit.text = String(format: "%.2f", (zdravilo?.dose)!) + " " + (zdravilo?.form)!
        self.frequency.text = zdravilo?.frequency
        self.pill_time.text = arrayToString(additional: timeStr)
        self.additionalRules.text = arrayToString(additional: (zdravilo?.additionalRules)!)
        self.pill_img.image = UIImage(named: (zdravilo?.pill_img)!)
        self.box_img.image = UIImage(named: (zdravilo?.box_img)!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        pill_img.isUserInteractionEnabled = true
        pill_img.addGestureRecognizer(tapGestureRecognizer)
        box_img.isUserInteractionEnabled = true
        box_img.addGestureRecognizer(tapGestureRecognizer1)
        
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let popOverVC = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopupViewController
        popOverVC.image1 = tappedImage.image
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePill(_ sender: Any) {
        let usersData:UserDefaults = UserDefaults.standard
        var taken = usersData.value(forKey: "taken") as? [String: Bool]
        var overdue = usersData.value(forKey: "overdue") as? [Int]
        let jutro = usersData.value(forKey: "jutro") as? [Int]
        let dopoldne = usersData.value(forKey: "dopoldne") as? [Int]
        let popoldne = usersData.value(forKey: "popoldne") as? [Int]
        let vecer = usersData.value(forKey: "vecer") as? [Int]
        taken![String((zdravilo?.id)!)] = true
        for i in jutro! {
            if i == (zdravilo?.id)! {
                let newJutro = jutro?.filter { $0 != i }
                usersData.set(newJutro, forKey: "jutro")
            }
        }
        for i in dopoldne! {
            if i == (zdravilo?.id)! {
                let newDop = dopoldne?.filter { $0 != i }
                usersData.set(newDop, forKey: "dopoldne")
            }
        }
        for i in popoldne! {
            if i == (zdravilo?.id)! {
                let newPop = popoldne?.filter { $0 != i }
                usersData.set(newPop, forKey: "popoldne")
            }
        }
        for i in vecer! {
            if i == (zdravilo?.id)! {
                let newVecer = vecer?.filter { $0 != i }
                usersData.set(newVecer, forKey: "vecer")
            }
        }
        for i in overdue! {
            if i == (zdravilo?.id)! {
                let newJutro = jutro?.filter { $0 != i }
                usersData.set(newJutro, forKey: "overdue")
            }
        }
        usersData.set(taken, forKey: "taken")
        usersData.synchronize()
        _ = navigationController?.popViewController(animated: true)
    }
    
    func arrayToString(additional: [String]) -> String {
        var rules: String = ""
        var ind = 0
        for info in additional {
            if (ind == 0) {
                ind = 1
            }
            else {
                rules += ", "
            }
            rules += info
        }
        return rules
    }

}
