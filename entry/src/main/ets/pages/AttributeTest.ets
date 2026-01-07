/**
 * 神兵图录 - 属性测试页
 * 通过回答问题测试与用户最相配的神兵属性
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getAttributeColor, getAttributeDarkColor } from '../common/Theme'
import { RouterPath, AttributeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

/**
 * 测试选项类
 */
class TestOption {
  text: string = ''
  attributes: string[] = []

  constructor(text: string, attributes: string[]) {
    this.text = text
    this.attributes = attributes
  }
}

/**
 * 测试题目类
 */
class TestQuestion {
  id: number = 0
  question: string = ''
  options: TestOption[] = []

  constructor(id: number, question: string, options: TestOption[]) {
    this.id = id
    this.question = question
    this.options = options
  }
}

/**
 * 属性描述类
 */
class AttributeDescription {
  name: string = ''
  description: string = ''
  personality: string = ''

  constructor(name: string, description: string, personality: string) {
    this.name = name
    this.description = description
    this.personality = personality
  }
}

/**
 * 测试结果类
 */
class TestResult {
  attribute: string = ''
  name: string = ''
  description: string = ''
  personality: string = ''
  weapons: LegendaryWeapon[] = []

  constructor(attribute: string, name: string, description: string, personality: string, weapons: LegendaryWeapon[]) {
    this.attribute = attribute
    this.name = name
    this.description = description
    this.personality = personality
    this.weapons = weapons
  }
}

@Entry
@Component
struct AttributeTest {
  @State isLoading: boolean = true
  @State currentQuestionIndex: number = 0
  @State isTestComplete: boolean = false
  @State result: TestResult | null = null
  @State allWeapons: LegendaryWeapon[] = []
  @State attributeScores: Record<string, number> = {}
  @State selectedOption: number = -1
  @State isTransitioning: boolean = false

  private dataLoader: DataLoader | null = null

  // 测试题目列表
  private questions: TestQuestion[] = this.initQuestions()

  /**
   * 初始化测试题目
   */
  private initQuestions(): TestQuestion[] {
    const result: TestQuestion[] = []

    // 题目1
    const q1Options: TestOption[] = []
    q1Options.push(new TestOption('勇往直前，直接解决', ['fire', 'thunder']))
    q1Options.push(new TestOption('冷静分析，寻找最优解', ['water', 'ice']))
    q1Options.push(new TestOption('顺其自然，等待时机', ['wind', 'nature']))
    q1Options.push(new TestOption('坚守阵地，稳步推进', ['earth', 'light']))
    result.push(new TestQuestion(1, '面对困难时，你通常会？', q1Options))

    // 题目2
    const q2Options: TestOption[] = []
    q2Options.push(new TestOption('领导者，带领团队冲锋', ['fire', 'light']))
    q2Options.push(new TestOption('策略师，制定计划方案', ['water', 'dark']))
    q2Options.push(new TestOption('执行者，完成具体任务', ['earth', 'thunder']))
    q2Options.push(new TestOption('协调者，维护团队和谐', ['wind', 'nature']))
    result.push(new TestQuestion(2, '在团队中，你更倾向于扮演什么角色？', q2Options))

    // 题目3
    const q3Options: TestOption[] = []
    q3Options.push(new TestOption('熊熊燃烧的火山', ['fire', 'earth']))
    q3Options.push(new TestOption('平静深邃的深海', ['water', 'dark']))
    q3Options.push(new TestOption('电闪雷鸣的风暴', ['thunder', 'wind']))
    q3Options.push(new TestOption('晶莹剔透的冰川', ['ice', 'light']))
    result.push(new TestQuestion(3, '哪种自然景观最吸引你？', q3Options))

    // 题目4
    const q4Options: TestOption[] = []
    q4Options.push(new TestOption('操控火焰，焚尽一切', ['fire']))
    q4Options.push(new TestOption('召唤雷电，威震八方', ['thunder']))
    q4Options.push(new TestOption('控制时间，洞察万物', ['light', 'dark']))
    q4Options.push(new TestOption('掌控自然，万物为用', ['nature', 'earth']))
    result.push(new TestQuestion(4, '如果能拥有一种超能力，你会选择？', q4Options))

    // 题目5
    const q5Options: TestOption[] = []
    q5Options.push(new TestOption('立刻站出来抗争', ['fire', 'light']))
    q5Options.push(new TestOption('暗中收集证据再行动', ['dark', 'water']))
    q5Options.push(new TestOption('寻求合适的渠道解决', ['wind', 'earth']))
    q5Options.push(new TestOption('以德报怨，感化对方', ['light', 'nature']))
    result.push(new TestQuestion(5, '遇到不公正的事情，你会？', q5Options))

    // 题目6
    const q6Options: TestOption[] = []
    q6Options.push(new TestOption('爆发力强，速战速决', ['fire', 'thunder']))
    q6Options.push(new TestOption('持久稳健，以守为攻', ['earth', 'ice']))
    q6Options.push(new TestOption('灵活多变，出其不意', ['wind', 'water']))
    q6Options.push(new TestOption('暗影突袭，一击致命', ['dark', 'poison']))
    result.push(new TestQuestion(6, '你更喜欢什么样的战斗风格？', q6Options))

    // 题目7
    const q7Options: TestOption[] = []
    q7Options.push(new TestOption('勇气和热情', ['fire', 'light']))
    q7Options.push(new TestOption('智慧和冷静', ['water', 'ice']))
    q7Options.push(new TestOption('坚韧和耐心', ['earth', 'nature']))
    q7Options.push(new TestOption('自由和适应', ['wind', 'thunder']))
    result.push(new TestQuestion(7, '你认为最重要的品质是？', q7Options))

    // 题目8
    const q8Options: TestOption[] = []
    q8Options.push(new TestOption('盛夏，热情似火', ['fire']))
    q8Options.push(new TestOption('寒冬，沉静内敛', ['ice', 'dark']))
    q8Options.push(new TestOption('春天，生机勃勃', ['nature', 'light']))
    q8Options.push(new TestOption('秋天，成熟稳重', ['earth', 'wind']))
    result.push(new TestQuestion(8, '最能代表你心境的季节是？', q8Options))

    return result
  }

