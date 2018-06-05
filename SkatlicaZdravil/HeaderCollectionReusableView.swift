//
//  HeaderCollectionReusableView.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 23/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var imaag: UIImageView!
    }

class navigation: UINavigationController {
    override func viewDidAppear(_ animated: Bool) {
        let height: CGFloat = 100 //whatever height you want to add to the existing height
        let bounds = self.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
    }
}
