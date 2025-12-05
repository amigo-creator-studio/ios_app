//
//  WeatherEvent.swift
//  horseRace
//
//  Created by Amigo Lu on 2025/12/1.
//

// WeatherEvent.swift
import Foundation
import SwiftUI // 為了 Color 和 Image

enum WeatherEvent: String, CaseIterable, Identifiable {
    case sunny = "Sunny"
    case rainy = "rainy"
    case thunderstorm = "thunderstorm"
    // case windy = "刮風" // 可以根據需要擴展

    var id: String { self.rawValue }

    // 每個天氣事件的視覺圖標
    var systemIcon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .rainy: return "cloud.rain.fill"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        // case .windy: return "wind"
        }
    }
    
    // 每個天氣事件對速度的基礎影響因子 (負值表示減速)
    var speedImpactFactor: Double {
        switch self {
        case .sunny: return 0.0 // 晴朗天氣無影響
        case .rainy: return -0.08 // 下雨減速 0.08 cm/s
        case .thunderstorm: return -0.15 // 雷雨減速 0.15 cm/s (更嚴重)
        // case .windy: return -0.05
        }
    }
    
    // 天氣事件的顏色提示
    var color: Color {
        switch self {
        case .sunny: return .orange
        case .rainy: return .blue
        case .thunderstorm: return .purple
        }
    }
}
