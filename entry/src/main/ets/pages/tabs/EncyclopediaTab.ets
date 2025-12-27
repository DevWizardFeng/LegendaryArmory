/**
 * 神兵图录 - 百科Tab
 * 包含顶部二级导航：铸造大师、文化体系、技能词典
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor } from '../../common/Theme'
import { RouterPath, CultureNames, RarityNames, AttributeNames } from '../../common/Constants'
import { DataLoader } from '../../utils/DataLoader'
import { Blacksmith } from '../../model/Blacksmith'
import { Culture } from '../../model/Culture'
import { Ability } from '../../model/Ability'
import { LegendaryWeapon } from '../../model/LegendaryWeapon'

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
    Column() {
      // 顶部标题栏
      Row() {
        Text('兵器百科')
          .fontSize(FontSizes.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.ACCENT)
      }
      .height(56)
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })
      .backgroundColor(ThemeColors.PRIMARY_BG)

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
          AbilityContent()
        }
        .tabBar(this.customSubTabBar('技能词典', 2))
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
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }

  /**
   * 自定义二级Tab栏
   */
  @Builder
  customSubTabBar(name: string, index: number) {
    Text(name)
      .fontSize(this.currentSubTab === index ? FontSizes.BODY : FontSizes.BODY_SMALL)
      .fontColor(this.currentSubTab === index ? ThemeColors.ACCENT : ThemeColors.TEXT_SECONDARY)
      .fontWeight(this.currentSubTab === index ? FontWeight.Bold : FontWeight.Normal)
      .padding(Spacing.MEDIUM)
      .border({
        width: { bottom: this.currentSubTab === index ? 2 : 0 },
        color: ThemeColors.ACCENT
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
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }

  @Builder
  CultureFilter() {
    Scroll() {
      Row() {
        ForEach(this.cultureOptions, (culture: string) => {
          Text(culture ? (CultureNames[culture] || culture) : '全部')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(this.selectedCulture === culture ? ThemeColors.PRIMARY_BG : ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
            .backgroundColor(this.selectedCulture === culture ? ThemeColors.ACCENT : ThemeColors.CARD_BG)
            .borderRadius(Spacing.LARGE)
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
        color: ThemeColors.ACCENT
      })
      .borderRadius(Spacing.MEDIUM)

      // 信息
      Column() {
        Text(blacksmith.name.cn)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Row() {
          Text(CultureNames[blacksmith.culture] || blacksmith.culture)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.ACCENT)

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

        Text(`代表作品: ${blacksmith.masterworks.length} 件`)
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
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
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
            .fontColor(ThemeColors.TEXT_PRIMARY)
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
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }

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
          Text(culture.name_cn.substring(0, 1))
            .fontSize(FontSizes.TITLE)
            .fontColor(ThemeColors.ACCENT)
            .fontWeight(FontWeight.Bold)
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.SECONDARY_BG)
        .borderRadius(Spacing.MEDIUM)

        Column() {
          Text(culture.name_cn)
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(culture.region)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ top: Spacing.TINY })

          Text(`${this.getWeaponCount(culture.id)} 件神兵`)
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.ACCENT)
            .margin({ top: Spacing.TINY })
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

      Text(culture.description || culture.background)
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: Spacing.MEDIUM })
        .lineHeight(20)

      if ((culture.characteristics || []).length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach((culture.characteristics || []).slice(0, 3), (char: string) => {
            Text(char)
              .fontSize(FontSizes.SMALL)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
              .backgroundColor(ThemeColors.SECONDARY_BG)
              .borderRadius(4)
              .margin({ right: Spacing.TINY, top: Spacing.SMALL })
          })
        }
        .margin({ top: Spacing.SMALL })
      }
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
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
    Column() {
      Row() {
        Column() {
          Text(this.selectedCulture!.name_cn.substring(0, 1))
            .fontSize(32)
            .fontColor(ThemeColors.ACCENT)
            .fontWeight(FontWeight.Bold)
        }
        .width(64)
        .height(64)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.CARD_BG)
        .borderRadius(Spacing.MEDIUM)
        .border({
          width: 2,
          color: ThemeColors.ACCENT
        })

        Column() {
          Text(this.selectedCulture!.name)
            .fontSize(FontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(this.selectedCulture!.region)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.TINY })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: Spacing.LARGE })
      }
      .width('100%')
      .margin({ bottom: Spacing.LARGE })

      Text(this.selectedCulture!.description)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CharacteristicsSection() {
    if (this.selectedCulture!.characteristics && this.selectedCulture!.characteristics.length > 0) {
      Column() {
        Text('文化特色')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ bottom: Spacing.MEDIUM })

        ForEach(this.selectedCulture!.characteristics, (char: string, index: number) => {
          Row() {
            Text((index + 1).toString())
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.ACCENT)
              .width(24)

            Text(char)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Spacing.MEDIUM)
          .backgroundColor(ThemeColors.CARD_BG)
          .borderRadius(Spacing.SMALL)
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
          .fontColor(ThemeColors.TEXT_PRIMARY)

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
      Image($rawfile(`images/${weapon.image}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(Spacing.SMALL)

      Column() {
        Row() {
          Text(weapon.name.cn)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Text(RarityNames[weapon.rarity] || weapon.rarity)
            .fontSize(FontSizes.SMALL)
            .fontColor(getRarityColor(weapon.rarity))
            .margin({ left: Spacing.SMALL })
        }

        Text(weapon.description)
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
        .width(16)
        .height(16)
        .fillColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .margin({ bottom: Spacing.SMALL })
    .onClick(() => this.navigateToWeaponDetail(weapon.id))
  }
}

/**
 * 技能词典子组件（简化实现）
 */
@Component
struct AbilityContent {
  @State isLoading: boolean = true
  @State abilities: Ability[] = []
  @State selectedType: string = ''
  @State filteredAbilities: Ability[] = []
  private dataLoader: DataLoader | null = null

  // 技能类型选项
  private typeOptions: string[] = ['', 'elemental', 'physical', 'special', 'passive']
  private typeNames: Record<string, string> = {
    '': '全部',
    'elemental': '元素',
    'physical': '物理',
    'special': '特殊',
    'passive': '被动'
  }

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.abilities = await this.dataLoader.loadAbilities()
      this.applyFilter()
      this.isLoading = false
    } catch (error) {
      console.error('[AbilityContent] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  applyFilter(): void {
    if (this.selectedType) {
      this.filteredAbilities = this.abilities.filter(a => a.type === this.selectedType)
    } else {
      this.filteredAbilities = this.abilities
    }
  }

  build() {
    Column() {
      // 统计行
      Row() {
        Text(`共 ${this.filteredAbilities.length} 个`)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.SMALL, bottom: Spacing.SMALL })

      // 类型筛选
      this.TypeFilter()

      // 主内容区
      if (this.isLoading) {
        this.LoadingView()
      } else {
        this.ContentView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.PRIMARY_BG)
  }

  @Builder
  TypeFilter() {
    Scroll() {
      Row() {
        ForEach(this.typeOptions, (type: string) => {
          Text(this.typeNames[type] || type)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(this.selectedType === type ? ThemeColors.PRIMARY_BG : ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
            .backgroundColor(this.selectedType === type ? ThemeColors.ACCENT : ThemeColors.CARD_BG)
            .borderRadius(Spacing.LARGE)
            .margin({ right: Spacing.SMALL })
            .onClick(() => {
              this.selectedType = type
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

  @Builder
  ContentView() {
    List() {
      ForEach(this.filteredAbilities, (ability: Ability) => {
        ListItem() {
          this.AbilityCard(ability)
        }
        .margin({ bottom: Spacing.MEDIUM })
      }, (ability: Ability) => ability.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.MEDIUM })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  AbilityCard(ability: Ability) {
    Column() {
      Row() {
        Text(ability.name)
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Text(this.typeNames[ability.type] || ability.type)
          .fontSize(FontSizes.SMALL)
          .fontColor(ThemeColors.ACCENT)
          .padding({ left: Spacing.SMALL, right: Spacing.SMALL, top: 2, bottom: 2 })
          .backgroundColor(ThemeColors.SECONDARY_BG)
          .borderRadius(4)
      }
      .width('100%')

      Text(ability.description)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(22)
        .margin({ top: Spacing.MEDIUM })

      if (ability.effect) {
        Column() {
          Row() {
            Text('• ')
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.ACCENT)

            Text(ability.effect)
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(ThemeColors.TEXT_TERTIARY)
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.TINY })
        }
        .width('100%')
        .margin({ top: Spacing.SMALL })
      }
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
    .alignItems(HorizontalAlign.Start)
  }
}
