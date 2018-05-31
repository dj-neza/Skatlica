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
    var zdravila : Zdravila?
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "DanesCollectionViewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "navodila") {
            let indexPath: IndexPath = (collectionView?.indexPathsForSelectedItems![0])!
            let destViewController = segue.destination as? NavodilaViewController
            let zdravilo = zdraviloForIndexPath(indexPath)
            destViewController!.zdravilo = zdravilo
        }
    }
}

// MARK: - Private
private extension DanesCollectionViewController {
    func zdraviloForIndexPath(_ indexPath: IndexPath) -> Zdravilo {
        switch viewId {
        case "jutro":
            return zdravila!.jutro[indexPath.row]
        case "dopoldne":
            return zdravila!.dopoldne[indexPath.row]
        case "popoldne":
            return zdravila!.popoldne[indexPath.row]
        default:
            return zdravila!.vecer[indexPath.row]
        }
    }
    func overdueForIndexPath(_ indexPath: IndexPath) -> Zdravilo {
        return zdravila!.overdue[indexPath.row]
    }
}

// MARK: - UICollectionViewDataSource
extension DanesCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let currentTime = Date()
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch viewId {
        case "jutro":
            if (hour < 9) { return 2 }
            else { return 1 }
        case "dopoldne":
            if (hour >= 9 && hour < 12) { return 2 }
            else { return 1 }
        case "popoldne":
            if (hour >= 12 && hour < 18) { return 2 }
            else { return 1 }
        default:
            if (hour >= 18) { return 2 }
            else { return 1 }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if (numberOfSections(in: collectionView) == 1 || section == 1) {
            switch viewId {
            case "jutro":
                return zdravila!.jutro.count
            case "dopoldne":
                return zdravila!.dopoldne.count
            case "popoldne":
                return zdravila!.popoldne.count
            default:
                return zdravila!.vecer.count
            }
        }
        else {
            return zdravila!.overdue.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
    withReuseIdentifier: "HeaderCollectionReusableView", for: indexPath) as! HeaderCollectionReusableView
            switch viewId {
            case "jutro":
                headerView.sectionHeader.text = "Zjutraj"
            case "dopoldne":
                headerView.sectionHeader.text = "Dopoldne"
            case "popoldne":
                headerView.sectionHeader.text = "Popoldne"
            default:
                headerView.sectionHeader.text = "Zvecer"
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
        }
        else {
            if (indexPath.section == 0) {
                let zdravilo = overdueForIndexPath(indexPath)
                cell.pill_image.image = UIImage(named: zdravilo.pill_img)
                cell.pill_name.text = zdravilo.name
            }
            else {
                let zdravilo = zdraviloForIndexPath(indexPath)
                cell.pill_image.image = UIImage(named: zdravilo.pill_img)
                cell.pill_name.text = zdravilo.name
            }
        }
        return cell
    }
}

extension DanesCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 160)
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
}
