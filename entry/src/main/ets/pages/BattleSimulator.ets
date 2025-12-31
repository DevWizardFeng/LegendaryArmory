/**
 * 神兵图录 - 对战模拟页
 * 选择两件神兵进行对战模拟
 * 视觉风格：简洁激烈的对战体验
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getAttributeColor } from '../common/Theme'
import { CultureNames, RarityNames, AttributeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

/**
 * 对战结果
 */
interface BattleResult {
  winner: 'left' | 'right' | 'draw'
  leftScore: number
  rightScore: number
  details: BattleDetail[]
}

/**
 * 对战详情
 */
interface BattleDetail {
  round: number
  description: string
  highlight: boolean
}

/**
 * 品质加成配置
 */
class RarityBonus {
  artifact: number = 50
  legendary: number = 30
  epic: number = 15
  rare: number = 5

  getBonus(rarity: string): number {
    if (rarity === 'artifact') return this.artifact
    if (rarity === 'legendary') return this.legendary
    if (rarity === 'epic') return this.epic
    if (rarity === 'rare') return this.rare
    return 0
  }
}

/**
 * 属性相克配置
 */
class AttributeAdvantages {
  fire: string[] = ['ice', 'nature']
  water: string[] = ['fire', 'earth']
  ice: string[] = ['wind', 'nature']
  thunder: string[] = ['water', 'wind']
  wind: string[] = ['earth', 'poison']
  earth: string[] = ['thunder', 'fire']
  light: string[] = ['dark', 'death']
  dark: string[] = ['light', 'nature']

  getAdvantages(attr: string): string[] {
    if (attr === 'fire') return this.fire
    if (attr === 'water') return this.water
    if (attr === 'ice') return this.ice
    if (attr === 'thunder') return this.thunder
    if (attr === 'wind') return this.wind
    if (attr === 'earth') return this.earth
    if (attr === 'light') return this.light
    if (attr === 'dark') return this.dark
    return []
  }
}

@Entry
@Component
struct BattleSimulator {
  @State isLoading: boolean = true
  @State allWeapons: LegendaryWeapon[] = []
  @State leftWeapon: LegendaryWeapon | null = null
  @State rightWeapon: LegendaryWeapon | null = null
  @State battleResult: BattleResult | null = null
  @State isBattling: boolean = false
  @State showWeaponPicker: boolean = false
  @State pickerSide: 'left' | 'right' = 'left'
  @State searchText: string = ''

  // 对战动画状态
  @State leftShake: number = 0
  @State rightShake: number = 0
  @State vsScale: number = 1
  @State battleProgress: number = 0
  @State showResult: boolean = false

  private dataLoader: DataLoader | null = null
  private battleTimer: number = -1

  aboutToAppear(): void {
    this.loadData()
  }

