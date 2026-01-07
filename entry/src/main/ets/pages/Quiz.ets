/**
 * 神兵图录 - 挑战答题页
 * 实现多种答题模式
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing } from '../common/Theme'
import { DataLoader } from '../utils/DataLoader'
import { StorageManager } from '../utils/Storage'
import { Question } from '../model/Question'
import { QuizRecord } from '../model/UserData'

/**
 * 答题模式
 */
type QuizMode = 'classic' | 'speed' | 'endless' | 'topic'

/**
 * 游戏状态
 */
type GameState = 'menu' | 'playing' | 'result'

/**
 * 模式配置
 */
interface ModeConfig {
  mode: QuizMode
  name: string
  description: string
  questionCount: number
  timePerQuestion: number
  lives: number
}

@Entry
@Component
struct Quiz {
  @State gameState: GameState = 'menu'
  @State currentMode: QuizMode = 'classic'
  @State questions: Question[] = []
  @State currentQuestionIndex: number = 0
  @State score: number = 0
  @State combo: number = 0
  @State maxCombo: number = 0
  @State lives: number = 3
  @State timeLeft: number = 15
  @State selectedAnswer: number = -1
  @State isAnswerRevealed: boolean = false
  @State correctCount: number = 0
  @State wrongCount: number = 0
  @State highScore: number = 0
  private dataLoader: DataLoader | null = null
  private storageManager: StorageManager | null = null
  private timer: number = -1

  // 模式配置
  private modeConfigs: ModeConfig[] = [
    { mode: 'classic', name: '经典模式', description: '20题混合难度，15秒/题', questionCount: 20, timePerQuestion: 15, lives: 0 },
    { mode: 'speed', name: '速度模式', description: '30题快速作答，10秒/题', questionCount: 30, timePerQuestion: 10, lives: 0 },
    { mode: 'endless', name: '无尽模式', description: '无限题目，3条命', questionCount: 999, timePerQuestion: 15, lives: 3 },
    { mode: 'topic', name: '专题模式', description: '15题特定专题', questionCount: 15, timePerQuestion: 20, lives: 0 }
  ]

  aboutToAppear(): void {
    this.loadData()
  }

