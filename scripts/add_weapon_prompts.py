#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
为新增武器生成图片提示词
"""

import json

# 新增武器的图片生成提示词
new_weapon_prompts = [
    # 中国武器
    {
        "id": "weapon_pangu_axe",
        "name_cn": "盘古开天斧",
        "culture": "chinese",
        "prompt": "A colossal primordial axe used by Pangu to split chaos and create the world, massive stone and bronze construction, ancient wood handle, chaotic energy swirling, creation power, earth-toned with golden accents, mythical Chinese creation deity weapon"
    },
    {
        "id": "weapon_ruyi_jingu_bang",
        "name_cn": "如意金箍棒",
        "culture": "chinese",
        "prompt": "The magical staff of Sun Wukong Monkey King, golden metal rod with red bands at both ends, can change size, divine iron material, thunder aura, ancient Chinese characters inscribed, legendary Journey to the West weapon"
    },
    {
        "id": "weapon_jiuchidingnail",
        "name_cn": "九齿钉耙",
        "culture": "chinese",
        "prompt": "Nine-tooth rake of Zhu Bajie, golden mystical rake weapon, nine sharp teeth, wood handle wrapped, divine celestial weapon, earth element power, Journey to the West legendary tool"
    },
    {
        "id": "weapon_qingfeng",
        "name_cn": "青锋剑",
        "culture": "chinese",
        "prompt": "A lightweight immortal flying sword with blue-green blade, elegant and swift, cloud patterns on guard, jade-wrapped handle, wind element aura, Chinese xianxia cultivation sword"
    },
    {
        "id": "weapon_zhangba_shemao",
        "name_cn": "丈八蛇矛",
        "culture": "chinese",
        "prompt": "Zhang Fei's serpent spear from Three Kingdoms, 18-chi long polearm with serpent-shaped blade, black lacquer handle, fierce dark aura, menacing presence, Chinese historical weapon"
    },
    {
        "id": "weapon_yinyue_qiang",
        "name_cn": "银月枪",
        "culture": "chinese",
        "prompt": "Silver Moon Spear with crescent blade, elegant silver shaft, white silk tassels, ice and frost aura, moonlight glow, Chinese martial arts spear"
    },
    {
        "id": "weapon_longquan",
        "name_cn": "龙泉剑",
        "culture": "chinese",
        "prompt": "Legendary Longquan sword forged by Ou Yezi, blade like autumn water, dragon engravings, blue-silver colors, water element power, Chinese famous sword"
    },
    {
        "id": "weapon_haolong",
        "name_cn": "镐龙刀",
        "culture": "chinese",
        "prompt": "Ming Dynasty dragon saber, curved blade with dragon carvings, thunder element crackling, silver and purple colors, shark-skin handle, Chinese military sword"
    },
    {
        "id": "weapon_dashen_bian",
        "name_cn": "打神鞭",
        "culture": "chinese",
        "prompt": "God-Beating Whip of Jiang Ziya, divine golden whip, sacred light aura, power to punish immortals and gods, Investiture of the Gods artifact, Chinese mythology weapon"
    },

    # 日本武器
    {
        "id": "weapon_honjo_masamune",
        "name_cn": "本庄正宗",
        "culture": "japanese",
        "prompt": "Honjo Masamune katana, masterpiece of swordsmith Masamune, benevolent holy light, perfect blade curvature, silver and gold colors, merciful divine aura, Tokugawa family treasure"
    },
    {
        "id": "weapon_ama_no_habakiri",
        "name_cn": "天羽羽斩",
        "culture": "japanese",
        "prompt": "Ama-no-Habakiri divine sword used by Susanoo to slay Yamata-no-Orochi, thunder and wind elements, purple lightning crackling, divine Japanese mythology sword"
    },
    {
        "id": "weapon_juzumaru",
        "name_cn": "数珠丸恒次",
        "culture": "japanese",
        "prompt": "Juzumaru Tsunetsugu katana of the Five Swords Under Heaven, prayer beads wrapped around handle, Buddhist holy light, demon-slaying power, Nichiren's sacred blade"
    },
    {
        "id": "weapon_odenta",
        "name_cn": "大典太光世",
        "culture": "japanese",
        "prompt": "Odenta Mitsuyo katana that can slay illness demons, purifying white light, elegant blade, Maeda family heirloom, healing and exorcism power"
    },
    {
        "id": "weapon_kogarasu_maru",
        "name_cn": "小乌丸",
        "culture": "japanese",
        "prompt": "Kogarasu Maru ancient tachi, unique kissaki-moroha-zukuri blade tip, dark mystical aura, tengu legend, prototype Japanese sword design"
    },
    {
        "id": "weapon_tonbo_kiri",
        "name_cn": "蜻蛉切",
        "culture": "japanese",
        "prompt": "Tonbo-kiri spear, first of Japan's Three Great Spears, extremely sharp tip can cut dragonfly in half, Honda Tadakatsu's legendary weapon, wind element"
    },
    {
        "id": "weapon_nihongo",
        "name_cn": "日本号",
        "culture": "japanese",
        "prompt": "Nihongo spear, one of Three Great Spears, thick and mighty shaft, fire element, Kuroda family treasure, drunken warrior legend"
    },

    # 北欧武器
    {
        "id": "weapon_stormbreaker",
        "name_cn": "风暴战斧",
        "culture": "norse",
        "prompt": "Stormbreaker battle axe forged by dwarves for Thor, double-bladed axe head, Groot wood handle, thunder and ice powers, bifrost summoning, neutron star core metal"
    },
    {
        "id": "weapon_hofud",
        "name_cn": "霍弗德",
        "culture": "norse",
        "prompt": "Hofud sword of Heimdall guardian of Bifrost, dawn light blade, rainbow colors, vigilant watching power, Norse guardian weapon"
    },
    {
        "id": "weapon_skofnung",
        "name_cn": "斯考弗农",
        "culture": "norse",
        "prompt": "Skofnung cursed sword containing twelve warriors' souls, blood-red blade, berserker fury, unhealable wounds, Danish legendary weapon"
    },
    {
        "id": "weapon_dainsleif",
        "name_cn": "岱恩斯雷夫",
        "culture": "norse",
        "prompt": "Dainsleif cursed sword, must kill when drawn, death aura, eternal battle curse, dark iron blade, Norse dwarf-forged weapon"
    },
    {
        "id": "weapon_mistilteinn",
        "name_cn": "米斯蒂汀",
        "culture": "norse",
        "prompt": "Mistilteinn magic sword related to mistletoe, nature power, god-slaying ability, green plant patterns, Norse legendary blade"
    },

    # 希腊武器
    {
        "id": "weapon_harpe",
        "name_cn": "哈尔佩",
        "culture": "greek",
        "prompt": "Harpe sickle sword used by Perseus to behead Medusa, curved bronze blade, immortal-killing power, god-slaying weapon, Greek hero's tool"
    },
    {
        "id": "weapon_aegis",
        "name_cn": "埃吉斯",
        "culture": "greek",
        "prompt": "Aegis divine shield of Zeus and Athena, Medusa's head at center, goat skin surface, petrification power, golden divine shield radiating fear"
    },
    {
        "id": "weapon_caduceus",
        "name_cn": "赫尔墨斯之杖",
        "culture": "greek",
        "prompt": "Caduceus staff of Hermes, two snakes entwined, wings at top, golden divine wood, messenger god's symbol, Greek mythology staff"
    },
    {
        "id": "weapon_labrys",
        "name_cn": "拉布里斯",
        "culture": "greek",
        "prompt": "Labrys double-headed axe of Minoan Crete, symmetrical bronze blades, thunder element, Minotaur labyrinth symbol, ancient Greek ritual weapon"
    },
    {
        "id": "weapon_xiphos",
        "name_cn": "希腊短剑",
        "culture": "greek",
        "prompt": "Xiphos standard Greek short sword, straight double-edged bronze blade, hoplite warrior weapon, Spartan military equipment"
    },
    {
        "id": "weapon_dory",
        "name_cn": "多里长矛",
        "culture": "greek",
        "prompt": "Dory spear of Greek hoplites, 2-3 meters long, cornel wood shaft, phalanx formation core weapon, bronze spearhead"
    },

    # 中世纪欧洲武器
    {
        "id": "weapon_almace",
        "name_cn": "阿尔玛斯",
        "culture": "medieval_europe",
        "prompt": "Almace sword of Archbishop Turpin, Charlemagne's paladin weapon, holy light, cross guard, silver and gold colors, medieval European holy sword"
    },
    {
        "id": "weapon_arondight",
        "name_cn": "无毁的湖光",
        "culture": "medieval_europe",
        "prompt": "Arondight sword of Lancelot, sister sword to Excalibur, blue lake light, unbreakable blade, water and light elements, Arthurian legendary weapon"
    },
    {
        "id": "weapon_galatine",
        "name_cn": "转轮胜利之剑",
        "culture": "medieval_europe",
        "prompt": "Galatine sun sword of Sir Gawain, strongest at noon, solar flames, fire and light elements, golden radiance, Round Table knight weapon"
    },

    # 凯尔特武器
    {
        "id": "weapon_caladbolg",
        "name_cn": "硬光剑",
        "culture": "celtic",
        "prompt": "Caladbolg rainbow sword of Fergus mac Róich, can cleave mountain tops, rainbow light blade, wind element, Celtic Irish legendary weapon"
    },
    {
        "id": "weapon_cruaidin",
        "name_cn": "战斗硬剑",
        "culture": "celtic",
        "prompt": "Cruaidín Catutchenn battle sword that burns in combat, fire element, Celtic warrior weapon, flames engulfing blade"
    },

    # 印度武器
    {
        "id": "weapon_kaumodaki",
        "name_cn": "俱卢神棒",
        "culture": "indian",
        "prompt": "Kaumodaki divine mace of Vishnu, golden club with sacred inscriptions, thunder and light powers, Hindu deity weapon, lotus patterns"
    },
    {
        "id": "weapon_pashupatastra",
        "name_cn": "兽主之矢",
        "culture": "indian",
        "prompt": "Pashupatastra ultimate weapon of Shiva, divine bow with world-destroying arrows, fire and death elements, cosmic destruction power, Hindu mythological weapon"
    },

    # 阿拉伯武器
    {
        "id": "weapon_scimitar",
        "name_cn": "弯月刀",
        "culture": "arabian",
        "prompt": "Arabian scimitar with curved crescent blade, Damascus steel patterns, fire element, golden ornate hilt, Islamic warrior sword"
    },
    {
        "id": "weapon_jambiya",
        "name_cn": "阿拉伯短剑",
        "culture": "arabian",
        "prompt": "Jambiya traditional Yemeni dagger, S-curved blade, rhino horn handle, ornate decorations, Arabian honor symbol"
    },
    {
        "id": "weapon_khanda",
        "name_cn": "印度阔剑",
        "culture": "arabian",
        "prompt": "Khanda Sikh double-edged sword, wide straight blade, holy light, Sikh warrior weapon, faith and justice symbol"
    },

    # 埃及武器
    {
        "id": "weapon_anubis_staff",
        "name_cn": "阿努比斯权杖",
        "culture": "egyptian",
        "prompt": "Staff of Anubis god of death, jackal head decoration, obsidian and gold, death judgment power, Egyptian underworld deity weapon"
    },
    {
        "id": "weapon_horus_spear",
        "name_cn": "荷鲁斯之矛",
        "culture": "egyptian",
        "prompt": "Spear of Horus sky god, falcon-shaped spearhead, golden shaft, holy light and flight power, Egyptian pharaoh guardian weapon"
    },
    {
        "id": "weapon_set_axe",
        "name_cn": "塞特战斧",
        "culture": "egyptian",
        "prompt": "Battle axe of Set chaos god, desert storm power, beast head decorations, chaos element, Egyptian mythology weapon"
    },

    # 波斯武器
    {
        "id": "weapon_acinaces",
        "name_cn": "阿奇那刻斯短剑",
        "culture": "persian",
        "prompt": "Acinaces Persian noble dagger, straight blade, winged guard, golden ornate scabbard, Persian Empire royal weapon"
    },
    {
        "id": "weapon_khopesh_persian",
        "name_cn": "波斯镰刀剑",
        "culture": "persian",
        "prompt": "Persian khopesh sickle sword, curved blade, wind element, shield-hooking design, Persian warrior weapon"
    },
    {
        "id": "weapon_katar",
        "name_cn": "卡塔尔拳刃",
        "culture": "persian",
        "prompt": "Katar Indian punch dagger, horizontal cross grip, triangular blade, assassin weapon, dark element, armor-piercing design"
    },

    # 中美洲武器
    {
        "id": "weapon_atlatl",
        "name_cn": "投矛器",
        "culture": "mesoamerican",
        "prompt": "Atlatl Aztec spear-thrower, wooden lever device with feather decorations, wind element, Mesoamerican projectile weapon"
    },
    {
        "id": "weapon_tepoztopilli",
        "name_cn": "特波兹托皮利",
        "culture": "mesoamerican",
        "prompt": "Tepoztopilli Aztec spear with obsidian blades on sides, wooden shaft, earth element, eagle warrior weapon"
    },
    {
        "id": "weapon_huitzauhqui",
        "name_cn": "刺棒",
        "culture": "mesoamerican",
        "prompt": "Huitzauhqui Aztec spiked club, wooden mace with obsidian and bone spikes, earth element, tribal warrior weapon"
    },
    {
        "id": "weapon_tecpatl",
        "name_cn": "祭祀刀",
        "culture": "mesoamerican",
        "prompt": "Tecpatl Aztec sacrificial knife, razor-sharp obsidian blade, death element, ritual ceremonial weapon, pyramid altar tool"
    },

    # 非洲武器
    {
        "id": "weapon_iklwa",
        "name_cn": "伊克尔瓦短矛",
        "culture": "african",
        "prompt": "Iklwa Zulu short stabbing spear, broad blade, Shaka's military reform weapon, earth element, African close-combat spear"
    },
    {
        "id": "weapon_shotel",
        "name_cn": "埃塞俄比亚弯刀",
        "culture": "african",
        "prompt": "Shotel Ethiopian curved sword, extreme sickle curve, bypass shield design, wind element, African highland warrior weapon"
    },
    {
        "id": "weapon_makraka",
        "name_cn": "马克拉卡飞刀",
        "culture": "african",
        "prompt": "Makraka Central African throwing knife, wavy curved blade, unpredictable flight path, wind element, tribal hunting weapon"
    },
    {
        "id": "weapon_mambele",
        "name_cn": "曼贝勒飞刀",
        "culture": "african",
        "prompt": "Mambele West African multi-bladed throwing weapon, lightning shape with multiple sharp edges, dark element, tribal warrior tool"
    },

    # 中国武术武器
    {
        "id": "weapon_shuang_gou",
        "name_cn": "鸳鸯钩",
        "culture": "chinese",
        "prompt": "Twin hooks Chinese martial arts weapon, paired hook swords connected, silver blades with wind element, elegant flowing movements, wushu weapon"
    },
    {
        "id": "weapon_meteor_hammer",
        "name_cn": "流星锤",
        "culture": "chinese",
        "prompt": "Meteor hammer Chinese soft weapon, iron hammer on chain, thunder element, spinning attack motion, Chinese kung fu weapon"
    },
]

def main():
    """主函数"""
    # 读取现有prompts.json
    prompts_file = "/Users/zyb/Desktop/Harmony/LegendaryArmory/scripts/prompts.json"

    with open(prompts_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    current_count = len(data['creatures'])
    print(f"当前提示词数量: {current_count}")

    # 添加新提示词
    data['creatures'].extend(new_weapon_prompts)

    new_count = len(data['creatures'])
    print(f"新增提示词数量: {len(new_weapon_prompts)}")
    print(f"更新后提示词数量: {new_count}")

    # 保存更新后的数据
    with open(prompts_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n✓ 提示词已更新!")
    print(f"文件位置: {prompts_file}")

if __name__ == "__main__":
    main()
