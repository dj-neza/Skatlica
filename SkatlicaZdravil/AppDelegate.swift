//
//  AppDelegate.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 14/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var zdravilaNeurejena = [Zdravilo]()
    let calendar = Calendar.current
    let usersData:UserDefaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted: \(granted)")
        }
        center.delegate = self
        registerCategories()
        
        
        /*let patientId = "2"
        let controlId = "1"
        
        usersData.set(patientId, forKey: "patientId")
        usersData.set(controlId, forKey: "controlId")
        usersData.synchronize()*/
        //usersData.set(false, forKey: "isPatient")
        //usersData.set(["0": false, "1": true, "2": false, "3": false], forKey: "taken")
        usersData.synchronize()
        let firstLaunch = FirstLaunch()
        if firstLaunch.isFirstLaunch {
            print("first launch")
            
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "adherence", bundle: nil)
            let idCTRL = mainStoryboard.instantiateViewController(withIdentifier: "iding") as! idViewController
            
            self.window?.rootViewController = idCTRL
            
            /*zdravilaNeurejena = [Zdravilo]()
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
            usersData.synchronize()*/
        }
        else {
            let iss = usersData.value(forKey: "isPatient") as? Bool
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "adherence", bundle: nil)
            if iss! {
                let naviCTRL = mainStoryboard.instantiateViewController(withIdentifier: "navi") as! UINavigationController
                
                self.window?.rootViewController = naviCTRL
            }
            else {
                let naviCTRL = mainStoryboard.instantiateViewController(withIdentifier: "navi2") as! UINavigationController
                
                self.window?.rootViewController = naviCTRL
            }
        }
        
        return true
    }
    
    func registerCategories() {
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE",
                                                title: "Spomni me cez 5 minut",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let stopAction = UNNotificationAction(identifier: "STOP",
                                              title: "Vzel(a) sem tableto",
                                              options: .foreground)
        
        let expiredCategory = UNNotificationCategory(identifier: "TIMER",
                                                     actions: [snoozeAction, stopAction],
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
        
        center.setNotificationCategories([generalCategory, expiredCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //response.notification.request.content.categoryIdentifier
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            if response.notification.request.content.categoryIdentifier == "TIMER" {
                let content = response.notification.request.content
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
                let request = UNNotificationRequest(identifier: response.notification.request.identifier, content: content, trigger: trigger)
                // random click
                let decoded  = usersData.object(forKey: "zdravila") as! Data
                zdravilaNeurejena = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Zdravilo]
                var zdravilo: Zdravilo?
                for i in zdravilaNeurejena {
                    if String(i.id) == response.notification.request.identifier {
                        zdravilo = i
                    }
                }
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "adherence", bundle: nil)
                let pillCTRL = mainStoryboard.instantiateViewController(withIdentifier: "navodila") as! NavodilaViewController
                let navigationCTRL = mainStoryboard.instantiateViewController(withIdentifier: "navi") as! UINavigationController
                pillCTRL.zdravilo = zdravilo
                
                center.add(request, withCompletionHandler: nil)
                
                self.window?.rootViewController = navigationCTRL
                navigationCTRL.pushViewController(pillCTRL, animated: true)
            }
            else if response.notification.request.content.categoryIdentifier == "GENERAL" {
                //let userId = usersData.value(forKey: "controlId") as? String
                let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
                var dude: People?
                do {
                    let database = try Data(contentsOf: dataPath!)
                    let data = try JSON(data: database)
                    for (_, clovek) in data["starejsi"] {
                        if (clovek["id"].stringValue == usersData.value(forKey: "patientId") as? String) {
                            dude = dataToPeople(data: clovek)
                        }
                    }
                } catch {
                    print("Unable to read the database.")
                }
                
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "adherence", bundle: nil)
                let adhCTRL = mainStoryboard.instantiateViewController(withIdentifier: "adher") as! AdhViewController
                let navigationCTRL = mainStoryboard.instantiateViewController(withIdentifier: "navi2") as! UINavigationController
                adhCTRL.people1 = dude
                
                self.window?.rootViewController = navigationCTRL
                navigationCTRL.pushViewController(adhCTRL, animated: true)
            }
        case "SNOOZE":
            let content = response.notification.request.content
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
            let request = UNNotificationRequest(identifier: response.notification.request.identifier, content: content, trigger: trigger)
            center.add(request) { error in
                UNUserNotificationCenter.current().delegate = self
                if (error != nil){
                    print("error")
                }
            }
            break
        case "STOP":
            var taken = usersData.value(forKey: "taken") as? [String: Bool]
            let overdue = usersData.value(forKey: "overdue") as? [Int]
            let jutro = usersData.value(forKey: "jutro") as? [Int]
            let dopoldne = usersData.value(forKey: "dopoldne") as? [Int]
            let popoldne = usersData.value(forKey: "popoldne") as? [Int]
            let vecer = usersData.value(forKey: "vecer") as? [Int]
            taken![response.notification.request.identifier] = true
            
            let idd = "a" + response.notification.request.identifier
            center.removePendingNotificationRequests(withIdentifiers: [idd])
            
            for i in jutro! {
                if i == Int(response.notification.request.identifier) {
                    let newJutro = jutro?.filter { $0 != i }
                    usersData.set(newJutro, forKey: "jutro")
                }
            }
            for i in dopoldne! {
                if i == Int(response.notification.request.identifier) {
                    let newDop = dopoldne?.filter { $0 != i }
                    usersData.set(newDop, forKey: "dopoldne")
                }
            }
            for i in popoldne! {
                if i == Int(response.notification.request.identifier) {
                    let newPop = popoldne?.filter { $0 != i }
                    usersData.set(newPop, forKey: "popoldne")
                }
            }
            for i in vecer! {
                if i == Int(response.notification.request.identifier) {
                    let newVecer = vecer?.filter { $0 != i }
                    usersData.set(newVecer, forKey: "vecer")
                }
            }
            for i in overdue! {
                if i == Int(response.notification.request.identifier) {
                    let newJutro = jutro?.filter { $0 != i }
                    usersData.set(newJutro, forKey: "overdue")
                }
            }
            usersData.set(taken, forKey: "taken")
            usersData.synchronize()
            
            break
            
        default:
            break
        }
            
        
        completionHandler()
        
    }
    
    /*func zdravilaRazporedi(timeStart: Int, timeEnd: Int) -> [Int] {
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
    }*/
    
    func dataToPeople(data: JSON) -> People {
        var zdravila = [Zdravilo]()
        var indeeks = 0
        for (_, zd) in data["zdravila"] {
            let zdravilo = dataToZdravilo2(data: zd, ind: indeeks)
            indeeks = indeeks + 1
            zdravila.append(zdravilo)
        }
        let result = People(name: data["name"].stringValue, img: data["img"].stringValue, patientId: data["id"].stringValue, zdravila: zdravila)
        return result!
    }
    func dataToZdravilo2(data: JSON, ind: Int) -> Zdravilo {
        var time: [String] = []
        for (_, o) in data["time"] {
            time.append(o.stringValue)
        }
        var additional: [String] = []
        for (_, o2) in data["additionalRules"] {
            additional.append(o2.stringValue)
        }
        let result = Zdravilo(id: ind, name: data["name"].stringValue, pill_img: data["pill_img"].stringValue, box_img: data["box_img"].stringValue, startDate: data["startDate"].stringValue, endDate: data["endDate"].stringValue, dose: data["dose"].stringValue, form: data["form"].stringValue, time: time, frequency: data["frequency"].stringValue, additionalRules: additional)
        return result
    }
    
    /*func dataToZdravilo(data: JSON, ind: Int) -> Int {
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
    }*/

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
        return true
        //return !wasLaunchedBefore
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

