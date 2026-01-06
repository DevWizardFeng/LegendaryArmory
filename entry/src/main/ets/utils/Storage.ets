/**
 * 神兵图录 - 本地存储工具
 * 封装 Preferences API 实现用户数据持久化
 */

import { preferences } from '@kit.ArkData'
import { Favorites, History, HistoryItem, QuizRecord, UserSettings, Achievement } from '../model/UserData'

// 存储键名常量
const PREFERENCES_NAME = 'legendary_armory_preferences'
const KEY_FAVORITES = 'favorites'
const KEY_HISTORY = 'history'
const KEY_QUIZ_RECORDS = 'quiz_records'
const KEY_ACHIEVEMENTS = 'achievements'
const KEY_SETTINGS = 'settings'

// 历史记录最大数量
const MAX_HISTORY_ITEMS = 50

/**
 * 存储管理器类
 */
export class StorageManager {
  private context: Context
  private dataPreferences: preferences.Preferences | null = null

  constructor(context: Context) {
    this.context = context
  }

  /**
   * 初始化存储
   */
  async init(): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(this.context, PREFERENCES_NAME)
    } catch (error) {
      console.error('[Storage] 初始化存储失败:', error)
      throw new Error('初始化存储失败')
    }
  }

  /**
   * 确保已初始化
   */
  private ensureInit(): preferences.Preferences {
    if (!this.dataPreferences) {
      throw new Error('StorageManager 未初始化，请先调用 init()')
    }
    return this.dataPreferences
  }

  // ==================== 收藏功能 ====================

  /**
   * 获取收藏列表
   */
  async getFavorites(): Promise<string[]> {
    const prefs = this.ensureInit()
    const value = await prefs.get(KEY_FAVORITES, '[]')
    return JSON.parse(value as string) as string[]
  }

  /**
   * 添加收藏
   */
  async addFavorite(weaponId: string): Promise<void> {
    const favorites = await this.getFavorites()
    if (!favorites.includes(weaponId)) {
      favorites.push(weaponId)
      const prefs = this.ensureInit()
      await prefs.put(KEY_FAVORITES, JSON.stringify(favorites))
      await prefs.flush()

      // 同步更新 AppStorage，触发 @StorageLink 监听器
      AppStorage.setOrCreate('favoriteWeaponIds', favorites)
    }
  }

  /**
   * 移除收藏
   */
  async removeFavorite(weaponId: string): Promise<void> {
    const favorites = await this.getFavorites()
    const index = favorites.indexOf(weaponId)
    if (index > -1) {
      favorites.splice(index, 1)
      const prefs = this.ensureInit()
      await prefs.put(KEY_FAVORITES, JSON.stringify(favorites))
      await prefs.flush()

      // 同步更新 AppStorage，触发 @StorageLink 监听器
      AppStorage.setOrCreate('favoriteWeaponIds', favorites)
    }
  }

  /**
   * 检查是否已收藏
   */
  async isFavorite(weaponId: string): Promise<boolean> {
    const favorites = await this.getFavorites()
    return favorites.includes(weaponId)
  }

  // ==================== 浏览历史 ====================

  /**
   * 获取浏览历史
   */
  async getHistory(): Promise<HistoryItem[]> {
    const prefs = this.ensureInit()
    const value = await prefs.get(KEY_HISTORY, '[]')
    return JSON.parse(value as string) as HistoryItem[]
  }

  /**
   * 添加浏览记录
   */
  async addHistory(weaponId: string): Promise<void> {
    let history = await this.getHistory()
    // 移除已存在的相同记录
    history = history.filter(item => item.weapon_id !== weaponId)
    // 添加到开头
    history.unshift({
      weapon_id: weaponId,
      timestamp: Date.now()
    })
    // 限制数量
    if (history.length > MAX_HISTORY_ITEMS) {
      history = history.slice(0, MAX_HISTORY_ITEMS)
    }
    const prefs = this.ensureInit()
    await prefs.put(KEY_HISTORY, JSON.stringify(history))
    await prefs.flush()
  }

  /**
   * 清空浏览历史
   */
  async clearHistory(): Promise<void> {
    const prefs = this.ensureInit()
    await prefs.put(KEY_HISTORY, '[]')
    await prefs.flush()
  }

  // ==================== 答题记录 ====================

  /**
   * 获取答题记录
   */
  async getQuizRecords(): Promise<QuizRecord[]> {
    const prefs = this.ensureInit()
    const value = await prefs.get(KEY_QUIZ_RECORDS, '[]')
    return JSON.parse(value as string) as QuizRecord[]
  }

  /**
   * 添加答题记录
   */
  async addQuizRecord(record: QuizRecord): Promise<void> {
    const records = await this.getQuizRecords()
    records.unshift(record)
    const prefs = this.ensureInit()
    await prefs.put(KEY_QUIZ_RECORDS, JSON.stringify(records))
    await prefs.flush()
  }

  /**
   * 获取最高分
   */
  async getHighScore(mode: string): Promise<number> {
    const records = await this.getQuizRecords()
    const modeRecords = records.filter(r => r.mode === mode)
    if (modeRecords.length === 0) return 0
    return Math.max(...modeRecords.map(r => r.score))
  }

  // ==================== 用户设置 ====================

  /**
   * 获取用户设置
   */
  async getSettings(): Promise<UserSettings> {
    const prefs = this.ensureInit()
    const defaultSettings: UserSettings = {
      theme: 'dark',
      sound: true,
      vibration: true
    }
    const value = await prefs.get(KEY_SETTINGS, JSON.stringify(defaultSettings))
    return JSON.parse(value as string) as UserSettings
  }

  /**
   * 保存用户设置
   */
  async saveSettings(settings: UserSettings): Promise<void> {
    const prefs = this.ensureInit()
    await prefs.put(KEY_SETTINGS, JSON.stringify(settings))
    await prefs.flush()
  }

  // ==================== 成就系统 ====================

  /**
   * 默认成就列表
   */
  private getDefaultAchievements(): Achievement[] {
    return [
      {
        id: 'first_weapon',
        name: '初识神兵',
        description: '浏览第一件神兵',
        rarity: 'common',
        unlocked: false
      },
      {
        id: 'collector_10',
        name: '收藏达人',
        description: '收藏10件神兵',
        rarity: 'rare',
        unlocked: false,
        progress: 0,
        total: 10
      },
      {
        id: 'collector_30',
        name: '神兵鉴赏家',
        description: '收藏30件神兵',
        rarity: 'epic',
        unlocked: false,
        progress: 0,
        total: 30
      },
      {
        id: 'quiz_first',
        name: '知识探索者',
        description: '完成第一次答题挑战',
        rarity: 'common',
        unlocked: false
      },
      {
        id: 'quiz_master',
        name: '答题达人',
        description: '在答题中获得500分以上',
        rarity: 'rare',
        unlocked: false
      },
      {
        id: 'quiz_legend',
        name: '神兵学者',
        description: '在答题中获得1000分以上',
        rarity: 'epic',
        unlocked: false
      },
      {
        id: 'combo_5',
        name: '连击新手',
        description: '在答题中达成5连击',
        rarity: 'common',
        unlocked: false
      },
      {
        id: 'combo_10',
        name: '连击高手',
        description: '在答题中达成10连击',
        rarity: 'rare',
        unlocked: false
      },
      {
        id: 'divination',
        name: '命运探寻者',
        description: '完成第一次每日占卜',
        rarity: 'common',
        unlocked: false
      },
      {
        id: 'battle_first',
        name: '战斗模拟师',
        description: '完成第一次神兵对战',
        rarity: 'common',
        unlocked: false
      },
      {
        id: 'attribute_test',
        name: '属性觉醒',
        description: '完成神兵属性测试',
        rarity: 'common',
        unlocked: false
      },
      {
        id: 'explorer',
        name: '百科探索者',
        description: '浏览20件不同神兵',
        rarity: 'rare',
        unlocked: false,
        progress: 0,
        total: 20
      }
    ]
  }

  /**
   * 获取成就列表
   */
  async getAchievements(): Promise<Achievement[]> {
    const prefs = this.ensureInit()
    const value = await prefs.get(KEY_ACHIEVEMENTS, '')
    if (!value || value === '') {
      // 首次使用，初始化默认成就
      const defaults = this.getDefaultAchievements()
      await this.saveAchievements(defaults)
      return defaults
    }
    return JSON.parse(value as string) as Achievement[]
  }

  /**
   * 保存成就列表
   */
  async saveAchievements(achievements: Achievement[]): Promise<void> {
    const prefs = this.ensureInit()
    await prefs.put(KEY_ACHIEVEMENTS, JSON.stringify(achievements))
    await prefs.flush()
  }

  /**
   * 解锁成就
   */
  async unlockAchievement(achievementId: string): Promise<boolean> {
    const achievements = await this.getAchievements()
    const achievement = achievements.find(a => a.id === achievementId)
    if (achievement && !achievement.unlocked) {
      achievement.unlocked = true
      achievement.unlock_time = Date.now()
      await this.saveAchievements(achievements)
      return true
    }
    return false
  }

  /**
   * 更新成就进度
   */
  async updateAchievementProgress(achievementId: string, progress: number): Promise<boolean> {
    const achievements = await this.getAchievements()
    const achievement = achievements.find(a => a.id === achievementId)
    if (achievement && !achievement.unlocked && achievement.total) {
      achievement.progress = progress
      if (progress >= achievement.total) {
        achievement.unlocked = true
        achievement.unlock_time = Date.now()
      }
      await this.saveAchievements(achievements)
      return achievement.unlocked
    }
    return false
  }

  /**
   * 获取已解锁成就数量
   */
  async getUnlockedCount(): Promise<number> {
    const achievements = await this.getAchievements()
    return achievements.filter(a => a.unlocked).length
  }
}
