/**
 * 神兵图录 - 属性数据模型
 * 定义属性元素的数据结构
 */

import { AttributeType } from './LegendaryWeapon'

/**
 * 属性分类
 */
export type AttributeCategory = 'natural' | 'mystical' | 'special'

/**
 * 属性完整数据结构
 */
export interface Attribute {
  id: AttributeType                  // 属性ID
  name_cn: string                    // 中文名称
  name_en: string                    // 英文名称
  color: string                      // 代表色
  symbol: string                     // 符号/图标
  meaning: string                    // 象征含义
  category: AttributeCategory        // 元素分类
  strengths: AttributeType[]         // 克制的属性
  weaknesses: AttributeType[]        // 被克制的属性
  representative_weapons: string[]   // 代表兵器ID
}

/**
 * 属性列表数据
 */
export interface AttributesData {
  attributes: Attribute[]
}
