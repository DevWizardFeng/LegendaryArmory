/**
 * 神兵图录 - 首页轮播组件（博物馆典藏风格）
 * 展示精选神兵或专题
 */

import { ThemeColors, getRarityColor, getRarityDarkColor } from '../common/Theme'
import { Spacing, FontSizes } from '../common/Theme'

/**
 * 轮播项数据结构
 */
export interface BannerItem {
  id: string
  title: string
  subtitle: string
  image: string
  rarity?: string
  type: 'weapon' | 'topic' | 'culture'
}

/**
 * 轮播组件
 */
@Component
export struct Banner {
  @Prop items: BannerItem[] = []
  private onItemClick?: (item: BannerItem) => void
  @State currentIndex: number = 0

  build() {
    Column() {
      if (this.items.length > 0) {
        Swiper() {
          ForEach(this.items, (item: BannerItem) => {
            this.BannerCard(item)
          }, (item: BannerItem) => item.id)
        }
        .autoPlay(true)
        .interval(4000)
        .indicator(
          Indicator.dot()
            .color(ThemeColors.TEXT_TERTIARY)
            .selectedColor(ThemeColors.GOLD_PRIMARY)
        )
        .loop(true)
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .width('100%')
        .height(200)
      }
    }
    .width('100%')
  }

  @Builder
  BannerCard(item: BannerItem) {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 背景图片
      Image($rawfile(`images/${item.image}`))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.MEDIUM)

      // 渐变遮罩 - 使用 BASE_0 深炭黑
      Column()
        .width('100%')
        .height('60%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(11,13,16,0)', 0], ['rgba(11,13,16,0.85)', 1]]
        })

      // 文字信息
      Column() {
        // 品质标签 - 展柜铭牌风格
        if (item.rarity) {
          Text(this.getRarityText(item.rarity))
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(item.rarity))
            .fontWeight(FontWeight.Bold)
            .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
            .backgroundColor('rgba(26,34,51,0.85)')
            .borderRadius(4)
            .border({
              width: 1,
              color: getRarityDarkColor(item.rarity)
            })
            .margin({ bottom: Spacing.TINY })
        }

        // 标题使用羊皮纸色
        Text(item.title)
          .fontSize(FontSizes.TITLE)
          .fontColor(ThemeColors.TEXT_TITLE)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.subtitle)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.TINY })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(Spacing.LARGE)
    }
    .width('100%')
    .height('100%')
    .borderRadius(Spacing.MEDIUM)
    .clip(true)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(item)
      }
    })
  }

  /**
   * 获取品质文本
   */
  private getRarityText(rarity: string): string {
    switch (rarity) {
      case 'artifact': return '神器'
      case 'legendary': return '传说'
      case 'epic': return '史诗'
      case 'rare': return '稀有'
      default: return ''
    }
  }
}
