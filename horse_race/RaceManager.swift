// RaceManager.swift
import Foundation
import SwiftUI

class RaceManager: ObservableObject {
    @Published var horses: [Horse]
    @Published var raceHasStarted: Bool = false
    @Published var raceIsOver: Bool = false
    @Published var winner: Horse?
    @Published var raceTime: Int = 0

    // MARK: - 新增天氣相關屬性
    @Published var currentWeather: WeatherEvent? = .sunny // 當前天氣事件，初始為晴朗
    private var weatherTimer: Timer? = nil // 用於控制天氣持續時間的計時器
    private let weatherChangeProbability: Double = 0.1 // 每秒改變天氣的機率 (10%)
    private let minWeatherDuration: Int = 50 // 天氣持續的最短時間 (0.1秒為單位，所以是5秒)
    private let maxWeatherDuration: Int = 100 // 天氣持續的最長時間 (10秒)
    private var currentWeatherDuration: Int = 0 // 當前天氣已持續的時間
    private var scheduledWeatherChangeTime: Int = 0 // 預計下次天氣變化的時間點

    private var timer: Timer?

    let targetDistance: Double
    
    init(horses: [Horse], targetDistance: Double = 10.0) {
        self.horses = horses
        self.targetDistance = targetDistance
        
        for horse in self.horses {
            horse.targetDistance = targetDistance
        }
    }

    // MARK: - 比賽控制 (修改 startRace, stopRace 方法)

    func startRace() {
        guard !raceHasStarted else { return }

        raceHasStarted = true
        raceIsOver = false
        winner = nil
        raceTime = 0
        currentWeather = .sunny // 比賽開始時重置為晴朗
        scheduledWeatherChangeTime = Int.random(in: minWeatherDuration...maxWeatherDuration)
        currentWeatherDuration = 0

        horses.forEach { horse in
            horse.currentDistance = 0.0
            horse.isFinished = false
            horse.currentSpeed = horse.baseSpeedPerSecond
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.raceTime += 1 // 內部秒數累計 (0.1秒一個單位)

            // MARK: - 新增：天氣變化邏輯
            self.currentWeatherDuration += 1
            if self.currentWeatherDuration >= self.scheduledWeatherChangeTime {
                self.changeWeather() // 觸發天氣變化
                self.scheduledWeatherChangeTime = Int.random(in: self.minWeatherDuration...self.maxWeatherDuration) // 重新排程下一次變化
                self.currentWeatherDuration = 0 // 重置計數器
            }


            var allHorsesFinished = true
            for horse in self.horses {
                if !horse.isFinished {
                    // 更新馬匹狀態時傳入當前天氣
                    horse.update(timeElapsed: 0.1, currentWeather: self.currentWeather) // <-- 傳遞天氣
                    if !horse.isFinished {
                        allHorsesFinished = false
                    }
                }
            }

            if let firstHorseToFinish = self.horses.first(where: { $0.isFinished }) {
                if self.winner == nil {
                    self.winner = firstHorseToFinish
                }
            }

            if allHorsesFinished || self.winner != nil {
                self.stopRace()
            }
        }
    }

    func stopRace() {
        timer?.invalidate()
        timer = nil
        raceIsOver = true
        raceHasStarted = false
        currentWeather = nil // 比賽結束後清除天氣狀態
        
        horses.forEach { horse in
            if horse.currentDistance > targetDistance {
                horse.currentDistance = targetDistance
            }
        }
        
        horses.sort { $0.currentDistance > $1.currentDistance }
    }
    
    // MARK: - 新增：隨機改變天氣事件
    private func changeWeather() {
        // 隨機選擇一個天氣事件 (除了晴朗，讓晴朗作為預設)
        var possibleWeathers = WeatherEvent.allCases.filter { $0 != .sunny }
        possibleWeathers.append(.sunny) // 也可以選擇變回晴朗

        if let newWeather = possibleWeathers.randomElement() {
            if newWeather != currentWeather { // 只有當天氣真正改變時才打印和播放音效
                print("天氣變化為: \(newWeather.rawValue)")
                SoundManager.shared.playSound(named: "weather_\(newWeather.rawValue.lowercased())", loops: 0) // 播放天氣音效
                currentWeather = newWeather
            } else {
                // 如果隨機到相同天氣，則不會變更
            }
        }
    }
}
