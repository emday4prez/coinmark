//
//  Coin.swift
//  CoinMark


import Foundation

protocol Coin : Identifiable, Codable, Hashable {
    var id: UUID {get}
    var name: String {get}
    var series: String {get}
    var year: Int {get}
    var mintMark: String? {get}
    var isCollected: Bool {get set}
}
