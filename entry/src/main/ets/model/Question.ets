/**
 * 神兵图录 - 题目数据模型
 * 定义答题挑战的题目数据结构
 */

/**
 * 题目分类
 */
export type QuestionCategory = 'weapon' | 'blacksmith' | 'culture' | 'attribute' | 'ability'

/**
 * 难度等级
 */
export type DifficultyLevel = 'easy' | 'medium' | 'hard'

/**
 * 题目完整数据结构
 */
export interface Question {
  id: string                       // 唯一标识
  category: QuestionCategory       // 题目分类
  difficulty: DifficultyLevel      // 难度等级
  question: string                 // 题目内容
  options: string[]                // 选项（4个）
  correct_answer: number           // 正确答案索引（0-3）
  explanation: string              // 答案解释
  related_id?: string              // 关联的神兵/铸造师ID
}

/**
 * 题目列表数据
 */
export interface QuestionsData {
  questions: Question[]
}
