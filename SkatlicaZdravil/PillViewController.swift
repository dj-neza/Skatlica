//
//  PillViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 25/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class PillViewController: UIViewController {

    @IBOutlet weak var pill_name: UINavigationItem!
    @IBOutlet weak var pill_dates: UILabel!
    @IBOutlet weak var pill_q_unit: UILabel!
    @IBOutlet weak var frequency: UILabel!
    @IBOutlet weak var pill_time: UILabel!
    @IBOutlet weak var extra_info: UITextView!
    @IBOutlet weak var pill_img: UIImageView!
    @IBOutlet weak var box_img: UIImageView!
    
    var zdravilo: Zdravilo?
    
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
        
        self.pill_name.title = zdravilo?.name
        self.pill_dates.text = start + " - " + end
        self.pill_q_unit.text = (zdravilo?.dose)! + " " + (zdravilo?.form)!
        self.frequency.text = zdravilo?.frequency
        self.pill_time.text = arrayToString(additional: timeStr)
        self.extra_info.text = arrayToString(additional: (zdravilo?.additionalRules)!)
        self.pill_img.image = UIImage(named: (zdravilo?.pill_img)!)
        self.box_img.image = UIImage(named: (zdravilo?.box_img)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
