//
//  NavigationController.swift
//  Limit
//
//  Created by Rix Lai on 10/28/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {

    /* Only support portrait view */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
   
}
