/**
 * 神兵图录 - 神兵详情页（博物馆典藏风格）
 * 展示神兵完整信息
 */

import { router } from '@kit.ArkUI'
import { ThemeColors, FontSizes, Spacing, getRarityColor, getRarityDarkColor, getAttributeColor } from '../common/Theme'
import { RouterPath, CultureNames, WeaponTypeNames, RarityNames, AttributeNames } from '../common/Constants'
import { DataLoader } from '../utils/DataLoader'
import { StorageManager } from '../utils/Storage'
import { LegendaryWeapon, FamousOwner } from '../model/LegendaryWeapon'
import { AttributeTag } from '../components/AttributeTag'

/**
 * 路由参数
 */
interface RouteParams {
  weaponId: string
}

@Entry
@Component
struct WeaponDetail {
  @State isLoading: boolean = true
  @State weapon: LegendaryWeapon | null = null
  @State isFavorite: boolean = false
  @State relatedWeapons: LegendaryWeapon[] = []
  private dataLoader: DataLoader | null = null
  private storageManager: StorageManager | null = null

  aboutToAppear(): void {
    const params = router.getParams() as RouteParams | undefined
    if (params?.weaponId) {
      this.loadData(params.weaponId)
    }
  }

  /**
   * 加载神兵数据
   */
  async loadData(weaponId: string): Promise<void> {
    try {
      const context = getContext(this)
      this.dataLoader = new DataLoader(context)
      this.storageManager = new StorageManager(context)
      await this.storageManager.init()

      // 加载神兵数据
      this.weapon = await this.dataLoader.getWeaponById(weaponId) || null

      // 检查收藏状态
      this.isFavorite = await this.storageManager.isFavorite(weaponId)

      // 添加浏览历史
      await this.storageManager.addHistory(weaponId)

      // 加载相关神兵
      if (this.weapon?.related && this.weapon.related.length > 0) {
        const allWeapons = await this.dataLoader.loadWeapons()
        this.relatedWeapons = allWeapons.filter(w => this.weapon?.related.includes(w.id))
      }

      this.isLoading = false
    } catch (error) {
      console.error('[WeaponDetail] 加载数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 切换收藏状态
   */
  async toggleFavorite(): Promise<void> {
    if (!this.weapon || !this.storageManager) return

    try {
      if (this.isFavorite) {
        await this.storageManager.removeFavorite(this.weapon.id)
      } else {
        await this.storageManager.addFavorite(this.weapon.id)
      }
      this.isFavorite = !this.isFavorite
    } catch (error) {
      console.error('[WeaponDetail] 收藏操作失败:', error)
    }
  }

  /**
   * 返回上一页
   */
  goBack(): void {
    router.back()
  }

  /**
   * 跳转到相关神兵
   */
  navigateToWeapon(weaponId: string): void {
    router.replaceUrl({
      url: RouterPath.WEAPON_DETAIL,
      params: { weaponId: weaponId }
    })
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.LoadingView()
      } else if (!this.weapon) {
        this.ErrorView()
      } else {
        this.ContentView()
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
      Text('正在加载...')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 错误视图
   */
  @Builder
  ErrorView() {
    Column() {
      Text('未找到该神兵')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      Text('返回')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.GOLD_PRIMARY)
        .margin({ top: Spacing.MEDIUM })
        .onClick(() => this.goBack())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 主内容视图
   */
  @Builder
  ContentView() {
    Stack({ alignContent: Alignment.Top }) {
      // 滚动内容
      Scroll() {
        Column() {
          // 顶部图片区域
          this.HeaderSection()

          // 基本信息
          this.BasicInfoSection()

          // 属性与数据
          this.StatsSection()

          // 铸造传说
          this.ForgingLegendSection()

          // 战斗传说
          this.BattleLegendSection()

          // 技能列表
          this.AbilitiesSection()

          // 持有者
          this.OwnersSection()

          // 相关神兵
          this.RelatedWeaponsSection()

          // 底部间距
          Blank().height(100)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 悬浮导航栏
      this.FloatingNavBar()
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 悬浮导航栏 - 展柜控制风格
   */
  @Builder
  FloatingNavBar() {
    Row() {
      // 返回按钮
      Column() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(26,34,51,0.85)')
      .borderRadius(20)
      .onClick(() => this.goBack())

      Blank()

      // 收藏按钮
      Column() {
        Image(this.isFavorite ? $r('app.media.icon_favorite_filled') : $r('app.media.icon_favorite'))
          .width(24)
          .height(24)
          .fillColor(this.isFavorite ? ThemeColors.GOLD_PRIMARY : ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(26,34,51,0.85)')
      .borderRadius(20)
      .onClick(() => this.toggleFavorite())
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.LARGE })
  }

  /**
   * 顶部图片区域
   */
  @Builder
  HeaderSection() {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 背景图片 - 全屏展示
      Image($rawfile(`images/${this.weapon!.image}`))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 渐变遮罩 - 轻柔渐变，只遮底部文字区域
      Column()
        .width('100%')
        .height('50%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(11,13,16,0)', 0], ['rgba(11,13,16,0.8)', 1]]
        })

      // 名称和品质
      Column() {
        // 品质标签 - 展柜铭牌风格
        Text(RarityNames[this.weapon!.rarity] || this.weapon!.rarity)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(getRarityColor(this.weapon!.rarity))
          .fontWeight(FontWeight.Bold)
          .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.TINY, bottom: Spacing.TINY })
          .backgroundColor('rgba(26,34,51,0.85)')
          .borderRadius(4)
          .border({
            width: 1,
            color: getRarityDarkColor(this.weapon!.rarity)
          })

        // 中文名 - 使用羊皮纸色
        Text(this.weapon!.name.cn)
          .fontSize(FontSizes.TITLE_LARGE)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_TITLE)
          .margin({ top: Spacing.SMALL })

        // 英文名
        if (this.weapon!.name.en) {
          Text(this.weapon!.name.en)
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ top: Spacing.TINY })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(Spacing.LARGE)
    }
    .width('100%')
    .height(360)
    .clip(true)
  }

  /**
   * 基本信息区域
   */
  @Builder
  BasicInfoSection() {
    Column() {
      // 分类信息
      Row() {
        this.InfoChip(CultureNames[this.weapon!.culture] || this.weapon!.culture)
        this.InfoChip(WeaponTypeNames[this.weapon!.type] || this.weapon!.type)
      }
      .margin({ bottom: Spacing.MEDIUM })

      // 属性标签
      Row() {
        AttributeTag({ attribute: this.weapon!.attributes.primary, tagSize: 'large', showIcon: true })
        if (this.weapon!.attributes.secondary) {
          AttributeTag({
            attribute: this.weapon!.attributes.secondary,
            tagSize: 'large',
            showIcon: true
          })
            .margin({ left: Spacing.SMALL })
        }
      }
      .margin({ bottom: Spacing.MEDIUM })

      // 描述
      Text(this.weapon!.description)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)

      // 铭文 - 羊皮纸卷轴风格
      if (this.weapon!.inscription) {
        Column() {
          Text('"' + this.weapon!.inscription + '"')
            .fontSize(FontSizes.BODY)
            .fontColor(ThemeColors.PARCHMENT)
            .fontStyle(FontStyle.Italic)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(Spacing.MEDIUM)
        .margin({ top: Spacing.MEDIUM })
        .backgroundColor(ThemeColors.SURFACE_0)
        .borderRadius(Spacing.SMALL)
        .border({
          width: 1,
          color: ThemeColors.DIVIDER
        })
      }
    }
    .width('100%')
    .padding(Spacing.LARGE)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 信息标签
   */
  @Builder
  InfoChip(text: string) {
    Text(text)
      .fontSize(FontSizes.BODY_SMALL)
      .fontColor(ThemeColors.TEXT_SECONDARY)
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
      .backgroundColor(ThemeColors.SURFACE_0)
      .borderRadius(Spacing.LARGE)
      .border({
        width: 1,
        color: ThemeColors.DIVIDER
      })
      .margin({ right: Spacing.SMALL })
  }

  /**
   * 属性数据区域
   */
  @Builder
  StatsSection() {
    Column() {
      this.SectionTitle('属性数据')

      Row() {
        this.StatItem('攻击', this.weapon!.stats.attack, ThemeColors.RUST)
        this.StatItem('防御', this.weapon!.stats.defense, ThemeColors.INFO)
        this.StatItem('速度', this.weapon!.stats.speed, ThemeColors.SUCCESS)
        this.StatItem('暴击', this.weapon!.stats.critical || 0, ThemeColors.EMBER)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.LARGE })
  }

  /**
   * 数据项
   */
  @Builder
  StatItem(label: string, value: number, color: string) {
    Column() {
      // 进度环
      Stack() {
        Progress({ value: value, total: 100, type: ProgressType.Ring })
          .width(60)
          .height(60)
          .color(color)
          .backgroundColor(ThemeColors.SURFACE_0)
          .style({ strokeWidth: 6 })

        Text(value.toString())
          .fontSize(FontSizes.BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }

      Text(label)
        .fontSize(FontSizes.CAPTION)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.SMALL })
    }
  }

  /**
   * 区块标题 - 展签风格
   */
  @Builder
  SectionTitle(title: string) {
    Row() {
      Column()
        .width(4)
        .height(20)
        .backgroundColor(ThemeColors.GOLD_PRIMARY)
        .borderRadius(2)

      Text(title)
        .fontSize(FontSizes.SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_TITLE)
        .margin({ left: Spacing.SMALL })
    }
    .width('100%')
    .margin({ bottom: Spacing.MEDIUM })
  }

  /**
   * 铸造传说区域
   */
  @Builder
  ForgingLegendSection() {
    Column() {
      this.SectionTitle('铸造传说')

      Text(this.weapon!.forging_legend)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.LARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 战斗传说区域
   */
  @Builder
  BattleLegendSection() {
    Column() {
      this.SectionTitle('战斗传说')

      Text(this.weapon!.battle_legend)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(24)
    }
    .width('100%')
    .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.LARGE })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 技能列表区域
   */
  @Builder
  AbilitiesSection() {
    if (this.weapon!.abilities && this.weapon!.abilities.length > 0) {
      Column() {
        this.SectionTitle('神兵技能')

        ForEach(this.weapon!.abilities, (abilityId: string, index: number) => {
          Row() {
            Column() {
              Text((index + 1).toString())
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.GOLD_PRIMARY)
            }
            .width(24)
            .height(24)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.SURFACE_0)
            .borderRadius(12)

            Text(abilityId)
              .fontSize(FontSizes.BODY)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .margin({ left: Spacing.MEDIUM })
          }
          .width('100%')
          .padding(Spacing.MEDIUM)
          .margin({ bottom: Spacing.SMALL })
          .backgroundColor(ThemeColors.BASE_1)
          .borderRadius(Spacing.SMALL)
          .border({
            width: 1,
            color: ThemeColors.DIVIDER
          })
        })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.LARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 持有者区域
   */
  @Builder
  OwnersSection() {
    if (this.weapon!.famous_owners && this.weapon!.famous_owners.length > 0) {
      Column() {
        this.SectionTitle('著名持有者')

        ForEach(this.weapon!.famous_owners, (owner: FamousOwner) => {
          Row() {
            Column() {
              Text(owner.name)
                .fontSize(FontSizes.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.TEXT_TITLE)

              Text(owner.story)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(ThemeColors.TEXT_TERTIARY)
                .margin({ top: Spacing.TINY })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Spacing.MEDIUM)
          .margin({ bottom: Spacing.SMALL })
          .backgroundColor(ThemeColors.SURFACE_0)
          .borderRadius(Spacing.SMALL)
          .border({
            width: 1,
            color: ThemeColors.DIVIDER
          })
        })
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.LARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 相关神兵区域
   */
  @Builder
  RelatedWeaponsSection() {
    if (this.relatedWeapons.length > 0) {
      Column() {
        this.SectionTitle('相关神兵')

        Scroll() {
          Row() {
            ForEach(this.relatedWeapons, (weapon: LegendaryWeapon) => {
              this.RelatedWeaponCard(weapon)
            }, (weapon: LegendaryWeapon) => weapon.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.LARGE })
      .alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 相关神兵卡片
   */
  @Builder
  RelatedWeaponCard(weapon: LegendaryWeapon) {
    Column() {
      Image($rawfile(`images/${weapon.image}`))
        .width(100)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Spacing.SMALL, topRight: Spacing.SMALL })

      Column() {
        Text(weapon.name.cn)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(ThemeColors.TEXT_TITLE)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(RarityNames[weapon.rarity] || weapon.rarity)
          .fontSize(FontSizes.SMALL)
          .fontColor(getRarityColor(weapon.rarity))
          .margin({ top: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(Spacing.SMALL)
    }
    .width(100)
    .backgroundColor(ThemeColors.SURFACE_0)
    .borderRadius(Spacing.SMALL)
    .border({
      width: 1,
      color: getRarityDarkColor(weapon.rarity)
    })
    .shadow({
      radius: 6,
      color: `${getRarityColor(weapon.rarity)}12`,
      offsetX: 0,
      offsetY: 2
    })
    .margin({ right: Spacing.MEDIUM })
    .onClick(() => this.navigateToWeapon(weapon.id))
  }
}
