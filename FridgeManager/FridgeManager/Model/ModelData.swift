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
//    let amountAlert: Int
    let category: String
    let unit: String
    let purchaseDate: Date
    let expiredDate: Date
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

struct Recipe: Codable, Equatable {
    let id: String
    let ingredients: [String]
    let content: [String]
    let photo: String
}
