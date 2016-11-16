//
//  SubmitButton.swift
//  On The Map
//
//  Created by Michael Kroth on 11/9/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class SubmitButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10.0;
        self.layer.borderWidth = 0.0
        self.backgroundColor = UIColor.whiteColor()
    }


}
