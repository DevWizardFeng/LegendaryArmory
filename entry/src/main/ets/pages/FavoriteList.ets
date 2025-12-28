/**
 * 神兵图录 - 我的收藏列表页
 * 展示所有收藏的神兵
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor } from '../common/Theme'
import { RouterPath, RarityNames, CultureNames, WeaponTypeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { StorageManager } from '../utils/Storage'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

@Entry
@Component
struct FavoriteList {
  @State isLoading: boolean = true
  @State favoriteWeapons: LegendaryWeapon[] = []
  @StorageLink('favoriteWeaponIds') @Watch('onFavoritesChange') favoriteIds: string[] = []
  private dataLoader: DataLoader | null = null
  private storageManager: StorageManager | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 收藏变化监听
   */
  onFavoritesChange(): void {
    this.loadFavoriteWeapons()
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

      await this.loadFavoriteWeapons()
      this.isLoading = false
    } catch (error) {
      console.error('[FavoriteList] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 加载收藏的神兵
   */
  async loadFavoriteWeapons(): Promise<void> {
    if (!this.dataLoader || !this.storageManager) return

    try {
      const allWeapons = await this.dataLoader.loadWeapons()
      const favoriteIds = await this.storageManager.getFavorites()
      this.favoriteWeapons = allWeapons.filter(w => favoriteIds.includes(w.id))
    } catch (error) {
      console.error('[FavoriteList] 加载收藏失败:', error)
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

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_favorite'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航栏
        this.HeaderBar()

        if (this.isLoading) {
          this.LoadingView()
        } else if (this.favoriteWeapons.length === 0) {
          this.EmptyView()
        } else {
          this.WeaponList()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
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

      Text('我的收藏')
        .fontSize(FontSizes.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_TITLE)
        .margin({ left: Spacing.MEDIUM })

      Blank()

      Text(`${this.favoriteWeapons.length}`)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
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

      Text('暂无收藏')
        .fontSize(FontSizes.SUBTITLE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.LARGE })

      Text('浏览神兵详情页点击收藏按钮添加')
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
      ForEach(this.favoriteWeapons, (weapon: LegendaryWeapon) => {
        ListItem() {
          this.WeaponItem(weapon)
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
  WeaponItem(weapon: LegendaryWeapon) {
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

