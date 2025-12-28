/**
 * 神兵图录 - 文本转语音管理器
 * 封装 TextToSpeechEngine 用于播放神兵和锻造师介绍
 */

import { BusinessError } from '@kit.BasicServicesKit'
import { textToSpeech } from '@kit.CoreSpeechKit'

/**
 * TTS 播放状态
 */
export enum TTSState {
  IDLE = 0,        // 空闲
  PLAYING = 1,     // 播放中
  PAUSED = 2,      // 已暂停
  ERROR = 3        // 错误
}

/**
 * TTS 管理器
 */
export class TTSManager {
  private engine: textToSpeech.TextToSpeechEngine | null = null
  private state: TTSState = TTSState.IDLE
  private currentText: string = ''
  private currentRequestId: string = ''
  private onStateChange?: (state: TTSState) => void

  /**
   * 初始化 TTS 引擎
   */
  async init(): Promise<void> {
    try {
      // 如果已经初始化，直接返回
      if (this.engine) {
        console.info('[TTSManager] 引擎已初始化')
        return
      }

      // 创建引擎参数
      const extraParam: Record<string, Object> = {
        "style": 'interaction-broadcast',
        "locate": 'CN',
        "name": 'LegendaryArmoryTTS'
      }

      const initParams: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0,      // 发音人（0 表示默认）
        online: 1,      // 在线模式
        extraParams: extraParam
      }

      // 创建引擎实例
      return new Promise((resolve, reject) => {
        textToSpeech.createEngine(initParams, (err: BusinessError, engine: textToSpeech.TextToSpeechEngine) => {
          if (err) {
            console.error(`[TTSManager] 创建引擎失败: ${err.code} - ${err.message}`)
            this.updateState(TTSState.ERROR)
            reject(new Error(`TTS 引擎创建失败: ${err.message}`))
            return
          }

          console.info('[TTSManager] 引擎创建成功')
          this.engine = engine

          // 设置回调监听
          this.setupCallbacks()

          this.updateState(TTSState.IDLE)
          resolve()
        })
      })
    } catch (error) {
      console.error('[TTSManager] 初始化失败:', error)
      this.updateState(TTSState.ERROR)
      throw new Error(`TTS 初始化失败: ${error}`)
    }
  }

  /**
   * 设置回调监听
   */
  private setupCallbacks(): void {
    if (!this.engine) return

    // 创建监听器对象
    const speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart: (requestId: string, response: textToSpeech.StartResponse) => {
        console.info(`[TTSManager] 播放开始回调: ${requestId}`)
        // 确保状态为 PLAYING（speak 方法中已经设置，这里只是确认）
        if (this.state !== TTSState.PLAYING) {
          this.updateState(TTSState.PLAYING)
        }
      },

      // 播报完成回调
      onComplete: (requestId: string, response: textToSpeech.CompleteResponse) => {
        console.info(`[TTSManager] 播放完成回调: ${requestId}`)
        // 只有当前请求完成时才更新状态
        if (requestId === this.currentRequestId) {
          this.updateState(TTSState.IDLE)
          this.currentText = ''
          this.currentRequestId = ''
        }
      },

      // 停止播报回调
      onStop: (requestId: string, response: textToSpeech.StopResponse) => {
        console.info(`[TTSManager] 播放停止回调: ${requestId}`)
        this.updateState(TTSState.IDLE)
        this.currentText = ''
        this.currentRequestId = ''
      },

      // 音频流回调（可选）
      onData: (requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) => {
        // 可以在这里记录播放进度
        console.debug(`[TTSManager] 音频数据: ${requestId}, 序号: ${response.sequence}`)
      },

      // 错误回调
      onError: (requestId: string, errorCode: number, errorMessage: string) => {
        console.error(`[TTSManager] 播放错误回调: ${requestId}, code: ${errorCode}, msg: ${errorMessage}`)
        this.updateState(TTSState.ERROR)
        this.currentText = ''
        this.currentRequestId = ''
      }
    }

    // 设置监听器
    this.engine.setListener(speakListener)
  }

  /**
   * 播放文本
   */
  async speak(text: string): Promise<void> {
    try {
      // 检查引擎是否初始化
      let needInit = false
      if (!this.engine) {
        console.warn('[TTSManager] 引擎未初始化，尝试初始化...')
        needInit = true
        await this.init()
      }

      if (!this.engine) {
        throw new Error('TTS 引擎初始化失败')
      }

      // 如果刚初始化完成，等待引擎完全就绪
      if (needInit) {
        console.info('[TTSManager] 引擎刚初始化，等待就绪...')
        await new Promise<void>(resolve => setTimeout(resolve, 300))
      }

      // 如果正在播放，先停止
      if (this.state === TTSState.PLAYING) {
        await this.stop()
        // 等待一小段时间确保停止完成
        await new Promise<void>(resolve => setTimeout(resolve, 100))
      }

      this.currentText = text
      this.currentRequestId = Date.now().toString()

      // 设置播放参数
      const extraParam: Record<string, Object> = {
        "queueMode": 0,      // 队列模式：0-清空队列后播放，1-追加到队列
        "speed": 1.0,        // 语速（0.5-2.0）
        "volume": 1.0,       // 音量（0.0-2.0）
        "pitch": 1.0,        // 音调（0.5-2.0）
        "playType": 1        // 播放类型：1-边合成边播放（流式），0-合成完成后播放
      }

      const speakParams: textToSpeech.SpeakParams = {
        requestId: this.currentRequestId,
        extraParams: extraParam
      }

      // 先更新状态为播放中，让 UI 动效立即开始
      this.updateState(TTSState.PLAYING)

      // 开始播放
      console.info(`[TTSManager] 开始播放: ${text.substring(0, 50)}...`)
      this.engine.speak(text, speakParams)
    } catch (error) {
      console.error('[TTSManager] 播放失败:', error)
      this.updateState(TTSState.ERROR)
      throw new Error(`TTS 播放失败: ${error}`)
    }
  }

  /**
   * 停止播放
   */
  async stop(): Promise<void> {
    try {
      if (!this.engine || this.state !== TTSState.PLAYING) {
        return
      }

      console.info('[TTSManager] 停止播放')
      this.engine.stop()
      this.updateState(TTSState.IDLE)
      this.currentText = ''
      this.currentRequestId = ''
    } catch (error) {
      console.error('[TTSManager] 停止播放失败:', error)
      throw new Error(`TTS 停止失败: ${error}`)
    }
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    try {
      if (!this.engine) {
        return
      }

      // 先停止播放
      if (this.state === TTSState.PLAYING) {
        await this.stop()
      }

      console.info('[TTSManager] 释放引擎')
      this.engine.shutdown()
      this.engine = null
      this.updateState(TTSState.IDLE)
      this.currentText = ''
      this.currentRequestId = ''
    } catch (error) {
      console.error('[TTSManager] 释放资源失败:', error)
      throw new Error(`TTS 资源释放失败: ${error}`)
    }
  }

  /**
   * 更新状态
   */
  private updateState(newState: TTSState): void {
    this.state = newState
    if (this.onStateChange) {
      this.onStateChange(newState)
    }
  }

  /**
   * 获取当前状态
   */
  getState(): TTSState {
    return this.state
  }

  /**
   * 是否正在播放
   */
  isPlaying(): boolean {
    return this.state === TTSState.PLAYING
  }

  /**
   * 设置状态变化监听器
   */
  setOnStateChange(callback: (state: TTSState) => void): void {
    this.onStateChange = callback
  }
}

/**
 * 单例实例（可选）
 */
export const ttsManager = new TTSManager()
