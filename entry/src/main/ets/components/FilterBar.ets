/**
 * 神兵图录 - 筛选栏组件
 * 提供多维度筛选功能
 */

import { ThemeColors, FontSizes, Spacing, getRarityColor, getAttributeColor } from '../common/Theme'
import { CultureNames, WeaponTypeNames, RarityNames, AttributeNames } from '../common/Constants'

/**
 * 筛选项
 */
export interface FilterOption {
  key: string
  label: string
  color?: string
}

/**
 * 筛选类型
 */
export type FilterType = 'culture' | 'type' | 'attribute' | 'rarity'

/**
 * 筛选栏组件
 */
@Component
export struct FilterBar {
  @Link selectedCulture: string
  @Link selectedType: string
  @Link selectedAttribute: string
  @Link selectedRarity: string
  @State activeFilterType: FilterType | null = null
  private onFilterChange?: () => void

  // 获取文化选项
  private getCultureOptions(): FilterOption[] {
    const options: FilterOption[] = [{ key: '', label: '全部' }]
    const keys = Object.keys(CultureNames)
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      options.push({ key: key, label: CultureNames[key] })
    }
    return options
  }

  // 获取类型选项
  private getTypeOptions(): FilterOption[] {
    const options: FilterOption[] = [{ key: '', label: '全部' }]
    const keys = Object.keys(WeaponTypeNames)
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      options.push({ key: key, label: WeaponTypeNames[key] })
    }
    return options
  }

  // 获取属性选项
  private getAttributeOptions(): FilterOption[] {
    const options: FilterOption[] = [{ key: '', label: '全部' }]
    const keys = Object.keys(AttributeNames)
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      options.push({ key: key, label: AttributeNames[key], color: getAttributeColor(key) })
    }
    return options
  }

  // 获取品质选项
  private getRarityOptions(): FilterOption[] {
    const options: FilterOption[] = [{ key: '', label: '全部' }]
    const keys = Object.keys(RarityNames)
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      options.push({ key: key, label: RarityNames[key], color: getRarityColor(key) })
    }
    return options
  }

  build() {
    Column() {
      // 筛选按钮行
      Row() {
        this.FilterButton('文化', 'culture', this.selectedCulture)
        this.FilterButton('类型', 'type', this.selectedType)
        this.FilterButton('属性', 'attribute', this.selectedAttribute)
        this.FilterButton('品质', 'rarity', this.selectedRarity)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: Spacing.SMALL, bottom: Spacing.SMALL })

      // 展开的筛选选项
      if (this.activeFilterType !== null) {
        Column() {
          this.FilterOptions()
        }
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.MEDIUM })
        .backgroundColor(ThemeColors.SECONDARY_BG)
      }
    }
    .width('100%')
    .backgroundColor(ThemeColors.SECONDARY_BG)
  }

  /**
   * 筛选按钮
   */
  @Builder
  FilterButton(label: string, type: FilterType, selectedValue: string) {
    Row() {
      Text(label)
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(this.activeFilterType === type ? ThemeColors.ACCENT : ThemeColors.TEXT_SECONDARY)

      Text(this.getSelectedLabel(type, selectedValue))
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(selectedValue ? ThemeColors.ACCENT : ThemeColors.TEXT_TERTIARY)
        .margin({ left: 4 })
        .maxLines(1)

      Image($r('app.media.icon_arrow_down'))
        .width(12)
        .height(12)
        .fillColor(this.activeFilterType === type ? ThemeColors.ACCENT : ThemeColors.TEXT_TERTIARY)
        .rotate({ angle: this.activeFilterType === type ? 180 : 0 })
        .margin({ left: 4 })
    }
    .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
    .backgroundColor(this.activeFilterType === type ? ThemeColors.CARD_BG : Color.Transparent)
    .borderRadius(Spacing.LARGE)
    .onClick(() => {
      if (this.activeFilterType === type) {
        this.activeFilterType = null
      } else {
        this.activeFilterType = type
      }
    })
  }

  /**
   * 获取选中项的显示文本
   */
  private getSelectedLabel(type: FilterType, value: string): string {
    if (!value) return ''
    switch (type) {
      case 'culture': return CultureNames[value] || value
      case 'type': return WeaponTypeNames[value] || value
      case 'attribute': return AttributeNames[value] || value
      case 'rarity': return RarityNames[value] || value
      default: return ''
    }
  }

  /**
   * 筛选选项列表
   */
  @Builder
  FilterOptions() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.getCurrentOptions(), (option: FilterOption) => {
        this.FilterOptionItem(option)
      }, (option: FilterOption) => option.key)
    }
    .width('100%')
  }

  /**
   * 获取当前类型的选项
   */
  private getCurrentOptions(): FilterOption[] {
    switch (this.activeFilterType) {
      case 'culture': return this.getCultureOptions()
      case 'type': return this.getTypeOptions()
      case 'attribute': return this.getAttributeOptions()
      case 'rarity': return this.getRarityOptions()
      default: return []
    }
  }

  /**
   * 获取当前选中值
   */
  private getCurrentSelectedValue(): string {
    switch (this.activeFilterType) {
      case 'culture': return this.selectedCulture
      case 'type': return this.selectedType
      case 'attribute': return this.selectedAttribute
      case 'rarity': return this.selectedRarity
      default: return ''
    }
  }

  /**
   * 筛选选项项
   */
  @Builder
  FilterOptionItem(option: FilterOption) {
    Text(option.label)
      .fontSize(FontSizes.BODY_SMALL)
      .fontColor(this.isSelected(option.key) ? ThemeColors.PRIMARY_BG : (option.color || ThemeColors.TEXT_PRIMARY))
      .padding({ left: Spacing.MEDIUM, right: Spacing.MEDIUM, top: Spacing.SMALL, bottom: Spacing.SMALL })
      .backgroundColor(this.isSelected(option.key) ? (option.color || ThemeColors.ACCENT) : ThemeColors.CARD_BG)
      .borderRadius(Spacing.LARGE)
      .border({
        width: 1,
        color: option.color || ThemeColors.DIVIDER
      })
      .margin({ right: Spacing.SMALL, bottom: Spacing.SMALL })
      .onClick(() => {
        this.selectOption(option.key)
      })
  }

  /**
   * 检查是否选中
   */
  private isSelected(key: string): boolean {
    return this.getCurrentSelectedValue() === key
  }

  /**
   * 选择选项
   */
  private selectOption(key: string): void {
    switch (this.activeFilterType) {
      case 'culture':
        this.selectedCulture = key
        break
      case 'type':
        this.selectedType = key
        break
      case 'attribute':
        this.selectedAttribute = key
        break
      case 'rarity':
        this.selectedRarity = key
        break
    }
    this.activeFilterType = null
    if (this.onFilterChange) {
      this.onFilterChange()
    }
  }
}
