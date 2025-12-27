/**
 * 神兵图录 - 文化体系页
 * 展示各文化体系的神兵和背景介绍
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../common/Theme'
import { RouterPath, CultureNames, RarityNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { Culture } from '../model/Culture'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

@Entry
@Component
struct CultureList {
  @State isLoading: boolean = true
  @State cultures: Culture[] = []
  @State weapons: LegendaryWeapon[] = []
  @State selectedCulture: Culture | null = null
  @State cultureWeapons: LegendaryWeapon[] = []
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
      this.cultures = await this.dataLoader.loadCultures()
      this.weapons = await this.dataLoader.loadWeapons()
      this.isLoading = false
    } catch (error) {
      console.error('[CultureList] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 选择文化
   */
  selectCulture(culture: Culture): void {
    this.selectedCulture = culture
    this.cultureWeapons = this.weapons.filter(w => w.culture === culture.id)
  }

  /**
   * 返回文化列表
   */
  backToCultureList(): void {
    this.selectedCulture = null
    this.cultureWeapons = []
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    if (this.selectedCulture) {
      this.backToCultureList()
    } else {
      router.back()
    }
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

  /**
   * 获取文化的神兵数量
   */
  getWeaponCount(cultureId: string): number {
    return this.weapons.filter(w => w.culture === cultureId).length
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => this.goBack())

        Text(this.selectedCulture ? this.selectedCulture.name_cn : '文化体系')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ left: Spacing.MEDIUM })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      // 主内容区
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.selectedCulture) {
        this.CultureDetailView()
      } else {
        this.CultureListView()
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
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 文化列表视图
   */
  @Builder
  CultureListView() {
    List() {
      ForEach(this.cultures, (culture: Culture) => {
        ListItem() {
          this.CultureCard(culture)
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (culture: Culture) => culture.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  /**
   * 文化卡片
   */
  @Builder
  CultureCard(culture: Culture) {
    Column() {
      // 头部
      Row() {
        // 图标
        Column() {
          Text(culture.name_cn.substring(0, 1))
            .fontSize(FontSizes.TITLE)
            .fontColor(ThemeColors.ACCENT)
            .fontWeight(FontWeight.Bold)
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.SECONDARY_BG)
        .borderRadius(Spacing.MEDIUM)

        // 信息
        Column() {
          Text(culture.name_cn)
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(culture.region)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ top: Spacing.TINY })

          Text(`${this.getWeaponCount(culture.id)} 件神兵`)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.ACCENT)
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

      // 描述
      Text(culture.description || culture.background)
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: Spacing.MEDIUM })
        .lineHeight(20)

      // 特色标签
      if ((culture.characteristics || []).length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach((culture.characteristics || []).slice(0, 3), (char: string) => {
            Text(char)
              .fontSize(FontSizes.SMALL)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
              .backgroundColor(ThemeColors.SECONDARY_BG)
              .borderRadius(4)
              .margin({ right: Spacing.TINY, top: Spacing.SMALL })
          })
        }
        .margin({ top: Spacing.SMALL })
      }
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .onClick(() => this.selectCulture(culture))
  }

  /**
   * 文化详情视图
   */
  @Builder
  CultureDetailView() {
    Scroll() {
      Column() {
        // 文化介绍
        this.CultureIntroSection()

        // 文化特色
        this.CharacteristicsSection()

        // 代表神兵
        this.RepresentativeWeaponsSection()

        // 底部间距
        Blank().height(Spacing.XXLARGE)
      }
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  /**
   * 文化介绍区域
   */
  @Builder
  CultureIntroSection() {
    Column() {
      // 头部信息
      Row() {
        Column() {
          Text(this.selectedCulture!.name_cn.substring(0, 1))
            .fontSize(32)
            .fontColor(ThemeColors.ACCENT)
            .fontWeight(FontWeight.Bold)
        }
        .width(64)
        .height(64)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.CARD_BG)
        .borderRadius(Spacing.MEDIUM)
        .border({
          width: 2,
          color: ThemeColors.ACCENT
        })

        Column() {
          Text(this.selectedCulture!.name)
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(this.selectedCulture!.region)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.TINY })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: Spacing.LARGE })
      }
      .width('100%')
      .margin({ bottom: Spacing.LARGE })

      // 描述
      Text(this.selectedCulture!.description)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 文化特色区域
   */
  @Builder
  CharacteristicsSection() {
    if (this.selectedCulture!.characteristics && this.selectedCulture!.characteristics.length > 0) {
      Column() {
        Text('文化特色')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ bottom: Spacing.MEDIUM })

        ForEach(this.selectedCulture!.characteristics, (char: string, index: number) => {
          Row() {
            Text((index + 1).toString())
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.ACCENT)
              .width(24)

            Text(char)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_PRIMARY)
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
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 代表神兵区域
   */
  @Builder
  RepresentativeWeaponsSection() {
    Column() {
      Row() {
        Text('代表神兵')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Text(`共 ${this.cultureWeapons.length} 件`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')
      .margin({ top: Spacing.XLARGE, bottom: Spacing.MEDIUM })

      ForEach(this.cultureWeapons, (weapon: LegendaryWeapon) => {
        this.WeaponItem(weapon)
      }, (weapon: LegendaryWeapon) => weapon.id)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 神兵项
   */
  @Builder
  WeaponItem(weapon: LegendaryWeapon) {
    Row() {
      // 图片
      Image($rawfile(`images/${weapon.image}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)

      // 信息
      Column() {
        Row() {
          Text(weapon.name.cn)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(RarityNames[weapon.rarity] || weapon.rarity)
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(weapon.rarity))
            .margin({ left: Spacing.SMALL })
        }

        Text(weapon.description)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.TINY })
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
    .margin({ bottom: Spacing.SMALL })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}
