//
//  TodayPageViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 23/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import os.log
import SwiftyJSON

class TodayPageViewController: UIPageViewController, UIPageViewControllerDelegate {

    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var nazajButt: UIBarButtonItem!
    @IBOutlet weak var naprejButt: UIBarButtonItem!
    let nazajNames = ["", "Zjutraj", "Dopoldne", "Popoldne"]
    let naprejNames = ["Dopoldne", "Popoldne", "Zvecer", ""]
    let titleNames = ["Zjutraj", "Dopoldne", "Popoldne", "Zvecer"]
    let calendar = Calendar.current
    let usersData:UserDefaults = UserDefaults.standard
    
    let notification: Notification.Name = .NSCalendarDayChanged
    
    var zdravilaNeurejena = [Zdravilo]()
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(configureTodayPills), name: notification, object: nil)
        
        let decoded  = usersData.object(forKey: "zdravila") as! Data
        zdravilaNeurejena = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Zdravilo]

        //TODO: ali se poklice ali ne - configureTodayPills()
        //configureTodayPills()

        self.dataSource = nil
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        orderedViewControllers = redoControllers()
        let currentTime = Date()
        let hour = calendar.component(.hour, from: currentTime)
        var firstViewController = orderedViewControllers[0]
        pageTitle.title = titleNames[0]
        nazajButt.title = nazajNames[0]
        naprejButt.title = naprejNames[0]
        if (hour >= 18) {
            firstViewController = orderedViewControllers[3]
            getOverdueList(hour: 18)
            pageTitle.title = titleNames[3]
            nazajButt.title = nazajNames[3]
            naprejButt.title = naprejNames[3]
        }
        else if (hour >= 12) {
            firstViewController = orderedViewControllers[2]
            getOverdueList(hour: 12)
            pageTitle.title = titleNames[2]
            nazajButt.title = nazajNames[2]
            naprejButt.title = naprejNames[2]
        }
        else if (hour >= 9) {
            firstViewController = orderedViewControllers[1]
            getOverdueList(hour: 9)
            pageTitle.title = titleNames[1]
            nazajButt.title = nazajNames[1]
            naprejButt.title = naprejNames[1]
        }
        
        setViewControllers([firstViewController],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        //configurePageControl(activePage: firstViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Nazaj(_ sender: Any) {
        let nazaj = pageViewController(self, viewControllerBefore: self.viewControllers![0])
        if (nazaj != nil) {
            setViewControllers([nazaj!], direction: .reverse, animated: true, completion: nil)
            //configurePageControl(activePage: nazaj!)
        }
    }
    
    @IBAction func Naprej(_ sender: Any) {
        let naprej = pageViewController(self, viewControllerAfter: self.viewControllers![0])
        if (naprej != nil) {
            setViewControllers([naprej!], direction: .forward, animated: true, completion: nil)
            //configurePageControl(activePage: naprej!)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let page1 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page2 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page3 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page4 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        page1.viewId = "jutro"
        page2.viewId = "dopoldne"
        page3.viewId = "popoldne"
        page4.viewId = "vecer"
        return [page1, page2, page3, page4]
    }()
    
    func redoControllers() -> [UIViewController] {
        let page1 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page2 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page3 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page4 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        page1.viewId = "jutro"
        page2.viewId = "dopoldne"
        page3.viewId = "popoldne"
        page4.viewId = "vecer"
        return [page1, page2, page3, page4]
    }
    
    @objc func configureTodayPills() {
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
            
            usersData.synchronize()
        } catch {
            print("Unable to read the database.")
        }
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
    
    func getOverdueList(hour: Int) {
        var overdue = [Int]()
        let taken = usersData.value(forKey: "taken") as? [String: Bool]
        for i in zdravilaNeurejena {
            let hour1 = calendar.component(.hour, from: i.time[0])
            if (hour1 < hour && taken![String(i.id)] == false) { //} && i.taken == false) {
                overdue.append(i.id)
            }
        }
        usersData.set(overdue, forKey: "overdue")
        usersData.synchronize()
    }
    
    func configurePageControl(activePage: UIViewController) {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 100,width: UIScreen.main.bounds.width,height: 50))
        let indeks = orderedViewControllers.index(of: activePage)!
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = indeks
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.pageControl.isUserInteractionEnabled = false
        
        nazajButt.title = nazajNames[indeks]
        naprejButt.title = naprejNames[indeks]
        
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
}

extension TodayPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        pageTitle.title = titleNames[previousIndex]
        nazajButt.title = nazajNames[previousIndex]
        naprejButt.title = naprejNames[previousIndex]
        /*if (previousIndex == 1) {
            nazajButt.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: UIBarMetrics.default)
            naprejButt.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: UIBarMetrics.default)
        }*/
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        pageTitle.title = titleNames[nextIndex]
        nazajButt.title = nazajNames[nextIndex]
        naprejButt.title = naprejNames[nextIndex]
        /*if (nextIndex == 3) {
            nazajButt.setTitlePositionAdjustment(UIOffset(horizontal: 30, vertical: 30), for: UIBarMetrics.default)
            naprejButt.setTitlePositionAdjustment(UIOffset(horizontal: 30, vertical: 30), for: UIBarMetrics.default)
        }*/
        
        return orderedViewControllers[nextIndex]
    }
    
}

