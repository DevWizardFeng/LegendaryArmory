/**
 * 神兵图录 - 百科Tab
 * 包含顶部二级导航：铸造大师、文化体系、专题故事
 * 视觉风格：博物馆典藏风
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor } from '../../common/Theme'
import { RouterPath, CultureNames, RarityNames } from '../../common/Constants'
import { DataLoader } from '../../utils/DataLoader'
import { Blacksmith } from '../../model/Blacksmith'
import { Culture } from '../../model/Culture'
import { Topic } from '../../model/Topic'
import { LegendaryWeapon } from '../../model/LegendaryWeapon'

// 专题分类名称映射
const TopicCategoryNames: Record<string, string> = {
  'culture': '文化',
  'technique': '工艺',
  'legend': '传说',
  'history': '历史'
}

/**
 * 百科Tab内容组件
 */
@Component
export struct EncyclopediaContent {
  @State currentSubTab: number = 0
  @StorageLink('encyclopediaSubTabIndex') @Watch('onSubTabJump') subTabJump: number = -1
  private subTabController: TabsController = new TabsController()

  /**
   * 外部跳转到指定子Tab
   */
  onSubTabJump(): void {
    if (this.subTabJump >= 0 && this.subTabJump <= 2) {
      this.currentSubTab = this.subTabJump
      this.subTabController.changeIndex(this.subTabJump)
      AppStorage.setOrCreate('encyclopediaSubTabIndex', -1) // 重置
    }
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_tabbar'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部标题栏 - 添加毛玻璃效果
        Row() {
          Text('兵器百科')
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_TITLE)
        }
        .height(56)
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
        .backgroundColor('rgba(18,24,38,0.7)')
        .backdropBlur(10)

