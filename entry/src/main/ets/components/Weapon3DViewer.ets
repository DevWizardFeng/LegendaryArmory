/**
 * 神兵图录 - 3D武器查看器组件
 * 使用 HarmonyOS ArkGraphics 3D 引擎
 * 支持触控旋转、双指缩放、自动旋转
 * 注意：仅支持真机，模拟器不支持3D渲染（ArkGraphics3D Kit不支持模拟器）
 */

import { deviceInfo } from '@kit.BasicServicesKit'
import { ThemeColors, FontSizes, Spacing } from '../common/Theme'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

// 3D相关类型定义（动态导入后使用）
interface Color4 {
  r: number
  g: number
  b: number
  a: number
}

interface Position3D {
  x: number
  y: number
  z: number
}

interface LightCreateOptions {
  name: string
}

interface CameraCreateOptions {
  name: string
}

interface Scene3D {
  animations?: Animation3D[]
  getResourceFactory(): SceneResourceFactory
}

interface Animation3D {
  speed: number
  start(): void
  restart(): void
  onFinished(callback: () => void): void
}

interface SceneResourceFactory {
  createCamera(options: CameraCreateOptions): Promise<Camera3D>
  createLight(options: LightCreateOptions, type: number): Promise<Light3D>
}

interface Camera3D {
  enabled: boolean
  position: Position3D
  fov: number
}

interface Light3D {
  color: Color4
  intensity: number
  position: Position3D
  enabled: boolean
}

// 动态导入的3D模块引用
let Graphics3DModule: ESObject | null = null
let LightTypeEnum: ESObject | null = null

@Component
export struct Weapon3DViewer {
  @Prop weaponId: string = ''
  @Prop weapon: LegendaryWeapon | null = null
  @State sceneOpt: SceneOptions | null = null  // 使用系统的SceneOptions类型
  @State isLoading: boolean = true
  @State loadError: string = ''
  @State autoRotate: boolean = true
  @State is3DSupported: boolean = false  // 是否支持3D功能

  private scene: ESObject | null = null  // 使用ESObject避免类型冲突
  private camera: Camera3D | null = null
  private autoRotateTimer: number = -1

  // 相机控制参数
  private rotationY: number = 0           // 水平旋转角度
  private rotationX: number = 0           // 垂直旋转角度
  private cameraDistance: number = 3      // 相机距离
  private lastTouchX: number = 0
  private lastTouchY: number = 0
  private lastPinchDistance: number = 0

