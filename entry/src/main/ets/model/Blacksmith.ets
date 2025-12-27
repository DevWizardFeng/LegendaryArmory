/**
 * 神兵图录 - 铸造师数据模型
 * 定义传奇铸造师的数据结构
 */

import { CultureType } from './LegendaryWeapon'

/**
 * 多语言名称
 */
export interface BlacksmithName {
  original: string   // 原文名称
  cn: string         // 中文名称
  en: string         // 英文名称
}

/**
 * 铸造师完整数据结构
 */
export interface Blacksmith {
  id: string                    // 唯一标识
  name: BlacksmithName          // 多语言名称
  culture: CultureType          // 所属文化
  era: string                   // 时代背景
  title: string                 // 称号
  description: string           // 简介
  legend: string                // 完整传说故事
  forging_technique: string     // 独特锻造技艺
  masterworks: string[]         // 代表作品ID列表
  specialty: string             // 专长特色
  image: string                 // 图片文件名
}

/**
 * 铸造师列表数据
 */
export interface BlacksmithsData {
  blacksmiths: Blacksmith[]
}
