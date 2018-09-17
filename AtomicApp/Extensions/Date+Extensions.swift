//
//  Date+Extensions.swift
//  AtomicApp
//
//  Created by Omar Gomez on 6/13/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

extension Date {
    
    func formated(as format: String) -> String? {
        
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: self)
        
    }

}