  aboutToDisappear(): void {
    this.clearTimer()
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      const context = getContext(this)
      this.dataLoader = new DataLoader(context)
      this.storageManager = new StorageManager(context)
      await this.storageManager.init()
      this.highScore = await this.storageManager.getHighScore('classic')
    } catch (error) {
      console.error('[Quiz] 加载数据失败:', error)
    }
  }

  /**
   * 开始游戏
   */
  async startGame(mode: QuizMode): Promise<void> {
    this.currentMode = mode
    const config = this.modeConfigs.find(c => c.mode === mode)!

    // 加载题目
    const allQuestions = await this.dataLoader!.loadQuestions()
    this.questions = this.shuffleArray(allQuestions).slice(0, Math.min(config.questionCount, allQuestions.length))

    // 重置状态
    this.currentQuestionIndex = 0
    this.score = 0
    this.combo = 0
    this.maxCombo = 0
    this.lives = config.lives
    this.correctCount = 0
    this.wrongCount = 0
    this.selectedAnswer = -1
    this.isAnswerRevealed = false
    this.timeLeft = config.timePerQuestion

    // 获取历史最高分
    this.highScore = await this.storageManager!.getHighScore(mode)

    this.gameState = 'playing'
    this.startTimer()
  }

  /**
   * 打乱数组
   */
  shuffleArray<T>(array: T[]): T[] {
    const result = [...array]
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = result[i]
      result[i] = result[j]
      result[j] = temp
    }
    return result
  }

  /**
   * 开始计时器
   */
  startTimer(): void {
    this.clearTimer()
    this.timer = setInterval(() => {
      this.timeLeft--
      if (this.timeLeft <= 0) {
        this.handleTimeout()
      }
    }, 1000)
  }

  /**
   * 清除计时器
   */
  clearTimer(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  /**
   * 处理超时
   */
  handleTimeout(): void {
    this.selectedAnswer = -1
    this.isAnswerRevealed = true
    this.wrongCount++
    this.combo = 0

    console.info(`[Quiz] 超时! 当前错误数: ${this.wrongCount}`)

    if (this.currentMode === 'endless') {
      this.lives--
      if (this.lives <= 0) {
        this.endGame()
        return
      }
    }

    setTimeout(() => {
      this.nextQuestion()
    }, 2000) // 延长显示时间到2秒，让用户看清正确答案
  }

  /**
   * 选择答案
   */
  selectAnswer(index: number): void {
    if (this.isAnswerRevealed) return

    this.clearTimer()
    this.selectedAnswer = index
    this.isAnswerRevealed = true

    const currentQuestion = this.questions[this.currentQuestionIndex]
    // 使用 Number() 确保类型统一，并处理各种边界情况
    const rawCorrectAnswer = currentQuestion.correct_answer
    let correctAnswerIndex: number

    if (typeof rawCorrectAnswer === 'number' && !isNaN(rawCorrectAnswer)) {
      correctAnswerIndex = rawCorrectAnswer
    } else if (typeof rawCorrectAnswer === 'string') {
      correctAnswerIndex = parseInt(rawCorrectAnswer, 10)
      if (isNaN(correctAnswerIndex)) {
        correctAnswerIndex = 0
        console.error(`[Quiz] 无法解析正确答案: ${rawCorrectAnswer}，默认为 0`)
      }
    } else {
      correctAnswerIndex = 0
      console.error(`[Quiz] 未知的正确答案类型: ${typeof rawCorrectAnswer}，默认为 0`)
    }

    // 添加详细调试日志
    console.info(`[Quiz] ========== 答题判断 ==========`)
    console.info(`[Quiz] 题目: ${currentQuestion.question}`)
    console.info(`[Quiz] 选项: ${JSON.stringify(currentQuestion.options)}`)
    console.info(`[Quiz] 用户选择索引: ${index} (类型: ${typeof index})`)
    console.info(`[Quiz] 正确答案原始值: ${rawCorrectAnswer} (类型: ${typeof rawCorrectAnswer})`)
    console.info(`[Quiz] 正确答案索引: ${correctAnswerIndex} (类型: ${typeof correctAnswerIndex})`)

    // 使用双等号进行宽松比较，同时确保两者都转为数字
    const userChoice = Number(index)
    const correctChoice = Number(correctAnswerIndex)
    const isCorrect = userChoice === correctChoice

    console.info(`[Quiz] 比较: ${userChoice} === ${correctChoice} = ${isCorrect}`)
    console.info(`[Quiz] 判断结果: ${isCorrect ? '正确' : '错误'}`)
    console.info(`[Quiz] ================================`)

    if (isCorrect) {
      this.correctCount++
      this.combo++
      if (this.combo > this.maxCombo) {
        this.maxCombo = this.combo
      }
      // 计算得分（连击加成）
      let multiplier = 1
      if (this.combo >= 10) multiplier = 3
      else if (this.combo >= 5) multiplier = 2
      else if (this.combo >= 3) multiplier = 1.5
      this.score += Math.floor(100 * multiplier)
      console.info(`[Quiz] 正确! 当前正确数: ${this.correctCount}, 连击: ${this.combo}, 得分: ${this.score}`)
    } else {
      this.wrongCount++
      this.combo = 0
      console.info(`[Quiz] 错误! 当前错误数: ${this.wrongCount}`)
      if (this.currentMode === 'endless') {
        this.lives--
        if (this.lives <= 0) {
          setTimeout(() => this.endGame(), 1500)
          return
        }
      }
    }

    setTimeout(() => {
      this.nextQuestion()
    }, 2000) // 延长显示时间到2秒，让用户看清正确答案
  }

  /**
   * 下一题
   */
  nextQuestion(): void {
    if (this.currentQuestionIndex >= this.questions.length - 1) {
      this.endGame()
      return
    }

    this.currentQuestionIndex++
    this.selectedAnswer = -1
    this.isAnswerRevealed = false

    const config = this.modeConfigs.find(c => c.mode === this.currentMode)!
    this.timeLeft = config.timePerQuestion
    this.startTimer()
  }

  /**
   * 结束游戏
   */
  async endGame(): Promise<void> {
    this.clearTimer()
    this.gameState = 'result'

    // 保存记录
    const record: QuizRecord = {
      mode: this.currentMode,
      score: this.score,
      correct: this.correctCount,
      total: this.correctCount + this.wrongCount,
      combo: this.maxCombo,
      max_combo: this.maxCombo,
      time: 0,
      rank: 'bronze',
      timestamp: Date.now()
    }
    await this.storageManager!.addQuizRecord(record)

    // 更新最高分
    if (this.score > this.highScore) {
      this.highScore = this.score
    }
  }

  /**
   * 返回菜单
   */
  backToMenu(): void {
    this.gameState = 'menu'
    this.clearTimer()
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    if (this.gameState === 'playing') {
      this.backToMenu()
    } else {
      router.back()
    }
  }

  /**
   * 获取时间颜色
   */
  getTimeColor(): string {
    if (this.timeLeft <= 3) return ThemeColors.ERROR
    if (this.timeLeft <= 5) return ThemeColors.EMBER
    return ThemeColors.SUCCESS
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_quiz'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        if (this.gameState === 'menu') {
          this.MenuView()
        } else if (this.gameState === 'playing') {
          this.PlayingView()
        } else {
          this.ResultView()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 菜单视图
   */
  @Builder
  MenuView() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => router.back())

        Text('挑战答题')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .margin({ left: Spacing.MEDIUM })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      Scroll() {
        Column() {
          // 标题
          Column() {
            Text('选择答题模式')
              .fontSize(FontSizes.TITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_TITLE)

            Text('测试你对神兵的了解程度')
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ top: Spacing.SMALL })
          }
          .width('100%')
          .padding(Spacing.LARGE)
          .alignItems(HorizontalAlign.Center)

          // 模式列表
          ForEach(this.modeConfigs, (config: ModeConfig) => {
            this.ModeCard(config)
          })

          Blank().height(Spacing.XXLARGE)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 模式卡片
   */
  @Builder
  ModeCard(config: ModeConfig) {
    Row() {
      Column() {
        Text(config.name)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)

        Text(config.description)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: Spacing.TINY })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text('开始')
          .fontSize(FontSizes.BODY)
          .fontColor(ThemeColors.BASE_0)
          .fontWeight(FontWeight.Bold)
      }
      .width(64)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(ThemeColors.GOLD_PRIMARY)
      .borderRadius(18)
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .margin({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })
    .backgroundColor(ThemeColors.SURFACE_0)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .onClick(() => this.startGame(config.mode))
  }

  /**
   * 答题视图
   */
  @Builder
  PlayingView() {
    Column() {
      // 顶部状态栏
      this.GameHeader()

      // 题目区域
      if (this.questions.length > 0 && this.currentQuestionIndex < this.questions.length) {
        this.QuestionArea()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 游戏头部
   */
  @Builder
  GameHeader() {
    Column() {
      Row() {
        // 返回按钮
        Image($r('app.media.icon_close'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => this.backToMenu())

        Blank()

        // 分数
        Column() {
          Text('分数')
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)
          Text(this.score.toString())
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.GOLD_PRIMARY)
        }
        .alignItems(HorizontalAlign.Center)

        Blank()

        // 生命值（无尽模式）
        if (this.currentMode === 'endless') {
          Row() {
            ForEach([1, 2, 3], (i: number) => {
              Image($r('app.media.icon_favorite_filled'))
                .width(20)
                .height(20)
                .fillColor(i <= this.lives ? ThemeColors.RUST : ThemeColors.TEXT_TERTIARY)
                .margin({ left: 2 })
            })
          }
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      // 进度条
      Row() {
        // 题目进度
        Text(`${this.currentQuestionIndex + 1}/${this.questions.length}`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        Blank()

        // 连击
        if (this.combo > 1) {
          Text(`${this.combo} 连击!`)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.EMBER)
            .fontWeight(FontWeight.Bold)
        }

        Blank()

        // 倒计时
        Row() {
          Text(this.timeLeft.toString())
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTimeColor())
          Text('秒')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ left: 2 })
        }
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })

      // 时间进度条
      Progress({ value: this.timeLeft, total: this.modeConfigs.find(c => c.mode === this.currentMode)!.timePerQuestion })
        .width('100%')
        .height(4)
        .color(this.getTimeColor())
        .backgroundColor(ThemeColors.SURFACE_0)
    }
    .width('100%')
  }

  /**
   * 获取当前题目的正确答案索引
   */
  getCorrectAnswerIndex(): number {
    if (this.questions.length === 0 || this.currentQuestionIndex >= this.questions.length) {
      return -1
    }
    const currentQuestion = this.questions[this.currentQuestionIndex]
    const rawAnswer = currentQuestion.correct_answer

    // 统一的类型转换逻辑
    if (typeof rawAnswer === 'number' && !isNaN(rawAnswer)) {
      return rawAnswer
    } else if (typeof rawAnswer === 'string') {
      const parsed = parseInt(rawAnswer, 10)
      return isNaN(parsed) ? 0 : parsed
    }
    return 0
  }

  /**
   * 判断用户是否回答正确
   */
  isAnswerCorrect(): boolean {
    return this.selectedAnswer === this.getCorrectAnswerIndex() && this.selectedAnswer !== -1
  }

  /**
   * 判断是否超时
   */
  isTimeoutAnswer(): boolean {
    return this.selectedAnswer === -1
  }

  /**
   * 题目区域
   */
  @Builder
  QuestionArea() {
    Column() {
      Scroll() {
        Column() {
          // 题目
          Text(this.questions[this.currentQuestionIndex].question)
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_TITLE)
            .textAlign(TextAlign.Center)
            .padding(Spacing.LARGE)
            .lineHeight(28)

          // 选项
          Column() {
            ForEach(this.questions[this.currentQuestionIndex].options, (option: string, index: number) => {
              this.OptionButton(option, index)
            }, (option: string, index: number) => `${this.currentQuestionIndex}_${index}_${option}`)
          }
          .width('100%')
          .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
          .key(`quiz_question_${this.currentQuestionIndex}`)

          // 答题后显示正确答案提示
          if (this.isAnswerRevealed) {
            this.AnswerHint()
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 正确答案提示
   */
  @Builder
  AnswerHint() {
    Column() {
      // 判断结果提示
      Row() {
        // 使用现有的图标资源
        if (this.isAnswerCorrect()) {
          Image($r('app.media.icon_favorite_filled'))
            .width(20)
            .height(20)
            .fillColor(ThemeColors.SUCCESS)
            .margin({ right: Spacing.SMALL })
        } else {
          Image($r('app.media.icon_close'))
            .width(20)
            .height(20)
            .fillColor(ThemeColors.ERROR)
            .margin({ right: Spacing.SMALL })
        }

        Text(this.isTimeoutAnswer() ? '超时未答！' : (this.isAnswerCorrect() ? '回答正确！' : '回答错误！'))
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isAnswerCorrect() ? ThemeColors.SUCCESS : ThemeColors.ERROR)
      }
      .margin({ bottom: Spacing.MEDIUM })

      // 正确答案提示框（绿色边框）
      Column() {
        Row() {
          Text('正确答案：')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)

          Text(String.fromCharCode(65 + this.getCorrectAnswerIndex()))
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.SUCCESS)
            .margin({ left: Spacing.SMALL, right: Spacing.SMALL })

          Text(this.questions[this.currentQuestionIndex].options[this.getCorrectAnswerIndex()])
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .layoutWeight(1)
        }
        .width('100%')

        // 答案解释
        if (this.questions[this.currentQuestionIndex].explanation) {
          Text(this.questions[this.currentQuestionIndex].explanation)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.SMALL })
            .lineHeight(20)
        }
      }
      .width('100%')
      .padding(Spacing.MEDIUM)
      .backgroundColor(ThemeColors.SURFACE_0)
      .borderRadius(Spacing.SMALL)
      .border({
        width: 2,
        color: ThemeColors.SUCCESS  // 绿色边框
      })
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
  }

  /**
   * 选项按钮
   */
  @Builder
  OptionButton(text: string, index: number) {
    Row() {
      // 选项字母
      Column() {
        Text(String.fromCharCode(65 + index))
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getOptionLetterColor(index))
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getOptionBgColor(index))
      .borderRadius(18)

      // 选项文本
      Text(text)
        .fontSize(FontSizes.BODY)
        .fontColor(this.getOptionTextColor(index))
        .margin({ left: Spacing.MEDIUM })
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .margin({ bottom: Spacing.MEDIUM })
    .backgroundColor(this.getOptionCardBg(index))
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: 2,
      color: this.getOptionBorderColor(index)
    })
    .onClick(() => this.selectAnswer(index))
  }

  /**
   * 获取选项字母颜色
   */
  getOptionLetterColor(index: number): string {
    if (!this.isAnswerRevealed) {
      return this.selectedAnswer === index ? ThemeColors.BASE_0 : ThemeColors.TEXT_PRIMARY
    }
    const correctAnswer = this.getCorrectAnswerIndex()
    if (index === correctAnswer) return ThemeColors.BASE_0
    if (index === this.selectedAnswer) return ThemeColors.BASE_0
    return ThemeColors.TEXT_TERTIARY
  }

  /**
   * 获取选项背景色
   */
  getOptionBgColor(index: number): string {
    if (!this.isAnswerRevealed) {
      return this.selectedAnswer === index ? ThemeColors.GOLD_PRIMARY : ThemeColors.BASE_1
    }
    const correctAnswer = this.getCorrectAnswerIndex()
    if (index === correctAnswer) return ThemeColors.SUCCESS
    if (index === this.selectedAnswer) return ThemeColors.ERROR
    return ThemeColors.BASE_1
  }

  /**
   * 获取选项文本颜色
   */
  getOptionTextColor(index: number): string {
    if (!this.isAnswerRevealed) {
      return ThemeColors.TEXT_PRIMARY
    }
    const correctAnswer = this.getCorrectAnswerIndex()
    if (index === correctAnswer) return ThemeColors.SUCCESS
    if (index === this.selectedAnswer) return ThemeColors.ERROR
    return ThemeColors.TEXT_TERTIARY
  }

  /**
   * 获取选项卡片背景
   */
  getOptionCardBg(index: number): string {
    return ThemeColors.SURFACE_0
  }

  /**
   * 获取选项边框颜色
   */
  getOptionBorderColor(index: number): string {
    if (!this.isAnswerRevealed) {
      return this.selectedAnswer === index ? ThemeColors.GOLD_PRIMARY : ThemeColors.DIVIDER
    }
    const correctAnswer = this.getCorrectAnswerIndex()
    if (index === correctAnswer) return ThemeColors.SUCCESS
    if (index === this.selectedAnswer) return ThemeColors.ERROR
    return ThemeColors.DIVIDER
  }

  /**
   * 结果视图
   */
  @Builder
  ResultView() {
    Column() {
      Scroll() {
        Column() {
          // 标题
          Text('答题完成!')
            .fontSize(FontSizes.TITLE_LARGE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.GOLD_PRIMARY)
            .margin({ top: Spacing.XXLARGE })

          // 分数
          Text(this.score.toString())
            .fontSize(64)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_TITLE)
            .margin({ top: Spacing.LARGE })

          Text('分')
            .fontSize(FontSizes.SUBTITLE)
            .fontColor(ThemeColors.TEXT_SECONDARY)

          // 是否刷新记录
          if (this.score >= this.highScore && this.score > 0) {
            Text('新纪录!')
              .fontSize(FontSizes.SUBTITLE)
              .fontColor(ThemeColors.EMBER)
              .fontWeight(FontWeight.Bold)
              .margin({ top: Spacing.MEDIUM })
          }

          // 统计数据
          Column() {
            this.StatRow('正确', `${this.correctCount} 题`, ThemeColors.SUCCESS)
            this.StatRow('错误', `${this.wrongCount} 题`, ThemeColors.ERROR)
            this.StatRow('正确率', `${this.correctCount + this.wrongCount > 0 ? Math.round(this.correctCount / (this.correctCount + this.wrongCount) * 100) : 0}%`, ThemeColors.INFO)
            this.StatRow('最高连击', `${this.maxCombo} 连`, ThemeColors.EMBER)
            this.StatRow('历史最高', `${this.highScore} 分`, ThemeColors.GOLD_PRIMARY)
          }
          .width('100%')
          .padding(Spacing.LARGE)
          .margin({ top: Spacing.XLARGE })
          .backgroundColor(ThemeColors.SURFACE_0)
          .borderRadius(Spacing.MEDIUM)
          .border({ width: 1, color: ThemeColors.DIVIDER })

          // 按钮
          Row() {
            Column() {
              Text('返回')
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.TEXT_PRIMARY)
            }
            .width(120)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.SURFACE_0)
            .borderRadius(24)
            .border({ width: 1, color: ThemeColors.DIVIDER })
            .onClick(() => this.backToMenu())

            Column() {
              Text('再来一局')
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.BASE_0)
                .fontWeight(FontWeight.Bold)
            }
            .width(120)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.GOLD_PRIMARY)
            .borderRadius(24)
            .margin({ left: Spacing.MEDIUM })
            .onClick(() => this.startGame(this.currentMode))
          }
          .margin({ top: Spacing.XLARGE })

          Blank().height(Spacing.XXLARGE)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 统计行
   */
  @Builder
  StatRow(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      Blank()

      Text(value)
        .fontSize(FontSizes.BODY)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .width('100%')
    .padding({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })
  }
}
