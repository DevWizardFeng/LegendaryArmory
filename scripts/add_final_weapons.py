#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
最终补充武器数据到105个
"""

import json

# 补充剩余的武器（26个，达到105总数）
final_weapons = [
    # === 阿拉伯武器（4个）===
    {
        "id": "shamshir",
        "name": {"original": "شمشیر", "cn": "弯刀", "en": "Shamshir"},
        "culture": "arabian",
        "type": "sword",
        "attributes": {"primary": "wind"},
        "rarity": "epic",
        "stats": {"attack": 83, "defense": 68, "speed": 92, "weight": 2.0},
        "description": "波斯弯刀的代表，刀身优美弯曲，适合骑兵使用。",
        "forging_legend": "波斯工匠锻造，刀身优雅弯曲如新月。",
        "battle_legend": "波斯骑兵持此刀纵横沙场，挥砍如风。",
        "abilities": ["wind_blade", "critical_strike", "cavalry_charge"],
        "symbolism": "波斯弯刀，骑兵之刃",
        "inscription": "无",
        "famous_owners": [{"name": "波斯勇士", "title": "骑兵", "story": "沙漠之鹰"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "curved_single_edge", "guard_type": "crescent", "handle_type": "wrapped", "colors": ["#C0C0C0", "#FFD700", "#87CEEB"], "features": ["优美弯曲", "轻盈锋利"]},
        "image": "weapon_shamshir.png",
        "related": ["zulfiqar"],
        "tags": ["阿拉伯", "波斯", "风属性", "弯刀"]
    },
    {
        "id": "scimitar",
        "name": {"original": "سيف", "cn": "弯月刀", "en": "Scimitar"},
        "culture": "arabian",
        "type": "sword",
        "attributes": {"primary": "fire"},
        "rarity": "epic",
        "stats": {"attack": 85, "defense": 70, "speed": 90, "weight": 2.2},
        "description": "阿拉伯战士的标志性武器，刀身弯曲如新月，锋利无比。",
        "forging_legend": "阿拉伯工匠以大马士革钢锻造，刀身呈现水波纹。",
        "battle_legend": "阿拉伯战士持此刀征战，刀光如月华。",
        "abilities": ["flame_wave", "critical_strike", "moon_slash"],
        "symbolism": "新月之刀，沙漠战士",
        "inscription": "无",
        "famous_owners": [{"name": "萨拉丁", "title": "阿拉伯苏丹", "story": "十字军东征名将"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "curved_single_edge", "guard_type": "crescent_moon", "handle_type": "gold_inlaid", "colors": ["#C0C0C0", "#FFD700", "#FF4500"], "features": ["新月弯曲", "大马士革纹"]},
        "image": "weapon_scimitar.png",
        "related": ["zulfiqar"],
        "tags": ["阿拉伯", "火属性", "弯刀", "新月"]
    },
    {
        "id": "jambiya",
        "name": {"original": "جنبية", "cn": "阿拉伯短剑", "en": "Jambiya"},
        "culture": "arabian",
        "type": "dagger",
        "attributes": {"primary": "dark"},
        "rarity": "rare",
        "stats": {"attack": 75, "defense": 55, "speed": 95, "weight": 0.5},
        "description": "也门传统匕首，刀刃呈S形弯曲，是阿拉伯男子成年的象征。",
        "forging_legend": "也门工匠代代相传的锻造技艺，刀鞘常用犀牛角制成。",
        "battle_legend": "阿拉伯战士将其作为备用武器和荣誉象征随身携带。",
        "abilities": ["critical_strike", "stealth", "armor_pierce"],
        "symbolism": "男子气概，荣誉象征",
        "inscription": "无",
        "famous_owners": [{"name": "也门战士", "title": "部落勇士", "story": "成年礼物"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "curved_dagger", "guard_type": "none", "handle_type": "rhino_horn", "colors": ["#C0C0C0", "#8B4513", "#FFD700"], "features": ["S形弯曲", "犀牛角柄", "精美装饰"]},
        "image": "weapon_jambiya.png",
        "related": [],
        "tags": ["阿拉伯", "也门", "暗属性", "匕首"]
    },
    {
        "id": "khanda",
        "name": {"original": "खड्ग", "cn": "印度阔剑", "en": "Khanda"},
        "culture": "arabian",
        "type": "sword",
        "attributes": {"primary": "light"},
        "rarity": "epic",
        "stats": {"attack": 88, "defense": 75, "speed": 78, "weight": 3.5},
        "description": "印度锡克教的圣剑，双刃直剑，象征正义与勇气。",
        "forging_legend": "锡克教工匠锻造，剑身宽阔沉重，威力巨大。",
        "battle_legend": "锡克战士持此剑保卫信仰，剑光如正义之光。",
        "abilities": ["holy_judgment", "armor_pierce", "critical_strike"],
        "symbolism": "锡克信仰，正义之剑",
        "inscription": "信仰",
        "famous_owners": [{"name": "锡克战士", "title": "圣战士", "story": "为信仰而战"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "straight_double_edge", "guard_type": "simple", "handle_type": "wrapped", "colors": ["#C0C0C0", "#FFD700", "#FFFFFF"], "features": ["宽阔剑身", "圣光环绕", "双刃直剑"]},
        "image": "weapon_khanda.png",
        "related": [],
        "tags": ["印度", "锡克教", "光属性", "阔剑"]
    },

    # === 埃及武器（3个）===
    {
        "id": "anu bis_staff",
        "name": {"original": "Anubis Staff", "cn": "阿努比斯权杖", "en": "Anubis Staff"},
        "culture": "egyptian",
        "type": "staff",
        "attributes": {"primary": "death"},
        "rarity": "artifact",
        "stats": {"attack": 88, "defense": 80, "speed": 75, "weight": 4.0},
        "description": "死神阿努比斯的权杖，能引导亡魂，掌管冥界审判。",
        "forging_legend": "神匠在冥界锻造，蕴含死亡与审判之力。",
        "battle_legend": "阿努比斯持此杖引导死者灵魂，在天平前审判善恶。",
        "abilities": ["spirit_call", "soul_bind", "judgment"],
        "symbolism": "死亡审判，灵魂引导",
        "inscription": "象形文字",
        "famous_owners": [{"name": "阿努比斯", "title": "死神", "story": "冥界守护者"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "staff", "guard_type": "jackal_head", "handle_type": "obsidian", "colors": ["#2F4F4F", "#FFD700", "#8B0000"], "features": ["豺头装饰", "冥界之力", "审判光芒"]},
        "image": "weapon_anubis_staff.png",
        "related": ["was_scepter"],
        "tags": ["埃及", "神话", "阿努比斯", "死亡属性"]
    },
    {
        "id": "horus_spear",
        "name": {"original": "Horus Spear", "cn": "荷鲁斯之矛", "en": "Spear of Horus"},
        "culture": "egyptian",
        "type": "spear",
        "attributes": {"primary": "light"},
        "rarity": "legendary",
        "stats": {"attack": 90, "defense": 72, "speed": 88, "weight": 3.5},
        "description": "天空之神荷鲁斯的长矛，象征王权与正义，鹰首装饰。",
        "forging_legend": "神匠为荷鲁斯锻造，矛头呈鹰喙形。",
        "battle_legend": "荷鲁斯持此矛与塞特争夺王位，最终获胜成为法老的守护神。",
        "abilities": ["holy_judgment", "flight", "armor_pierce"],
        "symbolism": "王权正统，天空之力",
        "inscription": "象形文字",
        "famous_owners": [{"name": "荷鲁斯", "title": "天空之神", "story": "法老的守护神"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "spear_head", "guard_type": "falcon_pattern", "handle_type": "gold_inlaid", "colors": ["#FFD700", "#4169E1", "#FFFFFF"], "features": ["鹰喙矛头", "王权象征", "天空之力"]},
        "image": "weapon_horus_spear.png",
        "related": ["was_scepter"],
        "tags": ["埃及", "神话", "荷鲁斯", "光属性"]
    },
    {
        "id": "set_axe",
        "name": {"original": "Set Axe", "cn": "塞特战斧", "en": "Axe of Set"},
        "culture": "egyptian",
        "type": "axe",
        "attributes": {"primary": "chaos"},
        "rarity": "legendary",
        "stats": {"attack": 92, "defense": 68, "speed": 80, "weight": 6.0},
        "description": "混乱之神塞特的战斧，象征沙漠风暴与混乱。",
        "forging_legend": "在沙漠深处锻造，蕴含沙暴与混乱之力。",
        "battle_legend": "塞特持此斧对抗荷鲁斯，引发沙漠风暴。",
        "abilities": ["chaos_storm", "critical_strike", "curse"],
        "symbolism": "混乱风暴，沙漠之力",
        "inscription": "象形文字",
        "famous_owners": [{"name": "塞特", "title": "混乱之神", "story": "沙漠与风暴之神"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "axe_head", "guard_type": "none", "handle_type": "desert_wood", "colors": ["#8B4513", "#FF4500", "#2F4F4F"], "features": ["混乱气息", "沙暴环绕", "野兽头饰"]},
        "image": "weapon_set_axe.png",
        "related": ["horus_spear"],
        "tags": ["埃及", "神话", "塞特", "混沌属性"]
    },

    # === 波斯武器（3个）===
    {
        "id": "acinaces",
        "name": {"original": "Acinaces", "cn": "阿奇那刻斯短剑", "en": "Acinaces"},
        "culture": "persian",
        "type": "dagger",
        "attributes": {"primary": "fire"},
        "rarity": "epic",
        "stats": {"attack": 80, "defense": 65, "speed": 92, "weight": 1.2},
        "description": "波斯帝国贵族的仪式短剑，剑身笔直，是权力的象征。",
        "forging_legend": "波斯工匠为贵族锻造，剑鞘华丽装饰。",
        "battle_legend": "波斯贵族佩戴此剑出席仪式，象征地位与荣耀。",
        "abilities": ["critical_strike", "prestige", "armor_pierce"],
        "symbolism": "权力象征，贵族荣耀",
        "inscription": "波斯文",
        "famous_owners": [{"name": "波斯贵族", "title": "帝国贵族", "story": "权力的象征"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "straight_dagger", "guard_type": "winged", "handle_type": "gold_inlaid", "colors": ["#FFD700", "#C0C0C0", "#FF4500"], "features": ["笔直剑身", "华丽剑鞘", "翼形护手"]},
        "image": "weapon_acinaces.png",
        "related": ["shamshir_zomorrodnegar"],
        "tags": ["波斯", "火属性", "短剑", "贵族"]
    },
    {
        "id": "khopesh_persian",
        "name": {"original": "Persian Khopesh", "cn": "波斯镰刀剑", "en": "Persian Khopesh"},
        "culture": "persian",
        "type": "sword",
        "attributes": {"primary": "wind"},
        "rarity": "epic",
        "stats": {"attack": 84, "defense": 70, "speed": 86, "weight": 2.3},
        "description": "波斯版本的镰刀剑，刀刃弯曲如镰，兼具劈砍与钩拉功能。",
        "forging_legend": "波斯工匠改进埃及镰刀剑设计，更加轻盈灵活。",
        "battle_legend": "波斯战士在战场上用此剑勾住敌人盾牌。",
        "abilities": ["wind_blade", "disarm", "armor_pierce"],
        "symbolism": "波斯战术，灵活多变",
        "inscription": "无",
        "famous_owners": [{"name": "波斯战士", "title": "帝国士兵", "story": "战场利器"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "sickle_sword", "guard_type": "simple", "handle_type": "leather_wrapped", "colors": ["#C0C0C0", "#87CEEB", "#8B4513"], "features": ["镰刀形态", "轻盈设计", "钩拉功能"]},
        "image": "weapon_khopesh_persian.png",
        "related": ["khopesh"],
        "tags": ["波斯", "风属性", "镰刀剑"]
    },
    {
        "id": "katar",
        "name": {"original": "कटार", "cn": "卡塔尔拳刃", "en": "Katar"},
        "culture": "persian",
        "type": "dagger",
        "attributes": {"primary": "dark"},
        "rarity": "epic",
        "stats": {"attack": 82, "defense": 60, "speed": 95, "weight": 1.0},
        "description": "印度拳刃，横握使用，刺击力量强大，是刺客的利器。",
        "forging_legend": "印度工匠创造的独特武器，刀柄横向设计。",
        "battle_legend": "刺客持此刃暗杀目标，一击致命。",
        "abilities": ["armor_pierce", "critical_strike", "stealth"],
        "symbolism": "刺客之刃，一击必杀",
        "inscription": "无",
        "famous_owners": [{"name": "印度刺客", "title": "暗杀者", "story": "暗夜杀手"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "push_dagger", "guard_type": "horizontal", "handle_type": "cross_grip", "colors": ["#2F4F4F", "#C0C0C0", "#8B0000"], "features": ["横向握柄", "三角刀刃", "刺客利器"]},
        "image": "weapon_katar.png",
        "related": [],
        "tags": ["印度", "波斯", "暗属性", "拳刃"]
    },

    # === 中美洲武器（4个）===
    {
        "id": "atlatl",
        "name": {"original": "Atlatl", "cn": "投矛器", "en": "Atlatl"},
        "culture": "mesoamerican",
        "type": "throwing",
        "attributes": {"primary": "wind"},
        "rarity": "epic",
        "stats": {"attack": 85, "defense": 50, "speed": 95, "weight": 1.0},
        "description": "阿兹特克投矛器，利用杠杆原理大幅增加投矛距离和威力。",
        "forging_legend": "美洲原住民发明的精巧投掷工具，可将标枪投出数百米。",
        "battle_legend": "阿兹特克战士用投矛器远距离杀伤西班牙征服者。",
        "abilities": ["long_range", "critical_strike", "armor_pierce"],
        "symbolism": "远程利器，智慧结晶",
        "inscription": "无",
        "famous_owners": [{"name": "阿兹特克战士", "title": "投矛手", "story": "远程打击"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "throwing_stick", "guard_type": "none", "handle_type": "wood", "colors": ["#8B4513", "#228B22", "#FFD700"], "features": ["杠杆设计", "木质结构", "羽毛装饰"]},
        "image": "weapon_atlatl.png",
        "related": ["macuahuitl"],
        "tags": ["中美洲", "阿兹特克", "风属性", "投掷武器"]
    },
    {
        "id": "tepoztopilli",
        "name": {"original": "Tepoztopilli", "cn": "特波兹托皮利", "en": "Tepoztopilli"},
        "culture": "mesoamerican",
        "type": "spear",
        "attributes": {"primary": "earth"},
        "rarity": "epic",
        "stats": {"attack": 84, "defense": 68, "speed": 80, "weight": 3.5},
        "description": "阿兹特克长矛，矛头两侧镶嵌黑曜石刀片，锋利无比。",
        "forging_legend": "阿兹特克工匠在木质矛头两侧嵌入黑曜石刀片。",
        "battle_legend": "阿兹特克精锐战士持此矛作战，矛尖锋利如剃刀。",
        "abilities": ["armor_pierce", "critical_strike", "reach"],
        "symbolism": "精锐武器，黑曜石之矛",
        "inscription": "无",
        "famous_owners": [{"name": "阿兹特克鹰战士", "title": "精锐战士", "story": "帝国卫队"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "obsidian_spear", "guard_type": "none", "handle_type": "wood", "colors": ["#8B4513", "#2F4F4F", "#FFD700"], "features": ["黑曜石刀片", "木质长柄", "锋利矛头"]},
        "image": "weapon_tepoztopilli.png",
        "related": ["macuahuitl"],
        "tags": ["中美洲", "阿兹特克", "土属性", "长矛"]
    },
    {
        "id": "huitzauhqui",
        "name": {"original": "Huitzauhqui", "cn": "刺棒", "en": "Huitzauhqui"},
        "culture": "mesoamerican",
        "type": "club",
        "attributes": {"primary": "earth"},
        "rarity": "rare",
        "stats": {"attack": 78, "defense": 65, "speed": 75, "weight": 4.0},
        "description": "阿兹特克战棒，木棒上镶嵌尖锐的黑曜石或骨刺。",
        "forging_legend": "阿兹特克工匠在木棒上嵌入黑曜石或动物骨刺。",
        "battle_legend": "阿兹特克战士用战棒击打敌人，骨刺造成可怕伤口。",
        "abilities": ["critical_strike", "bleeding", "stun"],
        "symbolism": "战棒利器，原始威力",
        "inscription": "无",
        "famous_owners": [{"name": "阿兹特克战士", "title": "部落勇士", "story": "部落守护者"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "spiked_club", "guard_type": "none", "handle_type": "wood", "colors": ["#8B4513", "#2F4F4F", "#8B0000"], "features": ["尖刺装饰", "木质战棒", "骨刺镶嵌"]},
        "image": "weapon_huitzauhqui.png",
        "related": ["macuahuitl"],
        "tags": ["中美洲", "阿兹特克", "土属性", "战棒"]
    },
    {
        "id": "tecpatl",
        "name": {"original": "Tecpatl", "cn": "祭祀刀", "en": "Tecpatl"},
        "culture": "mesoamerican",
        "type": "dagger",
        "attributes": {"primary": "death"},
        "rarity": "epic",
        "stats": {"attack": 80, "defense": 55, "speed": 85, "weight": 0.8},
        "description": "阿兹特克祭祀用的黑曜石刀，锋利如剃刀，用于献祭仪式。",
        "forging_legend": "阿兹特克祭司打磨黑曜石制成祭刀，用于神圣仪式。",
        "battle_legend": "在金字塔顶端，祭司用此刀进行活人献祭以取悦太阳神。",
        "abilities": ["critical_strike", "sacrifice", "death_mark"],
        "symbolism": "献祭之刀，神圣仪式",
        "inscription": "无",
        "famous_owners": [{"name": "阿兹特克祭司", "title": "大祭司", "story": "献祭仪式"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "obsidian_blade", "guard_type": "none", "handle_type": "wood_wrapped", "colors": ["#2F4F4F", "#8B0000", "#FFD700"], "features": ["黑曜石刀刃", "极度锋利", "仪式用途"]},
        "image": "weapon_tecpatl.png",
        "related": [],
        "tags": ["中美洲", "阿兹特克", "死亡属性", "祭祀刀"]
    },

    # === 非洲武器（4个）===
    {
        "id": "iklwa",
        "name": {"original": "Iklwa", "cn": "伊克尔瓦短矛", "en": "Iklwa"},
        "culture": "african",
        "type": "spear",
        "attributes": {"primary": "earth"},
        "rarity": "epic",
        "stats": {"attack": 86, "defense": 62, "speed": 88, "weight": 2.0},
        "description": "恰卡王改良的祖鲁短矛，矛头宽大，专为近战设计，发出'iklwa'的声音。",
        "forging_legend": "恰卡王改良传统投矛，创造出更适合近战的短矛。",
        "battle_legend": "祖鲁战士用短矛刺入敌人身体后拔出，发出'iklwa'的声音。",
        "abilities": ["armor_pierce", "critical_strike", "bleeding"],
        "symbolism": "祖鲁改革，近战利器",
        "inscription": "无",
        "famous_owners": [{"name": "恰卡", "title": "祖鲁之王", "story": "军事改革家"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "broad_spear", "guard_type": "none", "handle_type": "wood", "colors": ["#C0C0C0", "#8B4513", "#8B0000"], "features": ["宽大矛头", "短矛设计", "近战优化"]},
        "image": "weapon_iklwa.png",
        "related": ["assegai"],
        "tags": ["非洲", "祖鲁", "土属性", "短矛"]
    },
    {
        "id": "shotel",
        "name": {"original": "ሾቴል", "cn": "埃塞俄比亚弯刀", "en": "Shotel"},
        "culture": "african",
        "type": "sword",
        "attributes": {"primary": "wind"},
        "rarity": "epic",
        "stats": {"attack": 84, "defense": 60, "speed": 92, "weight": 1.8},
        "description": "埃塞俄比亚传统弯刀，刀身极度弯曲如镰，能绕过盾牌攻击。",
        "forging_legend": "埃塞俄比亚工匠锻造，刀身弯曲超过90度。",
        "battle_legend": "埃塞俄比亚战士用此刀绕过敌人盾牌直接攻击躯干。",
        "abilities": ["bypass_shield", "critical_strike", "wind_blade"],
        "symbolism": "绕盾攻击，独特战术",
        "inscription": "无",
        "famous_owners": [{"name": "埃塞俄比亚战士", "title": "高原勇士", "story": "盾牌克星"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "sickle_sword", "guard_type": "simple", "handle_type": "wood", "colors": ["#C0C0C0", "#8B4513", "#87CEEB"], "features": ["极度弯曲", "镰刀形态", "绕盾设计"]},
        "image": "weapon_shotel.png",
        "related": ["khopesh"],
        "tags": ["非洲", "埃塞俄比亚", "风属性", "弯刀"]
    },
    {
        "id": "makraka",
        "name": {"original": "Makraka", "cn": "马克拉卡飞刀", "en": "Makraka"},
        "culture": "african",
        "type": "throwing",
        "attributes": {"primary": "wind"},
        "rarity": "rare",
        "stats": {"attack": 75, "defense": 50, "speed": 98, "weight": 0.6},
        "description": "中非部落的投掷武器，刀身独特的曲线设计使其飞行轨迹难以预测。",
        "forging_legend": "中非工匠锻造，刀身呈波浪状弯曲。",
        "battle_legend": "部落战士投掷此刀，曲线飞行令敌人难以躲避。",
        "abilities": ["unpredictable", "critical_strike", "return"],
        "symbolism": "飞刀利器，曲线杀伤",
        "inscription": "无",
        "famous_owners": [{"name": "中非战士", "title": "部落猎人", "story": "狩猎与战争"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "curved_throwing", "guard_type": "none", "handle_type": "wrapped", "colors": ["#C0C0C0", "#8B4513", "#228B22"], "features": ["波浪弯曲", "投掷设计", "曲线飞行"]},
        "image": "weapon_makraka.png",
        "related": [],
        "tags": ["非洲", "中非", "风属性", "投掷武器"]
    },
    {
        "id": "mambele",
        "name": {"original": "Mambele", "cn": "曼贝勒飞刀", "en": "Mambele"},
        "culture": "african",
        "type": "throwing",
        "attributes": {"primary": "dark"},
        "rarity": "rare",
        "stats": {"attack": 78, "defense": 52, "speed": 95, "weight": 0.8},
        "description": "中非和西非的多刃投掷武器，形状如闪电，具有多个锋利边缘。",
        "forging_legend": "非洲工匠锻造出多刃设计，无论哪个角度击中都能造成伤害。",
        "battle_legend": "部落战士投掷此武器，多个刀刃确保击中目标。",
        "abilities": ["multi_blade", "critical_strike", "bleeding"],
        "symbolism": "闪电之刃，多重杀伤",
        "inscription": "无",
        "famous_owners": [{"name": "西非战士", "title": "部落勇士", "story": "投掷大师"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "multi_blade_throwing", "guard_type": "none", "handle_type": "center_grip", "colors": ["#2F4F4F", "#C0C0C0", "#8B4513"], "features": ["多刃设计", "闪电形状", "投掷武器"]},
        "image": "weapon_mambele.png",
        "related": ["makraka"],
        "tags": ["非洲", "西非", "暗属性", "投掷武器"]
    },

    # === 补充日本武器（2个）===
    {
        "id": "tonbo_kiri",
        "name": {"original": "蜻蛉切", "cn": "蜻蛉切", "en": "Tonbo-kiri"},
        "culture": "japanese",
        "type": "spear",
        "attributes": {"primary": "wind"},
        "rarity": "legendary",
        "stats": {"attack": 90, "defense": 70, "speed": 92, "weight": 2.8},
        "description": "天下三名枪之首，本多忠胜的佩枪，传说蜻蜓落在枪尖被一分为二。",
        "forging_legend": "村正门人锻造，枪尖锋利无比。",
        "battle_legend": "本多忠胜持此枪参加五十七次战役未曾受伤，被称为'战国第一猛将'。",
        "abilities": ["wind_blade", "critical_strike", "armor_pierce"],
        "symbolism": "名枪之首，猛将之魂",
        "inscription": "蜻蛉切",
        "famous_owners": [{"name": "本多忠胜", "title": "德川四天王", "story": "战国第一猛将"}],
        "blacksmith_id": "muramasa_smith",
        "appearance": {"blade_type": "straight_spear", "guard_type": "cross_guard", "handle_type": "black_lacquer", "colors": ["#C0C0C0", "#2F4F4F", "#8B0000"], "features": ["极度锋利", "蜻蜓传说", "长柄设计"]},
        "image": "weapon_tonbo_kiri.png",
        "related": ["nihongo", "otegine"],
        "tags": ["日本", "战国", "天下三枪", "风属性"]
    },
    {
        "id": "nihongo",
        "name": {"original": "日本号", "cn": "日本号", "en": "Nihongo"},
        "culture": "japanese",
        "type": "spear",
        "attributes": {"primary": "fire"},
        "rarity": "legendary",
        "stats": {"attack": 88, "defense": 72, "speed": 88, "weight": 3.0},
        "description": "天下三名枪之一，黑田家传世之宝，枪身粗大威猛。",
        "forging_legend": "名匠锻造，枪身比普通枪更粗壮。",
        "battle_legend": "母里太兵卫醉酒从福岛正则处赢得此枪，成为传奇。",
        "abilities": ["flame_wave", "critical_strike", "stun"],
        "symbolism": "豪勇之枪，醉酒传说",
        "inscription": "日本号",
        "famous_owners": [{"name": "母里太兵卫", "title": "黑田家臣", "story": "醉酒夺枪"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "thick_spear", "guard_type": "large_cross", "handle_type": "thick_shaft", "colors": ["#C0C0C0", "#8B0000", "#FFD700"], "features": ["粗壮枪身", "威猛气势", "名枪风范"]},
        "image": "weapon_nihongo.png",
        "related": ["tonbo_kiri", "otegine"],
        "tags": ["日本", "战国", "天下三枪", "火属性"]
    },

    # === 补充中国武器（2个）===
    {
        "id": "shuang_gou",
        "name": {"original": "双钩", "cn": "鸳鸯钩", "en": "Twin Hooks"},
        "culture": "chinese",
        "type": "soft_weapon",
        "attributes": {"primary": "wind"},
        "rarity": "epic",
        "stats": {"attack": 82, "defense": 70, "speed": 95, "weight": 2.5},
        "description": "中国武术特有的双兵器，钩身弯曲，可钩、可刺、可割，变化莫测。",
        "forging_legend": "武林高手创造的独特兵器，成对使用威力倍增。",
        "battle_legend": "江湖侠客持双钩行走江湖，钩法飘逸如舞。",
        "abilities": ["disarm", "chain_attack", "wind_blade"],
        "symbolism": "江湖利器，变化莫测",
        "inscription": "无",
        "famous_owners": [{"name": "江湖侠客", "title": "武林高手", "story": "双钩绝技"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "twin_hooks", "guard_type": "hook_guard", "handle_type": "rope_connected", "colors": ["#C0C0C0", "#87CEEB", "#FFD700"], "features": ["双钩成对", "钩刺结合", "飘逸灵动"]},
        "image": "weapon_shuang_gou.png",
        "related": [],
        "tags": ["中国", "武术", "风属性", "双兵器"]
    },
    {
        "id": "meteor_hammer",
        "name": {"original": "流星锤", "cn": "流星锤", "en": "Meteor Hammer"},
        "culture": "chinese",
        "type": "soft_weapon",
        "attributes": {"primary": "thunder"},
        "rarity": "epic",
        "stats": {"attack": 85, "defense": 60, "speed": 88, "weight": 3.5},
        "description": "中国古代软兵器，铁链连接铁锤，可远可近，威力巨大。",
        "forging_legend": "武林高手创制，链锤旋转如流星划过。",
        "battle_legend": "武林豪杰挥舞流星锤，锤影重重，敌人难以靠近。",
        "abilities": ["stun", "chain_attack", "reach"],
        "symbolism": "软兵利器，流星坠落",
        "inscription": "无",
        "famous_owners": [{"name": "武林豪杰", "title": "江湖高手", "story": "流星锤法"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "chain_hammer", "guard_type": "none", "handle_type": "chain", "colors": ["#C0C0C0", "#2F4F4F", "#9370DB"], "features": ["铁链连接", "旋转攻击", "远近兼备"]},
        "image": "weapon_meteor_hammer.png",
        "related": [],
        "tags": ["中国", "武术", "雷属性", "软兵器"]
    },

    # === 补充希腊武器（2个）===
    {
        "id": "xiphos",
        "name": {"original": "Ξίφος", "cn": "希腊短剑", "en": "Xiphos"},
        "culture": "greek",
        "type": "sword",
        "attributes": {"primary": "fire"},
        "rarity": "epic",
        "stats": {"attack": 80, "defense": 72, "speed": 90, "weight": 1.8},
        "description": "古希腊战士的标准配剑，双刃直剑，配合盾牌使用。",
        "forging_legend": "希腊工匠以青铜锻造，后改用铁制。",
        "battle_legend": "斯巴达战士以此剑配合圆盾作战，在温泉关浴血奋战。",
        "abilities": ["critical_strike", "armor_pierce", "shield_bash"],
        "symbolism": "希腊战士，斯巴达精神",
        "inscription": "ΜΟΛΩΝ ΛΑΒΕ",
        "famous_owners": [{"name": "列奥尼达", "title": "斯巴达国王", "story": "温泉关之战"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "straight_double_edge", "guard_type": "simple", "handle_type": "wood_wrapped", "colors": ["#CD853F", "#C0C0C0", "#8B0000"], "features": ["青铜光泽", "双刃直剑", "简洁实用"]},
        "image": "weapon_xiphos.png",
        "related": [],
        "tags": ["希腊", "古代", "火属性", "斯巴达"]
    },
    {
        "id": "dory",
        "name": {"original": "Δόρυ", "cn": "多里长矛", "en": "Dory"},
        "culture": "greek",
        "type": "spear",
        "attributes": {"primary": "earth"},
        "rarity": "epic",
        "stats": {"attack": 82, "defense": 75, "speed": 80, "weight": 3.0},
        "description": "古希腊重装步兵的主要武器，长约2-3米，方阵战术的核心。",
        "forging_legend": "希腊工匠锻造，矛杆用山茱萸木制成。",
        "battle_legend": "希腊方阵以长矛林立，铜墙铁壁般推进。",
        "abilities": ["reach", "formation", "armor_pierce"],
        "symbolism": "方阵之矛，团结力量",
        "inscription": "无",
        "famous_owners": [{"name": "斯巴达战士", "title": "重装步兵", "story": "方阵战术"}],
        "blacksmith_id": None,
        "appearance": {"blade_type": "spear_head", "guard_type": "none", "handle_type": "wood_shaft", "colors": ["#CD853F", "#C0C0C0", "#8B4513"], "features": ["长矛设计", "方阵利器", "双头矛尖"]},
        "image": "weapon_dory.png",
        "related": ["xiphos"],
        "tags": ["希腊", "古代", "土属性", "长矛"]
    },
]

def main():
    """主函数"""
    # 读取现有武器数据
    weapons_file = "/Users/zyb/Desktop/Harmony/LegendaryArmory/entry/src/main/resources/rawfile/data/weapons.json"

    with open(weapons_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    current_count = len(data['weapons'])
    print(f"当前武器数量: {current_count}")

    # 添加新武器
    data['weapons'].extend(final_weapons)

    new_count = len(data['weapons'])
    print(f"新增武器数量: {len(final_weapons)}")
    print(f"更新后武器数量: {new_count}")

    # 保存更新后的数据
    with open(weapons_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n✓ 武器数据已更新!")
    print(f"文件位置: {weapons_file}")
    print(f"最终武器数量: {new_count}")

    if new_count >= 100:
        print(f"✓ 已达到100+武器的目标! (共{new_count}个)")
    else:
        print(f"警告: 还需要添加 {100 - new_count} 个武器")

    # 统计各文化武器数量
    culture_count = {}
    for weapon in data['weapons']:
        culture = weapon['culture']
        culture_count[culture] = culture_count.get(culture, 0) + 1

    print("\n各文化武器数量统计:")
    for culture, count in sorted(culture_count.items()):
        print(f"  {culture}: {count}个")

if __name__ == "__main__":
    main()
