//
//  DecodableCoin.swift
//  CoinMark
//

import Foundation

struct DecodableCoin: Decodable {
    let name: String
    let series: String
    let year: Int
    let mintMark: String?
}