        // 二级Tab导航
        Tabs({ controller: this.subTabController, index: this.currentSubTab }) {
          TabContent() {
            BlacksmithContent()
          }
          .tabBar(this.customSubTabBar('铸造大师', 0))

          TabContent() {
            CultureContent()
          }
          .tabBar(this.customSubTabBar('文化体系', 1))

          TabContent() {
            TopicContent()
          }
          .tabBar(this.customSubTabBar('专题故事', 2))
        }
        .barMode(BarMode.Fixed)
        .barPosition(BarPosition.Start)
        .animationDuration(0)
        .onChange((index: number) => {
          this.currentSubTab = index
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 自定义二级Tab栏
   */
  @Builder
  customSubTabBar(name: string, index: number) {
    Text(name)
      .fontSize(this.currentSubTab === index ? FontSizes.BODY : FontSizes.BODY_SMALL)
      .fontColor(this.currentSubTab === index ? ThemeColors.GOLD_PRIMARY : ThemeColors.TEXT_SECONDARY)
      .fontWeight(this.currentSubTab === index ? FontWeight.Bold : FontWeight.Normal)
      .padding(Spacing.MEDIUM)
      .border({
        width: { bottom: this.currentSubTab === index ? 2 : 0 },
        color: ThemeColors.GOLD_PRIMARY
      })
  }
}

/**
 * 铸造大师子组件
 */
@Component
struct BlacksmithContent {
  @State isLoading: boolean = true
  @State blacksmiths: Blacksmith[] = []
  @State selectedCulture: string = ''
  @State filteredBlacksmiths: Blacksmith[] = []
  private dataLoader: DataLoader | null = null

  // 文化筛选选项
  private cultureOptions: string[] = ['', 'chinese', 'japanese', 'norse', 'greek', 'celtic', 'medieval_europe', 'indian']

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.blacksmiths = await this.dataLoader.loadBlacksmiths()
      this.applyFilter()
      this.isLoading = false
    } catch (error) {
      console.error('[BlacksmithContent] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  applyFilter(): void {
    if (this.selectedCulture) {
      this.filteredBlacksmiths = this.blacksmiths.filter(b => b.culture === this.selectedCulture)
    } else {
      this.filteredBlacksmiths = this.blacksmiths
    }
  }

  navigateToDetail(blacksmithId: string): void {
    router.pushUrl({
      url: RouterPath.BLACKSMITH_DETAIL,
      params: { blacksmithId: blacksmithId }
    })
  }

  build() {
    Column() {
      // 统计行
      Row() {
        Text(`共 ${this.filteredBlacksmiths.length} 位`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.SMALL, bottom: Spacing.SMALL })

      // 文化筛选
      this.CultureFilter()

      // 主内容区
      if (this.isLoading) {
        this.LoadingView()
      } else {
        this.ContentView()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CultureFilter() {
    Scroll() {
      Row() {
        ForEach(this.cultureOptions, (culture: string) => {
          Text(culture ? (CultureNames[culture] || culture) : '全部')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(this.selectedCulture === culture ? ThemeColors.BASE_0 : ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
            .backgroundColor(this.selectedCulture === culture ? ThemeColors.GOLD_PRIMARY : 'rgba(26,34,51,0.6)')
            .borderRadius(Spacing.LARGE)
            .border({ width: 1, color: this.selectedCulture === culture ? ThemeColors.GOLD_PRIMARY : ThemeColors.DIVIDER })
            .margin({ right: Spacing.SMALL })
            .onClick(() => {
              this.selectedCulture = culture
              this.applyFilter()
            })
        })
      }
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(48)
  }

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

  @Builder
  ContentView() {
    List() {
      ForEach(this.filteredBlacksmiths, (blacksmith: Blacksmith) => {
        ListItem() {
          this.BlacksmithCard(blacksmith)
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (blacksmith: Blacksmith) => blacksmith.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  BlacksmithCard(blacksmith: Blacksmith) {
    Row() {
      // 头像
      Column() {
        Image($rawfile(`images/${blacksmith.image}`))
          .width(80)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(Spacing.MEDIUM)
      }
      .border({
        width: 2,
        color: ThemeColors.GOLD_PRIMARY
      })
      .borderRadius(Spacing.MEDIUM)

      // 信息
      Column() {
        Text(blacksmith.name.cn)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)

        Row() {
          Text(CultureNames[blacksmith.culture] || blacksmith.culture)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.GOLD_PRIMARY)

          Text(' · ')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Text(blacksmith.era)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .margin({ top: Spacing.TINY })

        Text(blacksmith.title)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: Spacing.SMALL })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`代表作品: ${blacksmith.masterworks?.length || 0} 件`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: Spacing.SMALL })
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
    .backgroundColor('rgba(26,34,51,0.6)')
    .backdropBlur(15)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .onClick(() => this.navigateToDetail(blacksmith.id))
  }
}

/**
 * 文化体系子组件
 */
@Component
struct CultureContent {
  @State isLoading: boolean = true
  @State cultures: Culture[] = []
  @State weapons: LegendaryWeapon[] = []
  @State selectedCulture: Culture | null = null
  @State cultureWeapons: LegendaryWeapon[] = []
  private dataLoader: DataLoader | null = null

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.cultures = await this.dataLoader.loadCultures()
      this.weapons = await this.dataLoader.loadWeapons()
      this.isLoading = false
    } catch (error) {
      console.error('[CultureContent] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  selectCulture(culture: Culture): void {
    this.selectedCulture = culture
    this.cultureWeapons = this.weapons.filter(w => w.culture === culture.id)
  }

  backToCultureList(): void {
    this.selectedCulture = null
    this.cultureWeapons = []
  }

  navigateToWeaponDetail(weaponId: string): void {
    router.pushUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: weaponId }
    })
  }

  getWeaponCount(cultureId: string): number {
    return this.weapons.filter(w => w.culture === cultureId).length
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_culture'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        if (this.selectedCulture) {
          // 返回按钮
          Row() {
            Image($r('app.media.icon_back'))
              .width(24)
              .height(24)
              .fillColor(ThemeColors.TEXT_PRIMARY)
              .onClick(() => this.backToCultureList())

            Text(this.selectedCulture.name_cn)
              .fontSize(FontSizes.SUBTITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_TITLE)
              .margin({ left: Spacing.MEDIUM })
          }
          .width('100%')
          .height(48)
          .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

          this.CultureDetailView()
        } else {
          if (this.isLoading) {
            this.LoadingView()
          } else {
            this.CultureListView()
          }
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

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

  @Builder
  CultureListView() {
    List() {
      ForEach(this.cultures, (culture: Culture) => {
        ListItem() {
          this.CultureCard(culture)
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (culture: Culture) => culture.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  CultureCard(culture: Culture) {
    Column() {
      Row() {
        Column() {
          Text(culture.name_cn?.substring(0, 1) ?? '')
            .fontSize(FontSizes.TITLE)
            .fontColor(ThemeColors.GOLD_PRIMARY)
            .fontWeight(FontWeight.Bold)
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.BASE_1)
        .borderRadius(Spacing.MEDIUM)
        .border({ width: 1, color: ThemeColors.DIVIDER })

        Column() {
          Text(culture.name_cn ?? '')
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_TITLE)

          Text(culture.region ?? '')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ top: Spacing.TINY })

          Text(`${this.getWeaponCount(culture.id)} 件神兵`)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.GOLD_PRIMARY)
            .margin({ top: Spacing.TINY })
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

      Text(culture.description ?? culture.background ?? '')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: Spacing.MEDIUM })
        .lineHeight(20)

      if (culture.characteristics && culture.characteristics.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(culture.characteristics.slice(0, 3), (char: string) => {
            Text(char)
              .fontSize(FontSizes.SMALL)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
              .backgroundColor(ThemeColors.BASE_1)
              .borderRadius(4)
              .border({ width: 1, color: ThemeColors.DIVIDER })
              .margin({ right: Spacing.TINY, top: Spacing.SMALL })
          })
        }
        .margin({ top: Spacing.SMALL })
      }
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .backgroundColor('rgba(26,34,51,0.6)')
    .backdropBlur(15)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .onClick(() => this.selectCulture(culture))
  }

  @Builder
  CultureDetailView() {
    Scroll() {
      Column() {
        this.CultureIntroSection()
        this.CharacteristicsSection()
        this.RepresentativeWeaponsSection()
        Blank().height(Spacing.XXLARGE)
      }
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  CultureIntroSection() {
    if (this.selectedCulture) {
      Column() {
        Row() {
          Column() {
            Text(this.selectedCulture.name_cn?.substring(0, 1) ?? '')
              .fontSize(32)
              .fontColor(ThemeColors.GOLD_PRIMARY)
              .fontWeight(FontWeight.Bold)
          }
          .width(64)
          .height(64)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(26,34,51,0.6)')
          .backdropBlur(15)
          .borderRadius(Spacing.MEDIUM)
          .border({
            width: 2,
            color: ThemeColors.GOLD_PRIMARY
          })

          Column() {
            Text(this.selectedCulture.name ?? this.selectedCulture.name_cn ?? '')
              .fontSize(FontSizes.TITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_TITLE)

            Text(this.selectedCulture.region ?? '')
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ top: Spacing.TINY })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: Spacing.LARGE })
        }
        .width('100%')
        .margin({ bottom: Spacing.LARGE })

        Text(this.selectedCulture.description ?? this.selectedCulture.background ?? '')
          .fontSize(FontSizes.BODY)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .lineHeight(24)
      }
      .width('100%')
      .padding(Spacing.LARGE)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  CharacteristicsSection() {
    if (this.selectedCulture && this.selectedCulture.characteristics && this.selectedCulture.characteristics.length > 0) {
      Column() {
        Text('文化特色')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .margin({ bottom: Spacing.MEDIUM })

        ForEach(this.selectedCulture.characteristics, (char: string, index: number) => {
          Row() {
            Text((index + 1).toString())
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.GOLD_PRIMARY)
              .width(24)

            Text(char)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Spacing.MEDIUM)
          .backgroundColor('rgba(26,34,51,0.6)')
          .backdropBlur(15)
          .borderRadius(Spacing.SMALL)
          .border({ width: 1, color: ThemeColors.DIVIDER })
          .margin({ bottom: Spacing.SMALL })
        })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  RepresentativeWeaponsSection() {
    Column() {
      Row() {
        Text('代表神兵')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)

        Blank()

        Text(`共 ${this.cultureWeapons.length} 件`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')
      .margin({ top: Spacing.XLARGE, bottom: Spacing.MEDIUM })

      ForEach(this.cultureWeapons, (weapon: LegendaryWeapon) => {
        this.WeaponItem(weapon)
      }, (weapon: LegendaryWeapon) => weapon.id)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WeaponItem(weapon: LegendaryWeapon) {
    Row() {
      Image($rawfile(`images/${weapon.image ?? 'weapon_default.png'}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)
        .border({ width: 1, color: getRarityDarkColor(weapon.rarity ?? 'rare') })

      Column() {
        Row() {
          Text(weapon.name?.cn ?? '')
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_TITLE)

          Text(RarityNames[weapon.rarity] ?? weapon.rarity ?? '')
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(weapon.rarity ?? 'rare'))
            .margin({ left: Spacing.SMALL })
        }

        Text(weapon.description ?? '')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.TINY })
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
    .backgroundColor('rgba(26,34,51,0.6)')
    .backdropBlur(15)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .margin({ bottom: Spacing.SMALL })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}

/**
 * 专题故事子组件
 */
@Component
struct TopicContent {
  @State isLoading: boolean = true
  @State topics: Topic[] = []
  @State selectedCategory: string = ''
  @State filteredTopics: Topic[] = []
  private dataLoader: DataLoader | null = null

  // 分类筛选选项
  private categoryOptions: string[] = ['', 'culture', 'technique', 'legend', 'history']

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      const loadedTopics = await this.dataLoader.loadTopics()
      console.info('[TopicContent] 加载专题数量:', loadedTopics?.length || 0)
      this.topics = loadedTopics || []
      this.applyFilter()
      console.info('[TopicContent] 筛选后数量:', this.filteredTopics.length)
      this.isLoading = false
    } catch (error) {
      console.error('[TopicContent] 加载数据失败:', JSON.stringify(error))
      this.isLoading = false
    }
  }

  applyFilter(): void {
    if (this.selectedCategory) {
      this.filteredTopics = this.topics.filter(t => t.category === this.selectedCategory)
    } else {
      this.filteredTopics = this.topics
    }
  }

  navigateToDetail(topicId: string): void {
    router.pushUrl({
      url: RouterPath.TOPIC_DETAIL,
      params: { topicId: topicId }
    })
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.bg_topic'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 统计行
        Row() {
          Text(`共 ${this.filteredTopics.length} 篇`)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
        }
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.SMALL, bottom: Spacing.SMALL })

        // 分类筛选
        this.CategoryFilter()

        // 主内容区
        if (this.isLoading) {
          this.LoadingView()
        } else {
          this.ContentView()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CategoryFilter() {
    Scroll() {
      Row() {
        ForEach(this.categoryOptions, (category: string) => {
          Text(category ? (TopicCategoryNames[category] || category) : '全部')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(this.selectedCategory === category ? ThemeColors.BASE_0 : ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
            .backgroundColor(this.selectedCategory === category ? ThemeColors.GOLD_PRIMARY : ThemeColors.SURFACE_0)
            .borderRadius(Spacing.LARGE)
            .border({ width: 1, color: this.selectedCategory === category ? ThemeColors.GOLD_PRIMARY : ThemeColors.DIVIDER })
            .margin({ right: Spacing.SMALL })
            .onClick(() => {
              this.selectedCategory = category
              this.applyFilter()
            })
        })
      }
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(48)
  }

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

  @Builder
  ContentView() {
    List() {
      ForEach(this.filteredTopics, (topic: Topic) => {
        ListItem() {
          this.TopicCard(topic)
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (topic: Topic) => topic.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  TopicCard(topic: Topic) {
    Column() {
      // 封面图片
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r(`app.media.${topic.image.replace('.png', '')}`))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Spacing.MEDIUM, topRight: Spacing.MEDIUM })

        // 渐变遮罩
        Column()
          .width('100%')
          .height(80)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['transparent', 0], ['#CC000000', 1]]
          })
          .borderRadius({ topLeft: Spacing.MEDIUM, topRight: Spacing.MEDIUM })

        // 分类标签
        Text(TopicCategoryNames[topic.category] || topic.category)
          .fontSize(FontSizes.SMALL)
          .fontColor(ThemeColors.TEXT_TITLE)
          .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
          .backgroundColor('#99000000')
          .borderRadius(4)
          .margin(Spacing.MEDIUM)
      }
      .width('100%')

      // 内容区域
      Column() {
        Text(topic.title)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(topic.summary)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .lineHeight(20)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: Spacing.SMALL })

        Row() {
          Text(`${topic.related_weapons?.length || 0} 件相关神兵`)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)

          Blank()

          Row() {
            Text('阅读全文')
              .fontSize(FontSizes.CAPTION)
              .fontColor(ThemeColors.GOLD_PRIMARY)

            Image($r('app.media.icon_arrow_right'))
              .width(14)
              .height(14)
              .fillColor(ThemeColors.GOLD_PRIMARY)
              .margin({ left: 4 })
          }
        }
        .width('100%')
        .margin({ top: Spacing.MEDIUM })
      }
      .width('100%')
      .padding(Spacing.MEDIUM)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('rgba(26,34,51,0.6)')
    .backdropBlur(15)
    .borderRadius(Spacing.MEDIUM)
    .border({ width: 1, color: ThemeColors.DIVIDER })
    .onClick(() => this.navigateToDetail(topic.id))
  }
}
