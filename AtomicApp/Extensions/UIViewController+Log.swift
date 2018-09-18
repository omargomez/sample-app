//
//  UIViewController+Log.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 9/17/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation
import UIKit
import FoundationLogging

extension UIViewController {
    
    final func info(_ msg: String) {
        Log.info(message: msg)
    }
    
    final func error(_ msg: String) {
        Log.error(message: msg)
    }
    
}
