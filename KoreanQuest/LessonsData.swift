import Foundation

private func wd(_ korean: String, _ roman: String, _ meaning: String) -> Word {
    Word(korean: korean, roman: roman, meaning: meaning)
}

private func mk(_ korean: String,
                _ answer: String,
                _ meaning: String? = nil,
                _ note: String? = nil,
                _ words: [Word] = []) -> Item {
    Item(korean: korean, answer: answer, meaning: meaning, note: note, words: words)
}

enum Lessons {

    // MARK: 1. 基础辅音
    static let lesson1 = Lesson(
        id: 1,
        title: "基础辅音",
        subtitle: "看字母选发音 · 10 个",
        mode: .roman,
        items: [
            mk("ㄱ", "g / k", nil, "词首偏 g，词中或做收音时偏 k。",
               [wd("가방", "gabang", "包"), wd("고기", "gogi", "肉"), wd("국", "guk", "汤")]),
            mk("ㄴ", "n", nil, "舌尖抵住上齿龈的鼻音。",
               [wd("나", "na", "我"), wd("누나", "nuna", "姐姐"), wd("나라", "nara", "国家")]),
            mk("ㄷ", "d / t", nil, "词首偏 d，词中或收音偏 t。",
               [wd("다리", "dari", "腿"), wd("도시", "dosi", "城市"), wd("두부", "dubu", "豆腐")]),
            mk("ㄹ", "r / l", nil, "夹在元音之间偏 r（轻弹一下舌头），做收音偏 l。",
               [wd("라면", "ramyeon", "拉面"), wd("로봇", "robot", "机器人"), wd("라디오", "radio", "收音机")]),
            mk("ㅁ", "m", nil, "闭唇鼻音，像「姆」。",
               [wd("머리", "meori", "头"), wd("모자", "moja", "帽子"), wd("마음", "maeum", "心")]),
            mk("ㅂ", "b / p", nil, "词首偏 b，收尾偏 p。",
               [wd("바다", "bada", "大海"), wd("비", "bi", "雨"), wd("밥", "bap", "饭")]),
            mk("ㅅ", "s", nil, "在 ㅣ、ㅑ 这类元音前读 sh（시 = shi）。",
               [wd("사람", "saram", "人"), wd("사과", "sagwa", "苹果"), wd("산", "san", "山")]),
            mk("ㅇ", "ng / 不发音", nil, "在音节最前面不发音，只占位；做收音时读 ng。",
               [wd("아기", "agi", "婴儿"), wd("우유", "uyu", "牛奶"), wd("안경", "angyeong", "眼镜")]),
            mk("ㅈ", "j", nil, "类似「鸡」的声母，不送气。",
               [wd("집", "jip", "家"), wd("지하철", "jihacheol", "地铁"), wd("잠", "jam", "睡觉")]),
            mk("ㅎ", "h", nil, "像「喝」，气流很轻。",
               [wd("하늘", "haneul", "天空"), wd("한국", "hanguk", "韩国"), wd("회사", "hoesa", "公司")])
        ]
    )

    // MARK: 2. 基础元音
    static let lesson2 = Lesson(
        id: 2,
        title: "基础元音",
        subtitle: "看字母选发音 · 6 个",
        mode: .roman,
        items: [
            mk("ㅏ", "a", nil, "类似「啊」，嘴自然张开。",
               [wd("아이", "ai", "孩子"), wd("아빠", "appa", "爸爸")]),
            mk("ㅓ", "eo", nil, "类似「哦」但嘴型扁、不圆唇。",
               [wd("어머니", "eomeoni", "妈妈"), wd("언니", "eonni", "姐姐"), wd("서울", "seoul", "首尔")]),
            mk("ㅗ", "o", nil, "圆唇的「哦」，嘴唇收圆。",
               [wd("오이", "oi", "黄瓜"), wd("오늘", "oneul", "今天"), wd("오리", "ori", "鸭子")]),
            mk("ㅜ", "u", nil, "圆唇的「乌」。",
               [wd("우산", "usan", "雨伞"), wd("우리", "uri", "我们"), wd("구두", "gudu", "皮鞋")]),
            mk("ㅡ", "eu", nil, "扁唇的「呃」，嘴角向两边拉开。",
               [wd("그림", "geurim", "画"), wd("음악", "eumak", "音乐"), wd("이름", "ireum", "名字")]),
            mk("ㅣ", "i", nil, "像「衣」。",
               [wd("시계", "sigye", "手表"), wd("시간", "sigan", "时间"), wd("피자", "pija", "披萨")])
        ]
    )

