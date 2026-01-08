/**
 * 神兵图录 - 3D武器查看器组件
 * 使用 HarmonyOS ArkGraphics 3D 引擎
 * 支持触控旋转、双指缩放、自动旋转
 * 注意：仅支持真机，模拟器不支持3D渲染
 */

import {
  Scene, Camera, Light, LightType,
  SceneResourceFactory
} from '@kit.ArkGraphics3D'
import { deviceInfo } from '@kit.BasicServicesKit'
import { ThemeColors, FontSizes, Spacing } from '../common/Theme'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

// SceneOptions和ModelType需要通过类型定义
interface SceneOptions {
  scene: Scene
  modelType?: number  // 0=TEXTURE, 1=SURFACE
}

@Component
export struct Weapon3DViewer {
  @Prop weaponId: string = ''
  @Prop weapon: LegendaryWeapon | null = null
  @State sceneOpt: SceneOptions | null = null
  @State isLoading: boolean = true
  @State loadError: string = ''
  @State autoRotate: boolean = true
  @State isEmulator: boolean = false  // 是否是模拟器

  private scene: Scene | null = null
  private camera: Camera | null = null
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
      // 首先检测是否是模拟器
      if (this.checkIsEmulator()) {
        console.warn('[Weapon3DViewer] 检测到模拟器环境，3D功能不可用')
        this.isEmulator = true
        this.loadError = '3D预览仅支持真机设备，模拟器暂不支持'
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
   * 检测是否是模拟器环境
   * 通过设备信息判断
   */
  private checkIsEmulator(): boolean {
    try {
      // 检查设备类型和品牌
      const brand = deviceInfo.brand || ''
      const manufacturer = deviceInfo.manufacture || ''
      const productModel = deviceInfo.productModel || ''
      const marketName = deviceInfo.marketName || ''

      console.info(`[Weapon3DViewer] 设备信息: brand=${brand}, manufacturer=${manufacturer}, model=${productModel}, marketName=${marketName}`)

      // 模拟器的特征：brand/manufacturer 通常为空或包含 emulator/default 等关键词
      const emulatorKeywords = ['emulator', 'simulator', 'default', 'generic', 'unknown']

      const brandLower = brand.toLowerCase()
      const manufacturerLower = manufacturer.toLowerCase()
      const modelLower = productModel.toLowerCase()

      for (const keyword of emulatorKeywords) {
        if (brandLower.includes(keyword) ||
            manufacturerLower.includes(keyword) ||
            modelLower.includes(keyword)) {
          return true
        }
      }

      // 如果brand和manufacturer都为空，也可能是模拟器
      if (!brand && !manufacturer) {
        console.warn('[Weapon3DViewer] 设备品牌和厂商信息为空，可能是模拟器')
        return true
      }

      return false
    } catch (error) {
      console.error('[Weapon3DViewer] 设备检测失败:', error)
      // 检测失败时默认假设是真机
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
   * 加载3D模型
   */
  async load3DModel(): Promise<void> {
    try {
      this.isLoading = true

      // 1. 加载GLB模型
      const modelPath = `models/${this.weaponId}.glb`
      console.info(`[Weapon3DViewer] 加载模型路径: ${modelPath}`)

      try {
        this.scene = await Scene.load($rawfile(modelPath))
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
      const rf: SceneResourceFactory = this.scene.getResourceFactory()
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

      // 7. 配置场景选项
      this.sceneOpt = {
        scene: this.scene,
        modelType: 1  // 1 = SURFACE (专有硬件合成)
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
  async setupCamera(rf: SceneResourceFactory): Promise<void> {
    this.camera = await rf.createCamera({ name: "MainCamera" })

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
  async setupLighting(rf: SceneResourceFactory): Promise<void> {
    // 主光(Key Light) - 暖色调平行光
    const keyLight: Light = await rf.createLight(
      { name: "KeyLight" },
      LightType.DIRECTIONAL
    )
    keyLight.color = { r: 1.0, g: 0.95, b: 0.9, a: 1.0 }
    keyLight.intensity = 1.2
    keyLight.position = { x: 5, y: 10, z: 5 }
    keyLight.enabled = true

    // 补光(Fill Light) - 冷色调柔和光
    const fillLight: Light = await rf.createLight(
      { name: "FillLight" },
      LightType.DIRECTIONAL
    )
    fillLight.color = { r: 0.8, g: 0.85, b: 1.0, a: 1.0 }
    fillLight.intensity = 0.5
    fillLight.position = { x: -5, y: 5, z: 5 }
    fillLight.enabled = true

    // 轮廓光(Rim Light) - 白色边缘光
    const rimLight: Light = await rf.createLight(
      { name: "RimLight" },
      LightType.DIRECTIONAL
    )
    rimLight.color = { r: 1.0, g: 1.0, b: 1.0, a: 1.0 }
    rimLight.intensity = 0.8
    rimLight.position = { x: 0, y: 5, z: -10 }
    rimLight.enabled = true
  }

  /**
   * 配置材质增强
   * 注意：当前HarmonyOS API不支持动态材质修改，此功能暂时简化
   */
  async setupMaterials(rf: SceneResourceFactory): Promise<void> {
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
    const idleAnim = this.scene.animations[0]
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
      } else if (this.sceneOpt) {
        // 3D视图
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
   */
  @Builder
  ControlOverlay() {
    Column() {
      // 顶部工具栏
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
        .backgroundColor('rgba(26,34,51,0.8)')
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
          Image($r('app.media.icon_back'))  // 临时使用back图标代替reset
            .width(20)
            .height(20)
            .fillColor(ThemeColors.TEXT_PRIMARY)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(26,34,51,0.8)')
        .backdropBlur(10)
        .borderRadius(20)
        .onClick(() => this.resetCamera())
      }
      .width('100%')
      .padding(Spacing.LARGE)

      Blank()

      // 底部提示信息
      Column() {
        if (this.weapon) {
          Text(this.weapon.name.cn)
            .fontSize(FontSizes.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_TITLE)
        }

        Text('👆 拖动旋转  👌 双指缩放')
          .fontSize(FontSizes.CAPTION)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: Spacing.TINY })
      }
      .width('100%')
      .padding(Spacing.LARGE)
      .backgroundColor('rgba(26,34,51,0.8)')
      .backdropBlur(20)
      .borderRadius({ topLeft: Spacing.LARGE, topRight: Spacing.LARGE })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
