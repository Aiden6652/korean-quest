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
    static let orange = Color(red: 1.00, green: 0.58, blue: 0.05)
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
    private var cachedVoice: AVSpeechSynthesisVoice?
    private var didLookup = false

    /// 设备上到底装没装韩语语音包。没装的话系统会拿默认语言（中文/英文）去念韩语，
    /// 念出来的东西完全是另一回事，界面上必须提示用户去下载。
    var koreanVoiceInstalled: Bool { resolveVoice() != nil }

    var voiceDescription: String {
        guard let v = resolveVoice() else { return "未安装韩语语音包" }
        return "\(v.name)（\(v.language)）"
    }

    /// 从系统语音里挑一个韩语语音：音质高的优先，其次 ko-KR 本地化优先
    private func resolveVoice() -> AVSpeechSynthesisVoice? {
        if didLookup { return cachedVoice }
        didLookup = true
        let korean = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("ko") }
        cachedVoice = korean.sorted { l, r in
            let lq = Int(l.quality.rawValue)
            let rq = Int(r.quality.rawValue)
            if lq != rq { return lq > rq }
            let lkr = (l.language == "ko-KR") ? 1 : 0
            let rkr = (r.language == "ko-KR") ? 1 : 0
            return lkr > rkr
        }.first
        return cachedVoice
    }

    func speak(_ text: String) {
        if !sessionReady {
            let s = AVAudioSession.sharedInstance()
            try? s.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try? s.setActive(true)
            sessionReady = true
        }
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        // 找不到韩语语音时 AVSpeechSynthesisVoice(language:) 会返回 nil，
        // utterance.voice 置空会让系统用默认语言念——宁可保持 ko-KR 请求也不指定别的语种
        u.voice = resolveVoice() ?? AVSpeechSynthesisVoice(language: "ko-KR")
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

    /// 念一个题目/单词：先过发音修正表，再交给语音源
    static func speakKorean(_ korean: String) { provider.speak(Pronunciation.text(for: korean)) }

    /// 韩语语音包是否可用（自定义语音源时按可用处理）
    static var koreanVoiceInstalled: Bool {
        (provider as? SystemSpeech)?.koreanVoiceInstalled ?? true
    }

    static var voiceDescription: String {
        (provider as? SystemSpeech)?.voiceDescription ?? "自定义语音源"
    }
}
