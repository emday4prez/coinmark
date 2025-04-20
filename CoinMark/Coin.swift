//
//  Coin.swift
//  CoinMark

import Foundation
import SwiftData

@Model
final class Coin {
    var name: String
    var series: String
    var year: Int
    var mintMark: String?
    var isCollected: Bool
    
    init(name: String, series: String, year: Int, mintMark: String? = nil, isCollected: Bool = false){
        
        self.name = name
        self.series = series
        self.year = year
        self.mintMark = mintMark
        self.isCollected = isCollected
    }
    
}
