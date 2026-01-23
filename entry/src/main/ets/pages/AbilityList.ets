/**
 * 神兵图录 - 技能百科页
 * 展示所有神兵技能分类和详情
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getAttributeColor } from '../common/Theme'
import { AttributeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { Ability, AbilityType } from '../model/Ability'

/**
 * 技能类型标签
 */
interface AbilityTypeTab {
  type: AbilityType | 'all'
  name: string
}

@Entry
@Component
struct AbilityList {
  @State isLoading: boolean = true
  @State abilities: Ability[] = []
  @State filteredAbilities: Ability[] = []
  @State selectedType: AbilityType | 'all' = 'all'
  @State expandedAbilityId: string = ''
  private dataLoader: DataLoader | null = null

  // 技能类型标签
  private typeTabs: AbilityTypeTab[] = [
    { type: 'all', name: '全部' },
    { type: 'elemental', name: '元素系' },
    { type: 'physical', name: '物理系' },
    { type: 'special', name: '特殊系' },
    { type: 'passive', name: '被动系' }
  ]

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载技能数据
   */
  async loadData(): Promise<void> {
    try {
      this.dataLoader = new DataLoader(getContext(this))
      this.abilities = await this.dataLoader.loadAbilities()
      this.applyFilter()
      this.isLoading = false
    } catch (error) {
      console.error('[AbilityList] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 应用筛选
   */
  applyFilter(): void {
    if (this.selectedType === 'all') {
      this.filteredAbilities = this.abilities
    } else {
      this.filteredAbilities = this.abilities.filter(a => a.type === this.selectedType)
    }
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    router.back()
  }

  /**
   * 获取技能类型颜色
   */
  getTypeColor(type: AbilityType): string {
    switch (type) {
      case 'elemental': return ThemeColors.ATTR_FIRE
      case 'physical': return ThemeColors.ATTR_EARTH
      case 'special': return ThemeColors.ATTR_TIME_SPACE
      case 'passive': return ThemeColors.SUCCESS
      default: return ThemeColors.TEXT_SECONDARY
    }
  }

  /**
   * 获取技能类型名称
   */
  getTypeName(type: AbilityType): string {
    switch (type) {
      case 'elemental': return '元素系'
      case 'physical': return '物理系'
      case 'special': return '特殊系'
      case 'passive': return '被动系'
      default: return type
    }
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

        Text('技能百科')
          .fontSize(FontSizes.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ left: Spacing.MEDIUM })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      // 类型标签栏
      this.TypeTabs()

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

  /**
   * 类型标签栏
   */
  @Builder
  TypeTabs() {
    Scroll() {
      Row() {
        ForEach(this.typeTabs, (tab: AbilityTypeTab) => {
          Text(tab.name)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(this.selectedType === tab.type ? ThemeColors.PRIMARY_BG : ThemeColors.TEXT_SECONDARY)
            .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
            .backgroundColor(this.selectedType === tab.type ? ThemeColors.ACCENT : ThemeColors.CARD_BG)
            .borderRadius(Spacing.LARGE)
            .margin({ right: Spacing.SMALL })
            .onClick(() => {
              this.selectedType = tab.type
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
   * 内容视图
   */
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

  /**
   * 技能卡片
   */
  @Builder
  AbilityCard(ability: Ability) {
    Column() {
      // 头部信息
      Row() {
        // 技能图标区
        Column() {
          Text((ability.name_cn || ability.name || ability.id).substring(0, 1))
            .fontSize(FontSizes.TITLE)
            .fontColor(this.getTypeColor(ability.type || ability.category))
            .fontWeight(FontWeight.Bold)
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.SECONDARY_BG)
        .borderRadius(Spacing.SMALL)
        .border({
          width: 1,
          color: this.getTypeColor(ability.type || ability.category)
        })

        // 名称和类型
        Column() {
          Text(ability.name_cn || ability.name || ability.id)
            .fontSize(FontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Row() {
            Text(this.getTypeName(ability.type || ability.category))
              .fontSize(FontSizes.CAPTION)
              .fontColor(this.getTypeColor(ability.type || ability.category))

            if (ability.element) {
              Text(' · ')
                .fontSize(FontSizes.CAPTION)
                .fontColor(ThemeColors.TEXT_TERTIARY)
              Text(AttributeNames[ability.element] || ability.element)
                .fontSize(FontSizes.CAPTION)
                .fontColor(getAttributeColor(ability.element))
            }
          }
          .margin({ top: Spacing.TINY })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: Spacing.MEDIUM })
        .layoutWeight(1)

        // 展开/收起按钮
        Image($r('app.media.icon_arrow_down'))
          .width(20)
          .height(20)
          .fillColor(ThemeColors.TEXT_TERTIARY)
          .rotate({ angle: this.expandedAbilityId === ability.id ? 180 : 0 })
      }
      .width('100%')
      .onClick(() => {
        if (this.expandedAbilityId === ability.id) {
          this.expandedAbilityId = ''
        } else {
          this.expandedAbilityId = ability.id
        }
      })

      // 展开的详细信息
      if (this.expandedAbilityId === ability.id) {
        Column() {
          // 分割线
          Divider()
            .color(ThemeColors.DIVIDER)
            .margin({ top: Spacing.MEDIUM, bottom: Spacing.MEDIUM })

          // 描述
          Text(ability.description)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .lineHeight(22)

          // 效果
          if (ability.effect) {
            Row() {
              Text('效果: ')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.TEXT_TERTIARY)
              Text(ability.effect)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.ACCENT)
            }
            .margin({ top: Spacing.MEDIUM })
          }

          // 冷却时间
          if (ability.cooldown) {
            Row() {
              Text('冷却: ')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.TEXT_TERTIARY)
              Text(`${ability.cooldown} 回合`)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.INFO)
            }
            .margin({ top: Spacing.SMALL })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding(Spacing.MEDIUM)
    .backgroundColor(ThemeColors.CARD_BG)
    .borderRadius(Spacing.MEDIUM)
  }
}
