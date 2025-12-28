/**
 * 神兵图录 - 主题配置（博物馆典藏陈列风）
 * 设计理念：暗场展厅 + 金属点亮 + 矿物颜料
 */

/**
 * 颜色主题
 */
export class ThemeColors {
  // ============ 背景层次（展厅暗场）============
  static readonly BASE_0 = '#0B0D10'           // 最深背景（页面底色）- 深炭黑
  static readonly BASE_1 = '#121826'           // 乌钢蓝黑（Tab栏、导航栏）
  static readonly SURFACE_0 = '#1A2233'        // 深靛铁（卡片背景）
  static readonly SURFACE_1 = '#2A3444'        // 冷铁灰（悬浮层）
  static readonly SURFACE_2 = '#3A4555'        // 较亮铁灰（Hover态）

  // 兼容旧命名
  static readonly PRIMARY_BG = ThemeColors.BASE_0
  static readonly SECONDARY_BG = ThemeColors.BASE_1
  static readonly CARD_BG = ThemeColors.SURFACE_0

  // ============ 金属点亮色 ============
  static readonly GOLD_PRIMARY = '#C7A35A'     // 旧金（主强调色）
  static readonly GOLD_SECONDARY = '#8C6A2F'   // 暗金（次强调）
  static readonly SILVER_PRIMARY = '#B9C2CC'   // 冷银
  static readonly SILVER_SECONDARY = '#8A9AAC' // 暗银

  // 兼容旧命名
  static readonly ACCENT = ThemeColors.GOLD_PRIMARY
  static readonly ACCENT_SECONDARY = ThemeColors.GOLD_SECONDARY

  // ============ 图录纸张色 ============
  static readonly PARCHMENT = '#E7D8B1'        // 羊皮纸
  static readonly PARCHMENT_LIGHT = '#F5ECD8'  // 浅羊皮纸
  static readonly INK = '#2B2320'              // 墨色

  // ============ 叙事强调色 ============
  static readonly EMBER = '#D26A2E'            // 余烬橙
  static readonly RUST = '#7A2E2A'             // 锈红
  static readonly FORGE_GLOW = '#E8A045'       // 炉火橙

  // ============ 文字颜色（针对灰色背景优化 - 高对比度）============
  static readonly TEXT_TITLE = '#F0E4C8'       // 标题（更亮的羊皮纸色）
  static readonly TEXT_PRIMARY = '#E8F0F8'     // 正文（接近白色的冷灰）
  static readonly TEXT_SECONDARY = '#C8D4E0'   // 次要信息（高亮度）
  static readonly TEXT_TERTIARY = '#B0BCC8'    // 辅助信息（中等亮度）

  // ============ 品质颜色（材质化）============
  static readonly RARITY_ARTIFACT = '#C7A35A'        // 神器 - 旧金
  static readonly RARITY_ARTIFACT_DARK = '#8C6A2F'
  static readonly RARITY_LEGENDARY = '#6B4FA1'       // 传说 - 皇室紫
  static readonly RARITY_LEGENDARY_DARK = '#4A3570'
  static readonly RARITY_EPIC = '#3A7FA3'            // 史诗 - 冷青钢
  static readonly RARITY_EPIC_DARK = '#2A5A73'
  static readonly RARITY_RARE = '#3E6B57'            // 稀有 - 月桂绿
  static readonly RARITY_RARE_DARK = '#2A4A3A'

