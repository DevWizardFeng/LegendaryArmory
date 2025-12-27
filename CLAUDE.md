# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**神兵图录 (Legendary Armory)** - A HarmonyOS encyclopedia app for legendary weapons from world mythology (Chinese, Japanese, European, Norse, Indian, Arabian, Celtic). Features include weapon browsing, blacksmith legends, quiz challenges, and battle simulation.

- **Platform**: HarmonyOS (ArkTS)
- **Architecture**: Pure frontend, no backend, fully offline
- **Status**: Initial development phase (0% complete - project scaffolding not yet created)
- **AI Generation**: Doubao API (doubao-seedream-4-5-251128) for pre-generating all images during development

## Critical Development Rules

### 1. Documentation-First Approach

**BEFORE writing ANY HarmonyOS code**, you MUST consult:
```bash
cat harmonyos_docs/文档索引.md
```

This index contains 9,482 HarmonyOS documents organized by category. Never assume syntax - always verify against official docs. The project uses strict HarmonyOS conventions that differ from standard TypeScript/JavaScript.

### 2. Image Management Constraints

**All images MUST be stored in a flat structure - NO nested folders allowed:**

```
entry/src/main/resources/base/media/
├── weapon_xuanyuan.png          # ✓ Correct
├── weapon_kusanagi.png
├── blacksmith_ouye.png
├── bg_weapon_detail.png
├── icon_fire.svg
└── icon_ice.svg
# ✗ NEVER create subfolders like weapons/ or icons/
```

**Rules:**
- Path: `entry/src/main/resources/base/media/` (flat structure only)
- Naming: Use prefixes like `weapon_`, `blacksmith_`, `bg_`, `icon_` for organization
- No emojis in code or UI - use SVG icons instead
- All background images are AI-generated dark metallic textures (4K, no people, no complete weapons)

### 3. Compilation Verification

**After completing EACH feature, you MUST run:**
```bash
hvigorw assembleHap
```

Do not proceed to the next feature until compilation succeeds with zero errors.

## Common Commands

### Image Generation

```bash
# Test single image generation (Doubao API)
python3 scripts/test_image_gen.py

# Batch generate all images for a specific culture
python3 scripts/batch_image_gen.py --culture chinese --max-concurrent 3

# Generate all images (resume-safe with skip logic)
python3 scripts/batch_image_gen.py

# Dry run to see what would be generated
python3 scripts/batch_image_gen.py --culture japanese --dry-run

# Process icons (remove background, crop, resize to 512x512)
python3 scripts/process_icons.py
```

**Note**: API credentials are hardcoded in scripts (do not modify `BASE_URL` or `API_KEY`). Generated images save to `entry/src/main/resources/base/media/` by default.

### HarmonyOS Build

```bash
# Compile HAP (HarmonyOS App Package)
hvigorw assembleHap

# Note: Project structure not yet initialized
# First run will require HarmonyOS project setup
```

## Architecture Overview

### Module Structure (Planned)

The app is organized into 7 major modules:

1. **首页发现 (Home)** - Carousel, quick navigation, search
2. **神兵图鉴 (Weapon Encyclopedia)** - 100+ legendary weapons with multi-dimensional classification (culture, type, attribute, rarity)
3. **铸造大师 (Master Blacksmiths)** - 20 legendary blacksmiths from 12 cultures
4. **兵器百科 (Weapon Compendium)** - Attribute systems, cultural backgrounds, skill dictionary
5. **挑战答题 (Quiz Challenge)** - 4 modes (Classic, Speed, Endless, Topic) with achievement/ranking systems
6. **互动娱乐 (Interactive)** - Daily fortune, attribute tests, battle simulator
7. **专题故事 (Featured Articles)** - In-depth articles on weapon culture and forging techniques
8. **我的页面 (Profile)** - Favorites, history, achievements, settings

### Data Architecture

All data stored locally as JSON in `entry/src/main/resources/rawfile/data/`:

