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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePill(_ sender: Any) {
        zdravilo?.taken = true
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
