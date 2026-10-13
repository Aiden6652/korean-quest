import SwiftUI

struct MapView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var teaching: Lesson?
    @State private var practicing: Lesson?

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
                Text("空心书本 = 这关的教学还没看，点关卡会先进教学；实心书本 = 已看过，随时点它复习。")
                    .font(.system(size: 12))
                    .foregroundColor(KQ.sub)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .background(KQ.bg.ignoresSafeArea())
        // 没看过教学的关卡：先教学，教学页点「开始练习」再进练习
        .fullScreenCover(item: $teaching) { lesson in
            LessonIntroView(
                lesson: lesson,
                onStart: {
                    store.markTaught(lesson.id)
                    teaching = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        practicing = lesson
                    }
                },
                onClose: { teaching = nil }
            )
        }
        .fullScreenCover(item: $practicing) { lesson in
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

            Button {
                guard unlocked else { return }
                SoundFX.tap()
                teaching = lesson
            } label: {
                Image(systemName: store.hasTaught(lesson.id) ? "book.fill" : "book")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(unlocked ? KQ.blue : KQ.locked)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(KQ.blue.opacity(unlocked ? 0.12 : 0.06)))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(KQ.locked, lineWidth: 2))
        .opacity(unlocked ? 1 : 0.75)
        .contentShape(Rectangle())
        .onTapGesture {
            guard unlocked else { return }
            SoundFX.tap()
            // 看过教学就直接练，没看过先看教学
            if store.hasTaught(lesson.id) {
                practicing = lesson
            } else {
                teaching = lesson
            }
        }
    }
}
