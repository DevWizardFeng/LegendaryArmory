#!/usr/bin/env python3
"""
神兵图录 - 3D模型批量生成脚本
使用Blender生成卡片式GLB模型
"""

import bpy
import os
import sys
from pathlib import Path

def create_weapon_card_model(weapon_id: str, image_path: str, output_path: str):
    """
    创建卡片式3D模型
    - 基础Plane网格 + 武器图片纹理
    - 添加透明度支持
    - 配置PBR材质(金属度0.9, 粗糙度0.2)
    - 导出为GLB格式

    Args:
        weapon_id: 武器ID
        image_path: 武器图片路径
        output_path: 输出GLB文件路径
    """
    try:
        # 1. 清空场景
        bpy.ops.wm.read_homefile(use_empty=True)

        # 2. 创建平面网格 (2x2单位)
        bpy.ops.mesh.primitive_plane_add(size=2, location=(0, 0, 0))
        plane = bpy.context.active_object
        plane.name = f"Weapon_{weapon_id}"

        # 3. 创建PBR材质
        mat = bpy.data.materials.new(name=f"Mat_{weapon_id}")
        mat.use_nodes = True
        nodes = mat.node_tree.nodes
        links = mat.node_tree.links

        # 清除默认节点
        nodes.clear()

        # 创建Principled BSDF节点
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs['Metallic'].default_value = 0.9   # 金属度
        bsdf.inputs['Roughness'].default_value = 0.2  # 粗糙度

        # 加载纹理图片
        tex_image = nodes.new(type='ShaderNodeTexImage')
        tex_image.location = (-400, 0)
        tex_image.image = bpy.data.images.load(image_path)
        tex_image.image.colorspace_settings.name = 'sRGB'

        # 连接纹理到Base Color
        links.new(tex_image.outputs['Color'], bsdf.inputs['Base Color'])

        # 连接Alpha通道(支持透明)
        links.new(tex_image.outputs['Alpha'], bsdf.inputs['Alpha'])

        # 材质输出节点
        output = nodes.new(type='ShaderNodeOutputMaterial')
        output.location = (300, 0)
        links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

        # 应用材质到平面
        plane.data.materials.append(mat)

        # 设置材质混合模式(支持透明)
        mat.blend_method = 'BLEND'
        # Note: shadow_method在Blender 5.0中已移除，不再需要设置

        # 4. 添加简单的漂浮动画(可选)
        # 注意：Blender 5.0的动画API已变化，暂时禁用动画生成
        # add_idle_animation(plane)

        # 5. 导出为GLB格式
        # 注意：简化参数以兼容Blender 5.0 API
        bpy.ops.export_scene.gltf(
            filepath=output_path,
            export_format='GLB',
            use_selection=False,
            export_materials='EXPORT',
            export_image_format='AUTO'
        )

        print(f"✅ 成功生成: {output_path}")
        return True

    except Exception as e:
        print(f"❌ 生成失败 {weapon_id}: {str(e)}")
        return False


def add_idle_animation(obj):
    """
    添加待机漂浮动画
    - 上下漂浮: 0.2单位幅度, 4秒循环
    - Y轴旋转: 360度, 8秒循环
    """
    # 清除现有动画
    if obj.animation_data:
        obj.animation_data_clear()

    # 创建动画动作
    action = bpy.data.actions.new(name=f"Idle_{obj.name}")
    obj.animation_data_create()
    obj.animation_data.action = action

    # Z轴漂浮动画 (上下)
    fcurve_z = action.fcurves.new(data_path="location", index=2)

    # 关键帧: 0秒(0), 2秒(0.2), 4秒(0)
    fcurve_z.keyframe_points.insert(frame=1, value=0)
    fcurve_z.keyframe_points.insert(frame=60, value=0.2)  # 2秒@30fps
    fcurve_z.keyframe_points.insert(frame=120, value=0)   # 4秒@30fps

    # Y轴旋转动画 (缓慢旋转)
    fcurve_rot_y = action.fcurves.new(data_path="rotation_euler", index=1)

    # 关键帧: 0秒(0°), 8秒(360°)
    fcurve_rot_y.keyframe_points.insert(frame=1, value=0)
    fcurve_rot_y.keyframe_points.insert(frame=240, value=6.28319)  # 2π弧度 = 360°

    # 设置插值模式为Bezier(平滑)
    for fcurve in action.fcurves:
        for kp in fcurve.keyframe_points:
            kp.interpolation = 'BEZIER'
            kp.handle_left_type = 'AUTO'
            kp.handle_right_type = 'AUTO'

    # 设置循环修改器
    for fcurve in action.fcurves:
        modifier = fcurve.modifiers.new(type='CYCLES')
        modifier.mode_after = 'REPEAT'
        modifier.mode_before = 'REPEAT'


