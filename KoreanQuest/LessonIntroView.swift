import SwiftUI

/// 关卡教学页：先讲清楚这一关的规则，再进练习。
/// 从地图点没学过的关卡会先进这里，学过的关卡随时可以点书本图标回来复习。
struct LessonIntroView: View {
    let lesson: Lesson
    var onStart: () -> Void
    var onClose: () -> Void

    @State private var page = 0

    private var cards: [TeachCard] { lesson.teach?.cards ?? [] }
    private var goal: String { lesson.teach?.goal ?? lesson.subtitle }
    private var isLast: Bool { cards.isEmpty || page >= cards.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            header

            if cards.isEmpty {
                Spacer(minLength: 0)
                Text("这关暂时没有教学内容，直接开打吧。")
                    .font(.system(size: 15))
                    .foregroundColor(KQ.sub)
                Spacer(minLength: 0)
            } else {
                pageStrip
                TabView(selection: $page) {
                    ForEach(Array(cards.enumerated()), id: \.offset) { i, c in
                        TeachCardView(card: c)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            footer
        }
        .background(KQ.bg.ignoresSafeArea())
        .onDisappear { Speech.stop() }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(KQ.sub)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("第 \(lesson.id) 关 · \(lesson.title)")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(KQ.ink)
                    Text("先看教学，再做题")
                        .font(.system(size: 12))
                        .foregroundColor(KQ.sub)
                }

                Spacer(minLength: 0)

                if !cards.isEmpty {
                    Text("\(page + 1)/\(cards.count)")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(KQ.sub)
                }
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(KQ.green)
                Text(goal)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(KQ.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(KQ.green.opacity(0.10)))
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    // MARK: - 页码

    private var pageStrip: some View {
        HStack(spacing: 6) {
            ForEach(0..<cards.count, id: \.self) { i in
                Capsule()
                    .fill(i <= page ? KQ.green : KQ.locked)
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }

    // MARK: - 底部按钮

    private var footer: some View {
        VStack(spacing: 6) {
            Button {
                SoundFX.tap()
                if isLast {
                    onStart()
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) { page += 1 }
                }
            } label: {
                Text(isLast ? "开始练习" : "下一张")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical: 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(KQ.green))
                    .shadow(color: KQ.greenDark, radius: 0, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            Button {
                SoundFX.tap()
                onStart()
            } label: {
                Text("跳过教学，直接练")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(KQ.sub)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }
}

// MARK: - 单张教学卡

private struct TeachCardView: View {
    let card: TeachCard

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(card.title)
                    .font(.system(size: 21, weight: .heavy))
                    .foregroundColor(KQ.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(card.body)
                    .font(.system(size: 15))
                    .foregroundColor(KQ.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if let tip = card.tip {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(KQ.yellow)
                        Text(tip)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(KQ.sub)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 12).fill(KQ.yellow.opacity(0.14)))
                }

                if !card.examples.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("点一下听发音")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(KQ.sub)
                        ForEach(card.examples) { w in
                            Button {
                                Speech.speakKorean(w.korean)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "speaker.wave.1.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(KQ.blue)
                                    Text(w.korean)
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundColor(KQ.blue)
                                    Text(w.roman)
                                        .font(.system(size: 12))
                                        .foregroundColor(KQ.sub)
                                    Text(w.meaning)
                                        .font(.system(size: 12))
                                        .foregroundColor(KQ.sub)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(KQ.blue.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
        }
    }
}
