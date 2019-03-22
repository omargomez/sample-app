//
//  Dictionary+Extensions.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 2/21/19.
//  Copyright © 2019 Omar Gómez. All rights reserved.
//

import Foundation

/* PArsing fallback, template for differemt typesStr
 * No tdoing good fallback
 * add a 'asJSONString' to return that part fo the tree as string
 */
extension Dictionary {
    
    class JSONDecorator {
        
        let target: [String:Any];
        
        init?(_ dict: Dictionary) {
            guard let typed = dict as? Dictionary<String,Any>  else {
                return nil
            }
            
            self.target = typed
        }
        
        func assInt() -> Int? {
            return nil
        }
        
        var asInt: Int?  {
            get {
                return nil
            }
        }
    }
    
    func decorate() -> JSONDecorator? {
        return JSONDecorator(self)
    }
    
    var root: JSONDecorator?  {
        get {
            return JSONDecorator(self)
        }
    }
    
    
    
}

class JSONRoot {
    
    let node: Any?
    
    init?(_ root: Any?) {
        guard let any = root else {
            return nil
        }
        node = any
    }
    
    subscript(posIdx: Int) -> JSONRoot? {
        get {
            guard let asArr = self.node as? Array<Any>, (asArr.count - 1) > posIdx else {
                return nil
            }
            
            return JSONRoot(asArr[posIdx])
        }
    }
    
    subscript(keyIdx: String) -> JSONRoot? {
        get {
            guard let asDict = self.node as? Dictionary<String,Any> else {
                return nil
            }
            
            return JSONRoot(asDict[keyIdx])
        }
    }
    
    var count: Int? {
        get {
            if let asDict = self.node as? Dictionary<String,Any> {
                return asDict.count
            } else if let asArr = self.node as? Array<Any> {
                return asArr.count
            } else {
                return nil
            }
        }
    }
    
    var asInt: Int?  {
        get {
            guard let result = self.node as? Int else {
                return nil
            }
            
            return result
        }
    }
    
    var asDouble: Double?  {
        get {
            guard let result = self.node as? Double else {
                return nil
            }
            
            return result
        }
    }
    
    var asDecimal: Decimal?  {
        get {
            guard let result = self.node as? Decimal else {
                return nil
            }
            
            return result
        }
    }
    
    var asString: String?  {
        get {
            guard let result = self.node as? String else {
                return nil
            }
            
            return result
        }
    }
    
    var asBool: Bool? {
        get {
            guard let result = self.node as? Bool else {
                return nil
            }
            
            return result
        }
    }
    
    var isNull: Bool {
        get {
            if let val = self.node {
                return val is NSNull
            } else {
                return true
            }
        }
    }

    var asJSONString: String? {
        get {
            guard let obj = self.node, let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
                return nil
            }
            return String(data: data, encoding: String.Encoding.utf8)
        }
    }
}
