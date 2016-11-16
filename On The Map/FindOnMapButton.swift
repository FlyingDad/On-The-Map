//
//  FindOnMapButton.swift
//  On The Map
//
//  Created by Michael Kroth on 11/9/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class FindOnMapButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10.0;
        self.layer.borderWidth = 1.0
        let borderColor = UIColor(red: 71.0/255.0, green: 121.0/255.0, blue: 159.0/255.0, alpha: 1.0)
        self.layer.borderColor = borderColor.CGColor
        self.backgroundColor = UIColor.whiteColor()
    }

}
