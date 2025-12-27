/**
 * 神兵图录 - 专题数据模型
 * 定义专题文章的数据结构
 */

/**
 * 专题分类
 */
export type TopicCategory = 'culture' | 'technique' | 'legend' | 'history'

/**
 * 专题完整数据结构
 */
export interface Topic {
  id: string                      // 唯一标识
  title: string                   // 标题
  category: TopicCategory         // 分类
  summary: string                 // 摘要
  content: string                 // 完整内容
  related_weapons: string[]       // 相关神兵ID
  image: string                   // 封面图片
}

/**
 * 专题列表数据
 */
export interface TopicsData {
  topics: Topic[]
}
