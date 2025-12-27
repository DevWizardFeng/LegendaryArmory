/**
 * 神兵图录 - 技能数据模型
 * 定义神兵技能的数据结构
 */

import { AttributeType } from './LegendaryWeapon'

/**
 * 技能分类
 */
export type AbilityCategory = 'elemental' | 'physical' | 'special' | 'passive'

/**
 * 著名使用案例
 */
export interface FamousUsage {
  weapon_id: string      // 使用该技能的武器ID
  description: string    // 使用描述
}

/**
 * 技能完整数据结构
 */
export interface Ability {
  id: string                     // 唯一标识
  name_cn: string                // 中文名称
  name_en: string                // 英文名称
  category: AbilityCategory      // 技能分类
  description: string            // 技能描述
  attribute?: AttributeType      // 相关属性（可选）
  famous_usage: FamousUsage[]    // 著名使用案例
}

/**
 * 技能列表数据
 */
export interface AbilitiesData {
  abilities: Ability[]
}
