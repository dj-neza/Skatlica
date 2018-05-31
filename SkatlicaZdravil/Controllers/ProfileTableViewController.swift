//
//  ProfileTableViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 17/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: Properties
    var profiles = [Profile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfiles()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as? ProfileTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProfileTableViewCell.")
        }

        let profile = profiles[indexPath.row]
        cell.left_img.image = profile.left_img
        cell.right_img.image = profile.right_img
        cell.label.text = profile.label
        cell.backgroundColor = profile.backgroundColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0) {
            self.performSegue(withIdentifier: "ctrl", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "elder", sender: self)
        }
    }
    
    //MARK: Private Methods
    private func loadProfiles() {
        
        let human = UIImage(named: "human")
        let nurse = UIImage(named: "nurse")
        let old1 = UIImage(named: "old1")
        let old2 = UIImage(named: "old2")
        
        guard let profile1 = Profile(left_img: old1, right_img: old2, label: "Vstopi kot starejši", backgroundColor: UIColor(red:0.89, green:0.57, blue:0.88, alpha:1.0)) else {
            fatalError("Unable to create profile")
        }
        
        guard let profile2 = Profile(left_img: human, right_img: nurse, label: "Vstopi kot skrbnik", backgroundColor: UIColor(red:0.36, green:0.44, blue:0.96, alpha:1.0)) else {
            fatalError("Unable to create profile")
        }
        
        profiles += [profile1, profile2]
    }

}
