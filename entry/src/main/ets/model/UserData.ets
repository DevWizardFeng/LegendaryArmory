/**
 * 神兵图录 - 用户数据模型
 * 定义本地存储的用户数据结构
 */

/**
 * 收藏列表
 */
export interface Favorites {
  weapon_ids: string[]
}

/**
 * 浏览历史项
 */
export interface HistoryItem {
  weapon_id: string
  timestamp: number
}

/**
 * 浏览历史
 */
export interface History {
  items: HistoryItem[]
}

/**
 * 答题模式
 */
export type QuizMode = 'classic' | 'speed' | 'endless' | 'topic'

/**
 * 段位等级
 */
export type RankTier = 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond'

/**
 * 答题记录
 */
export interface QuizRecord {
  mode: QuizMode         // 答题模式
  score: number          // 得分
  correct: number        // 正确数
  total: number          // 总题数
  combo: number          // 最高连击
  time: number           // 用时（秒）
  rank: RankTier         // 段位
  timestamp: number      // 时间戳
}

/**
 * 成就稀有度
 */
export type AchievementRarity = 'common' | 'rare' | 'epic' | 'legendary'

/**
 * 成就数据
 */
export interface Achievement {
  id: string                    // 成就ID
  name: string                  // 成就名称
  description: string           // 成就描述
  rarity: AchievementRarity     // 成就稀有度
  unlocked: boolean             // 是否已解锁
  unlock_time?: number          // 解锁时间
  progress?: number             // 当前进度
  total?: number                // 总目标
}

/**
 * 用户设置
 */
export interface UserSettings {
  theme: 'dark' | 'light'       // 主题
  sound: boolean                // 音效
  vibration: boolean            // 振动
}

/**
 * 完整用户数据
 */
export interface UserData {
  favorites: Favorites          // 收藏
  history: History              // 浏览历史
  quizRecords: QuizRecord[]     // 答题记录
  achievements: Achievement[]   // 成就
  settings: UserSettings        // 设置
}
