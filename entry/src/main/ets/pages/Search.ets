/**
 * 神兵图录 - 搜索页
 * 搜索神兵、铸造师、典故
 */

import { ThemeColors, FontSizes, Spacing } from '../common/Theme'

@Entry
@Component
struct Search {
  @State message: string = '搜索'

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
