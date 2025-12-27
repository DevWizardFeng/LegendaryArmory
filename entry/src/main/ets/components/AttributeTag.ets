/**
 * 神兵图录 - 属性标签组件
 * 用于展示神兵的元素属性
 */

import { ThemeColors, FontSizes, Spacing, getAttributeColor } from '../common/Theme'
import { AttributeNames } from '../common/Constants'

/**
 * 标签尺寸
 */
export type TagSize = 'small' | 'medium' | 'large'

/**
 * 属性标签组件
 */
@Component
export struct AttributeTag {
  @Prop attribute: string = ''
  @Prop tagSize: TagSize = 'medium'
  @Prop showIcon: boolean = true
  private onTagClick?: () => void

  build() {
    Row() {
      // 属性图标
      if (this.showIcon) {
        Image(this.getAttributeIcon())
          .width(this.getIconSize())
          .height(this.getIconSize())
          .fillColor(getAttributeColor(this.attribute))
          .margin({ right: this.tagSize === 'small' ? 2 : Spacing.TINY })
      }

      // 属性名称
      Text(AttributeNames[this.attribute] || this.attribute)
        .fontSize(this.getFontSize())
        .fontColor(getAttributeColor(this.attribute))
        .fontWeight(this.tagSize === 'large' ? FontWeight.Bold : FontWeight.Normal)
    }
    .padding(this.getPadding())
    .backgroundColor('rgba(0,0,0,0.3)')
    .borderRadius(this.getBorderRadius())
    .border({
      width: 1,
      color: getAttributeColor(this.attribute)
    })
    .onClick(() => {
      if (this.onTagClick) {
        this.onTagClick()
      }
    })
  }

  /**
   * 获取属性图标资源
   */
  private getAttributeIcon(): Resource {
    switch (this.attribute) {
      case 'fire': return $r('app.media.icon_fire')
      case 'water': return $r('app.media.icon_water')
      case 'ice': return $r('app.media.icon_ice')
      case 'thunder': return $r('app.media.icon_thunder')
      case 'wind': return $r('app.media.icon_wind')
      case 'earth': return $r('app.media.icon_earth')
      case 'light': return $r('app.media.icon_light')
      case 'dark': return $r('app.media.icon_dark')
      case 'poison': return $r('app.media.icon_poison')
      case 'nature': return $r('app.media.icon_nature')
      case 'time_space': return $r('app.media.icon_time_space')
      case 'death': return $r('app.media.icon_death')
      case 'chaos': return $r('app.media.icon_chaos')
      case 'special': return $r('app.media.icon_special')
      default: return $r('app.media.icon_special')
    }
  }

  /**
   * 获取图标尺寸
   */
  private getIconSize(): number {
    switch (this.tagSize) {
      case 'small': return 12
      case 'large': return 20
      default: return 16
    }
  }

  /**
   * 获取字体大小
   */
  private getFontSize(): number {
    switch (this.tagSize) {
      case 'small': return FontSizes.SMALL
      case 'large': return FontSizes.BODY
      default: return FontSizes.BODY_SMALL
    }
  }

  /**
   * 获取内边距
   */
  private getPadding(): Padding {
    switch (this.tagSize) {
      case 'small':
        return { left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 }
      case 'large':
        return { left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL }
      default:
        return { left: Spacing.SMALL, right: Spacing.SMALL, top: 4, bottom: 4 }
    }
  }

  /**
   * 获取圆角
   */
  private getBorderRadius(): number {
    switch (this.tagSize) {
      case 'small': return 4
      case 'large': return 8
      default: return 6
    }
  }
}

/**
 * 品质边框组件
 * 为卡片或图片添加品质对应颜色的边框效果
 */
@Component
export struct RarityBorder {
  @Prop rarity: string = ''
  @BuilderParam content: () => void

  build() {
    Column() {
      if (this.content) {
        this.content()
      }
    }
    .border({
      width: 2,
      color: this.getRarityColor()
    })
    .borderRadius(Spacing.MEDIUM)
  }

  /**
   * 获取品质颜色
   */
  private getRarityColor(): string {
    switch (this.rarity) {
      case 'artifact': return ThemeColors.RARITY_ARTIFACT
      case 'legendary': return ThemeColors.RARITY_LEGENDARY
      case 'epic': return ThemeColors.RARITY_EPIC
      case 'rare': return ThemeColors.RARITY_RARE
      default: return ThemeColors.DIVIDER
    }
  }
}
