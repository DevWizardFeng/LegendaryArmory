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
}
