/**
 * 神兵图录 - 神兵数据模型
 * 定义传说兵器的完整数据结构
 */

/**
 * 多语言名称
 */
export interface WeaponName {
  original: string   // 原文名称
  cn: string         // 中文名称
  en: string         // 英文名称
}

/**
 * 属性配置
 */
export interface WeaponAttributes {
  primary: AttributeType     // 主属性
  secondary?: AttributeType  // 副属性（可选）
}

/**
 * 武器数值
 */
export interface WeaponStats {
  attack: number    // 攻击力 1-100
  defense: number   // 防御力 1-100
  speed: number     // 速度 1-100
  weight: number    // 重量（kg）
}

/**
 * 著名持有者
 */
export interface FamousOwner {
  name: string      // 姓名
  title: string     // 称号
  story: string     // 故事简介
}

/**
 * 外观描述
 */
export interface WeaponAppearance {
  blade_type: string     // 剑身类型
  guard_type: string     // 护手类型
  handle_type: string    // 剑柄类型
  colors: string[]       // 主要颜色
  features: string[]     // 关键特征
}

/**
 * 文化类型枚举
 */
export type CultureType = 'chinese' | 'japanese' | 'greek' | 'norse' | 'celtic' |
  'medieval_europe' | 'indian' | 'arabian' | 'egyptian' | 'persian' |
  'mesoamerican' | 'african' | 'mixed'

/**
 * 兵器类型枚举
 */
export type WeaponType = 'sword' | 'katana' | 'hammer' | 'axe' | 'spear' | 'bow' |
  'staff' | 'dagger' | 'polearm' | 'trident' | 'chain_weapon' | 'scythe' |
  'club' | 'soft_weapon' | 'shield' | 'claw' | 'throwing' | 'other'

/**
 * 属性类型枚举
 */
export type AttributeType = 'fire' | 'water' | 'ice' | 'thunder' | 'wind' | 'earth' |
  'light' | 'dark' | 'poison' | 'nature' | 'time_space' | 'death' | 'chaos' | 'special'

/**
 * 品质类型枚举
 */
export type RarityType = 'artifact' | 'legendary' | 'epic' | 'rare'

/**
 * 传说兵器完整数据结构
 */
export interface LegendaryWeapon {
  id: string                          // 唯一标识
  name: WeaponName                    // 多语言名称
  culture: CultureType                // 文化体系
  type: WeaponType                    // 兵器类型
  attributes: WeaponAttributes        // 属性配置
  rarity: RarityType                  // 品质等级
  stats: WeaponStats                  // 数值属性
  description: string                 // 中文通俗描述
  forging_legend: string              // 铸造传说
  battle_legend: string               // 战斗传说
  abilities: string[]                 // 技能ID列表
  symbolism: string                   // 象征意义
  inscription: string                 // 铭文刻字
  famous_owners: FamousOwner[]        // 著名持有者
  blacksmith_id?: string              // 铸造者ID
  appearance: WeaponAppearance        // 外观描述
  image: string                       // 图片文件名
  related: string[]                   // 相关神兵ID
  tags: string[]                      // 标签
}

/**
 * 神兵列表数据
 */
export interface WeaponsData {
  weapons: LegendaryWeapon[]
}
