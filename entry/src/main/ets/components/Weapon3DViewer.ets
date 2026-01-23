/**
 * 神兵图录 - 3D武器查看器组件
 * 使用 HarmonyOS ArkGraphics 3D 引擎
 * 支持触控旋转、双指缩放、自动旋转
 * 注意：仅支持真机，模拟器不支持3D渲染（ArkGraphics3D Kit不支持模拟器）
 */

import { Scene, Camera, Light, LightType, SceneResourceFactory, Vec3, Quaternion } from '@kit.ArkGraphics3D'
import { deviceInfo } from '@kit.BasicServicesKit'
import { ThemeColors, FontSizes, Spacing } from '../common/Theme'
import { LegendaryWeapon } from '../model/LegendaryWeapon'

@Component
export struct Weapon3DViewer {
  @Prop weaponId: string = ''
  @Prop weapon: LegendaryWeapon | null = null
  @State sceneOpt: SceneOptions | null = null
  @State isLoading: boolean = true
  @State loadError: string = ''
  @State autoRotate: boolean = true
  @State is3DSupported: boolean = false
  // 加载失败回调，用于通知父组件切换回2D视图
  onLoadError: () => void = () => {}

  private scene: Scene | null = null
  private camera: Camera | null = null
  private autoRotateTimer: number = -1

  // 相机控制参数
  // 注意：当前模型是水平平面(Y=0)，需要从上方俯视才能看到
  private rotationY: number = 0
  private rotationX: number = 1.5  // 约86度俯视角，接近垂直向下看
  private cameraDistance: number = 3  // 拉近距离
  private lastTouchX: number = 0
  private lastTouchY: number = 0
  private lastPinchDistance: number = 0

  aboutToAppear(): void {
    // 检测系统是否支持3D功能
    if (!this.check3DSupport()) {
      console.warn('[Weapon3DViewer] 当前设备不支持3D功能')
      this.is3DSupported = false
      this.loadError = '3D预览仅支持真机设备'
      this.isLoading = false
      this.onLoadError()
      return
    }

    // 检查模型是否存在
    if (!Weapon3DViewer.hasModel(this.weaponId)) {
      console.warn(`[Weapon3DViewer] 武器 ${this.weaponId} 暂无3D模型`)
      this.is3DSupported = false
      this.loadError = '该神兵暂无3D模型'
      this.isLoading = false
      this.onLoadError()
      return
    }

    this.is3DSupported = true
    console.info(`[Weapon3DViewer] 开始加载3D��型: ${this.weaponId}`)
    this.load3DModel()
  }

  aboutToDisappear(): void {
    this.stopAutoRotate()
    this.scene = null
  }