  // 属性描述 - 使用方法初始化以避免 ArkTS 对象字面量限制
  private attributeDescriptions: Map<string, AttributeDescription> = this.initAttributeDescriptions()

  /**
   * 初始化属性描述
   */
  private initAttributeDescriptions(): Map<string, AttributeDescription> {
    const map = new Map<string, AttributeDescription>()
    map.set('fire', new AttributeDescription('火属性', '你如烈焰般热情奔放，拥有无尽的能量与斗志。', '热情、勇敢、直率、富有感染力'))
    map.set('water', new AttributeDescription('水属性', '你如流水般智慧通透，善于适应变化并包容万物。', '冷静、智慧、灵活、富有洞察力'))
    map.set('ice', new AttributeDescription('冰属性', '你如寒冰般冷静理性，拥有超然的判断力与意志力。', '理性、坚定、自律、内心强大'))
    map.set('thunder', new AttributeDescription('雷属性', '你如雷电般迅猛果断，拥有惊人的爆发力与执行力。', '果断、敏捷、爆发力强、不拖泥带水'))
    map.set('wind', new AttributeDescription('风属性', '你如清风般自由洒脱，向往自由并善于变通。', '自由、洒脱、灵活、善于沟通'))
    map.set('earth', new AttributeDescription('土属性', '你如大地般坚实可靠，是值得信赖的中坚力量。', '稳重、可靠、有耐心、脚踏实地'))
    map.set('light', new AttributeDescription('光属性', '你如阳光般正义光明，拥有照亮他人的力量。', '正义、乐观、富有领导力、鼓舞人心'))
    map.set('dark', new AttributeDescription('暗属性', '你如暗夜般深邃神秘，拥有洞察本质的智慧。', '深沉、神秘、洞察力强、不拘常规'))
    map.set('nature', new AttributeDescription('木属性', '你如草木般生生不息，拥有蓬勃的生命力与包容心。', '温和、有生命力、善于成长、包容'))
    map.set('poison', new AttributeDescription('毒属性', '你如毒药般另辟蹊径，善于用非常规手段解决问题。', '机智、冷酷、精于算计、手段多样'))
    return map
  }

  aboutToAppear(): void {
    this.initScores()
    this.loadData()
  }

