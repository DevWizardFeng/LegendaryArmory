/**
 * 神兵图录 - 浏览历史列表页
 * 展示所有浏览过的神兵
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor } from '../common/Theme'
import { RouterPath, RarityNames, CultureNames, WeaponTypeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { StorageManager } from '../utils/Storage'
import { LegendaryWeapon } from '../model/LegendaryWeapon'
import { HistoryItem } from '../model/UserData'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct HistoryList {
  @State isLoading: boolean = true
  @State historyWeapons: LegendaryWeapon[] = []
  @StorageLink('historyWeaponIds') @Watch('onHistoryChange') historyIds: string[] = []
  private dataLoader: DataLoader | null = null
  private storageManager: StorageManager | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 历史变化监听
   */
  onHistoryChange(): void {
    this.loadHistoryWeapons()
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

      await this.loadHistoryWeapons()
      this.isLoading = false
    } catch (error) {
      console.error('[HistoryList] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 加载浏览历史
   */
  async loadHistoryWeapons(): Promise<void> {
    if (!this.dataLoader || !this.storageManager) return

    try {
      const allWeapons = await this.dataLoader.loadWeapons()
      const history = await this.storageManager.getHistory()
      // 按时间倒序排列，最近浏览的在前面
      this.historyWeapons = (history
        .map((h: HistoryItem) => allWeapons.find(w => w.id === h.weapon_id))
        .filter((w) => w !== undefined) as LegendaryWeapon[])
    } catch (error) {
      console.error('[HistoryList] 加载历史失败:', error)
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
   * 返回
   */
  navigateBack(): void {
    router.back()
  }

  /**
   * 清空历史
   */
  async clearHistory(): Promise<void> {
    if (!this.storageManager) return

    try {
      // 显示确认对话框
      const result = await promptAction.showDialog({
        title: '清空历史',
        message: '确定要清空所有浏览历史吗？',
        buttons: [
          { text: '取消', color: ThemeColors.TEXT_SECONDARY },
          { text: '确定', color: ThemeColors.GOLD_PRIMARY }
        ]
      })

      if (result.index === 1) {
        await this.storageManager.clearHistory()
        this.historyWeapons = []
        AppStorage.setOrCreate('historyWeaponIds', [])

        promptAction.showToast({
          message: '已清空浏览历史',
          duration: 2000
        })
      }
    } catch (error) {
      console.error('[HistoryList] 清空历史失败:', error)
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderBar()

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.historyWeapons.length === 0) {
        this.EmptyView()
      } else {
        this.WeaponList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
  }

  /**
   * 顶部导航栏
   */
  @Builder
  HeaderBar() {
    Row() {
      Image($r('app.media.icon_back'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.TEXT_PRIMARY)
        .onClick(() => this.navigateBack())

      Text('浏览历史')
        .fontSize(FontSizes.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_TITLE)
        .margin({ left: Spacing.MEDIUM })

      Blank()

      if (this.historyWeapons.length > 0) {
        Text('清空')
          .fontSize(FontSizes.BODY)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => this.clearHistory())
      }
    }
    .height(56)
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    .backgroundColor(ThemeColors.BASE_1)
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
   * 空状态视图
   */
  @Builder
  EmptyView() {
    Column() {
      Image($r('app.media.icon_empty'))
        .width(80)
        .height(80)
        .fillColor(ThemeColors.TEXT_TERTIARY)

      Text('暂无浏览记录')
        .fontSize(FontSizes.SUBTITLE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.LARGE })

      Text('浏览神兵后会自动记录')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.SMALL })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 神兵列表
   */
  @Builder
  WeaponList() {
    List() {
      ForEach(this.historyWeapons, (weapon: LegendaryWeapon, index: number) => {
        ListItem() {
          this.WeaponItem(weapon, index)
        }
      }, (weapon: LegendaryWeapon) => weapon.id)
    }
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .divider({
      strokeWidth: 0,
      startMargin: 0,
      endMargin: 0
    })
  }

  /**
   * 神兵项
   */
  @Builder
  WeaponItem(weapon: LegendaryWeapon, index: number) {
    Row() {
      // 图片
      Image($rawfile(`images/${weapon.image}`))
        .width(64)
        .height(64)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)
        .border({ width: 2, color: getRarityDarkColor(weapon.rarity) })

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
        .width('100%')

        Text(`${CultureNames[weapon.culture] || weapon.culture} · ${WeaponTypeNames[weapon.type] || weapon.type}`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: 4 })

        if (weapon.attributes.primary) {
          Text(`属性: ${weapon.attributes.primary}${weapon.attributes.secondary ? ' / ' + weapon.attributes.secondary : ''}`)
            .fontSize(FontSizes.SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.MEDIUM })
      .layoutWeight(1)

      Image($r('app.media.icon_arrow_right'))
        .width(20)
        .height(20)
        .fillColor(ThemeColors.TEXT_TERTIARY)
        .margin({ left: Spacing.MEDIUM })
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.SURFACE_0)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .margin({ bottom: Spacing.MEDIUM })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}

