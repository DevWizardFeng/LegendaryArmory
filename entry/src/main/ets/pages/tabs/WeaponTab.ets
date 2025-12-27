/**
 * 神兵图录 - 神兵Tab
 * 展示所有神兵，支持多维度筛选
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames, AttributeNames } from '../../common/Constants'
import { DataLoader } from '../../utils/DataLoader'
import { LegendaryWeapon } from '../../model/LegendaryWeapon'
import { WeaponCard } from '../../components/WeaponCard'
import { FilterBar } from '../../components/FilterBar'

/**
 * 神兵Tab内容组件
 */
@Component
export struct WeaponListContent {
  @State isLoading: boolean = true
  @State allWeapons: LegendaryWeapon[] = []
  @State filteredWeapons: LegendaryWeapon[] = []
  @State selectedCulture: string = ''
  @State selectedType: string = ''
  @State selectedAttribute: string = ''
  @State selectedRarity: string = ''
  @State displayMode: 'grid' | 'list' = 'grid'
  @StorageLink('weaponPresetFilter') @Watch('onPresetFilterChange') presetFilter: string = ''
  @StorageLink('favoriteWeaponIds') favoriteIds: string[] = []
  private dataLoader: DataLoader | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 预设筛选变化监听
   */
  onPresetFilterChange(): void {
    if (this.presetFilter) {
      // 根据预设筛选类型展开对应筛选维度
      // 注意：这里只是设置了筛选类型的提示，具体的筛选逻辑在FilterBar组件内部处理
      console.info('[WeaponTab] 收到预设筛选:', this.presetFilter)

      // 清空预设筛选（消费后重置）
      AppStorage.setOrCreate('weaponPresetFilter', '')
    }
  }

  /**
   * 加载神兵数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.allWeapons = await this.dataLoader.loadWeapons()
      this.applyFilter()
      this.isLoading = false
    } catch (error) {
      console.error('[WeaponTab] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 应用筛选
   */
  applyFilter(): void {
    let result = this.allWeapons

    if (this.selectedCulture) {
      result = result.filter(w => w.culture === this.selectedCulture)
    }

    if (this.selectedType) {
      result = result.filter(w => w.type === this.selectedType)
    }

    if (this.selectedAttribute) {
      result = result.filter(w =>
        w.attributes.primary === this.selectedAttribute ||
        w.attributes.secondary === this.selectedAttribute
      )
    }

    if (this.selectedRarity) {
      result = result.filter(w => w.rarity === this.selectedRarity)
    }

    this.filteredWeapons = result
  }

  /**
   * 跳转到神兵详情
   */
  navigateToDetail(weaponId: string): void {
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: weaponId }
    })
  }

  /**
   * 清除所有筛选
   */
  clearAllFilters(): void {
    this.selectedCulture = ''
    this.selectedType = ''
    this.selectedAttribute = ''
    this.selectedRarity = ''
    this.applyFilter()
  }

  /**
   * 检查是否有激活的筛选
   */
  private hasActiveFilter(): boolean {
    return !!(this.selectedCulture || this.selectedType || this.selectedAttribute || this.selectedRarity)
  }

  build() {
    Column() {
      // 顶部导航栏（移除返回按钮）
      Row() {
        Text('神兵图鉴')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        // 显示模式切换
        Image(this.displayMode === 'grid' ? $r('app.media.icon_list') : $r('app.media.icon_grid'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => {
            this.displayMode = this.displayMode === 'grid' ? 'list' : 'grid'
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .backgroundColor(ThemeColors.PRIMARY_BG)

      // 筛选栏
      FilterBar({
        selectedCulture: $selectedCulture,
        selectedType: $selectedType,
        selectedAttribute: $selectedAttribute,
        selectedRarity: $selectedRarity,
        onFilterChange: () => this.applyFilter()
      })

      // 筛选结果统计
      Row() {
        Text(`共 ${this.filteredWeapons.length} 件神兵`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)

        if (this.hasActiveFilter()) {
          Blank()
          Text('清除筛选')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.ACCENT)
            .onClick(() => this.clearAllFilters())
        }
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.SMALL, bottom: Spacing.SMALL })

      // 主内容区
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.filteredWeapons.length === 0) {
        this.EmptyView()
      } else {
        if (this.displayMode === 'grid') {
          this.GridView()
        } else {
          this.ListView()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.PRIMARY_BG)
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
        .color(ThemeColors.ACCENT)
      Text('正在加载...')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
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

      Text('未找到匹配的神兵')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })

      Text('尝试调整筛选条件')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.SMALL })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 网格视图
   */
  @Builder
  GridView() {
    Scroll() {
      Grid() {
        ForEach(this.filteredWeapons, (weapon: LegendaryWeapon) => {
          GridItem() {
            WeaponCard({
              weapon: weapon,
              cardSize: 'medium',
              onCardClick: () => this.navigateToDetail(weapon.id)
            })
          }
        }, (weapon: LegendaryWeapon) => weapon.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Spacing.MEDIUM)
      .rowsGap(Spacing.MEDIUM)
      .width('100%')
      .padding(Spacing.LARGE)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  /**
   * 列表视图
   */
  @Builder
  ListView() {
    List() {
      ForEach(this.filteredWeapons, (weapon: LegendaryWeapon) => {
        ListItem() {
          WeaponCard({
            weapon: weapon,
            cardSize: 'small',
            onCardClick: () => this.navigateToDetail(weapon.id)
          })
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (weapon: LegendaryWeapon) => weapon.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
