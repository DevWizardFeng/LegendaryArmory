/**
 * 神兵图录 - 每日占卜页
 * 每日抽取一件神兵作为今日运势
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor } from '../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames, AttributeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

/**
 * 运势等级
 */
interface Fortune {
  level: string
  description: string
  color: string
}

@Entry
@Component
struct DailyDivination {
  @State isLoading: boolean = true
  @State isRevealed: boolean = false
  @State selectedWeapon: LegendaryWeapon | null = null
  @State fortune: Fortune | null = null
  @State allWeapons: LegendaryWeapon[] = []
  @State todayDate: string = ''
  private dataLoader: DataLoader | null = null

  // 运势配置
  private fortunes: Fortune[] = [
    { level: '大吉', description: '今日诸事皆宜，神兵庇佑', color: ThemeColors.RARITY_ARTIFACT },
    { level: '中吉', description: '今日运势平顺，稳中有进', color: ThemeColors.RARITY_LEGENDARY },
    { level: '小吉', description: '今日宜静不宜动，静待时机', color: ThemeColors.RARITY_EPIC },
    { level: '吉', description: '今日可小试身手，不宜冒进', color: ThemeColors.SUCCESS },
    { level: '末吉', description: '今日需谨慎行事，后福可期', color: ThemeColors.INFO }
  ]

  // 每日寄语
  private dailyMessages: string[] = [
    '剑气纵横三万里，一剑光寒十九洲',
    '十年磨一剑，霜刃未曾试',
    '宝剑锋从磨砺出，梅花香自苦寒来',
    '手持三尺青锋，心怀万里江山',
    '神兵在握，天下我有'
  ]

  aboutToAppear(): void {
    this.todayDate = this.formatDate(new Date())
    this.loadData()
  }

  /**
   * 格式化日期
   */
  formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    return `${year}年${month}月${day}日`
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
      console.error('[DailyDivination] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 执行占卜
   */
  performDivination(): void {
    if (this.allWeapons.length === 0) return

    // 基于日期的伪随机选择
    const today = new Date()
    const seed = today.getFullYear() * 10000 + (today.getMonth() + 1) * 100 + today.getDate()
    const weaponIndex = seed % this.allWeapons.length
    const fortuneIndex = seed % this.fortunes.length

    this.selectedWeapon = this.allWeapons[weaponIndex]
    this.fortune = this.fortunes[fortuneIndex]
    this.isRevealed = true
  }

  /**
   * 获取每日寄语
   */
  getDailyMessage(): string {
    const today = new Date()
    const index = today.getDate() % this.dailyMessages.length
    return this.dailyMessages[index]
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
  navigateToWeaponDetail(): void {
    if (!this.selectedWeapon) return
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: this.selectedWeapon.id }
    })
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => this.goBack())

        Text('每日占卜')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .margin({ left: Spacing.MEDIUM })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      if (this.isLoading) {
        this.LoadingView()
      } else if (!this.isRevealed) {
        this.DivinationView()
      } else {
        this.ResultView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
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
        .color(ThemeColors.GOLD_PRIMARY)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 占卜视图
   */
  @Builder
  DivinationView() {
    Column() {
      Blank().layoutWeight(1)

      // 日期
      Text(this.todayDate)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      // 标题
      Text('今日神兵')
        .fontSize(FontSizes.TITLE_LARGE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.GOLD_PRIMARY)
        .margin({ top: Spacing.MEDIUM })

      // 寄语
      Text(this.getDailyMessage())
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .fontStyle(FontStyle.Italic)
        .margin({ top: Spacing.SMALL })
        .textAlign(TextAlign.Center)

      // 占卜按钮
      Column() {
        Column() {
          Text('开')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.GOLD_PRIMARY)
        }
        .width(120)
        .height(120)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.SURFACE_0)
        .borderRadius(60)
        .border({
          width: 3,
          color: ThemeColors.GOLD_PRIMARY
        })
      }
      .margin({ top: Spacing.XXLARGE })
      .onClick(() => this.performDivination())

      Text('点击揭示今日神兵')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.LARGE })

      Blank().layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding(Spacing.LARGE)
  }

  /**
   * 结果视图
   */
  @Builder
  ResultView() {
    Scroll() {
      Column() {
        // 日期
        Text(this.todayDate)
          .fontSize(FontSizes.BODY)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: Spacing.LARGE })

        // 运势
        Column() {
          Text(this.fortune!.level)
            .fontSize(FontSizes.TITLE_LARGE)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.fortune!.color)

          Text(this.fortune!.description)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.SMALL })
        }
        .margin({ top: Spacing.LARGE })

        // 神兵卡片
        Column() {
          // 图片
          Stack({ alignContent: Alignment.Bottom }) {
            Image($rawfile(`images/${this.selectedWeapon!.image}`))
              .width('100%')
              .aspectRatio(1.2)
              .objectFit(ImageFit.Cover)

            // 渐变遮罩
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], [ThemeColors.SURFACE_0, 1]]
              })
          }
          .width('100%')
          .clip(true)
          .borderRadius({ topLeft: Spacing.MEDIUM, topRight: Spacing.MEDIUM })

          // 信息
          Column() {
            // 品质标签
            Text(RarityNames[this.selectedWeapon!.rarity] || this.selectedWeapon!.rarity)
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(getRarityColor(this.selectedWeapon!.rarity))
              .fontWeight(FontWeight.Bold)
              .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.TINY, bottom: Spacing.TINY })
              .backgroundColor('rgba(0,0,0,0.5)')
              .borderRadius(4)

            // 名称
            Text(this.selectedWeapon!.name.cn)
              .fontSize(FontSizes.TITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_TITLE)
              .margin({ top: Spacing.SMALL })

            // 文化和类型
            Text(`${CultureNames[this.selectedWeapon!.culture]} · ${WeaponTypeNames[this.selectedWeapon!.type]}`)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ top: Spacing.TINY })

            // 属性
            Row() {
              Text(AttributeNames[this.selectedWeapon!.attributes.primary] || this.selectedWeapon!.attributes.primary)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.GOLD_PRIMARY)
                .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
                .backgroundColor(ThemeColors.BASE_1)
                .borderRadius(4)

              if (this.selectedWeapon!.attributes.secondary) {
                Text(AttributeNames[this.selectedWeapon!.attributes.secondary] || this.selectedWeapon!.attributes.secondary)
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(ThemeColors.GOLD_PRIMARY)
                  .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
                  .backgroundColor(ThemeColors.BASE_1)
                  .borderRadius(4)
                  .margin({ left: Spacing.SMALL })
              }
            }
            .margin({ top: Spacing.MEDIUM })

            // 描述
            Text(this.selectedWeapon!.description)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ top: Spacing.MEDIUM })
              .lineHeight(22)

            // 查看详情按钮
            Column() {
              Text('查看详情')
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.BASE_0)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.GOLD_PRIMARY)
            .borderRadius(24)
            .margin({ top: Spacing.LARGE })
            .onClick(() => this.navigateToWeaponDetail())
          }
          .width('100%')
          .padding(Spacing.LARGE)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .backgroundColor(ThemeColors.SURFACE_0)
        .borderRadius(Spacing.MEDIUM)
        .margin({ top: Spacing.XLARGE, left: Spacing.LARGE, right: Spacing.LARGE })
        .border({
          width: 1,
          color: getRarityDarkColor(this.selectedWeapon!.rarity)
        })

        // 再次占卜提示
        Text('明日再来获取新的神兵运势')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
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
