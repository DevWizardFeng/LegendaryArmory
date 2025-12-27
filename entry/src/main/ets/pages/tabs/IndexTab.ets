/**
 * 神兵图录 - 首页Tab（博物馆典藏风格）
 * 展示轮播推荐、快速入口、传说神兵列表
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor } from '../../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames } from '../../common/Constants'
import { Banner, BannerItem } from '../../components/Banner'
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
    { id: 'attribute', name: '元素属性', icon: $r('app.media.icon_element'), type: 'attribute' },
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
        // 标题栏 - 使用旧金色
        Row() {
          Text('神兵图录')
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.GOLD_PRIMARY)

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

        // 搜索栏（点击入口，非真实输入框）
        Row() {
          Row() {
            Image($r('app.media.icon_search'))
              .width(20)
              .height(20)
              .fillColor(ThemeColors.TEXT_TERTIARY)
              .margin({ right: Spacing.SMALL })

            Text('搜索神兵、铸造师、典故...')
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_TERTIARY)
          }
          .width('100%')
          .height(44)
          .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM })
          .backgroundColor(ThemeColors.SURFACE_0)
          .borderRadius(22)
          .border({ width: 1, color: ThemeColors.DIVIDER })
          .onClick(() => this.navigateToSearch())
        }
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })
      }
      .width('100%')
      .backgroundColor(ThemeColors.BASE_0)

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
    .backgroundColor(ThemeColors.BASE_0)
  }

  /**
   * 加载中视图 - 使用旧金色
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.GOLD_PRIMARY)
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
      // 标题 - 使用羊皮纸色
      Row() {
        Text('快速入口')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE, bottom: Spacing.MEDIUM })

      // 入口网格 - 博物馆展柜风格
      Row() {
        ForEach(this.quickEntries, (entry: QuickEntry, index: number) => {
          Column() {
            Column() {
              Image(entry.icon)
                .width(40)
                .height(40)
                .objectFit(ImageFit.Contain)
                .borderRadius(8)
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.SURFACE_0)
            .borderRadius(16)
            .border({
              width: 1,
              color: ThemeColors.DIVIDER
            })

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
        }, (entry: QuickEntry, index: number) => entry.id + index)
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
          .fontColor(ThemeColors.TEXT_TITLE)

        Blank()

        Row() {
          Text('查看全部')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
          Image($r('app.media.icon_arrow_right'))
            .width(20)
            .height(20)
            .fillColor(ThemeColors.TEXT_TERTIARY)
            .margin({ left: Spacing.SMALL })
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
   * 神兵卡片 - 博物馆展柜风格
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

        // 品质标签 - 展柜铭牌风格
        Text(RarityNames[weapon.rarity] || weapon.rarity)
          .fontSize(FontSizes.SMALL)
          .fontColor(getRarityColor(weapon.rarity))
          .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
          .backgroundColor('rgba(26,34,51,0.85)')
          .borderRadius(4)
          .border({
            width: 1,
            color: getRarityDarkColor(weapon.rarity)
          })
          .margin({ top: Spacing.SMALL, right: Spacing.SMALL })
      }
      .width('100%')

      // 信息区域
      Column() {
        // 名称使用羊皮纸色
        Text(weapon.name.cn)
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_TITLE)
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
    .backgroundColor(ThemeColors.SURFACE_0)
    .borderRadius(Spacing.MEDIUM)
    .border({
      width: 1,
      color: getRarityDarkColor(weapon.rarity)
    })
    .shadow({
      radius: 8,
      color: `${getRarityColor(weapon.rarity)}15`,
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}
