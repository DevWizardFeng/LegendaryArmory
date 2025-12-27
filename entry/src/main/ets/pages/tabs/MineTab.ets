/**
 * 神兵图录 - 我的Tab
 * 收藏、历史、设置
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor } from '../../common/Theme'
import { RouterPath, RarityNames, CultureNames, WeaponTypeNames, AppConstants } from '../../common/Constants'
import { DataLoader } from '../../utils/DataLoader'
import { StorageManager } from '../../utils/Storage'
import { LegendaryWeapon } from '../../model/LegendaryWeapon'
import { HistoryItem, UserSettings } from '../../model/UserData'

/**
 * 我的Tab内容组件
 */
@Component
export struct MineContent {
  @State isLoading: boolean = true
  @State favoriteCount: number = 0
  @State historyCount: number = 0
  @State settings: UserSettings = { theme: 'dark', sound: true, vibration: true }
  @StorageLink('currentTabIndex') @Watch('onTabShow') currentTabIndex: number = 0
  @StorageLink('favoriteWeaponIds') @Watch('onFavoritesChange') favoriteIds: string[] = []
  @StorageLink('historyWeaponIds') @Watch('onHistoryChange') historyIds: string[] = []
  private storageManager: StorageManager | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * Tab显示时刷新数据
   */
  onTabShow(): void {
    if (this.currentTabIndex === 4) { // 我的Tab索引
      this.loadCounts()
    }
  }

  /**
   * 收藏变化监听
   */
  onFavoritesChange(): void {
    this.favoriteCount = this.favoriteIds.length
  }

