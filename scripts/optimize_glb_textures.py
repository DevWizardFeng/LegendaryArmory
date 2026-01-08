#!/usr/bin/env python3
"""
优化GLB模型 - 降低纹理分辨率
将4K纹理降至1K (1024x1024)
"""
import bpy
import os
import sys
from pathlib import Path

def optimize_glb(input_path: str, output_path: str, texture_size: int = 1024):
    """
    优化GLB文件 - 降低纹理分辨率
    """
    try:
        # 清空场景
        bpy.ops.wm.read_homefile(use_empty=True)
        
        # 导入GLB
        bpy.ops.import_scene.gltf(filepath=input_path)
        
        # 降低所有图片分辨率
        for img in bpy.data.images:
            if img.size[0] > texture_size or img.size[1] > texture_size:
                img.scale(texture_size, texture_size)
        
        # 导出优化后的GLB
        bpy.ops.export_scene.gltf(
            filepath=output_path,
            export_format='GLB',
            export_image_format='JPEG',  # 使用JPEG压缩
            export_jpeg_quality=85       # 85%质量
        )
        
        return True
    except Exception as e:
        print(f"优化失败: {e}")
        return False

if __name__ == "__main__":
    models_dir = Path("entry/src/main/resources/rawfile/models")
    
    for glb_file in models_dir.glob("*.glb"):
        print(f"优化 {glb_file.name}...")
        temp_output = glb_file.with_suffix('.optimized.glb')
        
        if optimize_glb(str(glb_file), str(temp_output)):
            # 替换原文件
            glb_file.unlink()
            temp_output.rename(glb_file)
            print(f"✓ {glb_file.name} 已优化")

