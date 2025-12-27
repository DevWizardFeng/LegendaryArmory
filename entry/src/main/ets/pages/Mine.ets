/**
 * 神兵图录 - 我的页面
 * 收藏、历史、设置
 */

import { ThemeColors, FontSizes, Spacing } from '../common/Theme'

@Entry
@Component
struct Mine {
  @State message: string = '我的'

  build() {
    Column() {
      Text(this.message)
        .fontSize(FontSizes.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
      Text('开发中...')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }
}