def batch_generate_models(weapons_dir: Path, output_dir: Path, dry_run: bool = False):
    """
    批量生成所有武器的3D模型

    Args:
        weapons_dir: 武器图片目录
        output_dir: 输出GLB文件目录
        dry_run: 是否仅测试不实际生成
    """
    # 确保输出目录存在
    output_dir.mkdir(parents=True, exist_ok=True)

    # 查找所有武器图片
    weapon_images = list(weapons_dir.glob("weapon_*.png"))

    print(f"\n{'='*60}")
    print(f"  神兵图录 - 3D模型批量生成")
    print(f"{'='*60}")
    print(f"输入目录: {weapons_dir}")
    print(f"输出目录: {output_dir}")
    print(f"找到武器图片: {len(weapon_images)} 张")
    print(f"模式: {'🔍 预览模式' if dry_run else '🚀 生成模式'}")
    print(f"{'='*60}\n")

    if dry_run:
        print("预览将要生成的模型:\n")
        for img_file in weapon_images[:10]:  # 只显示前10个
            weapon_id = img_file.stem.replace("weapon_", "")
            output_file = output_dir / f"{weapon_id}.glb"
            print(f"  {weapon_id:30} -> {output_file.name}")

        if len(weapon_images) > 10:
            print(f"  ... 还有 {len(weapon_images) - 10} 个模型")
        print(f"\n提示: 移除 --dry-run 参数开始实际生成")
        return

    # 开始批量生成
    success_count = 0
    failed_count = 0

    for idx, img_file in enumerate(weapon_images, 1):
        weapon_id = img_file.stem.replace("weapon_", "")
        output_file = output_dir / f"{weapon_id}.glb"

        print(f"[{idx}/{len(weapon_images)}] 生成 {weapon_id}...", end=" ")

        # 跳过已存在的文件
        if output_file.exists():
            print("⏭️  已存在，跳过")
            continue

        # 生成模型
        if create_weapon_card_model(weapon_id, str(img_file), str(output_file)):
            success_count += 1
        else:
            failed_count += 1

    # 统计结果
    print(f"\n{'='*60}")
    print(f"  生成完成！")
    print(f"{'='*60}")
    print(f"✅ 成功: {success_count} 个")
    print(f"❌ 失败: {failed_count} 个")
    print(f"📦 总计: {len(list(output_dir.glob('*.glb')))} 个GLB文件")

    # 估算包体积
    total_size = sum(f.stat().st_size for f in output_dir.glob('*.glb'))
    print(f"💾 总大小: {total_size / 1024 / 1024:.2f} MB")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    # 解析命令行参数
    import argparse

    parser = argparse.ArgumentParser(
        description="神兵图录 - 批量生成3D武器模型",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 预览模式(不实际生成)
  blender --background --python scripts/generate_card_3d_models.py -- --dry-run

  # 生成所有模型
  blender --background --python scripts/generate_card_3d_models.py

  # 指定自定义路径
  blender --background --python scripts/generate_card_3d_models.py -- \\
    --input custom/path/images \\
    --output custom/path/models
        """
    )

    parser.add_argument(
        '--input',
        type=str,
        default='entry/src/main/resources/base/media',
        help='武器图片输入目录 (默认: entry/src/main/resources/base/media)'
    )

    parser.add_argument(
        '--output',
        type=str,
        default='entry/src/main/resources/rawfile/models',
        help='GLB模型输出目录 (默认: entry/src/main/resources/rawfile/models)'
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='预览模式：仅显示将要生成的文件，不实际生成'
    )

    # Blender会传递额外的参数，需要过滤
    if '--' in sys.argv:
        args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
    else:
        args = parser.parse_args([])

    # 执行批量生成
    weapons_dir = Path(args.input)
    output_dir = Path(args.output)

    if not weapons_dir.exists():
        print(f"❌ 错误: 输入目录不存在: {weapons_dir}")
        sys.exit(1)

    batch_generate_models(weapons_dir, output_dir, args.dry_run)
