// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var playerHorseStats = HorseStats()
    @State private var showRaceView = false
    
    private let computerHorse1Stats = HorseStats(strength: 6, burst: 4, luck: 5, endurance: 5, stamina: 5)
    private let computerHorse2Stats = HorseStats(strength: 4, burst: 6, luck: 5, endurance: 5, stamina: 5)
    private let computerHorse3Stats = HorseStats(strength: 7, burst: 6, luck: 5, endurance: 8, stamina: 7)
    private let computerHorse4Stats = HorseStats(strength: 4, burst: 8, luck: 10, endurance: 3, stamina: 7)
    
    let raceTargetDistance: Double = 10.0

    init() {
        // 在 ContentView 初始化時預載入音效
        // 確保這些檔案已加入專案
        SoundManager.shared.loadSound(named: "gamestart", fileExtension: "mp3") // 假設你有這個檔案
        SoundManager.shared.loadSound(named: "button_click", fileExtension: "mp3") // 假設你有這個檔案
        SoundManager.shared.loadSound(named: "race_start", fileExtension: "mp3")
        SoundManager.shared.loadSound(named: "race_finish", fileExtension: "mp3")
        SoundManager.shared.loadSound(named: "horse_gallop", fileExtension: "mp3")
        SoundManager.shared.loadSound(named: "weather_rainy", fileExtension: "mp3") // 假設有 weather_rainy.mp3
        SoundManager.shared.loadSound(named: "weather_thunderstorm", fileExtension: "mp3") // 假設有 weather_thunderstorm.mp3
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("賽馬大亨")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor)
                
                Text("我的愛馬能力設定")
                    .font(.title3)
                HorseAbilityPicker(stats: $playerHorseStats)
                
                VStack(alignment: .leading) {
                    Text("電腦馬匹能力預覽：")
                        .font(.headline)
                    Text("PC馬1 (綠): 力量:\(computerHorse1Stats.strength) 爆發:\(computerHorse1Stats.burst) 運氣:\(computerHorse1Stats.luck) 耐力:\(computerHorse1Stats.endurance) 體力:\(computerHorse1Stats.stamina)")
                        .font(.caption)
                    Text("PC馬2 (紅): 力量:\(computerHorse2Stats.strength) 爆發:\(computerHorse2Stats.burst) 運氣:\(computerHorse2Stats.luck) 耐力:\(computerHorse2Stats.endurance) 體力:\(computerHorse2Stats.stamina)")
                        .font(.caption)
                    Text("PC馬3 (紅): 力量:\(computerHorse3Stats.strength) 爆發:\(computerHorse3Stats.burst) 運氣:\(computerHorse3Stats.luck) 耐力:\(computerHorse3Stats.endurance) 體力:\(computerHorse3Stats.stamina)")
                        .font(.caption)
                    Text("PC馬4 (紅): 力量:\(computerHorse4Stats.strength) 爆發:\(computerHorse4Stats.burst) 運氣:\(computerHorse4Stats.luck) 耐力:\(computerHorse4Stats.endurance) 體力:\(computerHorse4Stats.stamina)")
                        .font(.caption)
                }
                .padding(.horizontal)
                
                Button(action: {
                    SoundManager.shared.playSound(named: "button_click") // 播放按鈕音效
                    if playerHorseStats.totalPoints == 30 {
                        showRaceView = true
                    } else {
                        print("請分配正好 10 點能力！")
                    }
                }) {
                    Text("開始多馬比賽！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(playerHorseStats.totalPoints == 30 ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .disabled(playerHorseStats.totalPoints != 30)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showRaceView) {
                let playerHorse = Horse(name: "我的愛馬", color: .purple, stats: playerHorseStats, targetDistance: raceTargetDistance)
                let computerHorse1 = Horse(name: "PC馬1", color: .green, stats: computerHorse1Stats, targetDistance: raceTargetDistance)
                let computerHorse2 = Horse(name: "PC馬2", color: .red, stats: computerHorse2Stats, targetDistance: raceTargetDistance)
                let computerHorse3 = Horse(name: "PC馬3", color: .red, stats: computerHorse3Stats, targetDistance: raceTargetDistance)
                let computerHorse4 = Horse(name: "PC馬4", color: .red, stats: computerHorse4Stats, targetDistance: raceTargetDistance)
                
                let raceManager = RaceManager(horses: [playerHorse, computerHorse1, computerHorse2, computerHorse3, computerHorse4], targetDistance: raceTargetDistance)
                
                RaceView(raceManager: raceManager, isRacing: $showRaceView)
            }
            // MARK: - 新增：ContentView 的 onAppear 和 onDisappear 控制背景音樂
//            .onAppear {
//                SoundManager.shared.playSound(named: "gamestart", loops: 0) // 開場音樂無限循環播放
//            }
//            .onDisappear {
//                // 當離開 ContentView 時（例如進入 RaceView），停止開場音樂
//                SoundManager.shared.stopSound(named: "gamestart")
//            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
