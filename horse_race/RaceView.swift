// RaceView.swift
import SwiftUI

// ... (RaceView 結構體及其所有內容保持不變) ...
struct RaceView: View {
    @StateObject var raceManager: RaceManager
    @Binding var isRacing: Bool
    
    let raceTargetDistance: Double

    init(raceManager: RaceManager, isRacing: Binding<Bool>) {
        _raceManager = StateObject(wrappedValue: raceManager)
        _isRacing = isRacing
        self.raceTargetDistance = raceManager.targetDistance
    }

    var body: some View {
        VStack {
            Text("賽道：目標 \(raceTargetDistance, specifier: "%.1f") cm")
                .font(.title2)
                .fontWeight(.bold)
            
            // MARK: - 新增：顯示當前天氣
            HStack {
                if let weather = raceManager.currentWeather {
                    Image(systemName: weather.systemIcon)
                        .font(.title3)
                        .foregroundColor(weather.color)
                    Text(weather.rawValue)
                        .font(.headline)
                        .foregroundColor(weather.color)
                } else {
                    Text("等待比賽開始...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 10)
            
            ForEach(raceManager.horses) { horse in
                HorseRaceTrackView(horse: horse, targetDistance: raceTargetDistance)
            }
            .padding(.vertical, 5)
            
            Spacer()
            
            if raceManager.raceIsOver {
                if let winner = raceManager.winner {
                    Text("恭喜！\(winner.name) 贏得了比賽！")
                        .font(.title)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else {
                    Text("比賽結束！")
                        .font(.title)
                        .fontWeight(.bold)
                }
            } else {
                Text("比賽進行中... \(String(format: "%.1f", Double(raceManager.raceTime) / 10.0)) 秒")
                    .font(.headline)
            }
            
            Spacer()
            
            Button("結束比賽") {
                SoundManager.shared.playSound(named: "button_click")
                raceManager.stopRace()
                isRacing = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            SoundManager.shared.stopAllSounds()
            SoundManager.shared.playSound(named: "race_start")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                SoundManager.shared.playSound(named: "horse_gallop", loops: -1)
            }
            raceManager.startRace()
        }
        .onDisappear {
            SoundManager.shared.stopAllSounds()
        }
        .onChange(of: raceManager.raceIsOver) { newValue in
            if newValue {
                SoundManager.shared.stopSound(named: "horse_gallop")
                if raceManager.winner != nil {
                    SoundManager.shared.playSound(named: "race_finish")
                }
            }
        }
    }
}


// MARK: - 新增馬匹賽道動畫 View
struct HorseRaceTrackView: View {
    @ObservedObject var horse: Horse // 觀察單匹馬的狀態
    let targetDistance: Double      // 目標距離

    // 賽道的可視寬度 (這個值需要根據你的 UI 調整，以使馬匹能夠從左邊跑到右邊)
    // 假設我們希望賽道寬度是 300 點
    let trackWidth: CGFloat = 600
    // 馬匹圖標的寬度，用於調整起始和結束位置
    let horseImageWidth: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(horse.name)
                .font(.headline)
                .foregroundColor(horse.color)
            
            // 賽道容器
            ZStack(alignment: .leading) {
                // 賽道背景
                Capsule() // 使用圓角矩形作為賽道背景
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: trackWidth, height: 100)
                
                // 馬匹圖片
                
                if horse.isFinished {
                    // 1. 馬匹跑完時，顯示靜止的 PNG 圖
                    Image(systemName: "figure.equestrian.sports")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: horseImageWidth, height: 20)
                        .foregroundColor(horse.color) // PNG 可以著色
                        .offset(x: calculateHorseOffsetX())
                        .animation(.linear(duration: 0.1), value: horse.currentDistance)
                } else {
                    // 2. 馬匹正在跑時，顯示會動的 GIF
                    // 這裡使用我們剛寫好的 GifImage 元件，傳入檔案名稱 "horse_running"
                    GifImage("horse_running")
                        .frame(width: 120, height: 100) // GIF 通常需要明確設定寬高
                        // 注意：GIF 沒辦法像 PNG 那樣直接用 .foregroundColor() 變色
                        .offset(x: calculateHorseOffsetX())
                        .animation(.linear(duration: 0.1), value: horse.currentDistance)
                }
            }
            .frame(width: trackWidth, alignment: .leading) // 確保 ZStack 有固定寬度
            
            // 顯示當前距離和速度
            HStack {
                Text("\(horse.currentDistance, specifier: "%.1f") cm")
                    .font(.subheadline)
                Spacer()
                Text("速度: \(horse.currentSpeed, specifier: "%.2f") cm/s")
                    .font(.caption)
            }
        }
        .padding(.horizontal)
    }

    // 計算馬匹的水平偏移量
    private func calculateHorseOffsetX() -> CGFloat {
        // 防止除以零
        guard targetDistance > 0 else { return 0 }

        // 馬匹進度百分比 (0.0 到 1.0)
        let progress = min(1.0, max(0.0, horse.currentDistance / targetDistance))

        // 可移動的總距離 = 賽道寬度 - 馬匹圖片寬度
        let availableTrackSpace = trackWidth - horseImageWidth

        // 計算實際偏移量
        return availableTrackSpace * progress
    }
}

// ... (HorseProgressView 結構體現在可以刪除，因為被 HorseRaceTrackView 取代) ...
// 如果你仍想保留 ProgressView 作為參考或備用，可以保留，但 RaceView 不會再呼叫它。
/*
struct HorseProgressView: View {
    @ObservedObject var horse: Horse
    let targetDistance: Double
    
    var body: some View {
        HStack {
            Text(horse.name)
                .font(.headline)
                .foregroundColor(horse.color)
                .frame(width: 80, alignment: .leading)
            
            ProgressView(value: horse.currentDistance, total: targetDistance)
                .accentColor(horse.color)
                .frame(height: 10)
                .animation(.linear(duration: 0.1), value: horse.currentDistance)
            
            Text("\(horse.currentDistance, specifier: "%.1f") cm")
                .font(.subheadline)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal)
    }
}
*/
