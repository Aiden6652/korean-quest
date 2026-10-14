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

/// 一个人声选项（进度页里可以直接挑）
struct VoiceOption: Identifiable, Hashable {
    let id: String      // AVSpeechSynthesisVoice.identifier
    let label: String   // "Yuna · 高级版 · 女声"
}

/// 韩语语音的音质档位。standard 就是那种很机械的电子音，
/// 下载「增强／高级」版之后同一个人声会自然很多。
enum VoiceGrade {
    case missing, standard, enhanced, premium

    var text: String {
        switch self {
        case .missing:  return "未安装韩语语音包"
        case .standard: return "标准版（机械音）"
        case .enhanced: return "增强版"
        case .premium:  return "高级版（最自然）"
        }
    }

    var shortHint: String? {
        switch self {
        case .missing:
            return "没装韩语语音包，现在是拿中文／英文在念。进度页有下载方法。"
        case .standard:
            return "现在是机械音，进度页可以换成增强／高级女声。"
        default:
            return nil
        }
    }

    var hint: String? {
        switch self {
        case .missing:
            return "系统没装韩语语音，现在是用中文／英文在念韩语，当然难听。到 设置 → 辅助功能 → 朗读内容 → 声音 → 韩语，下载一个。"
        case .standard:
            return "现在是标准版（机械音）。同一个人声还有「增强／高级」版：设置 → 辅助功能 → 朗读内容 → 声音 → 韩语，把增强或高级版下下来，再到下面挑它，念起来自然很多。"
        default:
            return nil
        }
    }
}

/// 默认实现：系统 TTS，韩语 ko-KR，不依赖任何外部音频文件。
final class SystemSpeech: SpeechProvider {
    static let shared = SystemSpeech()
    private let synth = AVSpeechSynthesizer()
    private var sessionReady = false
    private var cachedVoice: AVSpeechSynthesisVoice?
    private var didLookup = false

    /// 语速：0.42 那档偏慢，韩语慢速念最机械，默认抬到接近正常说话的速度
    private var rate: Double {
        let v = UserDefaults.standard.double(forKey: Speech.rateKey)
        return v <= 0 ? 0.5 : v
    }

    /// 设备上到底装没装韩语语音包
    var koreanVoiceInstalled: Bool { resolveVoice() != nil }

    var grade: VoiceGrade {
        guard let v = resolveVoice() else { return .missing }
        switch Int(v.quality.rawValue) {
        case 3: return .premium
        case 2: return .enhanced
        default: return .standard
        }
    }

    var voiceDescription: String {
        guard let v = resolveVoice() else { return "未安装韩语语音包" }
        return "\(v.name) · \(grade.text) · \(genderText(v))"
    }

    /// 进度页的人声列表：音质好的排前面
    var voiceOptions: [VoiceOption] {
        let korean = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("ko") }
        return korean.sorted { l, r in
            let lq = Int(l.quality.rawValue)
            let rq = Int(r.quality.rawValue)
            if lq != rq { return lq > rq }
            let lp = SystemSpeech.naturalness(l)
            let rp = SystemSpeech.naturalness(r)
            if lp != rp { return lp > rp }
            return l.name < r.name
        }.map { v in
            VoiceOption(id: v.identifier,
                        label: "\(v.name) · \(SystemSpeech.gradeText(v)) · \(SystemSpeech.genderText(v))")
        }
    }

    /// 换了人声之后让它重新挑一次
    func reloadVoice() {
        didLookup = false
        cachedVoice = nil
    }

    // MARK: 选人声

    private var preferredIdentifier: String? {
        let s = UserDefaults.standard.string(forKey: Speech.voiceIdKey)
        if let s = s, !s.isEmpty { return s }
        return nil
    }

    /// 优先级：手选的 > 女声里音质最好的 > 全部里音质最好的
    private func resolveVoice() -> AVSpeechSynthesisVoice? {
        if didLookup { return cachedVoice }
        didLookup = true

        let korean = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("ko") }

        if let id = preferredIdentifier,
           let picked = korean.first(where: { $0.identifier == id }) {
            cachedVoice = picked
            return picked
        }

        let females = korean.filter { $0.gender == .female }
        let pool = females.isEmpty ? korean : females
        cachedVoice = pool.sorted { l, r in
            let lq = Int(l.quality.rawValue)
            let rq = Int(r.quality.rawValue)
            if lq != rq { return lq > rq }
            let lp = SystemSpeech.naturalness(l)
            let rp = SystemSpeech.naturalness(r)
            if lp != rp { return lp > rp }
            let lkr = (l.language == "ko-KR") ? 1 : 0
            let rkr = (r.language == "ko-KR") ? 1 : 0
            return lkr > rkr
        }.first
        return cachedVoice
    }

    /// 同档位里 Siri / Yuna 那类比 compact 小体积包自然
    private static func naturalness(_ v: AVSpeechSynthesisVoice) -> Int {
        let id = v.identifier.lowercased()
        if id.contains("premium") || id.contains("siri") || id.contains("yuna") { return 3 }
        if id.contains("enhanced") { return 2 }
        if id.contains("compact") { return 0 }
        return 1
    }

    private static func gradeText(_ v: AVSpeechSynthesisVoice) -> String {
        switch Int(v.quality.rawValue) {
        case 3: return "高级版"
        case 2: return "增强版"
        default: return "标准版"
        }
    }

    private static func genderText(_ v: AVSpeechSynthesisVoice) -> String {
        switch v.gender {
        case .female: return "女声"
        case .male: return "男声"
        default: return "未知"
        }
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
        u.rate = Float(rate)
        u.pitchMultiplier = 1.0
        // 不跟随「朗读内容」里为无障碍调的慢速设置，否则念出来更慢更机械
        if #available(iOS 16.0, *) {
            u.prefersAssistiveVoiceSettings = false
        }
        synth.speak(u)
    }

    func stop() { synth.stopSpeaking(at: .immediate) }
}

/// 以后要换成豆包语音 API，只要再写一个实现了 SpeechProvider 的类，
/// 把 Speech.provider 换掉即可，其它代码一行都不用改。
/// final class DoubaoSpeech: SpeechProvider { ... }
enum Speech {
    /// 语速（0.3 慢 … 0.6 快），进度页可调
    static let rateKey = "kq.speechRate.v1"
    /// 手选的人声 identifier，空 = 自动（女声优先）
    static let voiceIdKey = "kq.voiceId.v1"

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

    static var grade: VoiceGrade {
        (provider as? SystemSpeech)?.grade ?? .premium
    }

    static var voiceOptions: [VoiceOption] {
        (provider as? SystemSpeech)?.voiceOptions ?? []
    }

    /// 换完人声/语速后调一下，立刻生效
    static func reloadVoice() {
        (provider as? SystemSpeech)?.reloadVoice()
    }
}
