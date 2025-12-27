/**
 * 神兵图录 - 数据加载工具
 * 负责从 rawfile 加载 JSON 数据
 */

import { util } from '@kit.ArkTS'
import { LegendaryWeapon, WeaponsData } from '../model/LegendaryWeapon'
import { Blacksmith, BlacksmithsData } from '../model/Blacksmith'
import { Ability, AbilitiesData } from '../model/Ability'
import { Attribute, AttributesData } from '../model/Attribute'
import { Culture, CulturesData } from '../model/Culture'
import { Question, QuestionsData } from '../model/Question'
import { Topic, TopicsData } from '../model/Topic'

/**
 * 数据加载器类
 * 提供异步加载 JSON 数据的方法
 */
export class DataLoader {
  private context: Context

  constructor(context: Context) {
    this.context = context
  }

  /**
   * 从 rawfile 加载 JSON 文件
   * @param fileName 文件名（不含路径前缀）
   * @returns 解析后的 JSON 对象
   */
  private async loadJsonFile<T>(fileName: string): Promise<T> {
    try {
      const resourceManager = this.context.resourceManager
      const rawFile = await resourceManager.getRawFileContent(`data/${fileName}`)
      const textDecoder = new util.TextDecoder('utf-8')
      const jsonString = textDecoder.decodeToString(rawFile)
      return JSON.parse(jsonString) as T
    } catch (error) {
      console.error(`[DataLoader] 加载 ${fileName} 失败:`, error)
      throw new Error(`加载 ${fileName} 失败`)
    }
  }

  /**
   * 加载神兵数据
   */
  async loadWeapons(): Promise<LegendaryWeapon[]> {
    const data = await this.loadJsonFile<WeaponsData>('weapons.json')
    return data.weapons
  }

  /**
   * 加载铸造师数据
   */
  async loadBlacksmiths(): Promise<Blacksmith[]> {
    const data = await this.loadJsonFile<BlacksmithsData>('blacksmiths.json')
    return data.blacksmiths
  }

  /**
   * 加载技能数据
   */
  async loadAbilities(): Promise<Ability[]> {
    const data = await this.loadJsonFile<AbilitiesData>('abilities.json')
    return data.abilities
  }

  /**
   * 加载属性数据
   */
  async loadAttributes(): Promise<Attribute[]> {
    const data = await this.loadJsonFile<AttributesData>('attributes.json')
    return data.attributes
  }

  /**
   * 加载文化体系数据
   */
  async loadCultures(): Promise<Culture[]> {
    const data = await this.loadJsonFile<CulturesData>('cultures.json')
    return data.cultures
  }

  /**
   * 加载题目数据
   */
  async loadQuestions(): Promise<Question[]> {
    const data = await this.loadJsonFile<QuestionsData>('questions.json')
    return data.questions
  }

  /**
   * 加载专题数据
   */
  async loadTopics(): Promise<Topic[]> {
    try {
      console.info('[DataLoader] 开始加载topics.json')
      const data = await this.loadJsonFile<TopicsData>('topics.json')
      console.info('[DataLoader] topics.json加载成功, 数量:', data?.topics?.length || 0)
      return data.topics || []
    } catch (error) {
      console.error('[DataLoader] 加载topics.json失败:', JSON.stringify(error))
      return []
    }
  }

  /**
   * 根据ID获取神兵
   */
  async getWeaponById(id: string): Promise<LegendaryWeapon | undefined> {
    const weapons = await this.loadWeapons()
    return weapons.find(w => w.id === id)
  }

  /**
   * 根据ID获取铸造师
   */
  async getBlacksmithById(id: string): Promise<Blacksmith | undefined> {
    const blacksmiths = await this.loadBlacksmiths()
    return blacksmiths.find(b => b.id === id)
  }

  /**
   * 根据文化筛选神兵
   */
  async getWeaponsByCulture(culture: string): Promise<LegendaryWeapon[]> {
    const weapons = await this.loadWeapons()
    return weapons.filter(w => w.culture === culture)
  }

  /**
   * 根据品质筛选神兵
   */
  async getWeaponsByRarity(rarity: string): Promise<LegendaryWeapon[]> {
    const weapons = await this.loadWeapons()
    return weapons.filter(w => w.rarity === rarity)
  }

  /**
   * 根据属性筛选神兵
   */
  async getWeaponsByAttribute(attribute: string): Promise<LegendaryWeapon[]> {
    const weapons = await this.loadWeapons()
    return weapons.filter(w =>
      w.attributes.primary === attribute ||
      w.attributes.secondary === attribute
    )
  }
}
