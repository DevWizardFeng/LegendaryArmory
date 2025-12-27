/**
 * 神兵图录 - 神兵卡片组件
 * 用于列表和网格展示的神兵卡片
 */

import { ThemeColors, FontSizes, Spacing, getRarityColor, getAttributeColor } from '../common/Theme'
import { CultureNames, WeaponTypeNames, RarityNames, AttributeNames } from '../common/Constants'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

/**
 * 卡片尺寸类型
 */
export type CardSize = 'small' | 'medium' | 'large'

/**
 * 神兵卡片组件
 */
@Component
export struct WeaponCard {
  @Prop weapon: LegendaryWeapon
  @Prop cardSize: CardSize = 'medium'
  private onCardClick?: () => void

  build() {
    if (this.cardSize === 'large') {
      this.LargeCard()
    } else if (this.cardSize === 'small') {
      this.SmallCard()
    } else {
      this.MediumCard()
    }
  }

  /**
   * 中等尺寸卡片（默认）
   */
  @Builder
  MediumCard() {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($rawfile(`images/${this.weapon.image}`))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Spacing.MEDIUM, topRight: Spacing.MEDIUM })

        // 品质标签
        Text(RarityNames[this.weapon.rarity] || this.weapon.rarity)
          .fontSize(FontSizes.SMALL)
          .fontColor(getRarityColor(this.weapon.rarity))
          .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
          .backgroundColor('rgba(0,0,0,0.6)')
          .borderRadius(4)
          .margin({ top: Spacing.SMALL, right: Spacing.SMALL })
      }
      .width('100%')

      // 信息区域
      Column() {
        Text(this.weapon.name.cn)
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(CultureNames[this.weapon.culture] || this.weapon.culture)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(' | ')
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(WeaponTypeNames[this.weapon.type] || this.weapon.type)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .margin({ top: Spacing.TINY })

        // 属性标签
        Row() {
          this.AttributeTag(this.weapon.attributes.primary)
          if (this.weapon.attributes.secondary) {
            this.AttributeTag(this.weapon.attributes.secondary)
          }
        }
        .margin({ top: Spacing.SMALL })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(Spacing.MEDIUM)
    }
    .width('100%')
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: 1,
      color: getRarityColor(this.weapon.rarity)
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }

  /**
   * 小尺寸卡片
   */
  @Builder
  SmallCard() {
    Row() {
      // 图片
      Image($rawfile(`images/${this.weapon.image}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)

      // 信息
      Column() {
        Text(this.weapon.name.cn)
          .fontSize(FontSizes.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${CultureNames[this.weapon.culture] || this.weapon.culture} · ${WeaponTypeNames[this.weapon.type] || this.weapon.type}`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: 2 })

        Row() {
          Text(RarityNames[this.weapon.rarity] || this.weapon.rarity)
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(this.weapon.rarity))
        }
        .margin({ top: Spacing.TINY })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.MEDIUM })
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: 1,
      color: ThemeColors.DIVIDER
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }

  /**
   * 大尺寸卡片
   */
  @Builder
  LargeCard() {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($rawfile(`images/${this.weapon.image}`))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Spacing.MEDIUM, topRight: Spacing.MEDIUM })

        // 渐变遮罩
        Column()
          .width('100%')
          .height('50%')
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.7)', 1]]
          })

        // 品质和属性
        Row() {
          Text(RarityNames[this.weapon.rarity] || this.weapon.rarity)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(getRarityColor(this.weapon.rarity))
            .fontWeight(FontWeight.Bold)
            .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
            .backgroundColor('rgba(0,0,0,0.5)')
            .borderRadius(4)

          Blank()

          this.AttributeTag(this.weapon.attributes.primary)
          if (this.weapon.attributes.secondary) {
            this.AttributeTag(this.weapon.attributes.secondary)
          }
        }
        .width('100%')
        .padding(Spacing.MEDIUM)
      }
      .width('100%')

      // 信息区域
      Column() {
        Row() {
          Text(this.weapon.name.cn)
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          if (this.weapon.name.en) {
            Text(this.weapon.name.en)
              .fontSize(FontSizes.CAPTION)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .margin({ left: Spacing.SMALL })
          }
        }

        Text(`${CultureNames[this.weapon.culture] || this.weapon.culture} · ${WeaponTypeNames[this.weapon.type] || this.weapon.type}`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: Spacing.TINY })

        Text(this.weapon.description)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.SMALL })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(Spacing.LARGE)
    }
    .width('100%')
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: 2,
      color: getRarityColor(this.weapon.rarity)
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }

  /**
   * 属性标签
   */
  @Builder
  AttributeTag(attribute: string) {
    Row() {
      Text(AttributeNames[attribute] || attribute)
        .fontSize(FontSizes.SMALL)
        .fontColor(getAttributeColor(attribute))
    }
    .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
    .backgroundColor('rgba(0,0,0,0.3)')
    .borderRadius(4)
    .border({
      width: 1,
      color: getAttributeColor(attribute)
    })
    .margin({ right: Spacing.TINY })
  }
}
