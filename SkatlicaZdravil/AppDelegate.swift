//
//  AppDelegate.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 14/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var zdravilaNeurejena = [Zdravilo]()
    let calendar = Calendar.current
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let patientId = "2"
        let controlId = "1"
            
        var usersData:UserDefaults = UserDefaults.standard
        usersData.set(patientId, forKey: "patientId")
        usersData.set(controlId, forKey: "controlId")
        usersData.synchronize()
        
        let firstLaunch = FirstLaunch()
        if firstLaunch.isFirstLaunch {
            print("first launch")
            zdravilaNeurejena = [Zdravilo]()
            let userId = usersData.value(forKey: "patientId") as? String
            let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
            do {
                let database = try Data(contentsOf: dataPath!)
                let data = try JSON(data: database)
                var takenBase = [String : Bool]()
                let overdue = [Int]()
                var indeeks = 0
                for (_, object) in data["starejsi"] {
                    if (object["id"].stringValue == userId) {
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
            usersData.synchronize()
        }
        
        return true
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

final class FirstLaunch {
    
    let userDefaults: UserDefaults = .standard
    
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        //return true
        return !wasLaunchedBefore
    }
    
    init() {
        let key = "com.FirstLaunch.WasLaunchedBefore"
        let wasLaunchedBefore = userDefaults.bool(forKey: key)
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            userDefaults.set(true, forKey: key)
        }
    }
    
}

