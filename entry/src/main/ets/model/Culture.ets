/**
 * 神兵图录 - 文化体系数据模型
 * 定义不同文化体系的数据结构
 */

import { CultureType } from './LegendaryWeapon'

/**
 * 文化体系完整数据结构
 */
export interface Culture {
  id: CultureType                        // 文化ID
  name_cn: string                        // 中文名称
  name_en: string                        // 英文名称
  region: string                         // 地理区域
  period: string                         // 时代背景
  background: string                     // 文化背景介绍
  forging_history: string                // 兵器铸造史
  features: string[]                     // 文化特色
  weapon_characteristics: string[]       // 兵器特点
  representative_weapons: string[]       // 代表兵器ID
  representative_blacksmiths: string[]   // 代表铸造师ID
}

/**
 * 文化体系列表数据
 */
export interface CulturesData {
  cultures: Culture[]
}
