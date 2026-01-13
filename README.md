# 神兵图录 - 传说兵器图鉴 App

一款聚焦全球传说兵器的图鉴类工具 App，提供神兵浏览、铸造传说、战斗模拟、AI 生成专属神兵等功能。

## 项目概述

- **产品名称**: 神兵图录 (Legendary Armory)
- **产品类型**: 兵器图鉴 + AI 生成器 + 知识百科
- **目标平台**: 鸿蒙 HarmonyOS
- **技术架构**: 纯前端，无后端依赖
- **当前版本**: v1.1.0
- **开发状态**: 初始阶段

## 核心功能

### 已规划模块

- ⚔️ **神兵图鉴**: 60+ 传说兵器，涵盖中国、日本、欧洲、北欧、印度等多文化
- 🔨 **铸造大师**: 20+ 传奇铸造师传记，了解神兵背后的工匠
- 📚 **兵器百科**: 属性元素、文化体系、技能词典
- 🎯 **挑战答题**: 4种模式、成就系统、排行榜
- 🎲 **互动娱乐**: 每日占卜、属性测试、对战模拟
- 🛠️ **AI锻造器**: 自定义生成专属神兵（AI生成 + 手动拼接）
- 📖 **专题故事**: 深度解析兵器文化与铸造技艺

## 技术方案

### 开发约束

**重要提示**: 在编写任何代码之前，你必须查阅 `harmonyos_docs/文档索引.md`！

- ✅ 纯前端架构，无后端服务
- ✅ 数据存储：本地 JSON 文件
- ✅ 用户数据：LocalStorage / Preferences
- ✅ 图片管理：**所有图片必须放在 `entry/src/main/resources/base/media/` 目录，不允许文件夹嵌套**
- ✅ 图标处理：**不使用 emoji，所有图标必须使用 SVG 文件存储在 `base/media/`**
- ✅ AI 生图：豆包 Doubao-Seedream-4.5（4K超高清）
- ✅ 编译检查：**每完成一个功能，必须运行 `hvigorw assembleHap` 确保编译无错误**

### AI 生图方案

使用豆包 AI（Doubao-Seedream-4.5）生成所有图片素材：

- **神兵图片**: 每个类目至少 20 张，4K 超高清
- **铸造师图片**: 20+ 张铸造场景
- **背景图片**: 9 张沉浸式背景（深色金属质感）
- **图标资源**: SVG 格式（属性、文化、品质等）

#### 生图脚本

参考 `example.py` 创建生图脚本，注意：
- `baseURL` 不可改变
- `apikey` 不可改变
- 请求模型固定为 `doubao-seedream-4-5-251128`

提示词模板示例：
```
中国传说神剑轩辕剑，金龙缠绕剑身，火焰雷电双属性特效，红金配色，
剑身铭刻日月星辰，龙首护手，黄金剑柄，神器级武器设计，
电影级光影，4K超高清，oc渲染，光线追踪，景深，超现实主义，
金属质感真实，暗黑风背景的光影效果营造出氛围，史诗感
```

### API 集成（锻造器功能）

```bash
curl -X POST https://ark.cn-beijing.volces.com/api/v3/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ARK_API_KEY" \
  -d '{
    "model": "doubao-seedream-4-5-251128",
    "prompt": "中国传说神剑，金龙缠绕剑身，火焰特效...",
    "sequential_image_generation": "disabled",
    "response_format": "url",
    "size": "2K",
    "stream": false,
    "watermark": true
  }'
```

## 项目结构

```
entry/src/main/
├── ets/
│   ├── pages/              # 页面
│   ├── components/         # 组件
│   ├── model/              # 数据模型
│   ├── utils/              # 工具类
│   └── common/             # 公共配置
│
└── resources/
    └── rawfile/
        ├── data/           # JSON 数据文件
        ├── images/         # AI 生成图片（不允许嵌套！）
        ├── svg/            # 手动拼接素材
        └── prompts/        # AI 提示词模板
```

