/**
 * 神兵图录 - 铸造大师列表页
 * 展示所有传奇铸造师
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../common/Theme'
import { RouterPath, CultureNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { Blacksmith } from '../model/Blacksmith'

@Entry
@Component
struct BlacksmithList {
  @State isLoading: boolean = true
  @State blacksmiths: Blacksmith[] = []
  @State selectedCulture: string = ''
  @State filteredBlacksmiths: Blacksmith[] = []
  private dataLoader: DataLoader | null = null

  // 文化筛选选项
  private cultureOptions: string[] = ['', 'chinese', 'japanese', 'norse', 'greek', 'celtic', 'medieval_europe', 'indian']

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.blacksmiths = await this.dataLoader.loadBlacksmiths()
      this.applyFilter()
      this.isLoading = false
    } catch (error) {
      console.error('[BlacksmithList] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 应用筛选
   */
  applyFilter(): void {
    if (this.selectedCulture) {
      this.filteredBlacksmiths = this.blacksmiths.filter(b => b.culture === this.selectedCulture)
    } else {
      this.filteredBlacksmiths = this.blacksmiths
    }
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    router.back()
  }

  /**
   * 跳转到铸造师详情
   */
  navigateToDetail(blacksmithId: string): void {
    router.pushUrl({
      url: RouterPath.BLACKSMITH_DETAIL,
      params: { blacksmithId: blacksmithId }
    })
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

        Text('铸造大师')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ left: Spacing.MEDIUM })

        Blank()

        Text(`共 ${this.filteredBlacksmiths.length} 位`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      // 文化筛选
      this.CultureFilter()

      // 主内容区
      if (this.isLoading) {
        this.LoadingView()
      } else {
        this.ContentView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }

  /**
   * 文化筛选栏
   */
  @Builder
  CultureFilter() {
    Scroll() {
      Row() {
        ForEach(this.cultureOptions, (culture: string) => {
          Text(culture ? (CultureNames[culture] || culture) : '全部')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(this.selectedCulture === culture ? ThemeColors.PRIMARY_BG : ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
            .backgroundColor(this.selectedCulture === culture ? ThemeColors.ACCENT : ThemeColors.CARD_BG)
            .borderRadius(Spacing.LARGE)
            .margin({ right: Spacing.SMALL })
            .onClick(() => {
              this.selectedCulture = culture
              this.applyFilter()
            })
        })
      }
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(48)
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
   * 内容视图
   */
  @Builder
  ContentView() {
    List() {
      ForEach(this.filteredBlacksmiths, (blacksmith: Blacksmith) => {
        ListItem() {
          this.BlacksmithCard(blacksmith)
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (blacksmith: Blacksmith) => blacksmith.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  /**
   * 铸造师卡片
   */
  @Builder
  BlacksmithCard(blacksmith: Blacksmith) {
    Row() {
      // 头像
      Column() {
        Image($rawfile(`images/${blacksmith.image}`))
          .width(80)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(Spacing.MEDIUM)
      }
      .border({
        width: 2,
        color: ThemeColors.ACCENT
      })
      .borderRadius(Spacing.MEDIUM)

      // 信息
      Column() {
        // 名称
        Text(blacksmith.name.cn)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        // 文化和时代
        Row() {
          Text(CultureNames[blacksmith.culture] || blacksmith.culture)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.ACCENT)

          Text(' · ')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(blacksmith.era)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .margin({ top: Spacing.TINY })

        // 称号
        Text(blacksmith.title)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: Spacing.SMALL })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 代表作品数量
        Text(`代表作品: ${blacksmith.masterworks?.length || 0} 件`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: Spacing.SMALL })
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
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .onClick(() => this.navigateToDetail(blacksmith.id))
  }
}
