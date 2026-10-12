import Foundation
import SwiftUI

// MARK: - 数据模型（全部 Codable，可直接导出成 JSON）

struct Word: Codable, Hashable, Identifiable {
    var id: String { korean }
    let korean: String
    let roman: String
    let meaning: String
}

enum QuestionMode: String, Codable {
    case roman    // 看韩语，选罗马音
    case meaning  // 看韩语，选中文意思
}

struct Item: Codable, Hashable, Identifiable {
    var id: String { korean }
    let korean: String
    let answer: String
    var meaning: String? = nil
    var note: String? = nil
    var words: [Word] = []
}

struct Lesson: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let mode: QuestionMode
    let items: [Item]
}

// MARK: - 出题

struct Question: Identifiable {
    let id = UUID()
    let item: Item
    let options: [String]
}

enum QuestionFactory {
    /// 从本关题目里随机抽题，每题三选一干扰项 + 正确项，共四选一。
    static func make(for lesson: Lesson, limit: Int = 12) -> [Question] {
        var picked = lesson.items.shuffled()
        if picked.count > limit { picked = Array(picked.prefix(limit)) }
        let pool = Array(Set(lesson.items.map { $0.answer }))

        return picked.map { item in
            var others = pool.filter { $0 != item.answer }.shuffled()
            while others.count < 3 { others.append("——") }
            let options = (Array(others.prefix(3)) + [item.answer]).shuffled()
            return Question(item: item, options: options)
        }
    }
}

// MARK: - 一局结果

struct SessionResult {
    let accuracy: Double
    let correct: [Item]
    let wrong: [Item]

    var total: Int { correct.count + wrong.count }
    var percent: Int { Int((accuracy * 100).rounded()) }
    var passed: Bool { accuracy >= 0.8 }
    var starCount: Int {
        guard accuracy >= 0.8 else { return 0 }
        if accuracy >= 0.95 { return 3 }
        if accuracy >= 0.9 { return 2 }
        return 1
    }
}

// MARK: - 错题本

struct Mistake: Codable, Hashable, Identifiable {
    var id: String { "\(lessonId)-\(korean)" }
    let lessonId: Int
    let korean: String
    let answer: String
    let meaning: String?
}

// MARK: - 进度（JSON 存 UserDefaults）

final class ProgressStore: ObservableObject {
    @Published private(set) var stars: [Int: Int] = [:]
    @Published private(set) var mistakes: [Mistake] = []
    @Published private(set) var streak: Int = 0
    @Published private(set) var lastDay: String = ""

    private let key = "kq.progress.v1"

    private struct Snapshot: Codable {
        var stars: [String: Int] = [:]
        var mistakes: [Mistake] = []
        var streak: Int = 0
        var lastDay: String = ""
    }

    init() { load() }

    // MARK: 查询
    func isUnlocked(_ id: Int) -> Bool {
        id <= 1 || stars[id - 1] != nil
    }

    func stars(for id: Int) -> Int { stars[id] ?? 0 }

    var passedCount: Int { stars.count }
    var totalStars: Int { stars.values.reduce(0, +) }

    // MARK: 结算
    func finish(lesson: Lesson, accuracy: Double, correct: [Item], wrong: [Item]) {
        if accuracy >= 0.8 {
            let s = accuracy >= 0.95 ? 3 : (accuracy >= 0.9 ? 2 : 1)
            stars[lesson.id] = max(stars[lesson.id] ?? 0, s)
        }

        // 本轮考过的题：先把旧记录清掉，答错的再重新入本（答对的自动移出）
        let touched = Set(correct.map { $0.korean } + wrong.map { $0.korean })
        mistakes.removeAll { $0.lessonId == lesson.id && touched.contains($0.korean) }
        for item in wrong {
            mistakes.append(Mistake(lessonId: lesson.id,
                                    korean: item.korean,
                                    answer: item.answer,
                                    meaning: item.meaning))
        }

        touchStreak()
        save()
    }

    func removeMistake(_ m: Mistake) {
        mistakes.removeAll { $0.id == m.id }
        save()
    }

    func clearMistakes() {
        mistakes.removeAll()
        save()
    }

    func resetAll() {
        stars = [:]
        mistakes = []
        streak = 0
        lastDay = ""
        save()
    }

    // MARK: 连续学习天数
    private func touchStreak() {
        let today = ProgressStore.dayString(Date())
        if lastDay == today { return }
        let y = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterday = ProgressStore.dayString(y)
        streak = (lastDay == yesterday) ? streak + 1 : 1
        lastDay = today
    }

    static func dayString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    // MARK: 持久化
    private func save() {
        var s: [String: Int] = [:]
        for (k, v) in stars { s[String(k)] = v }
        let snap = Snapshot(stars: s, mistakes: mistakes, streak: streak, lastDay: lastDay)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        var s: [Int: Int] = [:]
        for (k, v) in snap.stars { if let i = Int(k) { s[i] = v } }
        stars = s
        mistakes = snap.mistakes
        streak = snap.streak
        lastDay = snap.lastDay
    }
}