**图片存储规范**（重要！）：
```
resources/base/media/
├── weapon_xuanyuan.png       # 神兵图片
├── weapon_kusanagi.png
├── weapon_excalibur.png
├── blacksmith_ouye.png       # 铸造师图片
├── blacksmith_ganjiang.png
├── bg_weapon_detail.png      # 背景图片
├── bg_culture_detail.png
├── icon_fire.svg             # 属性图标（SVG）
├── icon_ice.svg
└── ...                       # 所有图片平铺，不嵌套！
```

## 开发流程

### 1. 环境准备
```bash
# 查阅开发文档
cat harmonyos_docs/文档索引.md

# 初始化项目（如果尚未初始化）
# 按照鸿蒙开发规范创建项目
```

### 2. 数据准备

查看 `神兵图录-PRD.md` 第七章，准备以下数据：

- [ ] 神兵数据 (weapons.json) - 60-80 条
- [ ] 铸造师数据 (blacksmiths.json) - 20 条
- [ ] 技能数据 (abilities.json) - 50+ 条
- [ ] 属性数据 (attributes.json) - 7 条
- [ ] 文化数据 (cultures.json) - 7 条
- [ ] 题目数据 (questions.json) - 100+ 条

### 3. 图片生成

使用 AI 生图脚本（基于 example.py 改造）：

```bash
# 创建生图脚本
python scripts/generate_weapons.py    # 生成神兵图片
python scripts/generate_blacksmiths.py # 生成铸造师图片
python scripts/generate_backgrounds.py # 生成背景图片

# 所有生成的图片移动到 base/media/
mv output/*.png entry/src/main/resources/base/media/
```

**确保每个类目至少 20 张图片！**

### 4. 开发阶段

按 PRD 第六章开发计划执行：

#### Phase 1 - MVP (2-3周)
- [ ] 项目初始化
- [ ] 首页布局 + 轮播
- [ ] 神兵列表页
- [ ] 神兵详情页
- [ ] 搜索功能
- [ ] 收藏功能

#### Phase 2 - 完善 (2周)
- [ ] 兵器百科
- [ ] 铸造师图鉴
- [ ] 分类筛选
- [ ] 浏览历史
- [ ] 专题文章

#### Phase 3 - 挑战答题 (1-2周)
- [ ] 答题系统
- [ ] 成就系统
- [ ] 排行榜

#### Phase 4 - 锻造器 (2-3周)
- [ ] AI 锻造器 UI
- [ ] 豆包 API 集成
- [ ] 手动拼接方案

#### Phase 5 - 互动娱乐 (1周)
- [ ] 每日占卜
- [ ] 对战模拟
- [ ] 属性测试

### 5. 编译验证

**每完成一个功能模块，必须执行：**

```bash
# 编译项目
hvigorw assembleHap

# 必须确保编译成功，无任何错误！
# 如有错误，立即修复后再继续开发
```

### 6. 测试与发布

- [ ] 功能测试
- [ ] 性能优化
- [ ] 用户体验优化
- [ ] 准备应用商店素材
- [ ] 提交华为应用市场

## 数据格式示例

### 神兵数据 (weapons.json)