  async aboutToAppear(): Promise<void> {
    try {
      // 首先检测系统是否支持3D功能
      if (!this.check3DSupport()) {
        console.warn('[Weapon3DViewer] 当前设备不支持3D功能（模拟器或系统能力不足）')
        this.is3DSupported = false
        this.loadError = '3D预览仅支持真机设备，模拟器暂不支持'
        this.isLoading = false
        return
      }

      this.is3DSupported = true

      // 动态导入3D模块
      const moduleLoaded = await this.loadGraphics3DModule()
      if (!moduleLoaded) {
        console.error('[Weapon3DViewer] 无法加载3D模块')
        this.loadError = '3D模块加载失败，请在真机上运行'
        this.isLoading = false
        return
      }

      console.info(`[Weapon3DViewer] 开始加载3D模型: ${this.weaponId}`)
      await this.load3DModel()
      if (this.autoRotate) {
        this.startAutoRotate()
      }
      console.info(`[Weapon3DViewer] 3D模型加载成功: ${this.weaponId}`)
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error)
      console.error(`[Weapon3DViewer] 初始化失败: ${errorMsg}`, error)
      this.loadError = `3D模型加载失败: ${errorMsg}`
      this.isLoading = false
    }
  }

  /**
   * 检测系统是否支持3D功能
   * 使用 canIUse 检测 SystemCapability.ArkUi.Graphics3D
   */
  private check3DSupport(): boolean {
    try {
      // 使用 canIUse 检测3D系统能力
      const hasGraphics3D = canIUse('SystemCapability.ArkUi.Graphics3D')
      console.info(`[Weapon3DViewer] SystemCapability.ArkUi.Graphics3D: ${hasGraphics3D}`)

      if (!hasGraphics3D) {
        console.warn('[Weapon3DViewer] 系统不支持 ArkUi.Graphics3D 能力')
        return false
      }

      // 额外检查设备信息作为辅助判断
      const brand = deviceInfo.brand || ''
      const productModel = deviceInfo.productModel || ''
      console.info(`[Weapon3DViewer] 设备信息: brand=${brand}, model=${productModel}`)

      // 检查是否包含模拟器关键词
      const emulatorKeywords = ['emulator', 'simulator', 'sdk', 'genymotion']
      const brandLower = brand.toLowerCase()
      const modelLower = productModel.toLowerCase()

      for (const keyword of emulatorKeywords) {
        if (brandLower.includes(keyword) || modelLower.includes(keyword)) {
          console.warn(`[Weapon3DViewer] 检测到模拟器关键词: ${keyword}`)
          return false
        }
      }

      return true
    } catch (error) {
      console.error('[Weapon3DViewer] 3D能力检测失败:', error)
      return false
    }
  }

  /**
   * 动态加载 ArkGraphics3D 模块
   * 避免在不支持的设备上静态导入导致崩溃
   */
  private async loadGraphics3DModule(): Promise<boolean> {
    try {
      // 动态导入 ArkGraphics3D 模块
      Graphics3DModule = await import('@kit.ArkGraphics3D')
      if (Graphics3DModule) {
        LightTypeEnum = Graphics3DModule.LightType
        console.info('[Weapon3DViewer] ArkGraphics3D 模块加载成功')
        return true
      }
      return false
    } catch (error) {
      console.error('[Weapon3DViewer] ArkGraphics3D 模块加载失败:', error)
      return false
    }
  }

  aboutToDisappear(): void {
    this.stopAutoRotate()
    if (this.scene) {
      // 清理资源
      this.scene = null
    }
  }

  /**
   * 将武器ID转换为模型文件名
   * 武器ID格式如 "xuanyuan_sword"，模型文件名为 "xuanyuan.glb"
   */
  private getModelFileName(): string {
    // 武器ID到模型文件名的映射表
    const modelMapping: Record<string, string> = {
      // 中国神兵
      'xuanyuan_sword': 'xuanyuan',
      'zhanlu_sword': 'zhanlu',
      'chixiao_sword': 'chixiao',
      'ganjiang_sword': 'ganjiang',
      'moye_sword': 'moye',
      'qinglong_yanyue_dao': 'qinglong',
      // 日本神兵
      'kusanagi': 'kusanagi',
      'mikazuki_munechika': 'mikazuki',
      'muramasa': 'muramasa',
      'honjo_masamune': 'honjo_masamune',
      // 北欧神兵
      'mjolnir': 'mjolnir',
      'gungnir': 'gungnir',
      'tyrfing': 'tyrfing',
      'gram': 'gram',
      // 凯尔特神兵
      'fragarach': 'fragarach',
      'gae_bolg': 'gae_bolg',
      'claomh_solais': 'claomh_solais',
      'caladbolg': 'caladbolg',
      // 欧洲神兵
      'excalibur': 'excalibur',
      'durandal': 'durandal',
      // 希腊神兵
      'poseidon_trident': 'poseidon_trident',
      'zeus_thunderbolt': 'zeus_thunderbolt',
      'hades_bident': 'hades_bident',
      // 印度神兵
      'vajra': 'vajra',
      'trishula': 'trishula',
      'pashupatastra': 'pashupatastra',
      // 中东神兵
      'khopesh': 'khopesh',
      'zulfiqar': 'zulfiqar',
      'shamshir': 'shamshir'
    }

    // 优先使用映射表
    if (modelMapping[this.weaponId]) {
      return modelMapping[this.weaponId]
    }

    // 如果映射表中没有，尝试智能转换：去掉常见后缀
    let modelName = this.weaponId
    const suffixes = ['_sword', '_blade', '_dao', '_spear', '_hammer', '_axe', '_bow', '_staff']
    for (const suffix of suffixes) {
      if (modelName.endsWith(suffix)) {
        modelName = modelName.slice(0, -suffix.length)
        break
      }
    }

    return modelName
  }

  /**
   * 加载3D模型
   */
  async load3DModel(): Promise<void> {
    try {
      this.isLoading = true

      // 确保3D模块已加载
      if (!Graphics3DModule) {
        console.error('[Weapon3DViewer] 3D模块未加载')
        this.loadError = '3D模块未初始化'
        this.isLoading = false
        return
      }

      // 1. 加载GLB模型 - 使用转换后的模型文件名
      const modelFileName = this.getModelFileName()
      const modelPath = `models/${modelFileName}.glb`
      console.info(`[Weapon3DViewer] 武器ID: ${this.weaponId}, 模型文件: ${modelFileName}, 完整路径: ${modelPath}`)

      try {
        // 使用动态导入的Scene.load方法
        const SceneClass: ESObject = Graphics3DModule.Scene
        this.scene = await SceneClass.load($rawfile(modelPath))
      } catch (sceneError) {
        console.error(`[Weapon3DViewer] Scene.load失败:`, sceneError)
        this.loadError = `无法加载模型文件: ${modelPath}`
        this.isLoading = false
        return
      }

      if (!this.scene) {
        console.error('[Weapon3DViewer] 场景加载失败：scene为null')
        this.loadError = '场景加载失败'
        this.isLoading = false
        return
      }

      console.info(`[Weapon3DViewer] 场景加载成功`)

      // 2. 获取资源工厂
      const rf: ESObject = this.scene.getResourceFactory()
      if (!rf) {
        console.error('[Weapon3DViewer] 无法获取资源工厂')
        this.loadError = '无法获取资源工厂'
        this.isLoading = false
        return
      }

      // 3. 配置相机
      try {
        await this.setupCamera(rf)
        console.info(`[Weapon3DViewer] 相机配置成功`)
      } catch (cameraError) {
        console.error(`[Weapon3DViewer] 相机配置失败:`, cameraError)
        this.loadError = '相机配置失败'
        this.isLoading = false
        return
      }

      // 4. 配置光照
      try {
        await this.setupLighting(rf)
        console.info(`[Weapon3DViewer] 光照配置成功`)
      } catch (lightError) {
        console.error(`[Weapon3DViewer] 光照配置失败:`, lightError)
        // 光照配置失败不是致命错误，继续
        console.warn(`[Weapon3DViewer] 光照配置失败，使用默认光照`)
      }

      // 5. 增强材质(如果需要)
      try {
        await this.setupMaterials(rf)
        console.info(`[Weapon3DViewer] 材质配置成功`)
      } catch (materialError) {
        console.error(`[Weapon3DViewer] 材质配置失败:`, materialError)
        // 材质配置失败不是致命错误，继续
        console.warn(`[Weapon3DViewer] 材质配置失败，使用默认材质`)
      }

      // 6. 播放待机动画(如果有)
      try {
        this.playIdleAnimation()
      } catch (animError) {
        console.error(`[Weapon3DViewer] 动画播放失败:`, animError)
        // 动画失败不是致命错误，继续
      }

      // 7. 配置场景选项 - 直接使用动态加载的scene对象
      this.sceneOpt = {
        scene: this.scene,
        modelType: ModelType.SURFACE
      }

      this.isLoading = false
      console.info(`[Weapon3DViewer] 模型加载完成: ${this.weaponId}`)

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error)
      console.error(`[Weapon3DViewer] 模型加载失败 ${this.weaponId}: ${errorMsg}`, error)
      this.loadError = `无法加载${this.weaponId}的3D模型: ${errorMsg}`
      this.isLoading = false
      // 不再抛出错误，而是设置错误状态让UI显示
    }
  }

  /**
   * 配置相机
   */
  async setupCamera(rf: ESObject): Promise<void> {
    const cameraOpts: CameraCreateOptions = { name: "MainCamera" }
    this.camera = await rf.createCamera(cameraOpts)

    if (!this.camera) {
      throw new Error('相机创建失败')
    }

    // 设置相机初始位置
    this.camera.enabled = true
    this.camera.position.z = this.cameraDistance
    this.camera.position.y = 1

    // 设置相机视角参数
    this.camera.fov = 60 * Math.PI / 180  // 60度视角转弧度
  }

  /**
   * 配置三点式光照系统
   */
  async setupLighting(rf: ESObject): Promise<void> {
    // 确保LightType已加载
    if (!LightTypeEnum) {
      console.warn('[Weapon3DViewer] LightType未加载，跳过光照配置')
      return
    }

    // 主光(Key Light) - 暖色调平行光
    const keyLightOpts: LightCreateOptions = { name: "KeyLight" }
    const keyLight: Light3D = await rf.createLight(keyLightOpts, LightTypeEnum.DIRECTIONAL)
    const keyLightColor: Color4 = { r: 1.0, g: 0.95, b: 0.9, a: 1.0 }
    const keyLightPos: Position3D = { x: 5, y: 10, z: 5 }
    keyLight.color = keyLightColor
    keyLight.intensity = 1.2
    keyLight.position = keyLightPos
    keyLight.enabled = true

    // 补光(Fill Light) - 冷色调柔和光
    const fillLightOpts: LightCreateOptions = { name: "FillLight" }
    const fillLight: Light3D = await rf.createLight(fillLightOpts, LightTypeEnum.DIRECTIONAL)
    const fillLightColor: Color4 = { r: 0.8, g: 0.85, b: 1.0, a: 1.0 }
    const fillLightPos: Position3D = { x: -5, y: 5, z: 5 }
    fillLight.color = fillLightColor
    fillLight.intensity = 0.5
    fillLight.position = fillLightPos
    fillLight.enabled = true

    // 轮廓光(Rim Light) - 白色边缘光
    const rimLightOpts: LightCreateOptions = { name: "RimLight" }
    const rimLight: Light3D = await rf.createLight(rimLightOpts, LightTypeEnum.DIRECTIONAL)
    const rimLightColor: Color4 = { r: 1.0, g: 1.0, b: 1.0, a: 1.0 }
    const rimLightPos: Position3D = { x: 0, y: 5, z: -10 }
    rimLight.color = rimLightColor
    rimLight.intensity = 0.8
    rimLight.position = rimLightPos
    rimLight.enabled = true
  }

  /**
   * 配置材质增强
   * 注意：当前HarmonyOS API不支持动态材质修改，此功能暂时简化
   */
  async setupMaterials(rf: ESObject): Promise<void> {
    // 材质增强功能依赖高级API，当前版本暂不支持
    // 保留方法以便future升级
    console.info('[Weapon3DViewer] 材质配置已简化')
  }

  /**
   * 判断武器是否需要发光效果
   */
  weaponHasGlow(): boolean {
    if (!this.weapon) return false
    return this.weapon.rarity === 'artifact' || this.weapon.rarity === 'legendary'
  }

  /**
   * 播放待机动画
   */
  playIdleAnimation(): void {
    if (!this.scene || !this.scene.animations || this.scene.animations.length === 0) {
      return
    }

    // 播放第一个动画(通常是待机动画)
    const idleAnim: Animation3D = this.scene.animations[0]
    idleAnim.speed = 1.0
    idleAnim.start()

    idleAnim.onFinished(() => {
      // 循环播放
      idleAnim.restart()
    })
  }

  /**
   * 开始自动旋转
   */
  startAutoRotate(): void {
    this.stopAutoRotate()

    this.autoRotateTimer = setInterval(() => {
      this.rotationY += 0.01  // 每帧旋转0.01弧度
      this.updateCameraPosition()
    }, 16)  // 约60fps
  }

  /**
   * 停止自动旋转
   */
  stopAutoRotate(): void {
    if (this.autoRotateTimer !== -1) {
      clearInterval(this.autoRotateTimer)
      this.autoRotateTimer = -1
    }
  }

  /**
   * 更新相机位置
   */
  updateCameraPosition(): void {
    if (!this.camera) return

    const x = Math.sin(this.rotationY) * Math.cos(this.rotationX) * this.cameraDistance
    const y = Math.sin(this.rotationX) * this.cameraDistance
    const z = Math.cos(this.rotationY) * Math.cos(this.rotationX) * this.cameraDistance

    this.camera.position.x = x
    this.camera.position.y = y
    this.camera.position.z = z
  }

  /**
   * 重置相机视角
   */
  resetCamera(): void {
    this.rotationY = 0
    this.rotationX = 0
    this.cameraDistance = 3
    this.updateCameraPosition()

    if (!this.autoRotate) {
      this.autoRotate = true
      this.startAutoRotate()
    }
  }

  /**
   * 处理触控事件
   */
  handleTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.stopAutoRotate()
      this.autoRotate = false

      if (event.touches.length === 1) {
        this.lastTouchX = event.touches[0].x
        this.lastTouchY = event.touches[0].y
      } else if (event.touches.length === 2) {
        this.lastPinchDistance = this.getTouchDistance(event.touches)
      }
    } else if (event.type === TouchType.Move) {
      if (event.touches.length === 1) {
        // 单指拖动 = 旋转
        const deltaX = event.touches[0].x - this.lastTouchX
        const deltaY = event.touches[0].y - this.lastTouchY

        this.rotationY += deltaX * 0.01
        this.rotationX += deltaY * 0.01

        // 限制垂直旋转角度(-80° to 80°)
        this.rotationX = Math.max(-1.4, Math.min(1.4, this.rotationX))

        this.updateCameraPosition()

        this.lastTouchX = event.touches[0].x
        this.lastTouchY = event.touches[0].y

      } else if (event.touches.length === 2) {
        // 双指捏合 = 缩放
        const distance = this.getTouchDistance(event.touches)
        const scale = distance / this.lastPinchDistance

        this.cameraDistance *= (1 / scale)

        // 限制缩放范围(1.5 to 10)
        this.cameraDistance = Math.max(1.5, Math.min(10, this.cameraDistance))

        this.updateCameraPosition()

        this.lastPinchDistance = distance
      }
    }
  }

  /**
   * 计算两个触点之间的距离
   */
  getTouchDistance(touches: TouchObject[]): number {
    if (touches.length < 2) return 0

    const dx = touches[0].x - touches[1].x
    const dy = touches[0].y - touches[1].y

    return Math.sqrt(dx * dx + dy * dy)
  }

  build() {
    Stack() {
      if (this.isLoading) {
        // 加载状态
        this.LoadingView()
      } else if (this.loadError) {
        // 错误状态
        this.ErrorView()
      } else if (this.sceneOpt && this.is3DSupported) {
        // 3D视图 - 仅在支持3D的设备上渲染
        Component3D(this.sceneOpt)
          .width('100%')
          .height('100%')
          .onTouch((event: TouchEvent) => this.handleTouch(event))

        // 控制UI浮层
        this.ControlOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
  }

  /**
   * 加载视图
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.GOLD_PRIMARY)

      Text('正在加载3D模型...')
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 错误视图
   */
  @Builder
  ErrorView() {
    Column() {
      Image($r('app.media.icon_close'))
        .width(48)
        .height(48)
        .fillColor(ThemeColors.ERROR)

      Text(this.loadError)
        .fontSize(FontSizes.BODY)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: Spacing.MEDIUM })

      Text('点击返回2D视图')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: Spacing.SMALL })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 控制UI浮层
   * 注意：顶部区域留空，避免与页面导航栏重叠
   */
  @Builder
  ControlOverlay() {
    Column() {
      // 顶部留空区域（避免与页面导航栏重叠）
      Blank()

      // 底部控制区域
      Column() {
        // 控制按钮行
        Row() {
          // 自动旋转开关
          Row() {
            Image(this.autoRotate ? $r('app.media.icon_pause') : $r('app.media.icon_play'))
              .width(20)
              .height(20)
              .fillColor(ThemeColors.TEXT_PRIMARY)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(26,34,51,0.9)')
          .backdropBlur(10)
          .borderRadius(20)
          .onClick(() => {
            this.autoRotate = !this.autoRotate
            if (this.autoRotate) {
              this.startAutoRotate()
            } else {
              this.stopAutoRotate()
            }
          })

          Blank()

          // 重置视角
          Row() {
            Image($r('app.media.icon_3d'))
              .width(20)
              .height(20)
              .fillColor(ThemeColors.TEXT_PRIMARY)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(26,34,51,0.9)')
          .backdropBlur(10)
          .borderRadius(20)
          .onClick(() => this.resetCamera())
        }
        .width('100%')
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, bottom: Spacing.SMALL })

        // 底部提示信息
        Column() {
          if (this.weapon) {
            Text(this.weapon.name.cn)
              .fontSize(FontSizes.SUBTITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_TITLE)
          }

          Text('单指拖动旋转 | 双指缩放')
            .fontSize(FontSizes.CAPTION)
            .fontColor(ThemeColors.TEXT_TERTIARY)
            .margin({ top: Spacing.TINY })
        }
        .width('100%')
        .padding(Spacing.MEDIUM)
      }
      .width('100%')
      .backgroundColor('rgba(26,34,51,0.85)')
      .backdropBlur(20)
      .borderRadius({ topLeft: Spacing.LARGE, topRight: Spacing.LARGE })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
  }
}
