import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var showReset = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("我的进度")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(KQ.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)

                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        bigStat("\(store.passedCount)/\(Lessons.all.count)", "已通关", KQ.green)
                        bigStat("\(store.totalStars)/\(Lessons.all.count * 3)", "星星", KQ.yellow)
                        bigStat("\(store.streak)", "连续天数", KQ.red)
                    }
                    ProgressView(value: Double(store.passedCount),
                                 total: Double(Lessons.all.count))
                        .tint(KQ.green)
                    Text("答错的题会自动进错题本，下次随机出题会再考你。")
                        .font(.system(size: 12))
                        .foregroundColor(KQ.sub)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(KQ.locked, lineWidth: 2))

                mistakesCard

                Button { showReset = true } label: {
                    Text("清空所有进度")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(KQ.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(KQ.red.opacity(0.4), lineWidth: 2))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .background(KQ.bg.ignoresSafeArea())
        .alert("确定清空所有进度？", isPresented: $showReset) {
            Button("清空", role: .destructive) { store.resetAll() }
            Button("取消", role: .cancel) { }
        } message: {
            Text("关卡星星、错题本和连续天数都会被清除，无法恢复。")
        }
    }

    private var mistakesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("错题本")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(KQ.ink)
                Text("\(store.mistakes.count) 题")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(KQ.sub)
                Spacer()
                if !store.mistakes.isEmpty {
                    Button("全部清空") { store.clearMistakes() }
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(KQ.red)
                }
            }

            if store.mistakes.isEmpty {
                Text("错题本是空的，继续保持。")
                    .font(.system(size: 13))
                    .foregroundColor(KQ.sub)
                    .padding(.vertical, 6)
            } else {
                ForEach(store.mistakes) { m in
                    HStack(spacing: 8) {
                        Text("第\(m.lessonId)关")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(KQ.sub)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(KQ.locked))
                        Text(m.korean)
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundColor(KQ.ink)
                        Text(m.answer)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(KQ.red)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Button { Speech.speak(m.korean) } label: {
                            Image(systemName: "speaker.wave.1.fill")
                                .foregroundColor(KQ.blue)
                        }
                        .buttonStyle(.plain)
                        Button { store.removeMistake(m) } label: {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(KQ.green)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(KQ.locked, lineWidth: 2))
    }

    private func bigStat(_ value: String, _ title: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(KQ.sub)
        }
        .frame(maxWidth: .infinity)
    }
}