  aboutToDisappear(): void {
    if (this.battleTimer >= 0) {
      clearInterval(this.battleTimer)
    }
  }

  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.allWeapons = await this.dataLoader.loadWeapons()
      this.isLoading = false
    } catch (error) {
      console.error('[BattleSimulator] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  openPicker(side: 'left' | 'right'): void {
    this.pickerSide = side
    this.searchText = ''
    this.showWeaponPicker = true
  }

  selectWeapon(weapon: LegendaryWeapon): void {
    if (this.pickerSide === 'left') {
      this.leftWeapon = weapon
    } else {
      this.rightWeapon = weapon
    }
    this.showWeaponPicker = false
    this.battleResult = null
    this.showResult = false
  }

  randomSelect(): void {
    if (this.allWeapons.length < 2) {
      console.warn('[BattleSimulator] 神兵数量不足，无法随机选择')
      return
    }
    const shuffled = [...this.allWeapons].sort(() => Math.random() - 0.5)
    this.leftWeapon = shuffled[0]
    this.rightWeapon = shuffled[1]
    this.battleResult = null
    this.showResult = false
  }

  /**
   * 开始对战
   */
  startBattle(): void {
    if (!this.leftWeapon || !this.rightWeapon) return

    this.isBattling = true
    this.battleResult = null
    this.showResult = false
    this.battleProgress = 0

    // 对战动画：武器震动 + VS闪烁
    let tick = 0
    this.battleTimer = setInterval(() => {
      tick++

      // 武器左右震动
      animateTo({ duration: 100, curve: Curve.Linear }, () => {
        this.leftShake = (tick % 2 === 0) ? 5 : -5
        this.rightShake = (tick % 2 === 0) ? -5 : 5
      })

      // VS 缩放
      if (tick % 4 === 0) {
        animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
          this.vsScale = 1.2
        })
        setTimeout(() => {
          animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
            this.vsScale = 1
          })
        }, 200)
      }

      // 进度更新
      this.battleProgress = Math.min(tick * 5, 100)

      // 结束对战
      if (tick >= 20) {
        clearInterval(this.battleTimer)
        this.battleTimer = -1
        this.leftShake = 0
        this.rightShake = 0
        this.vsScale = 1
        this.battleResult = this.calculateBattle()
        this.isBattling = false

        // 延迟显示结果
        setTimeout(() => {
          animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.showResult = true
          })
        }, 200)
      }
    }, 100)
  }

  /**
   * 计算对战结果
   */
  calculateBattle(): BattleResult {
    if (!this.leftWeapon || !this.rightWeapon) {
      return { winner: 'draw', leftScore: 0, rightScore: 0, details: [] }
    }
    const left = this.leftWeapon
    const right = this.rightWeapon

    // 基础分数 - 添加空值保护
    const leftStats = left.stats ?? { attack: 0, defense: 0, speed: 0, critical: 0 }
    const rightStats = right.stats ?? { attack: 0, defense: 0, speed: 0, critical: 0 }
    let leftScore = (leftStats.attack ?? 0) + (leftStats.defense ?? 0) + (leftStats.speed ?? 0) + (leftStats.critical ?? 0)
    let rightScore = (rightStats.attack ?? 0) + (rightStats.defense ?? 0) + (rightStats.speed ?? 0) + (rightStats.critical ?? 0)

    // 品质加成
    let rarityBonus = new RarityBonus()
    leftScore += rarityBonus.getBonus(left.rarity ?? 'rare')
    rightScore += rarityBonus.getBonus(right.rarity ?? 'rare')

    // 属性相克
    const leftAttr = left.attributes?.primary ?? 'fire'
    const rightAttr = right.attributes?.primary ?? 'fire'
    const attributeAdvantage = this.checkAttributeAdvantage(leftAttr, rightAttr)
    if (attributeAdvantage === 'left') leftScore += 30
    else if (attributeAdvantage === 'right') rightScore += 30

    // 随机因素
    leftScore += Math.floor(Math.random() * 20)
    rightScore += Math.floor(Math.random() * 20)

    // 生成对战描述
    const details = this.generateBattleDetails(left, right, attributeAdvantage)

    let winner: 'left' | 'right' | 'draw'
    if (Math.abs(leftScore - rightScore) < 10) {
      winner = 'draw'
    } else {
      winner = leftScore > rightScore ? 'left' : 'right'
    }

    return { winner, leftScore, rightScore, details }
  }

  /**
   * 生成对战详情描述
   */
  generateBattleDetails(left: LegendaryWeapon, right: LegendaryWeapon, advantage: string): BattleDetail[] {
    const details: BattleDetail[] = []

    // 获取名称，添加空值保护
    const leftName = left?.name?.cn ?? '神兵'
    const rightName = right?.name?.cn ?? '神兵'

    // 开局
    const openings = [
      `${leftName}气势如虹，率先出击`,
      `${rightName}不甘示弱，正面迎战`,
    ]
    details.push({ round: 1, description: openings[Math.floor(Math.random() * 2)], highlight: false })

    // 属性克制
    if (advantage !== 'none') {
      const leftAttr = AttributeNames[left?.attributes?.primary ?? 'fire'] ?? left?.attributes?.primary ?? '未知'
      const rightAttr = AttributeNames[right?.attributes?.primary ?? 'fire'] ?? right?.attributes?.primary ?? '未知'
      if (advantage === 'left') {
        details.push({ round: 2, description: `${leftAttr}属性克制${rightAttr}，占据上风`, highlight: true })
      } else {
        details.push({ round: 2, description: `${rightAttr}属性克制${leftAttr}，扭转战局`, highlight: true })
      }
    } else {
      details.push({ round: 2, description: '双方势均力敌，激烈交锋', highlight: false })
    }

    // 终局
    const endings = [
      '神兵碰撞，火花四溅',
      '剑气纵横，胜负将分',
      '最后一击，尘埃落定'
    ]
    details.push({ round: 3, description: endings[Math.floor(Math.random() * 3)], highlight: false })

    return details
  }

  checkAttributeAdvantage(leftAttr: string, rightAttr: string): 'left' | 'right' | 'none' {
    let advantages = new AttributeAdvantages()
    if (advantages.getAdvantages(leftAttr).includes(rightAttr)) return 'left'
    if (advantages.getAdvantages(rightAttr).includes(leftAttr)) return 'right'
    return 'none'
  }

  goBack(): void {
    if (this.showWeaponPicker) {
      this.showWeaponPicker = false
    } else {
      router.back()
    }
  }

  getFilteredWeapons(): LegendaryWeapon[] {
    if (!this.searchText) return this.allWeapons
    const query = this.searchText.toLowerCase()
    return this.allWeapons.filter(w => {
      if (!w || !w.name) return false
      const nameCn = w.name.cn ?? ''
      const cultureName = CultureNames[w.culture] ?? ''
      return nameCn.toLowerCase().includes(query) || cultureName.includes(query)
    })
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_battle'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Stack() {
        Column() {
          // 顶部导航
          Row() {
            Column() {
              Image($r('app.media.icon_back'))
                .width(20)
                .height(20)
                .fillColor(ThemeColors.TEXT_PRIMARY)
            }
            .width(36)
            .height(36)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(0,0,0,0.4)')
            .borderRadius(18)
            .onClick(() => this.goBack())

            Text('对战模拟')
              .fontSize(FontSizes.SUBTITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_TITLE)
              .margin({ left: Spacing.MEDIUM })

            Blank()

            Text('随机')
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.GOLD_PRIMARY)
              .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
              .backgroundColor('rgba(0,0,0,0.4)')
              .borderRadius(Spacing.SMALL)
              .onClick(() => this.randomSelect())
          }
          .width('100%')
          .height(56)
          .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

          if (this.isLoading) {
            this.LoadingView()
          } else {
            this.BattleView()
          }
        }
        .width('100%')
        .height('100%')

        // 武器选择器弹窗
        if (this.showWeaponPicker) {
          this.WeaponPickerView()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

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

  @Builder
  BattleView() {
    Scroll() {
      Column() {
        // 对战区域
        Row() {
          // 左侧神兵
          Column() {
            if (this.leftWeapon) {
              Image($rawfile(`images/${this.leftWeapon.image}`))
                .width('100%')
                .height(110)
                .objectFit(ImageFit.Cover)
                .borderRadius(Spacing.MEDIUM)
                .border({ width: 2, color: getAttributeColor(this.leftWeapon.attributes.primary) })
                .translate({ x: this.leftShake })

              Text(this.leftWeapon.name.cn)
                .fontSize(FontSizes.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.TEXT_TITLE)
                .margin({ top: Spacing.SMALL })
                .maxLines(1)

              Text(RarityNames[this.leftWeapon.rarity])
                .fontSize(FontSizes.CAPTION)
                .fontColor(getRarityColor(this.leftWeapon.rarity))

              if (this.battleResult && this.showResult) {
                Text(this.battleResult.leftScore.toString())
                  .fontSize(FontSizes.TITLE)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.GOLD_PRIMARY)
                  .margin({ top: Spacing.SMALL })

                this.WinLoseTag(this.battleResult.winner === 'left' ? 'win' :
                  (this.battleResult.winner === 'draw' ? 'draw' : 'lose'))
              }
            } else {
              Column() {
                Image($r('app.media.icon_add'))
                  .width(32)
                  .height(32)
                  .fillColor(ThemeColors.TEXT_TERTIARY)

                Text('选择神兵')
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
                  .margin({ top: Spacing.SMALL })
              }
              .width('100%')
              .height(110)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0,0,0,0.3)')
              .borderRadius(Spacing.MEDIUM)
              .border({ width: 2, style: BorderStyle.Dashed, color: ThemeColors.DIVIDER })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            if (!this.isBattling) this.openPicker('left')
          })

          // VS
          Column() {
            Text('VS')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.GOLD_PRIMARY)
              .scale({ x: this.vsScale, y: this.vsScale })
          }
          .width(50)
          .justifyContent(FlexAlign.Center)

          // 右侧神兵
          Column() {
            if (this.rightWeapon) {
              Image($rawfile(`images/${this.rightWeapon.image}`))
                .width('100%')
                .height(110)
                .objectFit(ImageFit.Cover)
                .borderRadius(Spacing.MEDIUM)
                .border({ width: 2, color: getAttributeColor(this.rightWeapon.attributes.primary) })
                .translate({ x: this.rightShake })

              Text(this.rightWeapon.name.cn)
                .fontSize(FontSizes.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.TEXT_TITLE)
                .margin({ top: Spacing.SMALL })
                .maxLines(1)

              Text(RarityNames[this.rightWeapon.rarity])
                .fontSize(FontSizes.CAPTION)
                .fontColor(getRarityColor(this.rightWeapon.rarity))

              if (this.battleResult && this.showResult) {
                Text(this.battleResult.rightScore.toString())
                  .fontSize(FontSizes.TITLE)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.GOLD_PRIMARY)
                  .margin({ top: Spacing.SMALL })

                this.WinLoseTag(this.battleResult.winner === 'right' ? 'win' :
                  (this.battleResult.winner === 'draw' ? 'draw' : 'lose'))
              }
            } else {
              Column() {
                Image($r('app.media.icon_add'))
                  .width(32)
                  .height(32)
                  .fillColor(ThemeColors.TEXT_TERTIARY)

                Text('选择神兵')
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
                  .margin({ top: Spacing.SMALL })
              }
              .width('100%')
              .height(110)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0,0,0,0.3)')
              .borderRadius(Spacing.MEDIUM)
              .border({ width: 2, style: BorderStyle.Dashed, color: ThemeColors.DIVIDER })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            if (!this.isBattling) this.openPicker('right')
          })
        }
        .width('100%')
        .padding(Spacing.LARGE)

        // 对战按钮或进度
        if (this.isBattling) {
          // 对战进度条
          Column() {
            Text('对战中...')
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ bottom: Spacing.SMALL })

            Progress({ value: this.battleProgress, total: 100 })
              .width('60%')
              .height(6)
              .color(ThemeColors.GOLD_PRIMARY)
              .backgroundColor(ThemeColors.SURFACE_0)
          }
          .margin({ top: Spacing.LARGE })
        } else if (this.leftWeapon && this.rightWeapon) {
          Column() {
            Text('开始对战')
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.BASE_0)
              .fontWeight(FontWeight.Bold)
          }
          .width(140)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(ThemeColors.GOLD_PRIMARY)
          .borderRadius(22)
          .margin({ top: Spacing.LARGE })
          .onClick(() => this.startBattle())
        } else {
          Column() {
            Text('请选择神兵')
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_TERTIARY)
          }
          .width(140)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(ThemeColors.SURFACE_0)
          .borderRadius(22)
          .margin({ top: Spacing.LARGE })
        }

        // 对战结果
        if (this.battleResult && this.showResult) {
          this.ResultView()
        }

        Blank().height(100)
      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  WinLoseTag(result: 'win' | 'lose' | 'draw') {
    Text(result === 'win' ? '胜' : (result === 'draw' ? '平' : '负'))
      .fontSize(FontSizes.BODY_SMALL)
      .fontColor(ThemeColors.BASE_0)
      .fontWeight(FontWeight.Bold)
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: 4, bottom: 4 })
      .backgroundColor(result === 'win' ? ThemeColors.SUCCESS :
        (result === 'draw' ? ThemeColors.INFO : ThemeColors.TEXT_TERTIARY))
      .borderRadius(Spacing.SMALL)
      .margin({ top: Spacing.SMALL })
  }

  @Builder
  ResultView() {
    if (this.battleResult) {
      Column() {
        // 结果标题
        Text(this.getResultTitle())
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.battleResult.winner === 'draw' ? ThemeColors.INFO : ThemeColors.GOLD_PRIMARY)
          .margin({ top: Spacing.LARGE })

        // 对战详情
        Column() {
          ForEach(this.battleResult.details, (detail: BattleDetail) => {
            Row() {
              Text(`${detail.round}.`)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.TEXT_TERTIARY)
                .width(20)

              Text(detail.description)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(detail.highlight ? ThemeColors.GOLD_PRIMARY : ThemeColors.TEXT_SECONDARY)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          })
        }
        .width('100%')
        .padding(Spacing.MEDIUM)
        .margin({ top: Spacing.MEDIUM })
        .backgroundColor('rgba(0,0,0,0.3)')
        .borderRadius(Spacing.MEDIUM)

        // 再来一局
        Text('再来一局')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.GOLD_PRIMARY)
          .margin({ top: Spacing.LARGE })
          .onClick(() => {
            this.battleResult = null
            this.showResult = false
          })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    }
  }

  getResultTitle(): string {
    if (!this.battleResult) return ''
    if (this.battleResult.winner === 'draw') {
      return '势均力敌'
    } else if (this.battleResult.winner === 'left') {
      return `${this.leftWeapon?.name?.cn ?? '神兵'} 获胜`
    } else {
      return `${this.rightWeapon?.name?.cn ?? '神兵'} 获胜`
    }
  }

  @Builder
  WeaponPickerView() {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => this.showWeaponPicker = false)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column() {
      Row() {
        Text('选择神兵')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)

        Blank()

        Image($r('app.media.icon_close'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => this.showWeaponPicker = false)
      }
      .width('100%')
      .padding(Spacing.LARGE)

      Row() {
        TextInput({ placeholder: '搜索神兵...', text: this.searchText })
          .placeholderColor(ThemeColors.TEXT_TERTIARY)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .backgroundColor(ThemeColors.SURFACE_0)
          .borderRadius(Spacing.SMALL)
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value
          })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })

      List() {
        ForEach(this.getFilteredWeapons(), (weapon: LegendaryWeapon) => {
          ListItem() {
            Row() {
              Image($rawfile(`images/${weapon?.image ?? 'weapon_default.png'}`))
                .width(50)
                .height(50)
                .objectFit(ImageFit.Cover)
                .borderRadius(Spacing.SMALL)

              Column() {
                Text(weapon?.name?.cn ?? '')
                  .fontSize(FontSizes.BODY)
                  .fontColor(ThemeColors.TEXT_PRIMARY)

                Text(`${CultureNames[weapon?.culture] ?? ''} · ${RarityNames[weapon?.rarity] ?? ''}`)
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: Spacing.MEDIUM })
            }
            .width('100%')
            .padding(Spacing.MEDIUM)
          }
          .onClick(() => {
            if (weapon) {
              this.selectWeapon(weapon)
            }
          })
        }, (weapon: LegendaryWeapon) => weapon?.id ?? Math.random().toString())
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('70%')
    .backgroundColor(ThemeColors.BASE_0)
    .borderRadius({ topLeft: Spacing.LARGE, topRight: Spacing.LARGE })
    .position({ x: 0, y: '30%' })
  }
}
