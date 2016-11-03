//
//  LoginButton.swift
//  On The Map
//
//  Created by Michael Kroth on 10/27/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 0.0
        self.backgroundColor = UIColor(red: 244/255, green: 85/255, blue: 0.0, alpha: 1.0)
    }
}
