# 韩语闯关 (Korean Quest)

从零开始的自学韩语 App。Swift + SwiftUI，16 个关卡共 200 道题，四选一随机出题，进度本地保存，GitHub Actions 编译出**不签名**的 `.ipa`。

> 面向场景：看懂朋友圈、日常聊天。**全部用平语，不学敬语。**

## 关卡

**第一部分：字母与拼读**

| # | 关卡 | 内容 | 形式 |
|---|------|------|------|
| 1 | 基础辅音 | ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅎ | 看字母选发音 |
| 2 | 基础元音 | ㅏㅓㅗㅜㅡㅣ | 看字母选发音 |
| 3 | 复合元音 | ㅑㅕㅛㅠㅐㅔㅘㅝㅙㅞㅚㅟㅢ | 看字母选发音 |
| 4 | 紧音 + 送气音 | ㄲㄸㅃㅆㅉ / ㅋㅌㅍㅊ | 看字母选发音 |
| 5 | 单收音 | ㄱㄴㄷㄹㅁㅂㅇ 作收音 | 看整字选读音 |
| 6 | 双收音 | ㄺㅄㄵㄼㄻㄿ | 看整字选读音 |
| 7 | 拼读实战 | 随机整字带收音 | 看整字选读音 |
| 8 | 朋友圈解码 | 平语短句、ㅋㅋ/ㅎㅎ、~네/~군 | 看韩语选中文 |

**第二部分：真正能用了**

| # | 关卡 | 内容 | 形式 |
|---|------|------|------|
| 9 | 音变规则 | 连音、ㅎ 脱落、紧音化（한국어、좋아、같이…） | 看词选读音 |
| 10 | 高频名词 | 사람、친구、돈、시간、전화… | 看韩语选中文 |
| 11 | 动词形容词 | 먹다、가다、하다、있다、없다… | 看韩语选中文 |
| 12 | 平语口语形 | 가、봐、해、줘、돼、안 돼… | 看韩语选中文 |
| 13 | 日常问答 | 밥 먹었어?、몇 시에?、잘 자、같이 가자… | 看韩语选中文 |
| 14 | 聊天缩略语 | ㅇㅇ ㅇㅋ ㅂㅂ ㄱㄱ ㄴㄴ ㅈㅅ ㄹㅇ… | 看韩语选中文 |
| 15 | 汉字词数字 | 일이삼사오육칠팔구십백천만 | 看韩语选中文 |
| 16 | 固有词数字 + 量词 | 하나둘셋넷…＋ 개 명 살 시 분 번 | 看韩语选中文 |

第 9 关是分水岭：前面是「认字」，第 9 关开始是「看懂真实句子」。第 14 关是韩国人打字真实用的缩写，朋友圈里最常见。

每关末尾都带例词（只认不背），答完题在反馈面板里显示，点小喇叭可朗读。

## 每关机制

- 随机出题，**四选一**，每局 16 题（题池不足 16 的全部出）
- 答对绿色、答错红色并高亮正确答案
- 正确率 **≥ 80%** 才过关（≥90% 两星，≥95% 三星）
- 错题进错题本；下次再答对会自动移出
- 3 颗红心，答错扣一颗，扣完重来
- 进度用 JSON 存进 `UserDefaults`（`kq.progress.v1`）

## 声音

- 答对：系统音效 `1057`
- 答错：`1053` + 震动
- 朗读：`AVSpeechSynthesizer`，语言 `ko-KR`
- 零外部音频文件。以后要换豆包语音 API，只要写一个实现 `SpeechProvider` 的类，把 `Speech.provider` 换掉即可，其它代码不用动

## 目录

```
korean-quest/
├── .github/workflows/build.yml        # CI：编译 + 打 ipa + 上传产物
├── KoreanQuest.xcodeproj/             # 已含共享 scheme
└── KoreanQuest/
    ├── KoreanQuestApp.swift           # App 入口 + 底部两个 Tab
    ├── Models.swift                   # 数据模型 / 出题 / ProgressStore（JSON 持久化）
    ├── LessonsData.swift              # 8 关全部题库
    ├── Services.swift                 # 配色 / 音效 / 触感 / 朗读接口
    ├── MapView.swift                  # 关卡地图
    ├── PracticeView.swift             # 练习界面
    ├── ResultView.swift               # 过关界面
    └── StatsView.swift                # 进度 + 错题本
```

## 本地跑

```bash
open KoreanQuest.xcodeproj
# 选 iPhone 模拟器，Cmd+R
```

真机需要你自己的开发者账号签名，这个工程默认不开签名。

## GitHub Actions 打 ipa 的步骤

1. 在 GitHub 建一个空仓库（不要勾选 README）。
2. 在本目录执行：
   ```bash
   git init
   git add .
   git commit -m "init korean quest"
   git remote add origin git@github.com:<你的用户名>/<仓库名>.git
   git branch -M main
   git push -u origin main
   ```
3. push 之后 Actions 自动跑（或去 Actions 页面点 `Build Unsigned IPA` → `Run workflow`）。
4. 跑完在本次运行的页面底部 **Artifacts** 下载 `KoreanQuest-unsigned-ipa`，解压得到 `KoreanQuest-unsigned.ipa`。

CI 里实际干的事：

```bash
# 1. 关闭签名编译
xcodebuild -project KoreanQuest.xcodeproj -scheme KoreanQuest \
  -configuration Release -sdk iphoneos -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  build

# 2. 按 IPA 规范打包（一个 Payload 目录 + zip）
mkdir -p Payload
cp -R build/Build/Products/Release-iphoneos/KoreanQuest.app Payload/
zip -qry KoreanQuest-unsigned.ipa Payload
```

## 关于这个 ipa

不签名的 ipa **不能直接双击装进普通 iPhone**，系统会拒绝。它的用途是：

- AltStore / Sideloadly 等工具重签后安装
- TrollStore（支持的系统版本）直接安装
- 越狱设备直接安装
- 自己用 `codesign` + 证书重签后安装

想要免重签直接装，就得把 workflow 里的 `CODE_SIGNING_ALLOWED=NO` 换成配置好证书和 provisioning profile 的正规签名流程。

## 改题库

所有题目都在 `KoreanQuest/LessonsData.swift`，一条长这样：

```swift
mk("닭", "dak", "鸡", "ㄺ 收音只读 ㄱ → [닥]。"),
mk("ㄱ", "g / k", nil, "词首偏 g，词中或做收音时偏 k。",
   [wd("가방", "gabang", "包"), wd("고기", "gogi", "肉")]),
```

参数顺序：`mk(韩语, 正确答案, 中文意思, 解析, [例词])`。
**同一关里正确答案不能重复**，否则干扰项会出问题。
