//
//  Quarter.swift
//  CoinMark
//

import SwiftData
import Foundation

@Model
final class Quarter{
    var id: UUID
    var name: String
    var series: String
    var year: Int
    var mintMark: String?
    var isCollected: Bool = false
    
    init(id: UUID = UUID(), name: String, series: String, year: Int, mintMark: String? = nil, isCollected: Bool = false) {
        self.id = id
        self.name = name
        self.series = series
        self.year = year
        self.mintMark = mintMark
        self.isCollected = isCollected
    }
}