    // MARK: 3. 复合元音
    static let lesson3 = Lesson(
        id: 3,
        title: "复合元音",
        subtitle: "看字母选发音 · 13 个",
        mode: .roman,
        items: [
            mk("ㅑ", "ya", nil, "ㅣ 的嘴型 + ㅏ 的音。",
               [wd("야구", "yagu", "棒球"), wd("양", "yang", "羊")]),
            mk("ㅕ", "yeo", nil, "ㅣ 的嘴型 + ㅓ 的音。",
               [wd("여자", "yeoja", "女生"), wd("여기", "yeogi", "这里")]),
            mk("ㅛ", "yo", nil, "ㅣ 的嘴型 + ㅗ 的音。",
               [wd("요리", "yori", "料理"), wd("요즘", "yojeum", "最近")]),
            mk("ㅠ", "yu", nil, "ㅣ 的嘴型 + ㅜ 的音。",
               [wd("유리", "yuri", "玻璃"), wd("뉴스", "nyuseu", "新闻")]),
            mk("ㅐ", "ae", nil, "嘴张得比 ㅔ 大；现代韩语里两者几乎同音。",
               [wd("개", "gae", "狗"), wd("내일", "naeil", "明天"), wd("새", "sae", "鸟")]),
            mk("ㅔ", "e", nil, "嘴张得比 ㅐ 小一点。",
               [wd("네", "ne", "是 / 你的"), wd("세수", "sesu", "洗脸"), wd("메뉴", "menyu", "菜单")]),
            mk("ㅘ", "wa", nil, "ㅗ + ㅏ，快速连读。",
               [wd("과자", "gwaja", "饼干"), wd("사과", "sagwa", "苹果"), wd("왕", "wang", "王")]),
            mk("ㅝ", "wo", nil, "ㅜ + ㅓ。",
               [wd("원", "won", "韩元"), wd("사원", "sawon", "职员")]),
            mk("ㅙ", "wae", nil, "ㅗ + ㅐ；和 ㅚ、ㅞ 现代读音基本一样。",
               [wd("왜", "wae", "为什么"), wd("돼", "dwae", "可以")]),
            mk("ㅞ", "we", nil, "ㅜ + ㅔ，出现得很少，读音同 ㅙ。",
               [wd("웨딩", "weding", "婚礼"), wd("웨이터", "weiteo", "服务员")]),
            mk("ㅚ", "oe", nil, "写法是 ㅗ + ㅣ，实际大多读成 ㅙ。",
               [wd("외국", "oeguk", "外国"), wd("회사", "hoesa", "公司")]),
            mk("ㅟ", "wi", nil, "ㅜ + ㅣ。",
               [wd("위", "wi", "上面"), wd("귀", "gwi", "耳朵"), wd("취미", "chwimi", "爱好")]),
            mk("ㅢ", "ui", nil, "ㅡ + ㅣ；在词首接近「으이」，在词中常读成 ㅣ。",
               [wd("의자", "uija", "椅子"), wd("의사", "uisa", "医生")])
        ]
    )

    // MARK: 4. 紧音 + 送气音
    static let lesson4 = Lesson(
        id: 4,
        title: "紧音 + 送气音",
        subtitle: "紧音 5 个 + 送气音 4 个",
        mode: .roman,
        items: [
            mk("ㄲ", "kk", nil, "ㄱ 的紧音：喉咙先绷紧再出声，完全不送气。",
               [wd("꼬리", "kkori", "尾巴"), wd("아까", "akka", "刚才")]),
            mk("ㄸ", "tt", nil, "ㄷ 的紧音。",
               [wd("딸", "ddal", "女儿"), wd("떡", "tteok", "打糕"), wd("또", "tto", "又")]),
            mk("ㅃ", "pp", nil, "ㅂ 的紧音。",
               [wd("빵", "ppang", "面包"), wd("오빠", "oppa", "哥哥")]),
            mk("ㅆ", "ss", nil, "ㅅ 的紧音。",
               [wd("쌀", "ssal", "大米"), wd("씨앗", "ssiat", "种子")]),
            mk("ㅉ", "jj", nil, "ㅈ 的紧音。",
               [wd("짜장면", "jjajangmyeon", "炸酱面"), wd("진짜", "jinjja", "真的")]),
            mk("ㅋ", "k", nil, "ㄱ 的送气音，气流明显。",
               [wd("커피", "keopi", "咖啡"), wd("코", "ko", "鼻子"), wd("카메라", "kamera", "相机")]),
            mk("ㅌ", "t", nil, "ㄷ 的送气音。",
               [wd("토마토", "tomato", "西红柿"), wd("티켓", "tiket", "票")]),
            mk("ㅍ", "p", nil, "ㅂ 的送气音。",
               [wd("피자", "pija", "披萨"), wd("팔", "pal", "胳膊"), wd("포도", "podo", "葡萄")]),
            mk("ㅊ", "ch", nil, "ㅈ 的送气音。",
               [wd("치마", "chima", "裙子"), wd("친구", "chingu", "朋友"), wd("차", "cha", "车 / 茶")])
        ]
    )

