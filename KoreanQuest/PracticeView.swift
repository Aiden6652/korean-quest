import SwiftUI

struct PracticeView: View {
    let lesson: Lesson
    var onFinish: (SessionResult) -> Void

    @Environment(\.dismiss) private var dismiss

    @AppStorage("kq.autoSpeak.v1") private var autoSpeak = true
    @AppStorage("kq.voiceWarned.v1") private var voiceWarned = false
    @State private var showVoiceAlert = false

    @State private var questions: [Question] = []
    @State private var index = 0
    @State private var picked: String? = nil
    @State private var checked = false
    @State private var correctItems: [Item] = []
    @State private var wrongItems: [Item] = []
    @State private var lives = 3
    @State private var result: SessionResult? = nil
    @State private var showTeach = false

    private struct OptStyle {
        let fill: Color
        let border: Color
        let text: Color
    }

    var body: some View {
        ZStack {
            KQ.bg.ignoresSafeArea()

            if let r = result {
                ResultView(lesson: lesson,
                           result: r,
                           onContinue: { dismiss() },
                           onRetry: { restart() })
            } else if !questions.isEmpty {
                playing
            }
        }
        .onAppear {
            if questions.isEmpty { restart() }
            // 机械音／没装韩语语音包时，进来提醒一次怎么换人声
            if !voiceWarned && !Speech.grade.isNatural {
                voiceWarned = true
                showVoiceAlert = true
            }
        }
        .alert("朗读声音可以更好", isPresented: $showVoiceAlert) {
            Button("知道了", role: .cancel) { }
        } message: {
            Text(Speech.grade.hint ?? "")
        }
        .sheet(isPresented: $showTeach) {
            LessonIntroView(lesson: lesson,
                            onStart: { showTeach = false },
                            onClose: { showTeach = false })
        }
    }

    // MARK: - 练习主界面

    private var current: Question { questions[min(index, questions.count - 1)] }

    /// TTS 真正念的东西（可能和字面写法不同）
    private var spoken: String { Pronunciation.text(for: current.item.korean) }

    private var progress: Double {
        Double(index + (checked ? 1 : 0)) / Double(max(questions.count, 1))
    }

