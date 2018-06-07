//
//  DodajanjeViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 18/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit
import os.log

class DodajanjeViewController: UIPageViewController, UIPageViewControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var addButton: UIBarButtonItem!
    var zdravilo: Zdravilo?
    var pageControl = UIPageControl()
    
    let page1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page1") as! Page1
    let page2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page2")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        self.delegate = self
        configurePageControl()
        addButton.isEnabled = false
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [page1, page2]
    }()
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
        if (self.pageControl.currentPage == orderedViewControllers.count-1) {
            addButton.isEnabled = true
        }
        else {
            addButton.isEnabled = false
        }
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === addButton else {
            os_log("Wrong button.", log: OSLog.default, type: .debug)
            return
        }
        let date = "01.01.1000"
        zdravilo = Zdravilo(id: 1, name: page1.vnos1.text!, pill_img: "human", box_img: "human", startDate: date, endDate: date, dose: "1.0", form: "pill", time: ["morning"], frequency: "daily")
    }
    
}

extension DodajanjeViewController: UIPageViewControllerDataSource {
    
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
