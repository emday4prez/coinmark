//
//  Quarter.swift
//  CoinMark
//

import Foundation

struct Quarter: Coin {
    var id = UUID()
    var name: String
    var series: String
    var year: Int
    var mintMark: String?
    var isCollected: Bool = false
}