  /**
   * 历史变化监听
   */
  onHistoryChange(): void {
    this.historyCount = this.historyIds.length
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      const context = getContext(this)
      this.storageManager = new StorageManager(context)
      await this.storageManager.init()

      await this.loadCounts()
      this.settings = await this.storageManager.getSettings()
      this.isLoading = false
    } catch (error) {
      console.error('[MineTab] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 加载收藏和历史数量
   */
  async loadCounts(): Promise<void> {
    if (!this.storageManager) return

    try {
      const favoriteIds = await this.storageManager.getFavorites()
      const history = await this.storageManager.getHistory()
      this.favoriteCount = favoriteIds.length
      this.historyCount = history.length
    } catch (error) {
      console.error('[MineTab] 加载数量失败:', error)
    }
  }

  /**
   * 跳转到神兵详情
   */
  navigateToWeaponDetail(weaponId: string): void {
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: weaponId }
    })
  }

  /**
   * 跳转到百科Tab的子页面
   */
  navigateToEncyclopedia(subTabIndex: number): void {
    AppStorage.setOrCreate('encyclopediaSubTabIndex', subTabIndex)
    AppStorage.setOrCreate('currentTabIndex', 2) // 百科Tab
  }

  /**
   * 跳转到收藏列表
   */
  navigateToFavorites(): void {
    router.pushUrl({
      url: RouterPath.FAVORITE_LIST
    })
  }

  /**
   * 跳转到历史列表
   */
  navigateToHistory(): void {
    router.pushUrl({
      url: RouterPath.HISTORY_LIST
    })
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_tabbar'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        if (this.isLoading) {
          this.LoadingView()
        } else {
          Scroll() {
            Column() {
              // 用户信息卡片
              this.UserInfoCard()

              // 功能入口
              this.FunctionEntries()

              // 我的收藏和浏览历史
              this.MyCollectionSection()

              // 关于应用
              this.AboutSection()

              // 底部间距
              Blank().height(Spacing.XXLARGE)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 加载中视图
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.GOLD_PRIMARY)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 用户信息卡片
   */
  @Builder
  UserInfoCard() {
    Row() {
      // 头像
      Column() {
        Text('神')
          .fontSize(32)
          .fontColor(ThemeColors.GOLD_PRIMARY)
          .fontWeight(FontWeight.Bold)
      }
      .width(72)
      .height(72)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(26,34,51,0.6)')
      .backdropBlur(15)
      .borderRadius(36)
      .border({
        width: 2,
        color: ThemeColors.GOLD_PRIMARY
      })

      // 信息
      Column() {
        Text('神兵收藏家')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)

        Row() {
          Text(`收藏 ${this.favoriteCount}`)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.GOLD_PRIMARY)

          Text(' | ')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(`浏览 ${this.historyCount}`)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .margin({ top: Spacing.SMALL })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.LARGE })
    }
    .width('100%')
    .padding(Spacing.LARGE)
  }

  /**
   * 功能入口
   */
  @Builder
  FunctionEntries() {
    Row() {
      // 专题故事 - 切换到百科Tab（子Tab索引2）
      this.FunctionButton('专题故事', $r('app.media.icon_topic'), () => {
        this.navigateToEncyclopedia(2)
      })
      // 文化体系 - 切换到百科Tab（子Tab索引1）
      this.FunctionButton('文化体系', $r('app.media.icon_culture'), () => {
        this.navigateToEncyclopedia(1)
      })
      // 铸造大师 - 切换到百科Tab（子Tab索引0）
      this.FunctionButton('铸造大师', $r('app.media.icon_blacksmith'), () => {
        this.navigateToEncyclopedia(0)
      })
      // 挑战答题 - 保持router.pushUrl（独立页面）
      this.FunctionButton('挑战答题', $r('app.media.icon_quiz'), () => {
        router.pushUrl({ url: RouterPath.QUIZ })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
  }

  /**
   * 功能按钮
   */
  @Builder
  FunctionButton(title: string, icon: Resource, onClick: () => void) {
    Column() {
      Column() {
        Image(icon)
          .width(28)
          .height(28)
          .fillColor(ThemeColors.GOLD_PRIMARY)
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(26,34,51,0.6)')
      .backdropBlur(15)
      .borderRadius(Spacing.MEDIUM)
      .border({ width: 1, color: ThemeColors.DIVIDER })

      Text(title)
        .fontSize(FontSizes.CAPTION)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.SMALL })
    }
    .onClick(onClick)
  }

  /**
   * 我的收藏区域
   */
  @Builder
  MyCollectionSection() {
    Column() {
      Text('我的')
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_TITLE)
        .margin({ bottom: Spacing.MEDIUM })

      Column() {
        // 我的收藏
        Row() {
          Text('我的收藏')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Blank()
          Text(`${this.favoriteCount}`)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Image($r('app.media.icon_arrow_right'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.TEXT_TERTIARY)
            .margin({ left: Spacing.SMALL })
        }
        .width('100%')
        .padding({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })
        .onClick(() => this.navigateToFavorites())

        Divider().color(ThemeColors.DIVIDER)

        // 浏览历史
        Row() {
          Text('浏览历史')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Blank()
          Text(`${this.historyCount}`)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Image($r('app.media.icon_arrow_right'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.TEXT_TERTIARY)
            .margin({ left: Spacing.SMALL })
        }
        .width('100%')
        .padding({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })
        .onClick(() => this.navigateToHistory())
      }
      .width('100%')
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM })
      .backgroundColor('rgba(26,34,51,0.6)')
      .backdropBlur(15)
      .borderRadius(Spacing.MEDIUM)
      .border({ width: 1, color: ThemeColors.DIVIDER })
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 关于应用区域
   */
  @Builder
  AboutSection() {
    Column() {
      Text('关于')
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_TITLE)
        .margin({ bottom: Spacing.MEDIUM })

      Column() {
        Row() {
          Text('应用名称')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Blank()
          Text(AppConstants.APP_NAME)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')
        .padding({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })

        Divider().color(ThemeColors.DIVIDER)

        Row() {
          Text('版本')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Blank()
          Text(AppConstants.APP_VERSION)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')
        .padding({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })

        Divider().color(ThemeColors.DIVIDER)

        Row() {
          Text('描述')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Blank()
          Text(AppConstants.APP_DESCRIPTION)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')
        .padding({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })
      }
      .width('100%')
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM })
      .backgroundColor('rgba(26,34,51,0.6)')
      .backdropBlur(15)
      .borderRadius(Spacing.MEDIUM)
      .border({ width: 1, color: ThemeColors.DIVIDER })
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }
}
