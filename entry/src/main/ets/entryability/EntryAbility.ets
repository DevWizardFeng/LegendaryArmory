/**
 * 神兵图录 - 应用入口 Ability
 * 应用启动入口，管理应用生命周期
 */
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  /**
   * 应用创建时回调
   * @param want 启动参数
   * @param launchParam 启动模式
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'LegendaryArmory', '%{public}s', 'Ability onCreate');
  }

  /**
   * 应用销毁时回调
   */
  onDestroy(): void {
    hilog.info(0x0000, 'LegendaryArmory', '%{public}s', 'Ability onDestroy');
  }

  /**
   * 窗口创建时回调
   * @param windowStage 窗口管理器
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'LegendaryArmory', '%{public}s', 'Ability onWindowStageCreate');

    // 加载首页
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'LegendaryArmory', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'LegendaryArmory', 'Succeeded in loading the content.');
    });
  }

  /**
   * 窗口销毁时回调
   */
  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'LegendaryArmory', '%{public}s', 'Ability onWindowStageDestroy');
  }

  /**
   * 应用进入前台时回调
   */
  onForeground(): void {
    hilog.info(0x0000, 'LegendaryArmory', '%{public}s', 'Ability onForeground');
  }

  /**
   * 应用进入后台时回调
   */
  onBackground(): void {
    hilog.info(0x0000, 'LegendaryArmory', '%{public}s', 'Ability onBackground');
  }
}
