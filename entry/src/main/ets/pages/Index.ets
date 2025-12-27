/**
 * 神兵图录 - 首页
 * 展示轮播推荐、快速入口、传说神兵列表
 */

@Entry
@Component
struct Index {
  @State message: string = '神兵图录'
  @State isLoading: boolean = true

  /**
   * 页面即将显示时回调
   */
  aboutToAppear(): void {
    // TODO: 加载首页数据
    this.isLoading = false
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.message)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      // 主内容区
      Scroll() {
        Column() {
          // 欢迎语
          Text('探索传说中的神兵利器')
            .fontSize(16)
            .fontColor('#b0b0b0')
            .margin({ top: 20, bottom: 20 })

          // 占位提示
          Column() {
            Text('正在开发中...')
              .fontSize(14)
              .fontColor('#666666')
            Text('神兵图鉴即将呈现')
              .fontSize(12)
              .fontColor('#444444')
              .margin({ top: 8 })
          }
          .width('90%')
          .padding(40)
          .backgroundColor('#1a1a2e')
          .borderRadius(12)
          .margin({ top: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0a0a1a')
  }
}
