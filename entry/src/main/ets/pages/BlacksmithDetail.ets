/**
 * 神兵图录 - 铸造大师详情页
 * 展示铸造师的完整信息和作品
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../common/Theme'
import { RouterPath, CultureNames, RarityNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { Blacksmith } from '../model/Blacksmith'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

/**
 * 路由参数
 */
interface RouteParams {
  blacksmithId: string
}

@Entry
@Component
struct BlacksmithDetail {
  @State isLoading: boolean = true
  @State blacksmith: Blacksmith | null = null
  @State masterworkWeapons: LegendaryWeapon[] = []
  private dataLoader: DataLoader | null = null

  aboutToAppear(): void {
    const params = router.getParams() as RouteParams | undefined
    if (params?.blacksmithId) {
      this.loadData(params.blacksmithId)
    }
  }

  /**
   * 加载数据
   */
  async loadData(blacksmithId: string): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.blacksmith = await this.dataLoader.getBlacksmithById(blacksmithId)

      // 加载代表作品
      if (this.blacksmith?.masterworks && this.blacksmith.masterworks.length > 0) {
        const allWeapons = await this.dataLoader.loadWeapons()
        this.masterworkWeapons = allWeapons.filter(w =>
          this.blacksmith?.masterworks.includes(w.id)
        )
      }

      this.isLoading = false
    } catch (error) {
      console.error('[BlacksmithDetail] 加载数据失败:', error)
      this.isLoading = false
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
      params: { weaponId: weaponId }
    })
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.LoadingView()
      } else if (!this.blacksmith) {
        this.ErrorView()
      } else {
        this.ContentView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.PRIMARY_BG)
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
      Text('正在加载...')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 错误视图
   */
  @Builder
  ErrorView() {
    Column() {
      Text('未找到该铸造师')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      Text('返回')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.ACCENT)
        .margin({ top: Spacing.MEDIUM })
        .onClick(() => this.goBack())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 内容视图
   */
  @Builder
  ContentView() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column() {
          // 头部区域
          this.HeaderSection()

          // 简介
          this.BioSection()

          // 铸造技法
          this.TechniquesSection()

          // 传奇事迹
          this.LegendSection()

          // 代表作品
          this.MasterworksSection()

          // 底部间距
          Blank().height(100)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 悬浮返回按钮
      Row() {
        Column() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor(ThemeColors.TEXT_PRIMARY)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(20)
        .onClick(() => this.goBack())
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, top: Spacing.LARGE })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 头部区域
   */
  @Builder
  HeaderSection() {
    Column() {
      // 背景和头像
      Stack({ alignContent: Alignment.BottomCenter }) {
        // 背景渐变
        Column()
          .width('100%')
          .height(200)
          .linearGradient({
            angle: 180,
            colors: [[ThemeColors.ACCENT, 0], [ThemeColors.PRIMARY_BG, 1]]
          })

        // 头像
        Column() {
          Image($rawfile(`images/${this.blacksmith!.image}`))
            .width(120)
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(60)
        }
        .border({
          width: 4,
          color: ThemeColors.ACCENT
        })
        .borderRadius(64)
        .margin({ bottom: -40 })
      }
      .width('100%')

      // 名称和称号
      Column() {
        Text(this.blacksmith!.name)
          .fontSize(FontSizes.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ top: 50 })

        Text(this.blacksmith!.title)
          .fontSize(FontSizes.BODY)
          .fontColor(ThemeColors.ACCENT)
          .margin({ top: Spacing.SMALL })

        // 文化和时代
        Row() {
          Text(CultureNames[this.blacksmith!.culture] || this.blacksmith!.culture)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.TINY, bottom: Spacing.TINY })
            .backgroundColor(ThemeColors.CARD_BG)
            .borderRadius(Spacing.LARGE)

          Text(this.blacksmith!.era)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.TINY, bottom: Spacing.TINY })
            .backgroundColor(ThemeColors.CARD_BG)
            .borderRadius(Spacing.LARGE)
            .margin({ left: Spacing.SMALL })
        }
        .margin({ top: Spacing.MEDIUM })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
  }

  /**
   * 简介区域
   */
  @Builder
  BioSection() {
    Column() {
      this.SectionTitle('人物简介')

      Text(this.blacksmith!.bio)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 区块标题
   */
  @Builder
  SectionTitle(title: string) {
    Row() {
      Column()
        .width(4)
        .height(20)
        .backgroundColor(ThemeColors.ACCENT)
        .borderRadius(2)

      Text(title)
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ left: Spacing.SMALL })
    }
    .width('100%')
    .margin({ bottom: Spacing.MEDIUM })
  }

  /**
   * 铸造技法区域
   */
  @Builder
  TechniquesSection() {
    if (this.blacksmith!.techniques && this.blacksmith!.techniques.length > 0) {
      Column() {
        this.SectionTitle('铸造技法')

        ForEach(this.blacksmith!.techniques, (technique: string, index: number) => {
          Row() {
            Column() {
              Text((index + 1).toString())
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.ACCENT)
            }
            .width(28)
            .height(28)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.SECONDARY_BG)
            .borderRadius(14)

            Text(technique)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .margin({ left: Spacing.MEDIUM })
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Spacing.MEDIUM)
          .backgroundColor(ThemeColors.CARD_BG)
          .borderRadius(Spacing.SMALL)
          .margin({ bottom: Spacing.SMALL })
        })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 传奇事迹区域
   */
  @Builder
  LegendSection() {
    Column() {
      this.SectionTitle('传奇事迹')

      Text(this.blacksmith!.legend)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 代表作品区域
   */
  @Builder
  MasterworksSection() {
    if (this.masterworkWeapons.length > 0) {
      Column() {
        this.SectionTitle('代表作品')

        ForEach(this.masterworkWeapons, (weapon: LegendaryWeapon) => {
          this.MasterworkCard(weapon)
        }, (weapon: LegendaryWeapon) => weapon.id)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 代表作品卡片
   */
  @Builder
  MasterworkCard(weapon: LegendaryWeapon) {
    Row() {
      // 图片
      Image($rawfile(`images/${weapon.image}`))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)
        .border({
          width: 2,
          color: getRarityColor(weapon.rarity)
        })

      // 信息
      Column() {
        Row() {
          Text(weapon.name.zh)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(RarityNames[weapon.rarity] || weapon.rarity)
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(weapon.rarity))
            .margin({ left: Spacing.SMALL })
        }

        Text(weapon.description)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.SMALL })
          .lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.MEDIUM })
      .layoutWeight(1)

      Image($r('app.media.icon_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .margin({ bottom: Spacing.MEDIUM })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}
