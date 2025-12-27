/**
 * 神兵图录 - 搜索页
 * 搜索神兵、铸造师、典故
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { LegendaryWeapon } from '../model/LegendaryWeapon'
import { WeaponCard } from '../components/WeaponCard'

/**
 * 搜索结果类型
 */
interface SearchResult {
  weapons: LegendaryWeapon[]
  total: number
}

@Entry
@Component
struct Search {
  @State searchText: string = ''
  @State isSearching: boolean = false
  @State searchResults: LegendaryWeapon[] = []
  @State allWeapons: LegendaryWeapon[] = []
  @State showResults: boolean = false
  @State searchHistory: string[] = []
  private dataLoader: DataLoader | null = null

  // 热门搜索词
  private hotKeywords: string[] = [
    '轩辕剑', '草薙剑', '雷神之锤', '湛卢剑',
    '欧冶子', '干将莫邪', '永恒之枪', '神器'
  ]

  // 推荐标签
  private recommendTags: string[] = [
    '中国', '日本', '北欧', '希腊',
    '火属性', '雷属性', '剑', '锤'
  ]

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.allWeapons = await this.dataLoader.loadWeapons()
    } catch (error) {
      console.error('[Search] 加载数据失败:', error)
    }
  }

  /**
   * 执行搜索
   */
  performSearch(keyword: string): void {
    if (!keyword.trim()) {
      this.searchResults = []
      this.showResults = false
      return
    }

    this.isSearching = true
    this.showResults = true

    const query = keyword.toLowerCase().trim()

    // 搜索匹配
    this.searchResults = this.allWeapons.filter(weapon => {
      // 名称匹配
      if (weapon.name.zh.toLowerCase().includes(query)) return true
      if (weapon.name.en && weapon.name.en.toLowerCase().includes(query)) return true

      // 文化匹配
      const cultureName = CultureNames[weapon.culture] || ''
      if (cultureName.includes(query) || weapon.culture.includes(query)) return true

      // 类型匹配
      const typeName = WeaponTypeNames[weapon.type] || ''
      if (typeName.includes(query) || weapon.type.includes(query)) return true

      // 品质匹配
      const rarityName = RarityNames[weapon.rarity] || ''
      if (rarityName.includes(query) || weapon.rarity.includes(query)) return true

      // 描述匹配
      if (weapon.description.includes(query)) return true

      // 持有者匹配
      if (weapon.famous_owners && weapon.famous_owners.some(o => o.name.includes(query))) return true

      // 标签匹配
      if (weapon.tags && weapon.tags.some(t => t.includes(query))) return true

      return false
    })

    // 添加到搜索历史
    this.addToHistory(keyword)

    this.isSearching = false
  }

  /**
   * 添加到搜索历史
   */
  addToHistory(keyword: string): void {
    // 移除已存在的相同记录
    this.searchHistory = this.searchHistory.filter(h => h !== keyword)
    // 添加到开头
    this.searchHistory.unshift(keyword)
    // 限制数量
    if (this.searchHistory.length > 10) {
      this.searchHistory = this.searchHistory.slice(0, 10)
    }
  }

  /**
   * 清空搜索历史
   */
  clearHistory(): void {
    this.searchHistory = []
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
  navigateToDetail(weaponId: string): void {
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: weaponId }
    })
  }

  build() {
    Column() {
      // 顶部搜索栏
      this.SearchHeader()

      // 主内容区
      if (this.showResults) {
        if (this.isSearching) {
          this.LoadingView()
        } else if (this.searchResults.length === 0) {
          this.EmptyResultView()
        } else {
          this.SearchResultsView()
        }
      } else {
        this.DefaultView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }

  /**
   * 搜索头部
   */
  @Builder
  SearchHeader() {
    Row() {
      // 返回按钮
      Image($r('app.media.icon_back'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.TEXT_PRIMARY)
        .onClick(() => this.goBack())

      // 搜索输入框
      Row() {
        Image($r('app.media.icon_search'))
          .width(20)
          .height(20)
          .fillColor(ThemeColors.TEXT_TERTIARY)
          .margin({ right: Spacing.SMALL })

        TextInput({ placeholder: '搜索神兵、铸造师、典故...', text: this.searchText })
          .placeholderColor(ThemeColors.TEXT_TERTIARY)
          .placeholderFont({ size: FontSizes.BODY })
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontSize(FontSizes.BODY)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.searchText = value
            if (value.trim()) {
              this.performSearch(value)
            } else {
              this.showResults = false
            }
          })
          .onSubmit(() => {
            if (this.searchText.trim()) {
              this.performSearch(this.searchText)
            }
          })

        // 清除按钮
        if (this.searchText.length > 0) {
          Image($r('app.media.icon_close'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.TEXT_TERTIARY)
            .margin({ left: Spacing.SMALL })
            .onClick(() => {
              this.searchText = ''
              this.showResults = false
            })
        }
      }
      .layoutWeight(1)
      .height(44)
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM })
      .margin({ left: Spacing.MEDIUM })
      .backgroundColor(ThemeColors.CARD_BG)
      .borderRadius(22)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })
  }

  /**
   * 默认视图（未搜索时）
   */
  @Builder
  DefaultView() {
    Scroll() {
      Column() {
        // 搜索历史
        if (this.searchHistory.length > 0) {
          this.HistorySection()
        }

        // 热门搜索
        this.HotSearchSection()

        // 推荐标签
        this.RecommendTagsSection()
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  /**
   * 搜索历史区域
   */
  @Builder
  HistorySection() {
    Column() {
      Row() {
        Text('搜索历史')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Text('清空')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .onClick(() => this.clearHistory())
      }
      .width('100%')
      .margin({ bottom: Spacing.MEDIUM })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.searchHistory, (keyword: string) => {
          this.TagItem(keyword, () => {
            this.searchText = keyword
            this.performSearch(keyword)
          })
        })
      }
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.LARGE })
  }

  /**
   * 热门搜索区域
   */
  @Builder
  HotSearchSection() {
    Column() {
      Text('热门搜索')
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ bottom: Spacing.MEDIUM })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.hotKeywords, (keyword: string) => {
          this.TagItem(keyword, () => {
            this.searchText = keyword
            this.performSearch(keyword)
          })
        })
      }
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 推荐标签区域
   */
  @Builder
  RecommendTagsSection() {
    Column() {
      Text('推荐分类')
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ bottom: Spacing.MEDIUM })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.recommendTags, (tag: string) => {
          this.ColorTagItem(tag, () => {
            this.searchText = tag
            this.performSearch(tag)
          })
        })
      }
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.XLARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 标签项
   */
  @Builder
  TagItem(text: string, onClick: () => void) {
    Text(text)
      .fontSize(FontSizes.BODY_SMALL)
      .fontColor(ThemeColors.TEXT_PRIMARY)
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
      .backgroundColor(ThemeColors.SECONDARY_BG)
      .borderRadius(Spacing.LARGE)
      .margin({ right: Spacing.SMALL, bottom: Spacing.SMALL })
      .onClick(onClick)
  }

  /**
   * 彩色标签项
   */
  @Builder
  ColorTagItem(text: string, onClick: () => void) {
    Text(text)
      .fontSize(FontSizes.BODY_SMALL)
      .fontColor(ThemeColors.ACCENT)
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
      .backgroundColor(ThemeColors.CARD_BG)
      .borderRadius(Spacing.LARGE)
      .border({
        width: 1,
        color: ThemeColors.ACCENT
      })
      .margin({ right: Spacing.SMALL, bottom: Spacing.SMALL })
      .onClick(onClick)
  }

  /**
   * 加载中视图
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(ThemeColors.ACCENT)
      Text('搜索中...')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 空结果视图
   */
  @Builder
  EmptyResultView() {
    Column() {
      Image($r('app.media.icon_empty'))
        .width(80)
        .height(80)
        .fillColor(ThemeColors.TEXT_TERTIARY)

      Text('未找到相关结果')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })

      Text('换个关键词试试')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.SMALL })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 搜索结果视图
   */
  @Builder
  SearchResultsView() {
    Column() {
      // 结果统计
      Text(`找到 ${this.searchResults.length} 件神兵`)
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM, bottom: Spacing.SMALL })

      // 结果列表
      List() {
        ForEach(this.searchResults, (weapon: LegendaryWeapon) => {
          ListItem() {
            this.SearchResultItem(weapon)
          }
          .margin({ bottom: Spacing.MEDIUM })
        }, (weapon: LegendaryWeapon) => weapon.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 搜索结果项
   */
  @Builder
  SearchResultItem(weapon: LegendaryWeapon) {
    Row() {
      // 图片
      Image($rawfile(`images/${weapon.image}`))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)

      // 信息
      Column() {
        Row() {
          Text(weapon.name.zh)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(RarityNames[weapon.rarity] || weapon.rarity)
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(weapon.rarity))
            .margin({ left: Spacing.SMALL })
        }

        Text(`${CultureNames[weapon.culture] || weapon.culture} · ${WeaponTypeNames[weapon.type] || weapon.type}`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: Spacing.TINY })

        Text(weapon.description)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.SMALL })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.MEDIUM })
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .onClick(() => this.navigateToDetail(weapon.id))
  }
}
