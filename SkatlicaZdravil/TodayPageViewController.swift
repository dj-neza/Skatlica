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

    @IBOutlet weak var nazajButt: UIBarButtonItem!
    @IBOutlet weak var naprejButt: UIBarButtonItem!
    let nazajNames = ["", "Zjutraj", "Dopoldne", "Popoldne"]
    let naprejNames = ["Dopoldne", "Popoldne", "Zvecer", ""]
    let calendar = Calendar.current
    
    let notification: Notification.Name = .NSCalendarDayChanged
    
    var zdravila = Zdravila(jutro: [], dopoldne: [], popoldne: [], vecer: [])
    var zdravilaNeurejena = [Zdravilo]()
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(configureTodayPills), name: notification, object: nil)

        //TODO: ali se poklice ali ne - configureTodayPills()
        configureTodayPills()

        self.dataSource = nil
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        orderedViewControllers = redoControllers()
        let currentTime = Date()
        let hour = calendar.component(.hour, from: currentTime)
        var firstViewController = orderedViewControllers[0]
        if (hour >= 18) {
            firstViewController = orderedViewControllers[3]
            getOverdueList(hour: 18)
        }
        else if (hour >= 12) {
            firstViewController = orderedViewControllers[2]
            getOverdueList(hour: 12)
        }
        else if (hour >= 9) {
            firstViewController = orderedViewControllers[1]
            getOverdueList(hour: 9)
        }
        
        setViewControllers([firstViewController],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        configurePageControl(activePage: firstViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Nazaj(_ sender: Any) {
        let nazaj = pageViewController(self, viewControllerBefore: self.viewControllers![0])
        if (nazaj != nil) {
            setViewControllers([nazaj!], direction: .reverse, animated: true, completion: nil)
            configurePageControl(activePage: nazaj!)
        }
    }
    
    @IBAction func Naprej(_ sender: Any) {
        let naprej = pageViewController(self, viewControllerAfter: self.viewControllers![0])
        if (naprej != nil) {
            setViewControllers([naprej!], direction: .forward, animated: true, completion: nil)
            configurePageControl(activePage: naprej!)
        }
    }
    
    /*@IBAction func unwinded(segue: UIStoryboardSegue) {
        let source = segue.source as? NavodilaViewController
        let vzeto = source?.zdravilo
        for i in (zdravila?.jutro)! {
            
        }
    }*/
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let page1 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page2 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page3 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        let page4 = UIStoryboard(name: "adherence", bundle: nil).instantiateViewController(withIdentifier: "page1") as! DanesCollectionViewController
        page1.viewId = "jutro"
        page2.viewId = "dopoldne"
        page3.viewId = "popoldne"
        page4.viewId = "vecer"
        page1.zdravila = zdravila
        page2.zdravila = zdravila
        page3.zdravila = zdravila
        page4.zdravila = zdravila
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
        page1.zdravila = zdravila
        page2.zdravila = zdravila
        page3.zdravila = zdravila
        page4.zdravila = zdravila
        return [page1, page2, page3, page4]
    }
    
    @objc func configureTodayPills() {
        let usersData:UserDefaults = UserDefaults.standard
        let userId = usersData.value(forKey: "patientId") as? String
        let dataPath = Bundle.main.url(forResource: "database", withExtension: "json")
        do {
            let database = try Data(contentsOf: dataPath!)
            let data = try JSON(data: database)
            let zdravilaNeurejena = [Zdravilo]()
            for (_, object) in data["starejsi"] {
                if (object["id"].stringValue == userId) {
                    for (_, data) in object["zdravila"] {
                        let zdravilo = dataToZdravilo(data: data)
                        self.zdravilaNeurejena.append(zdravilo)
                    }
                }
            }
            zdravila?.jutro = zdravilaRazporedi(timeStart: 6, timeEnd: 9)
            zdravila?.dopoldne = zdravilaRazporedi(timeStart: 9, timeEnd: 12)
            zdravila?.popoldne = zdravilaRazporedi(timeStart: 12, timeEnd: 18)
            zdravila?.vecer = zdravilaRazporedi(timeStart: 18, timeEnd: 24)
            zdravila?.overdue = []
        } catch {
            print("Unable to read the database.")
        }
    }
    func zdravilaRazporedi(timeStart: Int, timeEnd: Int) -> [Zdravilo] {
        var result = [Zdravilo]()
        for i in zdravilaNeurejena {
            let currentDay = Date()
            if (i.lasting.contains(currentDay)) {
                for j in i.time {
                    let hour = calendar.component(.hour, from: j)
                    if (hour >= timeStart && hour < timeEnd) {
                        let copy = i.copy() as! Zdravilo
                        copy.time = [j]
                        result.append(copy)
                    }
                }
            }
        }
        return result
    }
    
    func dataToZdravilo(data: JSON) -> Zdravilo {
        var time: [String] = []
        for (_, o) in data["time"] {
            time.append(o.stringValue)
        }
        var additional: [String] = []
        for (_, o2) in data["additionalRules"] {
            additional.append(o2.stringValue)
        }
        let result = Zdravilo(name: data["name"].stringValue, pill_img: data["pill_img"].stringValue, box_img: data["box_img"].stringValue, startDate: data["startDate"].stringValue, endDate: data["endDate"].stringValue, dose: data["dose"].floatValue, form: data["form"].stringValue, time: time, frequency: data["frequency"].stringValue, additionalRules: additional)
        return result!
    }
    
    func getOverdueList(hour: Int) {
        zdravila?.overdue = []
        for i in (zdravila?.jutro)! {
            let hour1 = calendar.component(.hour, from: i.time[0])
            if (hour1 < hour && i.taken == false) {
                zdravila?.overdue.append(i)
            }
        }
        for i in (zdravila?.dopoldne)! {
            let hour1 = calendar.component(.hour, from: i.time[0])
            if (hour1 < hour && i.taken == false) {
                zdravila?.overdue.append(i)
            }
        }
        for i in (zdravila?.popoldne)! {
            let hour1 = calendar.component(.hour, from: i.time[0])
            if (hour1 < hour && i.taken == false) {
                zdravila?.overdue.append(i)
            }
        }
        for i in (zdravila?.vecer)! {
            let hour1 = calendar.component(.hour, from: i.time[0])
            if (hour1 < hour && i.taken == false) {
                zdravila?.overdue.append(i)
            }
        }
    }
    
    func configurePageControl(activePage: UIViewController) {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 100,width: UIScreen.main.bounds.width,height: 50))
        let indeks = orderedViewControllers.index(of: activePage)!
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = indeks
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        
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
        
        return orderedViewControllers[nextIndex]
    }
    
}