  /**
   * 检测系统是否支持3D功能
   */
  private check3DSupport(): boolean {
    try {
      const hasGraphics3D = canIUse('SystemCapability.ArkUi.Graphics3D')
      console.info(`[Weapon3DViewer] SystemCapability.ArkUi.Graphics3D: ${hasGraphics3D}`)

      if (!hasGraphics3D) {
        return false
      }

      // 检查是否为模拟器
      const brand = deviceInfo.brand || ''
      const productModel = deviceInfo.productModel || ''
      console.info(`[Weapon3DViewer] 设备信息: brand=${brand}, model=${productModel}`)

      const emulatorKeywords = ['emulator', 'simulator', 'sdk', 'genymotion']
      const brandLower = brand.toLowerCase()
      const modelLower = productModel.toLowerCase()

      for (const keyword of emulatorKeywords) {
        if (brandLower.includes(keyword) || modelLower.includes(keyword)) {
          console.warn(`[Weapon3DViewer] 检测到模拟器: ${keyword}`)
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
   * 获取模型文件路径
   */
  /**
   * 检查武器是否有可用的3D模型
   */
  static hasModel(weaponId: string): boolean {
    // 只包含实际存在的模型文件（截至当前共14个）
    const availableModels = [
      'xuanyuan_sword', 'zhanlu_sword', 'chixiao_sword', 'ganjiang_sword', 'moye_sword',
      'qinglong_yanyue_dao', 'kusanagi', 'mikazuki_munechika', 'muramasa', 'honjo_masamune',
      'mjolnir', 'gungnir', 'tyrfing', 'gram'
    ]
    return availableModels.includes(weaponId)
  }

  private getModelPath(): string {
    // 武器ID到模型文件名的映射表（只包含实际存在的模型）
    const modelMapping: Record<string, string> = {
      'xuanyuan_sword': 'xuanyuan',
      'zhanlu_sword': 'zhanlu',
      'chixiao_sword': 'chixiao',
      'ganjiang_sword': 'ganjiang',
      'moye_sword': 'moye',
      'qinglong_yanyue_dao': 'qinglong',
      'kusanagi': 'kusanagi',
      'mikazuki_munechika': 'mikazuki',
      'muramasa': 'muramasa',
      'honjo_masamune': 'honjo_masamune',
      'mjolnir': 'mjolnir',
      'gungnir': 'gungnir',
      'tyrfing': 'tyrfing',
      'gram': 'gram'
    }

    let modelName = modelMapping[this.weaponId]
    if (!modelName) {
      // 智能转换：去掉常见后缀
      modelName = this.weaponId
      const suffixes = ['_sword', '_blade', '_dao', '_spear', '_hammer', '_axe', '_bow', '_staff']
      for (const suffix of suffixes) {
        if (modelName.endsWith(suffix)) {
          modelName = modelName.slice(0, -suffix.length)
          break
        }
      }
    }

    return `models/${modelName}.glb`
  }

  /**
   * 加载3D模型
   */
  private load3DModel(): void {
    const modelPath = this.getModelPath()
    console.info(`[Weapon3DViewer] 加载模型: ${modelPath}`)

    Scene.load($rawfile(modelPath))
      .then(async (result: Scene) => {
        this.scene = result
        console.info('[Weapon3DViewer] 场景加载成功')

        // 获取资源工厂并配置相机和光照
        const rf: SceneResourceFactory = this.scene.getResourceFactory()

        // 创建相机
        this.camera = await rf.createCamera({ name: "MainCamera" })
        this.camera.enabled = true
        this.camera.fov = 60 * Math.PI / 180
        this.camera.nearPlane = 0.1
        this.camera.farPlane = 100

        // 设置初始相机位置和朝向
        const initialX = Math.sin(this.rotationY) * Math.cos(this.rotationX) * this.cameraDistance
        const initialY = Math.sin(this.rotationX) * this.cameraDistance + 1
        const initialZ = Math.cos(this.rotationY) * Math.cos(this.rotationX) * this.cameraDistance
        this.camera.position = { x: initialX, y: initialY, z: initialZ }

        // 设置相机朝向（看向原点）
        const eye: Vec3 = { x: initialX, y: initialY, z: initialZ }
        const center: Vec3 = { x: 0, y: 0, z: 0 }
        const up: Vec3 = { x: 0, y: 1, z: 0 }
        this.camera.rotation = this.calculateLookAtRotation(eye, center, up)
        console.info('[Weapon3DViewer] 相机配置成功')

        // 创建光照
        try {
          // 主光（平行光）- 通过rotation设置方向
          const keyLight: Light = await rf.createLight({ name: "KeyLight" }, LightType.DIRECTIONAL)
          keyLight.color = { r: 1.0, g: 0.95, b: 0.9, a: 1.0 }
          keyLight.intensity = 1.5
          keyLight.enabled = true
          // 设置光照方向（从右上前方照射）
          const lightDir: Vec3 = { x: -1, y: -1, z: -1 }
          const lightUp: Vec3 = { x: 0, y: 1, z: 0 }
          keyLight.rotation = this.calculateLightRotation(lightDir, lightUp)

          // 补光（平行光）
          const fillLight: Light = await rf.createLight({ name: "FillLight" }, LightType.DIRECTIONAL)
          fillLight.color = { r: 0.8, g: 0.85, b: 1.0, a: 1.0 }
          fillLight.intensity = 0.6
          fillLight.enabled = true
          // 设置补光方向（从左下方照射）
          const fillDir: Vec3 = { x: 1, y: -0.5, z: 1 }
          fillLight.rotation = this.calculateLightRotation(fillDir, lightUp)

          console.info('[Weapon3DViewer] 光照配置成功')
        } catch (lightError) {
          console.warn('[Weapon3DViewer] 光照配置失败，使用默认光照:', lightError)
        }

        // 配置场景选项
        this.sceneOpt = {
          scene: this.scene,
          modelType: ModelType.SURFACE
        } as SceneOptions

        this.isLoading = false

        // 启动自动旋转
        if (this.autoRotate) {
          this.startAutoRotate()
        }

        console.info(`[Weapon3DViewer] 模型加载完成: ${this.weaponId}`)
      })
      .catch((error: Error) => {
        console.error(`[Weapon3DViewer] 模型加载失败: ${error.message}`)
        this.loadError = `无法加载模型: ${modelPath}`
        this.isLoading = false

        // 自动调用错误回调，通知父组件切换回2D视图
        if (this.onLoadError) {
          console.info('[Weapon3DViewer] 调用 onLoadError 回调')
          this.onLoadError()
        }
      })
  }

  /**
   * 计算光照方向的旋转四元数
   * 平行光的方向由其rotation决定，默认朝向-Z轴
   */
  private calculateLightRotation(direction: Vec3, up: Vec3): Quaternion {
    // 归一化方向向量
    const dir = this.normalize(direction)
    // 计算从默认方向(0,0,-1)到目标方向的旋转
    const defaultDir: Vec3 = { x: 0, y: 0, z: -1 }

    // 使用叉积和点积计算旋转
    const dot = this.dot(defaultDir, dir)
    if (dot > 0.9999) {
      // 方向相同，返回单位四元数
      return { x: 0, y: 0, z: 0, w: 1 }
    }
    if (dot < -0.9999) {
      // 方向相反，绕Y轴旋转180度
      return { x: 0, y: 1, z: 0, w: 0 }
    }

    const cross = this.cross(defaultDir, dir)
    const w = Math.sqrt(1 + dot)
    const scale = 1 / (2 * w)
    return {
      x: cross.x * scale,
      y: cross.y * scale,
      z: cross.z * scale,
      w: w / 2
    }
  }

  /**
   * 开始自动旋转
   */
  private startAutoRotate(): void {
    this.stopAutoRotate()
    this.autoRotateTimer = setInterval(() => {
      this.rotationY += 0.01
      this.updateCameraPosition()
    }, 16)
  }

  /**
   * 停止自动旋转
   */
  private stopAutoRotate(): void {
    if (this.autoRotateTimer !== -1) {
      clearInterval(this.autoRotateTimer)
      this.autoRotateTimer = -1
    }
  }

  /**
   * 更新相机位置和朝向
   */
  private updateCameraPosition(): void {
    if (!this.camera) return

    const x = Math.sin(this.rotationY) * Math.cos(this.rotationX) * this.cameraDistance
    const y = Math.sin(this.rotationX) * this.cameraDistance + 1
    const z = Math.cos(this.rotationY) * Math.cos(this.rotationX) * this.cameraDistance

    // 设置相机位置
    this.camera.position.x = x
    this.camera.position.y = y
    this.camera.position.z = z

    // 设置相机朝向（看向原点）
    const eye: Vec3 = { x: x, y: y, z: z }
    const center: Vec3 = { x: 0, y: 0, z: 0 }
    const up: Vec3 = { x: 0, y: 1, z: 0 }
    this.camera.rotation = this.calculateLookAtRotation(eye, center, up)
  }

  /**
   * 计算 lookAt 旋转四元数
   * 根据相机位置、目标点和上方向计算相机的旋转
   */
  private calculateLookAtRotation(eye: Vec3, center: Vec3, up: Vec3): Quaternion {
    // 计算前向向量（从相机指向目标）
    const f = this.normalize(this.sub(center, eye))
    // 计算右向量
    const m0 = this.normalize(this.cross(f, up))
    // 计算真正的上向量
    const m1 = this.cross(m0, f)
    // 反转前向向量（相机看向-Z方向）
    const m2: Vec3 = { x: -f.x, y: -f.y, z: -f.z }

    let t: number
    let q: Quaternion = { x: 0, y: 0, z: 0, w: 1 }

    if (m2.z < 0) {
      if (m0.x > m1.y) {
        t = 1.0 + m0.x - m1.y - m2.z
        q = { x: t, y: m0.y + m1.x, z: m2.x + m0.z, w: m1.z - m2.y }
      } else {
        t = 1.0 - m0.x + m1.y - m2.z
        q = { x: m0.y + m1.x, y: t, z: m1.z + m2.y, w: m2.x - m0.z }
      }
    } else {
      if (m0.x < -m1.y) {
        t = 1.0 - m0.x - m1.y + m2.z
        q = { x: m2.x + m0.z, y: m1.z + m2.y, z: t, w: m0.y - m1.x }
      } else {
        t = 1.0 + m0.x + m1.y + m2.z
        q = { x: m1.z - m2.y, y: m2.x - m0.z, z: m0.y - m1.x, w: t }
      }
    }

    // 归一化四元数
    const scale = 0.5 / Math.sqrt(t)
    return { x: q.x * scale, y: q.y * scale, z: q.z * scale, w: q.w * scale }
  }

  /**
   * 向量减法
   */
  private sub(l: Vec3, r: Vec3): Vec3 {
    return { x: l.x - r.x, y: l.y - r.y, z: l.z - r.z }
  }

  /**
   * 向量点积
   */
  private dot(l: Vec3, r: Vec3): number {
    return l.x * r.x + l.y * r.y + l.z * r.z
  }

  /**
   * 向量归一化
   */
  private normalize(l: Vec3): Vec3 {
    const d = Math.sqrt(this.dot(l, l))
    if (d === 0) return { x: 0, y: 0, z: 1 }
    return { x: l.x / d, y: l.y / d, z: l.z / d }
  }

  /**
   * 向量叉积
   */
  private cross(l: Vec3, r: Vec3): Vec3 {
    return {
      x: l.y * r.z - l.z * r.y,
      y: l.z * r.x - l.x * r.z,
      z: l.x * r.y - l.y * r.x
    }
  }

  /**
   * 重置相机视角
   */
  private resetCamera(): void {
    this.rotationY = 0
    this.rotationX = 1.5  // 俯视角度
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
  private handleTouch(event: TouchEvent): void {
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
        const deltaX = event.touches[0].x - this.lastTouchX
        const deltaY = event.touches[0].y - this.lastTouchY

        this.rotationY += deltaX * 0.01
        this.rotationX += deltaY * 0.01
        this.rotationX = Math.max(-1.4, Math.min(1.4, this.rotationX))

        this.updateCameraPosition()

        this.lastTouchX = event.touches[0].x
        this.lastTouchY = event.touches[0].y
      } else if (event.touches.length === 2) {
        const distance = this.getTouchDistance(event.touches)
        const scale = distance / this.lastPinchDistance

        this.cameraDistance *= (1 / scale)
        this.cameraDistance = Math.max(2, Math.min(15, this.cameraDistance))

        this.updateCameraPosition()
        this.lastPinchDistance = distance
      }
    }
  }

  /**
   * 计算两个触点之间的距离
   */
  private getTouchDistance(touches: TouchObject[]): number {
    if (touches.length < 2) return 0
    const dx = touches[0].x - touches[1].x
    const dy = touches[0].y - touches[1].y
    return Math.sqrt(dx * dx + dy * dy)
  }

  build() {
    Stack() {
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.loadError) {
        this.ErrorView()
      } else if (this.sceneOpt && this.is3DSupported) {
        Component3D(this.sceneOpt)
          .width('100%')
          .height('100%')
          .onTouch((event: TouchEvent) => this.handleTouch(event))

        this.ControlOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BASE_0)
  }

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
        .textAlign(TextAlign.Center)
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE })

      Text('点击返回2D视图')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(ThemeColors.GOLD_PRIMARY)
        .margin({ top: Spacing.MEDIUM })
        .padding({ left: Spacing.LARGE, right: Spacing.LARGE, top: Spacing.SMALL, bottom: Spacing.SMALL })
        .backgroundColor(ThemeColors.SURFACE_0)
        .borderRadius(Spacing.MEDIUM)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onLoadError()
    })
  }

  @Builder
  ControlOverlay() {
    Column() {
      Blank()

      Column() {
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