    // MARK: 5. 单收音
    static let lesson5 = Lesson(
        id: 5,
        title: "单收音",
        subtitle: "看整字选读音 · 7 个收音",
        mode: .roman,
        items: [
            mk("강", "gang", "江、河", "收音 ㅇ 读 ng：강 = gang。"),
            mk("산", "san", "山", "收音 ㄴ 读 n。"),
            mk("물", "mul", "水", "收音 ㄹ 读 l。"),
            mk("밥", "bap", "饭", "收音 ㅂ 读 p，只闭唇不爆破。"),
            mk("집", "jip", "家", "收音 ㅂ 读 p。"),
            mk("곰", "gom", "熊", "收音 ㅁ 读 m。"),
            mk("밤", "bam", "夜晚 / 栗子", "收音 ㅁ 读 m。"),
            mk("곧", "got", "马上", "收音 ㄷ 读 t。"),
            mk("국", "guk", "汤", "收音 ㄱ 读 k。")
        ]
    )

    // MARK: 6. 双收音
    static let lesson6 = Lesson(
        id: 6,
        title: "双收音",
        subtitle: "看整字选读音 · 6 组双收音",
        mode: .roman,
        items: [
            mk("닭", "dak", "鸡", "ㄺ 收音只读 ㄱ → [닥]。"),
            mk("값", "gap", "价格", "ㅄ 收音只读 ㅂ → [갑]。"),
            mk("없다", "eoptta", "没有", "ㅄ 读 ㅂ，后面 ㄷ 变紧音 → [업따]。"),
            mk("앉다", "antta", "坐", "ㄵ 收音只读 ㄴ，后面 ㄷ 变紧音 → [안따]。"),
            mk("여덟", "yeodeol", "八", "ㄼ 收音读 ㄹ → [여덜]。"),
            mk("삶", "sam", "生活 / 人生", "ㄻ 收音读 ㅁ → [삼]。"),
            mk("읊다", "eupta", "吟诵", "ㄿ 收音读 ㅂ → [읍따]。")
        ]
    )

    // MARK: 7. 拼读实战
    static let lesson7 = Lesson(
        id: 7,
        title: "拼读实战",
        subtitle: "随机整字 · 综合拼读",
        mode: .roman,
        items: [
            mk("한국", "hanguk", "韩国", "한 = han（ㄴ收音），국 = guk（ㄱ收音）。"),
            mk("사람", "saram", "人", "람 = ram（ㅁ收音）。"),
            mk("음식", "eumsik", "食物", "음 = eum（ㅁ收音），식 = sik（ㄱ收音）。"),
            mk("친구", "chingu", "朋友", "两个音节都没有收音，直接拼。"),
            mk("오늘", "oneul", "今天", "늘 = neul（ㄹ收音）。"),
            mk("시간", "sigan", "时间", "간 = gan（ㄴ收音）。"),
            mk("가방", "gabang", "包", "방 = bang（ㅇ收音）。"),
            mk("학교", "hakgyo", "学校", "학 = hak（ㄱ收音），교 = gyo。"),
            mk("회사", "hoesa", "公司", "회 = hoe，사 = sa。"),
            mk("물", "mul", "水", "收音 ㄹ 读 l。")
        ]
    )

    // MARK: 8. 朋友圈解码
    static let lesson8 = Lesson(
        id: 8,
        title: "朋友圈解码",
        subtitle: "平语短句 · 看韩语选中文",
        mode: .meaning,
        items: [
            mk("오늘", "今天", nil, "日常聊天出现率极高。"),
            mk("진짜", "真的 / 真的吗", nil, "口语里也当「超、非常」用：진짜 맛있어 = 超好吃。"),
            mk("너무", "太 / 非常", nil, "너무 예뻐 = 太漂亮了。"),
            mk("완전", "完全 / 超级", nil, "口语里＝「超」：완전 좋아 = 超喜欢。"),
            mk("ㅋㅋㅋ", "哈哈（大笑）", nil, "ㅋ 越多笑得越夸张。"),
            mk("ㅎㅎ", "呵呵（轻笑 / 尴尬笑）", nil, "比 ㅋㅋ 收敛很多。"),
            mk("맛있네", "好吃耶", nil, "~네＝发现、感叹「……呢」。"),
            mk("좋군", "不错嘛", nil, "~군＝恍然大悟「原来……啊」。"),
            mk("알겠어", "知道了", nil, "平语，朋友之间用；敬语是 알겠어요。"),
            mk("몰라", "不知道", nil, "平语。"),
            mk("배고파", "好饿", nil, "배고프다 的平语形。"),
            mk("심심해", "好无聊", nil, "심심하다 的平语形。"),
            mk("어디야", "你在哪", nil, "约见面必问的一句。"),
            mk("뭐 해", "在干嘛", nil, "뭐 해? = 干嘛呢？"),
            mk("대박", "厉害了 / 绝了", nil, "惊讶、赞叹都能用。"),
            mk("헐", "天啊 / 无语", nil, "表示震惊、无奈。")
        ]
    )

    static let all: [Lesson] = [
        lesson1, lesson2, lesson3, lesson4,
        lesson5, lesson6, lesson7, lesson8
    ]
}
