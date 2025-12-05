// Horse.swift
import Foundation
import SwiftUI

class Horse: ObservableObject, Identifiable {
    // ... (其他屬性保持不變) ...
    let id = UUID()
    let name: String
    let color: Color
    
    @Published var stats: HorseStats
    @Published var currentDistance: Double = 0.0
    @Published var isFinished: Bool = false
    @Published var currentSpeed: Double = 0.0

    var targetDistance: Double
    let baseSpeedPerSecond: Double = 0.2

    init(name: String, color: Color, stats: HorseStats, targetDistance: Double = 10.0) {
        self.name = name
        self.color = color
        self.stats = stats
        self.targetDistance = targetDistance
        self.currentSpeed = baseSpeedPerSecond
    }

    // MARK: - 遊戲邏輯：計算每秒前進距離 (現在包含天氣影響)

    func calculateSpeedBoost(currentWeather: WeatherEvent?) -> Double { // <-- 接收天氣參數
        var boost = 0.0

        // ... (原有的力量、爆發力、耐力、體力計算保持不變) ...
        // 1. 力量 (Strength)
        boost += Double(stats.strength - 5) * 0.05

        // 2. 爆發力 (Burst)
        if Int.random(in: 1...10) <= stats.burst {
            boost += 0.2
        }
        
        // 3. 運氣 (Luck): 影響浮動範圍，現在也抵抗天氣影響
        let luckFactor = Double.random(in: 0.9...1.1)
        boost *= (1.0 + Double(stats.luck - 5) * 0.02 * luckFactor)
        
        // 4. 耐力 (Endurance)
        let fatigueFactor = (currentDistance / targetDistance)
        let enduranceEffect = max(0.0, 1.0 - fatigueFactor * (1.0 - Double(stats.endurance - 5) * 0.05))
        boost *= enduranceEffect
        
        // 5. 體力 (Stamina)
        let staminaResilience = 1.0 + Double(stats.stamina - 5) * 0.03
        boost *= staminaResilience

        // MARK: - 新增：天氣影響計算
        if let weather = currentWeather, weather != .sunny { // 只有非晴朗天氣才會有影響
            var weatherPenalty = weather.speedImpactFactor // 獲取基礎天氣懲罰
            
            // 運氣抵抗力：運氣值越高，懲罰越小
            // 每點運氣減少懲罰的百分比，例如每點運氣減少 5% 的懲罰
            let luckResistance = 1.0 - (Double(stats.luck - 1) * 0.05) // 運氣從1開始算，最低1點運氣也有基礎抵抗
            weatherPenalty *= max(0.0, luckResistance) // 確保懲罰不會變成正向加成

            boost += weatherPenalty // 將天氣懲罰加入總速度加成
        }

        return max(0, boost)
    }

    // 更新方法現在需要傳入當前天氣
    func update(timeElapsed: Double, currentWeather: WeatherEvent?) { // <-- 修改方法簽名
        guard !isFinished else { return }

        // 基礎速度 + 能力加成 (現在會考慮天氣)
        let effectiveSpeed = baseSpeedPerSecond + calculateSpeedBoost(currentWeather: currentWeather) // <-- 傳遞天氣
        currentSpeed = effectiveSpeed
        
        currentDistance += effectiveSpeed * timeElapsed
        
        if currentDistance >= targetDistance {
            currentDistance = targetDistance
            isFinished = true
        }
    }
}
