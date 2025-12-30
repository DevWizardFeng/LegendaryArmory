/**
 * 神兵图录 - 专题详情页
 * 展示图文专题的完整内容
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../common/Theme'
import { RouterPath, RarityNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { Topic } from '../model/Topic'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

// 专题分类名称映射
const TopicCategoryNames: Record<string, string> = {
  'culture': '文化',
  'technique': '工艺',
  'legend': '传说',
  'history': '历史'
}

@Entry
@Component
struct TopicDetail {
  @State topic: Topic | null = null
  @State relatedWeapons: LegendaryWeapon[] = []
  @State isLoading: boolean = true
  @State scrollY: number = 0
  private dataLoader: DataLoader | null = null
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, string>
      const topicId = params?.topicId

      if (!topicId) {
        console.error('[TopicDetail] 未提供专题ID')
        return
      }

      this.dataLoader = new DataLoader(getContext(this))
      const topics = await this.dataLoader.loadTopics()
      this.topic = topics.find(t => t.id === topicId) || null

      // 加载相关神兵
      if (this.topic && this.topic.related_weapons?.length > 0) {
        const weapons = await this.dataLoader.loadWeapons()
        this.relatedWeapons = weapons.filter(w =>
          this.topic!.related_weapons.includes(w.id)
        )
      }

      this.isLoading = false
    } catch (error) {
      console.error('[TopicDetail] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  navigateToWeaponDetail(weaponId: string): void {
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: weaponId }
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.topic) {
        this.ContentView()
      } else {
        this.ErrorView()
      }

      // 顶部导航栏
      this.TopBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
  }

  @Builder
  TopBar() {
    Row() {
      // 返回按钮
      Row() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(ThemeColors.SURFACE_0)
      .borderRadius(22)
      .shadow({ radius: 8, color: '#40000000', offsetX: 0, offsetY: 2 })
      .onClick(() => router.back())

      Blank()
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: 48 })
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.GOLD_PRIMARY)
      Text('正在加载...')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorView() {
    Column() {
      Text('专题不存在')
        .fontSize(FontSizes.SUBTITLE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
      Text('返回')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.GOLD_PRIMARY)
        .margin({ top: Spacing.MEDIUM })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ContentView() {
    if (this.topic) {
      Scroll(this.scroller) {
        Column() {
          // 封面图片
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r(`app.media.${this.topic.image.replace('.png', '')}`))
              .width('100%')
              .height(280)
              .objectFit(ImageFit.Cover)

            // 渐变遮罩
            Column()
              .width('100%')
              .height(280)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['transparent', 0], [ThemeColors.BASE_0, 1]]
              })

            // 标题区域
            Column() {
              // 分类标签
              Text(TopicCategoryNames[this.topic.category] || this.topic.category)
                .fontSize(FontSizes.SMALL)
                .fontColor(ThemeColors.GOLD_PRIMARY)
                .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
                .backgroundColor(ThemeColors.SURFACE_0)
                .borderRadius(4)
                .border({ width: 1, color: ThemeColors.GOLD_PRIMARY })

              // 标题
              Text(this.topic.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.TEXT_TITLE)
                .margin({ top: Spacing.SMALL })

              // 摘要
              Text(this.topic.summary)
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.TEXT_SECONDARY)
                .margin({ top: Spacing.SMALL })
            }
            .alignItems(HorizontalAlign.Start)
            .padding(Spacing.LARGE)
          }
          .width('100%')

          // 正文内容
          this.ArticleContent()

          // 相关神兵
          if (this.relatedWeapons.length > 0) {
            this.RelatedWeaponsSection()
          }

          Blank().height(100)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  ArticleContent() {
    if (this.topic) {
      Column() {
        // 将内容按段落分割
        ForEach(this.topic.content.split('\n\n'), (paragraph: string, index: number) => {
          if (paragraph.startsWith('【') && paragraph.includes('】')) {
            // 小标题样式
            Text(paragraph)
              .fontSize(FontSizes.SUBTITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.GOLD_PRIMARY)
              .margin({ top: index === 0 ? 0 : Spacing.LARGE, bottom: Spacing.SMALL })
          } else if (paragraph.startsWith('- ') || paragraph.startsWith('• ')) {
            // 列表项样式
            Row() {
              Text('•')
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.GOLD_PRIMARY)
                .width(20)

              Text(paragraph.replace(/^[-•]\s*/, ''))
                .fontSize(FontSizes.BODY)
                .fontColor(ThemeColors.TEXT_PRIMARY)
                .lineHeight(24)
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
            .margin({ top: Spacing.SMALL })
          } else {
            // 普通段落样式
            Text(paragraph)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .lineHeight(26)
              .margin({ top: index === 0 ? 0 : Spacing.MEDIUM })
          }
        })
      }
      .width('100%')
      .padding(Spacing.LARGE)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  RelatedWeaponsSection() {
    Column() {
      // 标题
      Row() {
        Column()
          .width(4)
          .height(20)
          .backgroundColor(ThemeColors.GOLD_PRIMARY)
          .borderRadius(2)

        Text('相关神兵')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .margin({ left: Spacing.SMALL })

        Blank()

        Text(`${this.relatedWeapons.length}件`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')
      .margin({ bottom: Spacing.MEDIUM })

      // 神兵列表
      ForEach(this.relatedWeapons, (weapon: LegendaryWeapon) => {
        this.WeaponItem(weapon)
      }, (weapon: LegendaryWeapon) => weapon.id)
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .backgroundColor(ThemeColors.SURFACE_0)
    .margin({ top: Spacing.MEDIUM })
  }

  @Builder
  WeaponItem(weapon: LegendaryWeapon) {
    Row() {
      // 图片
      Image($rawfile(`images/${weapon.image}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)
        .border({ width: 1, color: getRarityColor(weapon.rarity) })

      // 信息
      Column() {
        Row() {
          Text(weapon.name.cn)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_TITLE)

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

      // 箭头
      Image($r('app.media.icon_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.BASE_1)
    .borderRadius(Spacing.MEDIUM)
    .margin({ bottom: Spacing.SMALL })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}
