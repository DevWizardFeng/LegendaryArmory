/**
 * 神兵图录 - 首页Tab
 * 展示轮播推荐、快速入口、传说神兵列表
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames } from '../../common/Constants'
import { Banner, BannerItem } from '../../components/Banner'
import { SearchBar } from '../../components/SearchBar'
import { DataLoader } from '../../utils/DataLoader'
import { LegendaryWeapon } from '../../model/LegendaryWeapon'

/**
 * 快速入口项
 */
interface QuickEntry {
  id: string
  name: string
  icon: Resource
  type: 'culture' | 'weaponType' | 'attribute' | 'rarity'
}

/**
 * 首页Tab内容组件
 */
@Component
export struct IndexContent {
  @State isLoading: boolean = true
  @State bannerItems: BannerItem[] = []
  @State featuredWeapons: LegendaryWeapon[] = []
  @State allWeapons: LegendaryWeapon[] = []
  private dataLoader: DataLoader | null = null

  // 快速入口数据
  private quickEntries: QuickEntry[] = [
    { id: 'culture', name: '文化体系', icon: $r('app.media.icon_culture'), type: 'culture' },
    { id: 'type', name: '兵器类型', icon: $r('app.media.icon_sword'), type: 'weaponType' },
    { id: 'attribute', name: '元素属性', icon: $r('app.media.icon_fire'), type: 'attribute' },
    { id: 'rarity', name: '品质分类', icon: $r('app.media.icon_rarity'), type: 'rarity' }
  ]

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载首页数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      const weapons = await this.dataLoader.loadWeapons()
      this.allWeapons = weapons

      // 设置轮播数据（精选神器级别的武器）
      const artifacts = weapons.filter(w => w.rarity === 'artifact').slice(0, 5)
      const bannerList: BannerItem[] = []
      for (let i = 0; i < artifacts.length; i++) {
        const w = artifacts[i]
        const item: BannerItem = {
          id: w.id,
          title: w.name.cn,
          subtitle: w.description.substring(0, 30) + '...',
          image: w.image,
          rarity: w.rarity,
          type: 'weapon'
        }
        bannerList.push(item)
      }
      this.bannerItems = bannerList

      // 设置推荐神兵（神器和传说级别）
      this.featuredWeapons = weapons
        .filter(w => w.rarity === 'artifact' || w.rarity === 'legendary')
        .slice(0, 8)

      this.isLoading = false
    } catch (error) {
      console.error('[IndexTab] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 跳转到搜索页
   */
  navigateToSearch(): void {
    router.pushUrl({ url: RouterPath.SEARCH })
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
   * 切换到神兵Tab并应用筛选
   */
  navigateToWeaponTab(filterType?: string): void {
    if (filterType) {
      // 设置预设筛选类型
      AppStorage.setOrCreate('weaponPresetFilter', filterType)
    }
    // 切换到神兵Tab（索引1）
    AppStorage.setOrCreate('currentTabIndex', 1)
  }

  /**
   * 切换到我的Tab
   */
  navigateToMineTab(): void {
    AppStorage.setOrCreate('currentTabIndex', 4)
  }

  build() {
    Column() {
      // 顶部区域
      Column() {
        // 标题栏
        Row() {
          Text('神兵图录')
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.ACCENT)

          Blank()

          // 设置按钮（切换到我的Tab）
          Image($r('app.media.icon_settings'))
            .width(24)
            .height(24)
            .fillColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => {
              this.navigateToMineTab()
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

        // 搜索栏
        Row() {
          SearchBar({
            placeholder: '搜索神兵、铸造师、典故...',
            onSearchFocus: () => this.navigateToSearch()
          })
        }
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })
      }
      .width('100%')
      .backgroundColor(ThemeColors.PRIMARY_BG)

      // 主内容区
      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            // Banner 轮播
            if (this.bannerItems.length > 0) {
              Column() {
                Banner({
                  items: this.bannerItems,
                  onItemClick: (item: BannerItem) => {
                    this.navigateToWeaponDetail(item.id)
                  }
                })
              }
              .width('100%')
              .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
            }

            // 快速入口
            this.QuickEntrySection()

            // 热门神兵
            this.FeaturedWeaponsSection()

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
   * 快速入口区域
   */
  @Builder
  QuickEntrySection() {
    Column() {
      // 标题
      Row() {
        Text('快速入口')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE, bottom: Spacing.MEDIUM })

      // 入口网格
      Row() {
        ForEach(this.quickEntries, (entry: QuickEntry) => {
          Column() {
            Column() {
              Image(entry.icon)
                .width(32)
                .height(32)
                .fillColor(ThemeColors.ACCENT)
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.CARD_BG)
            .borderRadius(16)

            Text(entry.name)
              .fontSize(FontSizes.CAPTION)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ top: Spacing.SMALL })
          }
          .layoutWeight(1)
          .onClick(() => {
            // 切换到神兵Tab并应用预设筛选
            this.navigateToWeaponTab(entry.type)
          })
        })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    }
    .width('100%')
  }

  /**
   * 热门神兵区域
   */
  @Builder
  FeaturedWeaponsSection() {
    Column() {
      // 标题行
      Row() {
        Text('热门神兵')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Row() {
          Text('查看全部')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
          Image($r('app.media.icon_arrow_right'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.TEXT_TERTIARY)
        }
        .onClick(() => {
          // 切换到神兵Tab
          this.navigateToWeaponTab()
        })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE, bottom: Spacing.MEDIUM })

      // 神兵网格 (2列)
      Grid() {
        ForEach(this.featuredWeapons, (weapon: LegendaryWeapon) => {
          GridItem() {
            this.WeaponCard(weapon)
          }
        }, (weapon: LegendaryWeapon) => weapon.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Spacing.MEDIUM)
      .rowsGap(Spacing.MEDIUM)
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .height(this.featuredWeapons.length > 0 ? (Math.ceil(this.featuredWeapons.length / 2) * 200) : 0)
    }
    .width('100%')
  }

  /**
   * 神兵卡片
   */
  @Builder
  WeaponCard(weapon: LegendaryWeapon) {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($rawfile(`images/${weapon.image}`))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Spacing.MEDIUM, topRight: Spacing.MEDIUM })

        // 品质标签
        Text(RarityNames[weapon.rarity] || weapon.rarity)
          .fontSize(FontSizes.SMALL)
          .fontColor(getRarityColor(weapon.rarity))
          .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
          .backgroundColor('rgba(0,0,0,0.6)')
          .borderRadius(4)
          .margin({ top: Spacing.SMALL, right: Spacing.SMALL })
      }
      .width('100%')

      // 信息区域
      Column() {
        Text(weapon.name.cn)
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(CultureNames[weapon.culture] || weapon.culture)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(' | ')
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(WeaponTypeNames[weapon.type] || weapon.type)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .margin({ top: Spacing.TINY })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(Spacing.MEDIUM)
    }
    .width('100%')
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: 1,
      color: getRarityColor(weapon.rarity)
    })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}
