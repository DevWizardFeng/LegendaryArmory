/**
 * 神兵图录 - 我的页面
 * 收藏、历史、设置
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../common/Theme'
import { RouterPath, RarityNames, CultureNames, WeaponTypeNames, AppConstants } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { StorageManager } from '../utils/Storage'
import { LegendaryWeapon } from '../model/LegendaryWeapon'
import { HistoryItem, UserSettings } from '../model/UserData'

/**
 * 菜单项
 */
interface MenuItem {
  icon: Resource
  title: string
  subtitle?: string
  onClick: () => void
}

@Entry
@Component
struct Mine {
  @State isLoading: boolean = true
  @State favoriteWeapons: LegendaryWeapon[] = []
  @State historyWeapons: LegendaryWeapon[] = []
  @State currentTab: 'favorites' | 'history' = 'favorites'
  @State settings: UserSettings = { theme: 'dark', sound: true, vibration: true }
  private dataLoader: DataLoader | null = null
  private storageManager: StorageManager | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  onPageShow(): void {
    // 页面显示时刷新数据
    this.refreshData()
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      const context = getContext(this)
      this.dataLoader = new DataLoader(context)
      this.storageManager = new StorageManager(context)
      await this.storageManager.init()

      await this.refreshData()
      this.settings = await this.storageManager.getSettings()
      this.isLoading = false
    } catch (error) {
      console.error('[Mine] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 刷新数据
   */
  async refreshData(): Promise<void> {
    if (!this.dataLoader || !this.storageManager) return

    try {
      const allWeapons = await this.dataLoader.loadWeapons()

      // 加载收藏
      const favoriteIds = await this.storageManager.getFavorites()
      this.favoriteWeapons = allWeapons.filter(w => favoriteIds.includes(w.id))

      // 加载历史
      const history = await this.storageManager.getHistory()
      this.historyWeapons = (history
        .map((h: HistoryItem) => allWeapons.find(w => w.id === h.weapon_id))
        .filter((w) => w !== undefined) as LegendaryWeapon[])
        .slice(0, 20)
    } catch (error) {
      console.error('[Mine] 刷新数据失败:', error)
    }
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    router.back()
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
   * 清空历史
   */
  async clearHistory(): Promise<void> {
    if (!this.storageManager) return
    await this.storageManager.clearHistory()
    this.historyWeapons = []
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => this.goBack())

        Text('我的')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .margin({ left: Spacing.MEDIUM })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            // 用户信息卡片
            this.UserInfoCard()

            // 功能入口
            this.FunctionEntries()

            // 收藏/历史切换
            this.TabSection()

            // 列表内容
            this.ListContent()

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
    .backgroundColor(ThemeColors.BASE_0)
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
      .backgroundColor(ThemeColors.SURFACE_0)
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
          Text(`收藏 ${this.favoriteWeapons.length}`)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.GOLD_PRIMARY)

          Text(' | ')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(`浏览 ${this.historyWeapons.length}`)
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
      this.FunctionButton('技能百科', $r('app.media.icon_ability'), () => {
        router.pushUrl({ url: RouterPath.ABILITY_LIST })
      })
      this.FunctionButton('文化体系', $r('app.media.icon_culture'), () => {
        router.pushUrl({ url: RouterPath.CULTURE_LIST })
      })
      this.FunctionButton('铸造大师', $r('app.media.icon_blacksmith'), () => {
        router.pushUrl({ url: RouterPath.BLACKSMITH_LIST })
      })
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
      .backgroundColor(ThemeColors.SURFACE_0)
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
   * 收藏/历史切换
   */
  @Builder
  TabSection() {
    Row() {
      this.TabButton('我的收藏', this.favoriteWeapons.length, this.currentTab === 'favorites', () => {
        this.currentTab = 'favorites'
      })
      this.TabButton('浏览历史', this.historyWeapons.length, this.currentTab === 'history', () => {
        this.currentTab = 'history'
      })

      Blank()

      if (this.currentTab === 'history' && this.historyWeapons.length > 0) {
        Text('清空')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .onClick(() => this.clearHistory())
      }
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
  }

  /**
   * 切换按钮
   */
  @Builder
  TabButton(title: string, count: number, isActive: boolean, onClick: () => void) {
    Column() {
      Row() {
        Text(title)
          .fontSize(FontSizes.BODY)
          .fontWeight(isActive ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(isActive ? ThemeColors.TEXT_TITLE : ThemeColors.TEXT_TERTIARY)

        Text(` (${count})`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(isActive ? ThemeColors.GOLD_PRIMARY : ThemeColors.TEXT_TERTIARY)
      }

      // 下划线
      Column()
        .width(40)
        .height(3)
        .backgroundColor(isActive ? ThemeColors.GOLD_PRIMARY : Color.Transparent)
        .borderRadius(2)
        .margin({ top: Spacing.SMALL })
    }
    .margin({ right: Spacing.XLARGE })
    .onClick(onClick)
  }

  /**
   * 列表内容
   */
  @Builder
  ListContent() {
    Column() {
      if (this.currentTab === 'favorites') {
        if (this.favoriteWeapons.length === 0) {
          this.EmptyView('暂无收藏', '浏览神兵详情页点击收藏按钮添加')
        } else {
          ForEach(this.favoriteWeapons, (weapon: LegendaryWeapon) => {
            this.WeaponItem(weapon)
          }, (weapon: LegendaryWeapon) => weapon.id)
        }
      } else {
        if (this.historyWeapons.length === 0) {
          this.EmptyView('暂无浏览记录', '浏览神兵后会自动记录')
        } else {
          ForEach(this.historyWeapons, (weapon: LegendaryWeapon) => {
            this.WeaponItem(weapon)
          }, (weapon: LegendaryWeapon) => weapon.id)
        }
      }
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
  }

  /**
   * 空状态视图
   */
  @Builder
  EmptyView(title: string, subtitle: string) {
    Column() {
      Image($r('app.media.icon_empty'))
        .width(60)
        .height(60)
        .fillColor(ThemeColors.TEXT_TERTIARY)

      Text(title)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })

      Text(subtitle)
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.SMALL })
    }
    .width('100%')
    .padding({ top: Spacing.XXLARGE, bottom: Spacing.XXLARGE })
  }

  /**
   * 神兵项
   */
  @Builder
  WeaponItem(weapon: LegendaryWeapon) {
    Row() {
      // 图片
      Image($rawfile(`images/${weapon.image}`))
        .width(56)
        .height(56)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)

      // 信息
      Column() {
        Row() {
          Text(weapon.name.cn)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_TITLE)

          Text(RarityNames[weapon.rarity] || weapon.rarity)
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(weapon.rarity))
            .margin({ left: Spacing.SMALL })
        }

        Text(`${CultureNames[weapon.culture] || weapon.culture} · ${WeaponTypeNames[weapon.type] || weapon.type}`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.MEDIUM })
      .layoutWeight(1)

      Image($r('app.media.icon_arrow_right'))
        .width(20)
        .height(20)
        .fillColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.SURFACE_0)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .margin({ bottom: Spacing.SMALL })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
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
      .backgroundColor(ThemeColors.SURFACE_0)
      .borderRadius(Spacing.MEDIUM)
      .border({ width: 1, color: ThemeColors.DIVIDER })
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }
}
