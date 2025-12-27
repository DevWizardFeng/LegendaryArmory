/**
 * 神兵图录 - 主题配置
 * 定义应用的颜色主题和样式
 */

/**
 * 颜色主题
 */
export class ThemeColors {
  // 主背景色
  static readonly PRIMARY_BG = '#0a0a1a'
  static readonly SECONDARY_BG = '#1a1a2e'
  static readonly CARD_BG = '#252540'

  // 文字颜色
  static readonly TEXT_PRIMARY = '#ffffff'
  static readonly TEXT_SECONDARY = '#b0b0b0'
  static readonly TEXT_TERTIARY = '#666666'

  // 强调色
  static readonly ACCENT = '#ffd700'
  static readonly ACCENT_SECONDARY = '#9d4edd'

  // 品质颜色
  static readonly RARITY_ARTIFACT = '#ffd700'   // 神器 - 金色
  static readonly RARITY_LEGENDARY = '#9d4edd'  // 传说 - 紫色
  static readonly RARITY_EPIC = '#4cc9f0'       // 史诗 - 蓝色
  static readonly RARITY_RARE = '#3cb371'       // 稀有 - 绿色

  // 属性颜色
  static readonly ATTR_FIRE = '#ff4500'
  static readonly ATTR_WATER = '#1e90ff'
  static readonly ATTR_ICE = '#00bfff'
  static readonly ATTR_THUNDER = '#9370db'
  static readonly ATTR_WIND = '#7fffd4'
  static readonly ATTR_EARTH = '#8b4513'
  static readonly ATTR_LIGHT = '#ffd700'
  static readonly ATTR_DARK = '#2f4f4f'
  static readonly ATTR_POISON = '#228b22'
  static readonly ATTR_NATURE = '#32cd32'
  static readonly ATTR_TIME_SPACE = '#9400d3'
  static readonly ATTR_DEATH = '#4a4a4a'
  static readonly ATTR_CHAOS = '#ff1493'
  static readonly ATTR_SPECIAL = '#ff69b4'

  // 功能颜色
  static readonly SUCCESS = '#4caf50'
  static readonly WARNING = '#ff9800'
  static readonly ERROR = '#f44336'
  static readonly INFO = '#2196f3'

  // 分割线
  static readonly DIVIDER = '#333344'
}

/**
 * 根据品质获取颜色
 */
export function getRarityColor(rarity: string): string {
  switch (rarity) {
    case 'artifact': return ThemeColors.RARITY_ARTIFACT
    case 'legendary': return ThemeColors.RARITY_LEGENDARY
    case 'epic': return ThemeColors.RARITY_EPIC
    case 'rare': return ThemeColors.RARITY_RARE
    default: return ThemeColors.TEXT_SECONDARY
  }
}

/**
 * 根据属性获取颜色
 */
export function getAttributeColor(attribute: string): string {
  switch (attribute) {
    case 'fire': return ThemeColors.ATTR_FIRE
    case 'water': return ThemeColors.ATTR_WATER
    case 'ice': return ThemeColors.ATTR_ICE
    case 'thunder': return ThemeColors.ATTR_THUNDER
    case 'wind': return ThemeColors.ATTR_WIND
    case 'earth': return ThemeColors.ATTR_EARTH
    case 'light': return ThemeColors.ATTR_LIGHT
    case 'dark': return ThemeColors.ATTR_DARK
    case 'poison': return ThemeColors.ATTR_POISON
    case 'nature': return ThemeColors.ATTR_NATURE
    case 'time_space': return ThemeColors.ATTR_TIME_SPACE
    case 'death': return ThemeColors.ATTR_DEATH
    case 'chaos': return ThemeColors.ATTR_CHAOS
    case 'special': return ThemeColors.ATTR_SPECIAL
    default: return ThemeColors.TEXT_SECONDARY
  }
}

/**
 * 字体大小
 */
export class FontSizes {
  static readonly TITLE_LARGE = 28
  static readonly TITLE = 24
  static readonly SUBTITLE = 20
  static readonly BODY_LARGE = 18
  static readonly BODY = 16
  static readonly BODY_SMALL = 14
  static readonly CAPTION = 12
  static readonly SMALL = 10
}

/**
 * 间距
 */
export class Spacing {
  static readonly TINY = 4
  static readonly SMALL = 8
  static readonly MEDIUM = 12
  static readonly LARGE = 16
  static readonly XLARGE = 24
  static readonly XXLARGE = 32
}
