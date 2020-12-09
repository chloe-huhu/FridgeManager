//
//  ModelData.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import Foundation

struct Food: Codable {
    let id: String
    let photo: String
    let name: String
    let amount: Int
    let amountAlert: Int
    let category: String
    let unit: String
    let purchaseDate: Date
    let expiredDate: Date
}

struct List: Codable {
    let id: String
    let photo: String
    let name: String
    let amount: Int
    let unit: String
    let brand: String
    let place: String
    let note: String
}

struct User: Codable {
    let id: String
    let name: String
    let photo: String
    let fredge: [String]
}
