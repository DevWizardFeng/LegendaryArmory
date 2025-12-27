/**
 * 神兵图录 - 主页面容器（博物馆典藏风格）
 * 包含5个Tab的底部导航栏（扩展模式）
 * - Tab切换无动画（animationDuration: 0）
 * - TabBar点击弹性动效（SpringMotion）
 */

import { router } from '@kit.ArkUI'
import { curves } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing } from '../common/Theme'
import { RouterPath } from '../common/Constants'
import { IndexContent } from './tabs/IndexTab'
import { WeaponListContent } from './tabs/WeaponTab'
import { EncyclopediaContent } from './tabs/EncyclopediaTab'
import { GameContent } from './tabs/GameTab'
import { MineContent } from './tabs/MineTab'

/**
 * 路由参数接口
 */
interface RouterParams {
  initialTab?: number
}

/**
 * 主页面容器
 */
@Entry
@Component
struct MainPage {
  @StorageLink('currentTabIndex') currentTabIndex: number = 0
  @State tabPressedStates: boolean[] = [false, false, false, false, false]  // 追踪每个Tab的按下状态
  private tabsController: TabsController = new TabsController()

  aboutToAppear(): void {
    // 接收路由参数（用于深度链接跳转）
    const params = router.getParams() as RouterParams
    if (params?.initialTab !== undefined) {
      this.currentTabIndex = params.initialTab
    }

    // 初始化全局状态
    AppStorage.setOrCreate('currentTabIndex', this.currentTabIndex)
    AppStorage.setOrCreate('favoriteWeaponIds', [])
    AppStorage.setOrCreate('historyWeaponIds', [])
    AppStorage.setOrCreate('weaponPresetFilter', '')
    AppStorage.setOrCreate('encyclopediaSubTabIndex', -1)
    AppStorage.setOrCreate('weaponListScrollOffset', 0)
  }

  /**
   * 自定义TabBar构建器（带弹性点击动效）- 博物馆导航风格
   */
  @Builder
  customTabBar(name: string, iconNormal: Resource, iconSelected: Resource, index: number) {
    Column() {
      Image(this.currentTabIndex === index ? iconSelected : iconNormal)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? ThemeColors.GOLD_PRIMARY : ThemeColors.TEXT_TERTIARY)
      Text(name)
        .fontSize(FontSizes.SMALL)
        .fontColor(this.currentTabIndex === index ? ThemeColors.GOLD_PRIMARY : ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.TINY })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .scale({
      x: this.tabPressedStates[index] ? 0.9 : 1.0,
      y: this.tabPressedStates[index] ? 0.9 : 1.0
    })  // 按下时缩小到0.9
    .animation({
      duration: 200,
      curve: curves.springMotion(),  // 弹簧曲线
      playMode: PlayMode.Normal
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.tabPressedStates[index] = true  // 按下
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.tabPressedStates[index] = false  // 释放
      }
    })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController,
        index: this.currentTabIndex
      }) {
        // Tab 0: 首页
        TabContent() {
          IndexContent()
        }
        .tabBar(this.customTabBar(
          '首页',
          $r('app.media.icon_tab_home_normal'),
          $r('app.media.icon_tab_home_selected'),
          0
        ))

        // Tab 1: 神兵
        TabContent() {
          WeaponListContent()
        }
        .tabBar(this.customTabBar(
          '神兵',
          $r('app.media.icon_tab_weapon_normal'),
          $r('app.media.icon_tab_weapon_selected'),
          1
        ))

        // Tab 2: 百科
        TabContent() {
          EncyclopediaContent()
        }
        .tabBar(this.customTabBar(
          '百科',
          $r('app.media.icon_tab_encyclopedia_normal'),
          $r('app.media.icon_tab_encyclopedia_selected'),
          2
        ))

        // Tab 3: 互动
        TabContent() {
          GameContent()
        }
        .tabBar(this.customTabBar(
          '互动',
          $r('app.media.icon_tab_game_normal'),
          $r('app.media.icon_tab_game_selected'),
          3
        ))

        // Tab 4: 我的
        TabContent() {
          MineContent()
        }
        .tabBar(this.customTabBar(
          '我的',
          $r('app.media.icon_tab_mine_normal'),
          $r('app.media.icon_tab_mine_selected'),
          4
        ))
      }
      .barMode(BarMode.Fixed)  // 固定模式（适合5个tab）
      .scrollable(false)  // 禁止滑动切换
      .animationDuration(0)  // 用户要求：Tab切换无动画
      .backgroundColor(ThemeColors.BASE_0)
      .barBackgroundColor(ThemeColors.BASE_1)
      .onSelected((index: number) => {
        this.currentTabIndex = index
        // 同步到全局状态
        AppStorage.setOrCreate('currentTabIndex', index)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
  }
}
