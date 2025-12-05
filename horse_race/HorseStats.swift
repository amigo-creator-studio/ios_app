//
//  HorseStats.swift
//  horseRace
//
//  Created by Amigo Lu on 2025/11/30.
//

// HorseStats.swift
import Foundation

struct HorseStats: Identifiable {
    let id = UUID() // 為了在 SwiftUI List 中識別
    var strength: Int = 7 // 力量：影響基礎速度
    var burst: Int = 7    // 爆發力：影響瞬間加速
    var luck: Int = 5     // 運氣：影響隨機事件或小幅速度加成/減益
    var endurance: Int = 6 // 耐力：影響長時間保持速度的能力
    var stamina: Int = 5  // 體力：影響在比賽後期是否會減速
    
    // 總能力點數，用於檢查用戶是否超額分配
    var totalPoints: Int {
        strength + burst + luck + endurance + stamina
    }
}
