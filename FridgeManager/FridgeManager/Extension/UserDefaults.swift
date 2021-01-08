//
//  UserDefaults.swift
//  Real
//
//  Created by 唐紹桓 on 2020/12/10.
//

import Foundation

extension UserDefaults {
    
    enum Key {
        
        case `default`(key: String)
        
        init(key: String) {
            
            self = .default(key: key)
        }
    }
}

extension UserDefaults.Key {

    static var fridgeID = UserDefaults.Key(key: "FridgeID")
    
}

extension UserDefaults {
    
    func set(_ value: Any?, forKey key: UserDefaults.Key) {
        
        if case UserDefaults.Key.default(key: let key) = key {
            
            self.setValue(value, forKey: key)
        }
    }
    
    func remove(forKey key: UserDefaults.Key) {
        
        if case UserDefaults.Key.default(key: let key) = key {
            
            self.removeObject(forKey: key)
        }
    }
    
    func value(forKey key: UserDefaults.Key) -> Any? {
        
        if case UserDefaults.Key.default(key: let key) = key {
            
            return self.value(forKey: key)
        }
        
        return nil
    }
    
    func string(forKey key: UserDefaults.Key) -> String? {
        
        if case UserDefaults.Key.default(let key) = key {
        
            return self.string(forKey: key)
        }
        
        return nil
    }
    
    func dictionary(forKey key: UserDefaults.Key) -> [String: Any]? {
        
        if case UserDefaults.Key.default(let key) = key {
        
            return self.dictionary(forKey: key)
        }
        
        return nil
    }
    
    func integer(forKey key: UserDefaults.Key) -> Int {
        
        if case UserDefaults.Key.default(let key) = key {
        
            return self.integer(forKey: key)
        }
        
        return 0
    }
    
    func float(forKey key: UserDefaults.Key) -> Float {
        
        if case UserDefaults.Key.default(let key) = key {
        
            return self.float(forKey: key)
        }
        
        return 0.0
    }
    
    func double(forKey key: UserDefaults.Key) -> Double {
        
        if case UserDefaults.Key.default(let key) = key {
            
            return self.double(forKey: key)
        }
       
        return 0.0
    }
    
    func bool(forKey key: UserDefaults.Key) -> Bool {
        
        if case UserDefaults.Key.default(let key) = key {
        
            return self.bool(forKey: key)
        }
        
        return false
    }
}
