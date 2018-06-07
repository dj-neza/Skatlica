//
//  DanesCollectionViewController.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 22/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

final class DanesCollectionViewController: UICollectionViewController {
    
    var viewId: String?
    var zdravila : [Zdravilo]?
    var open = false
    
    @IBOutlet weak var headerButton: UIButton!
    // MARK: - Properties
    fileprivate let reuseIdentifier = "DanesCollectionViewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate var itemsPerRow: CGFloat = 3
    
    let usersData:UserDefaults = UserDefaults.standard
    
    @IBAction func showOverdue(_ sender: UIButton) {
        if (open == false) {
            open = true
            self.collectionView?.reloadData()
        }
        else {
            open = false
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let decoded  = usersData.object(forKey: "zdravila") as! Data
        zdravila = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Zdravilo]
    }
    /*override func viewDidAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "navodila") {
            let indexPath: IndexPath = (collectionView?.indexPathsForSelectedItems![0])!
            let destViewController = segue.destination as? NavodilaViewController
            var zdravilo: Zdravilo?
            if (indexPath.section == 0) {
                zdravilo = zdraviloForIndexPath(indexPath)
            }
            else {
                zdravilo = overdueForIndexPath(indexPath)
            }
            destViewController!.zdravilo = zdravilo
        }
    }
}

// MARK: - Private
private extension DanesCollectionViewController {
    func zdraviloForIndexPath(_ indexPath: IndexPath) -> Zdravilo {
        let jutro = usersData.value(forKey: "jutro") as? [Int]
        let dopoldne = usersData.value(forKey: "dopoldne") as? [Int]
        let popoldne = usersData.value(forKey: "popoldne") as? [Int]
        let vecer = usersData.value(forKey: "vecer") as? [Int]
        var id = 0
        switch viewId {
        case "jutro":
            id = jutro![indexPath.row]
        case "dopoldne":
            id = dopoldne![indexPath.row]
        case "popoldne":
            id = popoldne![indexPath.row]
        default:
            id = vecer![indexPath.row]
        }
        for i in zdravila! {
            if i.id == id {
                return i
            }
        }
        return zdravila![0]
    }
    func overdueForIndexPath(_ indexPath: IndexPath) -> Zdravilo {
        let overdue = usersData.value(forKey: "overdue") as? [Int]
        let id = overdue![indexPath.row]
        for i in zdravila! {
            if i.id == id {
                return i
            }
        }
        return zdravila![0]
    }
}

// MARK: - UICollectionViewDataSource
extension DanesCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let currentTime = Date()
        let hour = Calendar.current.component(.hour, from: currentTime)
        let overdue = usersData.value(forKey: "overdue") as? [Int]
        switch viewId {
        case "jutro":
            if (hour < 9 && overdue?.count != 0) { return 2 }
            else { return 1 }
        case "dopoldne":
            if (hour >= 9 && hour < 12 && overdue?.count != 0) { return 2 }
            else { return 1 }
        case "popoldne":
            if (hour >= 12 && hour < 18 && overdue?.count != 0) { return 2 }
            else { return 1 }
        default:
            if (hour >= 18 && overdue?.count != 0) { return 2 }
            else { return 1 }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        var result: Int
        if (section == 0) {
            let jutro = usersData.value(forKey: "jutro") as? [Int]
            let dopoldne = usersData.value(forKey: "dopoldne") as? [Int]
            let popoldne = usersData.value(forKey: "popoldne") as? [Int]
            let vecer = usersData.value(forKey: "vecer") as? [Int]
            switch viewId {
            case "jutro":
                result = jutro!.count
            case "dopoldne":
                result = dopoldne!.count
            case "popoldne":
                result = popoldne!.count
            default:
                result = vecer!.count
            }
            if (result == 0) {
                self.collectionView?.setEmptyMessage("V tem delu dneva nimaš več zdravil.")
            }
            else {
                self.collectionView?.restore()
            }
        }
        else {
            if (open == true) {
                let overdue = usersData.value(forKey: "overdue") as? [Int]
                result = overdue!.count
                if (result != 0) {
                    self.collectionView?.restore()
                }
            }
            else {
                result = 0
            }
        }
        return result
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "HeaderCollectionReusableView", for: indexPath) as! HeaderCollectionReusableView
            if (indexPath.section == 0) {
                headerView.imaag.image = UIImage(named: "question")
                headerView.headerButton.setTitle("Za navodila klikni zdravilo", for: .normal)
                headerView.headerButton.setTitle("Za navodila klikni zdravilo", for: .highlighted)
                headerView.backgroundColor = UIColor.white
            }
            else {
                headerView.backgroundColor = UIColor(red:0.69, green:0.85, blue:0.92, alpha:1.0)
                if (collectionView.numberOfItems(inSection: indexPath.section) != 0) {
                    headerView.imaag.image = UIImage(named: "up")
                    headerView.headerButton.setTitle("Skrij zamujena zdravila", for: .normal)
                    headerView.headerButton.setTitle("Skrij zamujena zdravila", for: .highlighted)
                }
                else {
                    headerView.imaag.image = UIImage(named: "down")
                    headerView.headerButton.setTitle("Prikazi zamujena zdravila", for: .normal)
                    headerView.headerButton.setTitle("Prikazi zamujena zdravila", for: .highlighted)
                }
            }
        
            return headerView
            
        default:
            assert(false, "Error occured, something's up! :O")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as! DanesCollectionViewCell
        if (collectionView.numberOfSections == 1) {
            let zdravilo = zdraviloForIndexPath(indexPath)
            cell.pill_image.image = UIImage(named: zdravilo.pill_img)
            cell.pill_name.text = zdravilo.name
            //cell.pill_name.adjustsFontSizeToFitWidth = true
        }
        else {
            if (indexPath.section == 1) {
                let zdravilo = overdueForIndexPath(indexPath)
                cell.pill_image.image = UIImage(named: zdravilo.pill_img)
                cell.pill_name.text = zdravilo.name
                cell.backgroundColor = UIColor(red:1.00, green:0.83, blue:0.07, alpha:0.75)
                //cell.pill_name.adjustsFontSizeToFitWidth = true
            }
            else {
                let zdravilo = zdraviloForIndexPath(indexPath)
                cell.pill_image.image = UIImage(named: zdravilo.pill_img)
                cell.pill_name.text = zdravilo.name
                cell.backgroundColor = UIColor.white
                //cell.pill_name.adjustsFontSizeToFitWidth = true
            }
        }
        return cell
    }
}

extension DanesCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = collectionView.numberOfItems(inSection: indexPath.section)
        if (indexPath.section == 1) {
            if (count < 3) {
                itemsPerRow = 2
            }
            else {
                itemsPerRow = 3
            }
        }
        else if (collectionView.numberOfSections == 2) {
            if (count < 3) {
                itemsPerRow = 2
            }
            else {
                itemsPerRow = 3
            }
        }
        else {
            if (count < 5) {
                itemsPerRow = 2
            }
            else {
                itemsPerRow = 3
            }
        }
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem+40)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, referenceSizeForHeaderInSection: Int) -> CGSize {
        if (numberOfSections(in: collectionView) == 1 || referenceSizeForHeaderInSection == 1) {
            return CGSize(width: 0, height: 0)
        }
        else {
            return CGSize(width: collectionView.frame.size.width, height: 50)
        }
    }*/
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "HKGrotesk", size: 60)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}





