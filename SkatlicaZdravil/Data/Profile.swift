//
//  Profile.swift
//  SkatlicaZdravil
//
//  Created by Neza Dukic on 17/05/2018.
//  Copyright © 2018 Neza. All rights reserved.
//

import UIKit

class Profile {
    
    //MARK: Properties
    
    var left_img: UIImage?
    var right_img: UIImage?
    var label: String
    var backgroundColor: UIColor?
    
    //MARK: Initialization
    init?(left_img: UIImage?, right_img: UIImage?, label: String, backgroundColor: UIColor?) {
        guard !label.isEmpty else {
            return nil
        }
        
        self.left_img = left_img
        self.right_img = right_img
        self.label = label
        self.backgroundColor = backgroundColor
    }
}
