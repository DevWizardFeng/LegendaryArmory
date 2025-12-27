/**
 * 神兵图录 - 互动Tab
 * 提供挑战答题、每日占卜、对战模拟等游戏入口
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing } from '../../common/Theme'
import { RouterPath } from '../../common/Constants'

/**
 * 游戏入口配置
 */
interface GameEntry {
  id: string
  title: string
  subtitle: string
  icon: Resource
  iconBg: string
  route: string
}

/**
 * 互动Tab内容组件
 */
@Component
export struct GameContent {
  // 游戏入口配置（使用博物馆典藏风配色）
  private gameEntries: GameEntry[] = [
    {
      id: 'quiz',
      title: '挑战答题',
      subtitle: '测试你对神兵知识的掌握',
      icon: $r('app.media.icon_quiz'),
      iconBg: ThemeColors.RARITY_LEGENDARY,
      route: RouterPath.QUIZ
    },
    {
      id: 'divination',
      title: '每日占卜',
      subtitle: '抽取今日幸运神兵',
      icon: $r('app.media.icon_divination'),
      iconBg: ThemeColors.RARITY_ARTIFACT,
      route: RouterPath.DAILY_DIVINATION
    },
    {
      id: 'battle',
      title: '对战模拟',
      subtitle: '模拟神兵间的战斗',
      icon: $r('app.media.icon_battle'),
      iconBg: ThemeColors.RARITY_EPIC,
      route: RouterPath.BATTLE_SIMULATOR
    }
  ]

  /**
   * 导航到游戏页面
   */
  navigateToGame(route: string): void {
    router.pushUrl({ url: route })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('互动娱乐')
          .fontSize(FontSizes.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
      }
      .height(56)
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .backgroundColor(ThemeColors.BASE_1)

      // 游戏入口列表
      Scroll() {
        Column() {
          // 顶部说明
          Text('选择一个游戏开始体验')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.XLARGE, bottom: Spacing.XLARGE })

          // 游戏入口卡片
          ForEach(this.gameEntries, (entry: GameEntry) => {
            this.GameEntryCard(entry)
          }, (entry: GameEntry) => entry.id)

          // 底部间距（避免被TabBar遮挡）
          Blank().height(76)
        }
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
  }

  /**
   * 游戏入口卡片
   */
  @Builder
  GameEntryCard(entry: GameEntry) {
    Row() {
      // 图标 - 全尺寸显示
      Image(entry.icon)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.LARGE)

      // 信息
      Column() {
        Text(entry.title)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)

        Text(entry.subtitle)
          .fontSize(FontSizes.BODY)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: Spacing.SMALL })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.LARGE })
      .layoutWeight(1)

      // 箭头
      Image($r('app.media.icon_arrow_right'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .backgroundColor(ThemeColors.SURFACE_0)
    .borderRadius(Spacing.LARGE)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .margin({ bottom: Spacing.LARGE })
    .onClick(() => this.navigateToGame(entry.route))
  }
}
