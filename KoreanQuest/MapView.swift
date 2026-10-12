import SwiftUI

struct MapView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var active: Lesson?

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                banner
                ForEach(Lessons.all) { lesson in
                    node(lesson)
                }
                Text("每关正确率到 80% 才算过关，最高 3 颗星。")
                    .font(.system(size: 12))
                    .foregroundColor(KQ.sub)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .background(KQ.bg.ignoresSafeArea())
        .fullScreenCover(item: $active) { lesson in
            PracticeView(lesson: lesson) { result in
                store.finish(lesson: lesson,
                             accuracy: result.accuracy,
                             correct: result.correct,
                             wrong: result.wrong)
            }
        }
    }

    private var banner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("韩语闯关")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(KQ.ink)
                Text("已通关 \(store.passedCount)/\(Lessons.all.count) 关")
                    .font(.system(size: 13))
                    .foregroundColor(KQ.sub)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill").foregroundColor(KQ.yellow)
                Text("\(store.streak) 天")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(KQ.ink)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.white))
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private func node(_ lesson: Lesson) -> some View {
        let unlocked = store.isUnlocked(lesson.id)
        let s = store.stars(for: lesson.id)
        let main: Color = !unlocked ? KQ.locked : (s > 0 ? KQ.green : KQ.blue)

        return HStack(spacing: 14) {
            ZStack {
                Circle().fill(main.opacity(0.75)).frame(width: 68, height: 68).offset(y: 5)
                Circle().fill(main).frame(width: 68, height: 68)
                if s > 0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(.white)
                } else if unlocked {
                    Text("\(lesson.id)")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(lesson.title)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(KQ.ink)
                Text(lesson.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(KQ.sub)
                    .lineLimit(2)
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < s ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(i < s ? KQ.yellow : KQ.locked)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(KQ.locked, lineWidth: 2))
        .opacity(unlocked ? 1 : 0.75)
        .contentShape(Rectangle())
        .onTapGesture {
            if unlocked {
                SoundFX.tap()
                active = lesson
            }
        }
    }
}
