import SwiftUI

struct ResultView: View {
    let lesson: Lesson
    let result: SessionResult
    var onContinue: () -> Void
    var onRetry: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text(result.passed ? "过关！" : "再来一次")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(result.passed ? KQ.green : KQ.red)
                    .padding(.top, 26)

                if result.passed {
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < result.starCount ? "star.fill" : "star")
                                .font(.system(size: 40))
                                .foregroundColor(i < result.starCount ? KQ.yellow : KQ.locked)
                                .scaleEffect(i < result.starCount ? 1.0 : 0.82)
                        }
                    }
                } else {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(KQ.red)
                }

                VStack(spacing: 10) {
                    statRow("正确率", "\(result.percent)%", result.passed ? KQ.green : KQ.red)
                    statRow("答对", "\(result.correct.count) / \(result.total)", KQ.green)
                    statRow("答错", "\(result.wrong.count)", KQ.red)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(KQ.locked, lineWidth: 2))

                if !result.wrong.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("本轮错题（已存入错题本）")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(KQ.ink)
                        ForEach(result.wrong) { it in
                            HStack(spacing: 8) {
                                Text(it.korean)
                                    .font(.system(size: 17, weight: .heavy))
                                    .foregroundColor(KQ.ink)
                                Text(it.answer)
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(KQ.red)
                                Spacer(minLength: 0)
                                Button { Speech.speakKorean(it.korean) } label: {
                                    Image(systemName: "speaker.wave.1.fill")
                                        .foregroundColor(KQ.blue)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(KQ.locked, lineWidth: 2))
                }

                if !result.passed {
                    Text("正确率要到 80% 才算过关。把错题看一遍，再来一次吧。")
                        .font(.system(size: 13))
                        .foregroundColor(KQ.sub)
                        .multilineTextAlignment(.center)
                }

                Button {
                    if result.passed { onContinue() } else { onRetry() }
                } label: {
                    Text(result.passed ? "继续" : "重来一次")
                        .font(.system(size: 19, weight: .heavy))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(RoundedRectangle(cornerRadius: 16)
                            .fill(result.passed ? KQ.green : KQ.blue))
                        .shadow(color: result.passed ? KQ.greenDark : KQ.blueDark,
                                radius: 0, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                if result.passed {
                    Button("返回地图") { onContinue() }
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(KQ.sub)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(KQ.bg.ignoresSafeArea())
    }

    private func statRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(KQ.sub)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .heavy))
                .foregroundColor(color)
        }
    }
}
