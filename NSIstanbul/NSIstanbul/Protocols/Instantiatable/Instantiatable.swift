//
//  Instantiatable.swift
//  NSIstanbul
//
//  Created by Ilter Cengiz on 11/6/18.
//  Copyright © 2018 NSIstanbul. All rights reserved.
//

import UIKit

protocol Instantiatable {
    
    static func instantiate() -> Self
    
}
