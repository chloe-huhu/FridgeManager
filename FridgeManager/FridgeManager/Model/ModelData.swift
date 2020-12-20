//
//  ModelData.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import Foundation

struct Food: Codable {
    let id: String
    let photo: String?
    let name: String
    let amount: Int
    let amountAlert: Int
    let category: String
    let unit: String
    let purchaseDate: Date
    let expiredDate: Date
}

extension Food {
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "photo": photo as? Any,
            "name": name,
            "amount": amount ,
            "unit": unit,
            "amountAlert": amountAlert,
            "category": category,
            "purchaseDate": purchaseDate,
            "expiredDate": expiredDate
        ]
    }
}

struct List: Codable {
    let id: String
    let photo: String?
    let name: String
    let amount: Int
    let unit: String
    let brand: String
    let place: String
    let note: String
    let whoBuy: String
}

struct User: Codable {
    let uid: String
    let photo: String
    let email: String
    let displayName: String
    let myFridges: [String]
    let myInvites: [String]
}

struct Fridge: Codable {
    let fridgeName: String
    let fridgeID: String
    let users: [String]
    let category: [String]
}

struct Recipe: Codable {
    let name: String
    let url: [String]
    let photo: String
}

struct Ingredients: Codable {
    let name: String
    let amount: Int
    let unit: String
}
