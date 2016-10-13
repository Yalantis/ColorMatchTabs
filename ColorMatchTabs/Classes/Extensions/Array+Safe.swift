//
//  Array+Safe.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

extension Array {

    subscript (safe index: Int) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