```
rawfile/data/
├── weapons.json       # 100+ weapons (id, name, culture, type, attributes, stats, legends)
├── blacksmiths.json   # 20 blacksmiths (id, name, culture, era, masterworks, techniques)
├── abilities.json     # 50+ skills (elemental, physical, special, passive)
├── attributes.json    # 14 attributes (fire, water, ice, thunder, wind, earth, light, dark, poison, nature, time_space, death, chaos, special)
├── cultures.json      # 12 cultures (Chinese, Japanese, Greek, Norse, Celtic, Medieval Europe, Indian, Arabian, Egyptian, Persian, Mesoamerican, African)
├── questions.json     # 100+ quiz questions (weapon, blacksmith, culture, attribute, ability)
└── topics.json        # Featured articles
```

**User data** stored via LocalStorage/Preferences:
- Favorites (weapon IDs)
- Browse history
- Quiz records & achievements

See [神兵图录-PRD.md](神兵图录-PRD.md) sections 3.1-3.7 for complete TypeScript interfaces.

### Classification System

Weapons are categorized across 4 dimensions:

1. **Culture**: Chinese (轩辕剑, 湛卢剑, 干将莫邪) | Japanese (草薙剑, 三日月宗近, 村正) | Greek (宙斯雷霆, 波塞冬三叉戟) | Norse (雷神之锤Mjolnir, 永恒之枪Gungnir) | Celtic (光明之剑Claíomh Solais, 倒刺之矛Gáe Bolg) | Medieval Europe (Excalibur, Durandal, Joyeuse) | Indian (苏达尔善神轮, 湿婆三叉戟Trishula) | Arabian (佐勒菲卡尔Zulfiqar) | Egyptian (科佩什弯刀Khopesh, 沃斯权杖Was) | Persian (绿宝石神剑Shamshir-e Zomorrodnegar) | Mesoamerican (Macuahuitl, Atlatl) | African (祖鲁短矛Assegai, 埃塞俄比亚弯刀Shotel)
   - **Total: 12 cultural systems**

2. **Type**: Sword | Katana | Hammer | Axe | Spear | Bow | Staff | Dagger | Polearm | Trident | Chain Weapon | Scythe | Club | Soft Weapon | Shield | Claw | Throwing | Other
   - **Total: 15+ weapon categories**

3. **Attribute**: Fire 🔥 | Water 💧 | Ice ❄️ | Thunder ⚡ | Wind 🌪️ | Earth/Rock 🗿 | Light/Holy ✨ | Dark/Evil 🌑 | Poison ☠️ | Nature/Wood 🌿 | Time/Space ⏰ | Death/Undead 💀 | Chaos/Mixed 🌀 | Special (Blood/Mind/Sound)
   - Primary + optional secondary attributes
   - **Total: 14 elemental systems**
   - Elemental counter relationships (e.g., water > fire > ice > wind)

4. **Rarity**: Artifact (神器-gold) | Legendary (传说-purple) | Epic (史诗-blue) | Rare (稀有-green)

### Directory Structure (Planned)

```
entry/src/main/
├── ets/
│   ├── pages/              # UI pages (Index, WeaponList, WeaponDetail, Quiz, etc.)
│   ├── components/         # Reusable components (WeaponCard, AttributeTag, SearchBar)
│   ├── model/              # TypeScript data models matching JSON schemas
│   ├── utils/              # DataLoader, Storage, Search, BattleCalculator
│   └── common/             # Constants, Theme, AttributeColors
└── resources/
    ├── base/media/         # ALL images (flat structure, no folders!)
    └── rawfile/
        ├── data/           # JSON data files
        └── images/         # AI-generated images (weapons, blacksmiths, backgrounds)
```

## AI Image Generation

### Pre-Generation Approach

All images are **pre-generated during development** using Doubao-Seedream-4.5 and packaged with the app. No runtime API calls - fully offline operation.

```bash
# Generate images during development
python3 scripts/batch_image_gen.py --culture chinese
python3 scripts/batch_image_gen.py  # Generate all (resume-safe)
```

**Image Categories:**
- **Weapons**: 60-80 images (prefix: `weapon_`)
- **Blacksmiths**: 20 images (prefix: `blacksmith_`)
- **Backgrounds**: 9 types for different detail pages (prefix: `bg_`)
- **Icons**: Attribute/culture icons as SVG (prefix: `icon_`)

