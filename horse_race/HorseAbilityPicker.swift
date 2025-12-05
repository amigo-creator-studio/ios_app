//
//  HorseAbilityPicker.swift
//  horseRace
//
//  Created by Amigo Lu on 2025/11/30.
//

// HorseAbilityPicker.swift
import SwiftUI

struct HorseAbilityPicker: View {
    @Binding var stats: HorseStats // 綁定馬匹能力，方便外部修改
    let maxPoints: Int = 35       // 總共可分配點數
    
    // 計算剩餘點數
    var remainingPoints: Int {
        maxPoints - stats.totalPoints
    }

    var body: some View {
        VStack(spacing: 15) {
            Text("分配馬匹能力點數")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("剩餘點數: \(remainingPoints)")
                .font(.headline)
                .foregroundColor(remainingPoints < 0 ? .red : .green)
            
            // 力量
            AbilityStepper(label: "力量", value: $stats.strength, remainingPoints: remainingPoints, statsTotalPoints: stats.totalPoints, maxPoints: maxPoints)
            
            // 爆發力
            AbilityStepper(label: "爆發力", value: $stats.burst, remainingPoints: remainingPoints, statsTotalPoints: stats.totalPoints, maxPoints: maxPoints)
            
            // 運氣
            AbilityStepper(label: "運氣", value: $stats.luck, remainingPoints: remainingPoints, statsTotalPoints: stats.totalPoints, maxPoints: maxPoints)
            
            // 耐力
            AbilityStepper(label: "耐力", value: $stats.endurance, remainingPoints: remainingPoints, statsTotalPoints: stats.totalPoints, maxPoints: maxPoints)
            
            // 體力
            AbilityStepper(label: "體力", value: $stats.stamina, remainingPoints: remainingPoints, statsTotalPoints: stats.totalPoints, maxPoints: maxPoints)
            
            if remainingPoints < 0 {
                Text("點數分配超出上限！")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// 輔助 View：用於單個能力的增減按鈕
struct AbilityStepper: View {
    let label: String
    @Binding var value: Int
    let remainingPoints: Int
    let statsTotalPoints: Int
    let maxPoints: Int
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            
            Button {
                if value > 1 { // 能力值不能低於1
                    value -= 1
                }
            } label: {
                Image(systemName: "minus.circle.fill")
            }
            .disabled(value <= 1) // 當值為1時禁用減號
            
            Text("\(value)")
                .frame(width: 30)
            
            Button {
                if statsTotalPoints < maxPoints { // 總點數未滿時才能增加
                    value += 1
                }
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(statsTotalPoints >= maxPoints) // 當總點數已滿時禁用加號
        }
        .font(.title3)
        .foregroundColor(.accentColor)
    }
}
