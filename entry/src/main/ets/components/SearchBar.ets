/**
 * 神兵图录 - 搜索栏组件（博物馆典藏风格）
 * 提供搜索入口和热门搜索推荐
 */

import { ThemeColors, FontSizes, Spacing } from '../common/Theme'

/**
 * 搜索栏组件
 */
@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索神兵、铸造师、典故...'
  @Prop showHotSearch: boolean = false
  private onSearch?: (keyword: string) => void
  private onSearchFocus?: () => void
  @State searchText: string = ''
  @State isFocused: boolean = false

  // 热门搜索词
  private hotKeywords: string[] = ['轩辕剑', '草薙剑', '雷神之锤', '湛卢剑', '欧冶子']

  build() {
    Column() {
      // 搜索输入框 - 展柜搜索风格
      Row() {
        // 搜索图标
        Image($r('app.media.icon_search'))
          .width(20)
          .height(20)
          .fillColor(ThemeColors.TEXT_TERTIARY)
          .margin({ right: Spacing.SMALL })

        // 输入框
        TextInput({ placeholder: this.placeholder, text: this.searchText })
          .placeholderColor(ThemeColors.TEXT_TERTIARY)
          .placeholderFont({ size: FontSizes.BODY })
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontSize(FontSizes.BODY)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.searchText = value
          })
          .onSubmit(() => {
            if (this.onSearch && this.searchText.trim()) {
              this.onSearch(this.searchText.trim())
            }
          })
          .onFocus(() => {
            this.isFocused = true
            if (this.onSearchFocus) {
              this.onSearchFocus()
            }
          })
          .onBlur(() => {
            this.isFocused = false
          })

        // 清除按钮
        if (this.searchText.length > 0) {
          Image($r('app.media.icon_close'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.TEXT_TERTIARY)
            .margin({ left: Spacing.SMALL })
            .onClick(() => {
              this.searchText = ''
            })
        }
      }
      .width('100%')
      .height(44)
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM })
      .backgroundColor(ThemeColors.SURFACE_0)
      .borderRadius(22)
      .border({
        width: 1,
        color: this.isFocused ? ThemeColors.GOLD_PRIMARY : ThemeColors.DIVIDER
      })

      // 热门搜索 - 典藏标签风格
      if (this.showHotSearch) {
        Column() {
          Text('热门搜索')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.MEDIUM, bottom: Spacing.SMALL })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.hotKeywords, (keyword: string) => {
              Text(keyword)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.TEXT_PRIMARY)
                .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
                .backgroundColor(ThemeColors.BASE_1)
                .borderRadius(16)
                .border({
                  width: 1,
                  color: ThemeColors.DIVIDER
                })
                .margin({ right: Spacing.SMALL, bottom: Spacing.SMALL })
                .onClick(() => {
                  this.searchText = keyword
                  if (this.onSearch) {
                    this.onSearch(keyword)
                  }
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
  }
}
