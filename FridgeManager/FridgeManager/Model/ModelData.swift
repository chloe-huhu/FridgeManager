//
//  ModelData.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import Foundation

struct Foods: Codable {
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

struct Lists: Codable {
    let id: String
    let photo: String
    let name: String
    let amount: Int
    let unit: String
    let brand: String
    let place: String
    let note: String
}