```json
{
  "id": "xuanyuan_sword",
  "name": {
    "original": "轩辕剑",
    "cn": "轩辕剑",
    "en": "Xuanyuan Sword"
  },
  "culture": "chinese",
  "type": "sword",
  "attributes": {
    "primary": "fire",
    "secondary": "thunder"
  },
  "rarity": "artifact",
  "stats": {
    "attack": 95,
    "defense": 80,
    "speed": 85,
    "weight": 3.2
  },
  "description": "黄帝铸此剑以诛蚩尤，剑身刻有日月星辰，山川草木。",
  "forging_legend": "黄帝采首山之铜，铸剑于荆山之阳...",
  "battle_legend": "涿鹿之战，黄帝持轩辕剑斩蚩尤...",
  "abilities": ["dragon_slash", "thunder_strike", "divine_protection"],
  "symbolism": "中华民族的象征，代表正统与权威",
  "inscription": "日月星辰 山川草木",
  "famous_owners": [
    {
      "name": "黄帝",
      "title": "中华始祖",
      "story": "铸剑诛蚩尤，开创华夏文明"
    }
  ],
  "blacksmith_id": "legend_huangdi",
  "appearance": {
    "blade_type": "straight_double_edge",
    "guard_type": "dragon_head",
    "handle_type": "golden_wrapped",
    "colors": ["#FFD700", "#FF4500", "#8B0000"],
    "features": ["龙纹缠绕", "火焰特效", "雷电环绕", "日月星辰铭刻"]
  },
  "image": "weapon_xuanyuan.png",
  "related": ["zhanlu_sword", "chunjun_sword"],
  "tags": ["中国", "上古", "神器", "火雷双属性", "黄帝"]
}
```

### 铸造师数据 (blacksmiths.json)

```json
{
  "id": "ouye",
  "name": {
    "original": "欧冶子",
    "cn": "欧冶子",
    "en": "Ou Yezi"
  },
  "culture": "chinese",
  "era": "春秋时期",
  "title": "铸剑鼻祖",
  "description": "春秋时期越国铸剑大师，中国历史上最伟大的铸剑师之一。",
  "legend": "欧冶子铸剑时引天火淬炼，以五金之精铸成神剑...",
  "forging_technique": "引天火淬炼法、五金合炼术",
  "masterworks": ["longyuan_sword", "taie_sword", "gongbu_sword"],
  "specialty": "引天火淬炼，剑成必有异象",
  "image": "blacksmith_ouye.png"
}
```

## 开发注意事项

### 严格遵守的规范
 *** 注释 和对话一定要用中文 ***
1. **文档优先**: 编写代码前必须查阅 `harmonyos_docs/文档索引.md`
2. **语法约束**: 严格按照鸿蒙开发文档的语法规范，不可自己瞎写
3. **图片管理**:
   - 所有图片必须放在 `base/media/`
   - 不允许文件夹嵌套
   - 使用扁平化命名（如 `weapon_xuanyuan.png`）
4. **图标处理**: 不使用 emoji，所有图标用 SVG
5. **编译检查**: 每个功能完成后必须编译验证
6. **离线优先**: 纯单机应用，不使用线上图片
7. **提示词优化**: 生图的效果要保证，优化提示词跟主题切合。
8. **⚠️ 稳定性关键**: `@Builder` 方法中**禁止**使用强制非空断言 `!`，必须用 `if` 条件包裹状态变量访问，否则会导致 Mate 80 Pro 等设备运行时崩溃

### 配色方案

- **主色调**: 深蓝黑渐变 #0a0a1a → #1a1a2e
- **品质色**: 神器-金色 #ffd700 | 传说-紫色 #9d4edd | 史诗-蓝色 #4cc9f0 | 稀有-绿色 #3cb371
- **属性色**: 火-#ff4500 | 冰-#00bfff | 雷-#9370db | 光-#ffd700 | 暗-#2f4f4f | 风-#7fffd4 | 毒-#228b22

### 沉浸式体验

所有详情页背景使用 AI 生成：
- 深色金属纹理为主
- 4K 超高清分辨率
- 无人物、无完整兵器
- 确保文字高对比度可读

## 参考资源

- **需求文档**: `神兵图录-PRD.md`
- **开发文档**: `harmonyos_docs/文档索引.md`
- **生图脚本**: `example.py`

## 联系与反馈

- 项目类型: 个人开发 / 学习项目
- 技术栈: HarmonyOS ArkTS + 豆包 AI
- 开发周期: 预计 8-10 周

---

**最后更新**: 2025年12月27日
**文档版本**: v1.1
**项目状态**: 初始阶段
