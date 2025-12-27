/**
 * 神兵图录 - 对战模拟页
 * 选择两件神兵进行对战模拟
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getAttributeColor } from '../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames, AttributeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { LegendaryWeapon } from '../model/LegendaryWeapon'
import { Attribute } from '../model/Attribute'

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
  leftDamage: number
  rightDamage: number
}

@Entry
@Component
struct BattleSimulator {
  @State isLoading: boolean = true
  @State allWeapons: LegendaryWeapon[] = []
  @State attributes: Attribute[] = []
  @State leftWeapon: LegendaryWeapon | null = null
  @State rightWeapon: LegendaryWeapon | null = null
  @State battleResult: BattleResult | null = null
  @State isBattling: boolean = false
  @State showWeaponPicker: boolean = false
  @State pickerSide: 'left' | 'right' = 'left'
  @State searchText: string = ''
  private dataLoader: DataLoader | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.allWeapons = await this.dataLoader.loadWeapons()
      this.attributes = await this.dataLoader.loadAttributes()
      this.isLoading = false
    } catch (error) {
      console.error('[BattleSimulator] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 打开选择器
   */
  openPicker(side: 'left' | 'right'): void {
    this.pickerSide = side
    this.searchText = ''
    this.showWeaponPicker = true
  }

  /**
   * 选择神兵
   */
  selectWeapon(weapon: LegendaryWeapon): void {
    if (this.pickerSide === 'left') {
      this.leftWeapon = weapon
    } else {
      this.rightWeapon = weapon
    }
    this.showWeaponPicker = false
    this.battleResult = null
  }

  /**
   * 随机选择
   */
  randomSelect(): void {
    const shuffled = [...this.allWeapons].sort(() => Math.random() - 0.5)
    this.leftWeapon = shuffled[0]
    this.rightWeapon = shuffled[1]
    this.battleResult = null
  }

  /**
   * 开始对战
   */
  startBattle(): void {
    if (!this.leftWeapon || !this.rightWeapon) return

    this.isBattling = true
    this.battleResult = null

    // 模拟对战延迟
    setTimeout(() => {
      this.battleResult = this.calculateBattle()
      this.isBattling = false
    }, 2000)
  }

  /**
   * 计算对战结果
   */
  calculateBattle(): BattleResult {
    const left = this.leftWeapon!
    const right = this.rightWeapon!

    // 基础分数（基于属性）
    let leftScore = left.stats.attack + left.stats.defense + left.stats.speed + left.stats.critical
    let rightScore = right.stats.attack + right.stats.defense + right.stats.speed + right.stats.critical

    // 品质加成
    const rarityBonus: Record<string, number> = { artifact: 50, legendary: 30, epic: 15, rare: 5 }
    leftScore += rarityBonus[left.rarity] || 0
    rightScore += rarityBonus[right.rarity] || 0

    // 属性相克
    const attributeAdvantage = this.checkAttributeAdvantage(left.attributes.primary, right.attributes.primary)
    if (attributeAdvantage === 'left') leftScore += 30
    else if (attributeAdvantage === 'right') rightScore += 30

    // 生成对战详情
    const details: BattleDetail[] = [
      {
        round: 1,
        description: `${left.name.zh}发动攻击!`,
        leftDamage: Math.floor(left.stats.attack * (0.8 + Math.random() * 0.4)),
        rightDamage: 0
      },
      {
        round: 2,
        description: `${right.name.zh}反击!`,
        leftDamage: 0,
        rightDamage: Math.floor(right.stats.attack * (0.8 + Math.random() * 0.4))
      },
      {
        round: 3,
        description: '双方激烈交锋!',
        leftDamage: Math.floor(left.stats.critical * 0.5),
        rightDamage: Math.floor(right.stats.critical * 0.5)
      }
    ]

    // 添加随机因素
    leftScore += Math.floor(Math.random() * 20)
    rightScore += Math.floor(Math.random() * 20)

    let winner: 'left' | 'right' | 'draw'
    if (Math.abs(leftScore - rightScore) < 10) {
      winner = 'draw'
    } else {
      winner = leftScore > rightScore ? 'left' : 'right'
    }

    return { winner, leftScore, rightScore, details }
  }

  /**
   * 检查属性相克
   */
  checkAttributeAdvantage(leftAttr: string, rightAttr: string): 'left' | 'right' | 'none' {
    // 简化的属性相克规则
    const advantages: Record<string, string[]> = {
      fire: ['ice', 'nature'],
      water: ['fire', 'earth'],
      ice: ['wind', 'nature'],
      thunder: ['water', 'wind'],
      wind: ['earth', 'poison'],
      earth: ['thunder', 'fire'],
      light: ['dark', 'death'],
      dark: ['light', 'nature']
    }

    if (advantages[leftAttr]?.includes(rightAttr)) return 'left'
    if (advantages[rightAttr]?.includes(leftAttr)) return 'right'
    return 'none'
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    if (this.showWeaponPicker) {
      this.showWeaponPicker = false
    } else {
      router.back()
    }
  }

  /**
   * 获取筛选后的神兵
   */
  getFilteredWeapons(): LegendaryWeapon[] {
    if (!this.searchText) return this.allWeapons
    const query = this.searchText.toLowerCase()
    return this.allWeapons.filter(w =>
      w.name.zh.toLowerCase().includes(query) ||
      (CultureNames[w.culture] || '').includes(query)
    )
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor(ThemeColors.TEXT_PRIMARY)
            .onClick(() => this.goBack())

          Text('对战模拟')
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ left: Spacing.MEDIUM })

          Blank()

          Text('随机')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.ACCENT)
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
      .backgroundColor(ThemeColors.PRIMARY_BG)

      // 武器选择器弹窗
      if (this.showWeaponPicker) {
        this.WeaponPickerView()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 加载中视图
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.ACCENT)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 对战视图
   */
  @Builder
  BattleView() {
    Column() {
      // 对战区域
      Row() {
        // 左侧神兵
        this.WeaponSlot(this.leftWeapon, 'left')

        // VS
        Column() {
          Text('VS')
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.ACCENT)
        }
        .width(60)
        .justifyContent(FlexAlign.Center)

        // 右侧神兵
        this.WeaponSlot(this.rightWeapon, 'right')
      }
      .width('100%')
      .padding(Spacing.LARGE)

      // 开始对战按钮
      if (this.leftWeapon && this.rightWeapon && !this.isBattling) {
        Column() {
          Text('开始对战')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.PRIMARY_BG)
            .fontWeight(FontWeight.Bold)
        }
        .width(160)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.ACCENT)
        .borderRadius(24)
        .onClick(() => this.startBattle())
      }

      // 对战中
      if (this.isBattling) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(ThemeColors.ACCENT)
          Text('激战中...')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.MEDIUM })
        }
        .margin({ top: Spacing.LARGE })
      }

      // 对战结果
      if (this.battleResult) {
        this.ResultView()
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 神兵槽位
   */
  @Builder
  WeaponSlot(weapon: LegendaryWeapon | null, side: 'left' | 'right') {
    Column() {
      if (weapon) {
        // 已选择
        Stack({ alignContent: Alignment.TopEnd }) {
          Image($rawfile(`images/${weapon.image}`))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Spacing.MEDIUM)

          // 胜负标记
          if (this.battleResult) {
            if ((this.battleResult.winner === side) ||
                (this.battleResult.winner === 'draw')) {
              Column() {
                Text(this.battleResult.winner === 'draw' ? '平' : '胜')
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(ThemeColors.PRIMARY_BG)
                  .fontWeight(FontWeight.Bold)
              }
              .width(32)
              .height(32)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.battleResult.winner === 'draw' ? ThemeColors.INFO : ThemeColors.SUCCESS)
              .borderRadius(16)
              .margin({ top: Spacing.SMALL, right: Spacing.SMALL })
            } else {
              Column() {
                Text('败')
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(ThemeColors.PRIMARY_BG)
                  .fontWeight(FontWeight.Bold)
              }
              .width(32)
              .height(32)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(ThemeColors.ERROR)
              .borderRadius(16)
              .margin({ top: Spacing.SMALL, right: Spacing.SMALL })
            }
          }
        }
        .width('100%')

        Text(weapon.name.zh)
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ top: Spacing.SMALL })
          .maxLines(1)

        Text(RarityNames[weapon.rarity])
          .fontSize(FontSizes.CAPTION)
          .fontColor(getRarityColor(weapon.rarity))

        // 分数
        if (this.battleResult) {
          Text((side === 'left' ? this.battleResult.leftScore : this.battleResult.rightScore).toString())
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.ACCENT)
            .margin({ top: Spacing.SMALL })
        }
      } else {
        // 未选择
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
        .height(120)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.CARD_BG)
        .borderRadius(Spacing.MEDIUM)
        .border({
          width: 2,
          style: BorderStyle.Dashed,
          color: ThemeColors.DIVIDER
        })
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.openPicker(side))
  }

  /**
   * 结果视图
   */
  @Builder
  ResultView() {
    Column() {
      // 结果标题
      Text(this.battleResult!.winner === 'draw' ? '势均力敌!' :
           (this.battleResult!.winner === 'left' ? `${this.leftWeapon!.name.zh} 胜出!` : `${this.rightWeapon!.name.zh} 胜出!`))
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.battleResult!.winner === 'draw' ? ThemeColors.INFO : ThemeColors.SUCCESS)
        .margin({ top: Spacing.LARGE })

      // 对战详情
      Column() {
        ForEach(this.battleResult!.details, (detail: BattleDetail) => {
          Row() {
            Text(`回合${detail.round}:`)
              .fontSize(FontSizes.CAPTION)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .width(50)

            Text(detail.description)
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: Spacing.SMALL, bottom: Spacing.SMALL })
        })
      }
      .width('100%')
      .padding(Spacing.MEDIUM)
      .margin({ top: Spacing.MEDIUM })
      .backgroundColor(ThemeColors.CARD_BG)
      .borderRadius(Spacing.MEDIUM)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
  }

  /**
   * 武器选择器
   */
  @Builder
  WeaponPickerView() {
    Column() {
      // 遮罩
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
      // 头部
      Row() {
        Text('选择神兵')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Image($r('app.media.icon_close'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => this.showWeaponPicker = false)
      }
      .width('100%')
      .padding(Spacing.LARGE)

      // 搜索
      Row() {
        TextInput({ placeholder: '搜索神兵...', text: this.searchText })
          .placeholderColor(ThemeColors.TEXT_TERTIARY)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .backgroundColor(ThemeColors.CARD_BG)
          .borderRadius(Spacing.SMALL)
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value
          })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })

      // 列表
      List() {
        ForEach(this.getFilteredWeapons(), (weapon: LegendaryWeapon) => {
          ListItem() {
            Row() {
              Image($rawfile(`images/${weapon.image}`))
                .width(50)
                .height(50)
                .objectFit(ImageFit.Cover)
                .borderRadius(Spacing.SMALL)

              Column() {
                Text(weapon.name.zh)
                  .fontSize(FontSizes.BODY)
                  .fontColor(ThemeColors.TEXT_PRIMARY)

                Text(`${CultureNames[weapon.culture]} · ${RarityNames[weapon.rarity]}`)
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: Spacing.MEDIUM })
            }
            .width('100%')
            .padding(Spacing.MEDIUM)
          }
          .onClick(() => this.selectWeapon(weapon))
        }, (weapon: LegendaryWeapon) => weapon.id)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('70%')
    .backgroundColor(ThemeColors.PRIMARY_BG)
    .borderRadius({ topLeft: Spacing.LARGE, topRight: Spacing.LARGE })
    .position({ x: 0, y: '30%' })
  }
}