    private var playing: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(spacing: 14) {
                    card
                    options
                    if checked { feedback }
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 18)
            }
            bottomButton
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                Speech.stop()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(KQ.sub)
            }

            Button {
                SoundFX.tap()
                showTeach = true
            } label: {
                Image(systemName: "book.fill")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(KQ.blue)
            }
            .buttonStyle(.plain)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(KQ.locked).frame(height: 14)
                    Capsule().fill(KQ.green)
                        .frame(width: max(0, geo.size.width * progress), height: 14)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 20)

            HStack(spacing: 3) {
                Image(systemName: "heart.fill").foregroundColor(KQ.red)
                Text("\(max(lives, 0))")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(KQ.red)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }

    private var card: some View {
        VStack(spacing: 14) {
            Text(lesson.mode == .meaning ? "选出正确的中文意思" : "选出正确的读音")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(KQ.sub)

            Text(current.item.korean)
                .font(.system(size: current.item.korean.count > 3 ? 46 : 68, weight: .heavy))
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(KQ.ink)

            // 读的和写的不一样时（音变、缩写、单字母…）把实际读音标出来
            if Pronunciation.differs(current.item.korean) {
                Text(lesson.mode == .roman ? "实际读作 \(spoken)" : "读作 \(spoken)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(KQ.orange)
            }

            Button {
                Speech.speakKorean(current.item.korean)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(Pronunciation.differs(current.item.korean) ? "听实际发音" : "听发音")
                }
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(KQ.blue)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(KQ.blue.opacity(0.12)))
            }
            .buttonStyle(.plain)

            if !Speech.koreanVoiceInstalled {
                Text("设备没装韩语语音包，发音会不准：设置 → 辅助功能 → 朗读内容 → 声音 → 韩语，下载一个")
                    .font(.system(size: 12))
                    .foregroundColor(KQ.orange)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(KQ.locked, lineWidth: 2))
    }

    private var options: some View {
        VStack(spacing: 12) {
            ForEach(current.options, id: \.self) { opt in
                optionButton(opt)
            }
        }
    }

    private func optionButton(_ opt: String) -> some View {
        let st = optionStyle(opt)
        return Button {
            guard !checked else { return }
            picked = opt
            SoundFX.tap()
        } label: {
            Text(opt)
                .font(.system(size: 20, weight: .heavy))
                .minimumScaleFactor(0.6)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .foregroundColor(st.text)
                .background(RoundedRectangle(cornerRadius: 16).fill(st.fill))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(st.border, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func optionStyle(_ opt: String) -> OptStyle {
        if checked {
            if opt == current.item.answer {
                return OptStyle(fill: KQ.green, border: KQ.greenDark, text: .white)
            }
            if opt == picked {
                return OptStyle(fill: KQ.red, border: KQ.redDark, text: .white)
            }
            return OptStyle(fill: .white, border: KQ.locked, text: KQ.ink)
        }
        if opt == picked {
            return OptStyle(fill: KQ.blue.opacity(0.12), border: KQ.blue, text: KQ.blue)
        }
        return OptStyle(fill: .white, border: KQ.locked, text: KQ.ink)
    }

    private var feedback: some View {
        let ok = picked == current.item.answer
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                Text(ok ? "答对了！" : "答错了")
            }
            .font(.system(size: 17, weight: .heavy))
            .foregroundColor(ok ? KQ.green : KQ.red)

            if !ok {
                Text("正确答案：\(current.item.answer)")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(KQ.ink)
            }
            if let m = current.item.meaning {
                Text("意思：\(m)")
                    .font(.system(size: 14))
                    .foregroundColor(KQ.ink)
            }
            if let n = current.item.note {
                Text(n)
                    .font(.system(size: 13))
                    .foregroundColor(KQ.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !current.item.words.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(current.item.words) { w in
                        Button { Speech.speakKorean(w.korean) } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.1.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(KQ.blue)
                                Text(w.korean)
                                    .font(.system(size: 15, weight: .heavy))
                                    .foregroundColor(KQ.blue)
                                Text(w.roman)
                                    .font(.system(size: 13))
                                    .foregroundColor(KQ.sub)
                                Text(w.meaning)
                                    .font(.system(size: 13))
                                    .foregroundColor(KQ.sub)
                                Spacer(minLength: 0)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18)
            .fill(ok ? KQ.green.opacity(0.10) : KQ.red.opacity(0.10)))
    }

    private var buttonFill: Color {
        if !checked && picked == nil { return KQ.locked }
        if checked && picked != current.item.answer { return KQ.red }
        return KQ.green
    }

    private var buttonEdge: Color {
        if !checked && picked == nil { return KQ.locked }
        if checked && picked != current.item.answer { return KQ.redDark }
        return KQ.greenDark
    }

    private var bottomButton: some View {
        Button {
            if checked { advance() } else { check() }
        } label: {
            Text(checked ? "继续" : "检查")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16).fill(buttonFill))
                .shadow(color: buttonEdge, radius: 0, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 14)
        .background(KQ.bg)
    }

    // MARK: - 流程

    private func check() {
        guard let p = picked, !checked else { return }
        checked = true
        if p == current.item.answer {
            correctItems.append(current.item)
            SoundFX.correct()
            Haptics.ok()
        } else {
            wrongItems.append(current.item)
            lives -= 1
            SoundFX.wrong()
            Haptics.bad()
        }
        // 判完后念一遍实际发音，把「看到的」和「听到的」对上
        let text = current.item.korean
        if autoSpeak {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                Speech.speakKorean(text)
            }
        }
    }

    private func advance() {
        if lives <= 0 || index + 1 >= questions.count {
            finishSession()
        } else {
            index += 1
            picked = nil
            checked = false
        }
    }

    private func finishSession() {
        let total = questions.count
        let acc = total == 0 ? 0 : Double(correctItems.count) / Double(total)
        let r = SessionResult(accuracy: acc, correct: correctItems, wrong: wrongItems)
        Speech.stop()
        result = r
        onFinish(r)
    }

    private func restart() {
        questions = QuestionFactory.make(for: lesson)
        index = 0
        picked = nil
        checked = false
        correctItems = []
        wrongItems = []
        lives = 3
        result = nil
    }
}
