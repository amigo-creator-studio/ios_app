//
//  SoundManager.swift
//  horseRace
//
//  Created by Amigo Lu on 2025/11/30.
//

// SoundManager.swift
import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager() // 單例模式，確保只有一個音效管理器

    private var players: [String: AVAudioPlayer] = [:] // 儲存多個音效播放器

    private init() {} // 私有化初始化器，強制使用單例

    // 載入並預設音效，可以重複呼叫載入同一個音效
    func loadSound(named soundName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("Error: Sound file '\(soundName).\(fileExtension)' not found.")
            return
        }
        print("Sound file '\(soundName).\(fileExtension)' FOUND at URL: \(url)") // <-- 新增這行
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay() // 預先載入音訊，減少播放延遲
            players[soundName] = player // 儲存播放器
            print("Sound '\(soundName)' LOADED successfully.") // <-- 新增這行
        } catch {
            print("Error loading sound file \(soundName).\(fileExtension): \(error.localizedDescription)")
        }
    }

    // 播放音效
    func playSound(named soundName: String, loops: Int = 0) {
        guard let player = players[soundName] else {
            print("Error: Player for sound '\(soundName)' not loaded.")
            return
        }
        
        player.numberOfLoops = loops // 0表示不循環, -1表示無限循環
        player.play()
    }

    // 停止特定音效
    func stopSound(named soundName: String) {
        players[soundName]?.stop()
        players[soundName]?.currentTime = 0 // 重置播放進度
    }
    
    // 停止所有音效
    func stopAllSounds() {
        players.values.forEach { player in
            player.stop()
            player.currentTime = 0
        }
    }
}
