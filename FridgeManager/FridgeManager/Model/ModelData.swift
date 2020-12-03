//
//  ModelData.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import Foundation

struct Foods: Codable {
    let id: String
    let image: String
    let name: String
    let amount: Int
    let category: String
    let unit: String
    let purchaseDate: Date
    let expiredDate:Date
}