## Design System

### Color Scheme

**Main Palette:**
- Background: Deep blue-black gradient `#0a0a1a` → `#1a1a2e`
- Rarity colors: Artifact-`#ffd700` | Legendary-`#9d4edd` | Epic-`#4cc9f0` | Rare-`#3cb371`

**Attribute Colors:**
- Fire: `#ff4500` | Ice: `#00bfff` | Thunder: `#9370db` | Light: `#ffd700`
- Dark: `#2f4f4f` | Wind: `#7fffd4` | Poison: `#228b22`

### Visual Style
- Dark metallic textures with epic feel
- 4K backgrounds with deep shadows (no people, no complete weapons)
- High contrast for text readability
- Bold fonts for titles (e.g., Source Han Sans Bold)

## Development Workflow

### Phase 1 - MVP (Current Priority)
1. Initialize HarmonyOS project structure
2. Implement data models and JSON loader
3. Build Home page with carousel
4. Build Weapon List with multi-dimensional filtering
5. Build Weapon Detail page
6. Implement search and favorites
7. Generate initial 50+ weapon images

### Phase 2-4 (See 神兵图录-PRD.md Section 6)
- Phase 2: Encyclopedia modules (attributes, cultures, blacksmiths)
- Phase 3: Quiz system (4 modes, achievements, leaderboards)
- Phase 4: Interactive features (fortune, battle simulator, attribute tests)

## Important References

- **PRD**: [神兵图录-PRD.md](神兵图录-PRD.md) - Complete product requirements (1142 lines)
- **README**: [README.md](README.md) - Project overview and constraints
- **HarmonyOS Docs**: `harmonyos_docs/文档索引.md` - 9,482 official docs
- **Doubao API**: Base URL and key in `scripts/batch_image_gen.py` (unchangeable)

## Key Technical Constraints

1. **Pure frontend architecture** - No backend services, fully offline
2. **Offline-first** - All features work without internet (AI generation is development-time only)
3. **Local data only** - JSON files + LocalStorage/Preferences for user data
4. **Strict image path rules** - Flat `base/media/` structure (no nesting)
5. **Compile verification** - `hvigorw assembleHap` must pass after each feature
6. **Documentation compliance** - Always check `harmonyos_docs/` before using HarmonyOS APIs
7. **No emojis** - Use SVG icons exclusively

## Data Preparation Checklist

Before development, ensure these data files are created in `rawfile/data/`:

- [ ] `weapons.json` - 100+ legendary weapons with complete metadata (12 cultures, 15+ types, 14 attributes)
- [ ] `blacksmiths.json` - 20 master blacksmiths across 12 cultures
- [ ] `abilities.json` - 50+ skills categorized by type
- [ ] `attributes.json` - 14 elemental attributes with counter relationships
- [ ] `cultures.json` - 12 cultural backgrounds (Chinese, Japanese, Greek, Norse, Celtic, Medieval Europe, Indian, Arabian, Egyptian, Persian, Mesoamerican, African)
- [ ] `questions.json` - 100+ quiz questions with difficulty levels
- [ ] `topics.json` - Featured articles on weapon history/culture

## Quiz System Details

**4 Game Modes:**
- **Classic**: 20 questions, mixed difficulty, 15s per question
- **Speed**: 30 questions, 10s per question, emphasizes fast response
- **Endless**: Unlimited questions, 3 lives, highest score challenge
- **Topic**: 15 questions on specific topic (weapons/blacksmiths/cultures/attributes/skills)

**Mechanics:**
- Combo system: consecutive correct answers increase score multiplier (1x→1.5x→2x→3x)
- Countdown timer with color coding (green→orange→red)
- Achievement system with 4 rarity tiers (common, rare, epic, legendary)
- Local leaderboards with rank tiers (Bronze, Silver, Gold, Platinum, Diamond)

## Notes

- Project is in **initial development phase** - HarmonyOS project structure not yet created
- All percentage completion in PRD shows 0% - this is accurate
- When initializing project, follow structure in [README.md](README.md) section "项目结构"
- The API key for Doubao is project-specific and should not be changed

*** 注释 和对话一定要用中文 *** 