  /**
   * 初始化属性分数
   */
  initScores(): void {
    this.attributeScores = {
      'fire': 0,
      'water': 0,
      'ice': 0,
      'thunder': 0,
      'wind': 0,
      'earth': 0,
      'light': 0,
      'dark': 0,
      'nature': 0,
      'poison': 0
    }
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.allWeapons = await this.dataLoader.loadWeapons()
      this.isLoading = false
    } catch (error) {
      console.error('[AttributeTest] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 选择答案
   */
  selectOption(optionIndex: number): void {
    if (this.isTransitioning) return

    this.selectedOption = optionIndex
    const currentQuestion = this.questions[this.currentQuestionIndex]
    const selectedAttributes = currentQuestion.options[optionIndex].attributes

    // 增加对应属性的分数
    selectedAttributes.forEach(attr => {
      if (this.attributeScores[attr] !== undefined) {
        this.attributeScores[attr] += 1
      }
    })

    // 延迟进入下一题
    this.isTransitioning = true
    setTimeout(() => {
      if (this.currentQuestionIndex < this.questions.length - 1) {
        this.currentQuestionIndex++
        this.selectedOption = -1
      } else {
        this.calculateResult()
      }
      this.isTransitioning = false
    }, 500)
  }

  /**
   * 计算测试结果
   */
  calculateResult(): void {
    // 找出得分最高的属性
    let maxScore = 0
    let topAttribute = 'fire'

    Object.keys(this.attributeScores).forEach(attr => {
      if (this.attributeScores[attr] > maxScore) {
        maxScore = this.attributeScores[attr]
        topAttribute = attr
      }
    })

    // 获取属性描述 - 使用 Map.get()
    let attrDesc = this.attributeDescriptions.get(topAttribute)
    if (!attrDesc) {
      // 创建默认描述
      const defaultName = AttributeNames[topAttribute] || '未知'
      attrDesc = new AttributeDescription(defaultName, '你拥有独特的属性特质。', '独特、神秘')
    }

    // 获取该属性的神兵推荐
    const matchingWeapons = this.allWeapons.filter(w =>
      w.attributes?.primary === topAttribute || w.attributes?.secondary === topAttribute
    ).slice(0, 3)

    // 使用 TestResult 构造函数创建结果
    this.result = new TestResult(
      topAttribute,
      attrDesc.name,
      attrDesc.description,
      attrDesc.personality,
      matchingWeapons
    )

    this.isTestComplete = true
  }

  /**
   * 重新测试
   */
  restartTest(): void {
    this.initScores()
    this.currentQuestionIndex = 0
    this.selectedOption = -1
    this.isTestComplete = false
    this.result = null
  }

  /**
   * 分享测试结果（复制到剪贴板）
   */
  async shareResult(): Promise<void> {
    if (!this.result) return

    try {
      // 构建分享文本
      const weaponNames = this.result.weapons.map(w => w.name?.cn || '').join('、')
      const shareText = `【神兵图录·属性测试】\n\n` +
        `测试结果：${this.result.name}\n` +
        `性格特点：${this.result.personality}\n` +
        `${this.result.description}\n\n` +
        `推荐神兵：${weaponNames || '暂无'}\n\n` +
        `来测测你是什么属性的战士吧！`

      // 复制到剪贴板
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, shareText)
      const systemPasteboard = pasteboard.getSystemPasteboard()
      await systemPasteboard.setData(pasteboardData)

      // 显示提示
      promptAction.showToast({
        message: '测试结果已复制到剪贴板，可以分享给好友了',
        duration: 2000
      })

      console.info('[AttributeTest] 分享文本已复制到剪贴板')
    } catch (error) {
      console.error('[AttributeTest] 复制失败:', JSON.stringify(error))
      promptAction.showToast({
        message: '复制失败，请重试',
        duration: 2000
      })
    }
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    router.back()
  }

  /**
   * 跳转到神兵详情
   */
  navigateToWeaponDetail(weaponId: string): void {
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId }
    })
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_divination'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor(ThemeColors.TEXT_PRIMARY)
            .onClick(() => this.goBack())

          Text('属性测试')
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_TITLE)
            .margin({ left: Spacing.MEDIUM })

          Blank()

          if (!this.isTestComplete && !this.isLoading) {
            Text(`${this.currentQuestionIndex + 1}/${this.questions.length}`)
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

        if (this.isLoading) {
          this.LoadingView()
        } else if (this.isTestComplete) {
          this.ResultView()
        } else {
          this.QuestionView()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 加载视图
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.GOLD_PRIMARY)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 问题视图
   */
  @Builder
  QuestionView() {
    Column() {
      // 进度条
      Row() {
        ForEach(this.questions, (q: TestQuestion, index: number) => {
          Column()
            .width(index <= this.currentQuestionIndex ? 24 : 8)
            .height(4)
            .backgroundColor(index <= this.currentQuestionIndex ?
              ThemeColors.GOLD_PRIMARY : ThemeColors.SURFACE_0)
            .borderRadius(2)
            .margin({ right: 4 })
            .animation({ duration: 300 })
        }, (q: TestQuestion) => q.id.toString())
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      Blank().layoutWeight(1)

      // 问题
      Text(this.questions[this.currentQuestionIndex].question)
        .fontSize(FontSizes.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_TITLE)
        .textAlign(TextAlign.Center)
        .padding({ left: Spacing.XLARGE, right: Spacing.XLARGE })

      Blank().height(Spacing.XLARGE)

      // 选项
      Column() {
        ForEach(this.questions[this.currentQuestionIndex].options, (option: TestOption, index: number) => {
          this.OptionItem(option, index)
        }, (opt: TestOption, index: number) => `${this.currentQuestionIndex}_${index}_${opt.text}`)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .key(`question_${this.currentQuestionIndex}`)

      Blank().layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 结果视图
   */
  @Builder
  ResultView() {
    if (this.result) {
      Scroll() {
        Column() {
          // 属性图标背景
          Column() {
            Text(this.result.name)
              .fontSize(FontSizes.TITLE_LARGE)
              .fontWeight(FontWeight.Bold)
              .fontColor(getAttributeColor(this.result.attribute))
          }
          .width(120)
          .height(120)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(getAttributeDarkColor(this.result.attribute))
          .borderRadius(60)
          .border({
            width: 3,
            color: getAttributeColor(this.result.attribute)
          })
          .margin({ top: Spacing.XLARGE })

          // 属性名称
          Text(`你是${this.result.name}战士!`)
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_TITLE)
            .margin({ top: Spacing.LARGE })

          // 描述
          Text(this.result.description)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .margin({ top: Spacing.MEDIUM })
            .padding({ left: Spacing.XLARGE, right: Spacing.XLARGE })

          // 性格特点
          Column() {
            Text('性格特点')
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.TEXT_TERTIARY)

            Text(this.result.personality)
              .fontSize(FontSizes.BODY)
              .fontColor(getAttributeColor(this.result.attribute))
              .fontWeight(FontWeight.Medium)
              .margin({ top: Spacing.SMALL })
          }
          .width('100%')
          .padding(Spacing.MEDIUM)
          .margin({ top: Spacing.LARGE, left: Spacing.LARGE, right: Spacing.LARGE })
          .backgroundColor(ThemeColors.SURFACE_0)
          .borderRadius(Spacing.MEDIUM)

          // 推荐神兵
          if (this.result.weapons.length > 0) {
            Column() {
              Text('与你相配的神兵')
                .fontSize(FontSizes.SUBTITLE)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.TEXT_TITLE)
                .margin({ bottom: Spacing.MEDIUM })

              ForEach(this.result.weapons, (weapon: LegendaryWeapon) => {
                Row() {
                  Image($rawfile(`images/${weapon.image ?? 'weapon_default.png'}`))
                    .width(60)
                    .height(60)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Spacing.SMALL)

                  Column() {
                    Text(weapon.name?.cn ?? '')
                      .fontSize(FontSizes.BODY)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(ThemeColors.TEXT_TITLE)

                    Text(weapon.description ?? '')
                      .fontSize(FontSizes.CAPTION)
                      .fontColor(ThemeColors.TEXT_TERTIARY)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ top: Spacing.TINY })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: Spacing.MEDIUM })
                  .layoutWeight(1)

                  Image($r('app.media.icon_arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor(ThemeColors.TEXT_TERTIARY)
                }
                .width('100%')
                .padding(Spacing.MEDIUM)
                .backgroundColor(ThemeColors.SURFACE_0)
                .borderRadius(Spacing.MEDIUM)
                .margin({ bottom: Spacing.SMALL })
                .onClick(() => this.navigateToWeaponDetail(weapon.id))
              }, (w: LegendaryWeapon) => w.id)
            }
            .width('100%')
            .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
            .margin({ top: Spacing.XLARGE })
            .alignItems(HorizontalAlign.Start)
          }

          // 按钮
          Row() {
            Column() {
              Text('重新测试')
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.TEXT_PRIMARY)
            }
            .width(120)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.SURFACE_0)
            .borderRadius(22)
            .border({ width: 1, color: ThemeColors.DIVIDER })
            .onClick(() => this.restartTest())

            Column() {
              Text('分享结果')
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.BASE_0)
                .fontWeight(FontWeight.Bold)
            }
            .width(120)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.GOLD_PRIMARY)
            .borderRadius(22)
            .margin({ left: Spacing.MEDIUM })
            .onClick(() => this.shareResult())
          }
          .margin({ top: Spacing.XLARGE })

          Blank().height(Spacing.XXLARGE)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  /**
   * 选项项
   */
  @Builder
  OptionItem(option: TestOption, index: number) {
    Row() {
      Text(String.fromCharCode(65 + index))
        .fontSize(FontSizes.BODY)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedOption === index ? ThemeColors.BASE_0 : ThemeColors.GOLD_PRIMARY)
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.selectedOption === index ?
          ThemeColors.GOLD_PRIMARY : 'transparent')
        .borderRadius(16)
        .border({
          width: 2,
          color: ThemeColors.GOLD_PRIMARY
        })

      Text(option.text)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ left: Spacing.MEDIUM })
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(this.selectedOption === index ?
      'rgba(212,175,55,0.2)' : ThemeColors.SURFACE_0)
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: this.selectedOption === index ? 2 : 1,
      color: this.selectedOption === index ?
        ThemeColors.GOLD_PRIMARY : ThemeColors.DIVIDER
    })
    .margin({ bottom: Spacing.MEDIUM })
    .onClick(() => this.selectOption(index))
  }
}
