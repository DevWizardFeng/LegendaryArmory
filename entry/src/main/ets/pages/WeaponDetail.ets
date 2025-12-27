/**
 * 神兵图录 - 神兵详情页
 * 展示神兵完整信息
 */

import { ThemeColors, FontSizes, Spacing } from '../common/Theme'

@Entry
@Component
struct WeaponDetail {
  @State message: string = '神兵详情'

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
