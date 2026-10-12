import Foundation
import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox

// MARK: - 配色（多邻国风）
enum KQ {
    static let green = Color(red: 0.35, green: 0.79, blue: 0.02)
    static let greenDark = Color(red: 0.27, green: 0.62, blue: 0.01)
    static let red = Color(red: 1.00, green: 0.29, blue: 0.29)
    static let redDark = Color(red: 0.80, green: 0.19, blue: 0.19)
    static let blue = Color(red: 0.11, green: 0.69, blue: 0.96)
    static let blueDark = Color(red: 0.08, green: 0.53, blue: 0.75)
    static let yellow = Color(red: 1.00, green: 0.78, blue: 0.00)
    static let locked = Color(red: 0.90, green: 0.91, blue: 0.92)
    static let bg = Color(red: 0.97, green: 0.98, blue: 0.98)
    static let ink = Color(red: 0.24, green: 0.28, blue: 0.33)
    static let sub = Color(red: 0.56, green: 0.60, blue: 0.65)
}

// MARK: - 系统音效
enum SoundFX {
    /// 答对：1057
    static func correct() { AudioServicesPlaySystemSound(1057) }
    /// 答错：1053 + 震动
    static func wrong() {
        AudioServicesPlaySystemSound(1053)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    static func tap() { AudioServicesPlaySystemSound(1104) }
}

// MARK: - 触感
enum Haptics {
    static func ok() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func bad() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}

// MARK: - 发音朗读（预留可替换接口）
protocol SpeechProvider {
    func speak(_ text: String)
    func stop()
}

/// 默认实现：系统 TTS，韩语 ko-KR，不依赖任何外部音频文件。
final class SystemSpeech: SpeechProvider {
    static let shared = SystemSpeech()
    private let synth = AVSpeechSynthesizer()
    private var sessionReady = false

    func speak(_ text: String) {
        if !sessionReady {
            let s = AVAudioSession.sharedInstance()
            try? s.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try? s.setActive(true)
            sessionReady = true
        }
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        u.rate = 0.42
        u.pitchMultiplier = 1.0
        synth.speak(u)
    }

    func stop() { synth.stopSpeaking(at: .immediate) }
}

/// 以后要换成豆包语音 API，只要再写一个实现了 SpeechProvider 的类，
/// 把 Speech.provider 换掉即可，其它代码一行都不用改。
/// final class DoubaoSpeech: SpeechProvider { ... }
enum Speech {
    static var provider: SpeechProvider = SystemSpeech.shared
    static func speak(_ text: String) { provider.speak(text) }
    static func stop() { provider.stop() }
}