  // ============ 属性颜色（矿物颜料化）============
  static readonly ATTR_FIRE = '#B23A2A'              // 朱砂
  static readonly ATTR_FIRE_LIGHT = '#D07A2D'
  static readonly ATTR_WATER = '#2A5A8A'             // 深海蓝
  static readonly ATTR_WATER_LIGHT = '#5A8AB0'
  static readonly ATTR_ICE = '#2E6F8E'               // 冷釉蓝
  static readonly ATTR_ICE_LIGHT = '#88AFC1'
  static readonly ATTR_THUNDER = '#4B3F72'           // 靛紫
  static readonly ATTR_THUNDER_LIGHT = '#7E6ACB'
  static readonly ATTR_WIND = '#3E7B74'              // 青铜绿
  static readonly ATTR_WIND_LIGHT = '#9BC3B3'
  static readonly ATTR_EARTH = '#5A4535'             // 赭石
  static readonly ATTR_EARTH_LIGHT = '#8B7355'
  static readonly ATTR_LIGHT = '#C7A35A'             // 旧金
  static readonly ATTR_LIGHT_LIGHT = '#E7D8B1'
  static readonly ATTR_DARK = '#1B1F2A'              // 夜蓝黑
  static readonly ATTR_DARK_LIGHT = '#6E5A87'
  static readonly ATTR_POISON = '#2F5E3A'            // 苔藓绿
  static readonly ATTR_POISON_LIGHT = '#6D8F3B'
  static readonly ATTR_NATURE = '#3A5A3A'            // 深林绿
  static readonly ATTR_NATURE_LIGHT = '#6A8A5A'
  static readonly ATTR_TIME_SPACE = '#3A3A5A'        // 星空紫
  static readonly ATTR_TIME_SPACE_LIGHT = '#6A6A9A'
  static readonly ATTR_DEATH = '#2A2A2A'             // 骨灰黑
  static readonly ATTR_DEATH_LIGHT = '#4A4A4A'
  static readonly ATTR_CHAOS = '#5A2A4A'             // 暗紫红
  static readonly ATTR_CHAOS_LIGHT = '#8A4A6A'
  static readonly ATTR_SPECIAL = '#5A5A2A'           // 古铜
  static readonly ATTR_SPECIAL_LIGHT = '#8A8A5A'

  // ============ 功能颜色 ============
  static readonly SUCCESS = '#3E6B57'                // 复用稀有绿
  static readonly WARNING = '#D26A2E'                // 余烬橙
  static readonly ERROR = '#7A2E2A'                  // 锈红
  static readonly INFO = '#3A7FA3'                   // 冷青钢

  // ============ 分割线（针对灰色背景优化 - 高对比度）============
  static readonly DIVIDER = 'rgba(199,163,90,0.55)'         // 金色调（高透明度）
  static readonly DIVIDER_SILVER = 'rgba(185,194,204,0.40)' // 银色调（高透明度）
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
 * 根据品质获取暗色（用于边框、次要装饰）
 */
export function getRarityDarkColor(rarity: string): string {
  switch (rarity) {
    case 'artifact': return ThemeColors.RARITY_ARTIFACT_DARK
    case 'legendary': return ThemeColors.RARITY_LEGENDARY_DARK
    case 'epic': return ThemeColors.RARITY_EPIC_DARK
    case 'rare': return ThemeColors.RARITY_RARE_DARK
    default: return ThemeColors.TEXT_TERTIARY
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
 * 根据属性获取亮色（用于渐变、高亮）
 */
export function getAttributeLightColor(attribute: string): string {
  switch (attribute) {
    case 'fire': return ThemeColors.ATTR_FIRE_LIGHT
    case 'water': return ThemeColors.ATTR_WATER_LIGHT
    case 'ice': return ThemeColors.ATTR_ICE_LIGHT
    case 'thunder': return ThemeColors.ATTR_THUNDER_LIGHT
    case 'wind': return ThemeColors.ATTR_WIND_LIGHT
    case 'earth': return ThemeColors.ATTR_EARTH_LIGHT
    case 'light': return ThemeColors.ATTR_LIGHT_LIGHT
    case 'dark': return ThemeColors.ATTR_DARK_LIGHT
    case 'poison': return ThemeColors.ATTR_POISON_LIGHT
    case 'nature': return ThemeColors.ATTR_NATURE_LIGHT
    case 'time_space': return ThemeColors.ATTR_TIME_SPACE_LIGHT
    case 'death': return ThemeColors.ATTR_DEATH_LIGHT
    case 'chaos': return ThemeColors.ATTR_CHAOS_LIGHT
    case 'special': return ThemeColors.ATTR_SPECIAL_LIGHT
    default: return ThemeColors.TEXT_PRIMARY
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
