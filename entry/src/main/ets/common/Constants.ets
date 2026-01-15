/**
 * 神兵图录 - 常量定义
 * 定义应用中使用的各种常量
 */

/**
 * 应用信息
 */
export class AppConstants {
  static readonly APP_NAME = '神兵图录'
  static readonly APP_VERSION = '1.1.1'
  static readonly APP_DESCRIPTION = '传说兵器图鉴'
}

/**
 * 路由路径
 */
export class RouterPath {
  static readonly MAIN = 'pages/MainPage'
  static readonly INDEX = 'pages/Index'
  static readonly WEAPON_LIST = 'pages/WeaponList'
  static readonly WEAPON_DETAIL = 'pages/WeaponDetail'
  static readonly BLACKSMITH_LIST = 'pages/BlacksmithList'
  static readonly BLACKSMITH_DETAIL = 'pages/BlacksmithDetail'
  static readonly TOPIC_DETAIL = 'pages/TopicDetail'
  static readonly ABILITY_LIST = 'pages/AbilityList'
  static readonly CULTURE_LIST = 'pages/CultureList'
  static readonly SEARCH = 'pages/SearchPage'
  static readonly QUIZ = 'pages/Quiz'
  static readonly DAILY_DIVINATION = 'pages/DailyDivination'
  static readonly BATTLE_SIMULATOR = 'pages/BattleSimulator'
  static readonly ATTRIBUTE_TEST = 'pages/AttributeTest'
  static readonly MINE = 'pages/Mine'
  static readonly FAVORITE_LIST = 'pages/FavoriteList'
  static readonly HISTORY_LIST = 'pages/HistoryList'
}

/**
 * 文化名称映射
 */
export const CultureNames: Record<string, string> = {
  'chinese': '中国',
  'japanese': '日本',
  'greek': '希腊',
  'norse': '北欧',
  'celtic': '凯尔特',
  'medieval_europe': '中世纪欧洲',
  'indian': '印度',
  'arabian': '阿拉伯',
  'egyptian': '埃及',
  'persian': '波斯',
  'mesoamerican': '中美洲',
  'african': '非洲',
  'mixed': '混合'
}

/**
 * 兵器类型名称映射
 */
export const WeaponTypeNames: Record<string, string> = {
  'sword': '剑',
  'katana': '刀',
  'hammer': '锤',
  'axe': '斧',
  'spear': '矛',
  'bow': '弓',
  'staff': '杖',
  'dagger': '匕首',
  'polearm': '长柄',
  'trident': '叉戟',
  'chain_weapon': '链条',
  'scythe': '镰刀',
  'club': '棍棒',
  'soft_weapon': '软兵',
  'shield': '盾',
  'claw': '爪',
  'throwing': '投掷',
  'other': '其他'
}

/**
 * 属性名称映射
 */
export const AttributeNames: Record<string, string> = {
  'fire': '火',
  'water': '水',
  'ice': '冰',
  'thunder': '雷',
  'wind': '风',
  'earth': '土',
  'light': '光',
  'dark': '暗',
  'poison': '毒',
  'nature': '木',
  'time_space': '时空',
  'death': '死亡',
  'chaos': '混沌',
  'special': '特殊'
}

/**
 * 品质名称映射
 */
export const RarityNames: Record<string, string> = {
  'artifact': '神器',
  'legendary': '传说',
  'epic': '史诗',
  'rare': '稀有'
}

/**
 * 布局常量
 */
export class LayoutConstants {
  static readonly SAFE_AREA_TOP = 44
  static readonly SAFE_AREA_BOTTOM = 34
  static readonly TAB_BAR_HEIGHT = 56
  static readonly HEADER_HEIGHT = 56
  static readonly CARD_MARGIN = 12
  static readonly CARD_PADDING = 16
  static readonly BORDER_RADIUS = 12
}
