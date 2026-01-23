#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
深度分析explanation与正确答案的匹配度
检查是否有explanation描述不清或与正确答案不符的情况
"""

import json
from pathlib import Path

def analyze_explanations():
    """分析explanation质量"""
    questions_path = Path(__file__).parent.parent / 'entry/src/main/resources/rawfile/data/questions.json'

    with open(questions_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    questions = data.get('questions', [])

    print("=" * 80)
    print("Explanation质量分析报告")
    print("=" * 80)
    print()

    # 分类统计
    clear_explanations = []  # 清晰的解析
    vague_explanations = []  # 模糊的解析
    missing_explanations = []  # 缺失的解析

    for q in questions:
        q_id = q.get('id', '')
        question = q.get('question', '')
        options = q.get('options', [])
        correct_answer = q.get('correct_answer')
        explanation = q.get('explanation', '')

        correct_option = options[correct_answer]

        # 检查1: 是否有explanation
        if not explanation or explanation.strip() == '':
            missing_explanations.append({
                'id': q_id,
                'question': question,
                'correct_option': correct_option
            })
            continue

        # 检查2: explanation是否包含正确答案的关键信息
        # 提取正确答案的关键词
        keywords = []

        # 对于短答案（<=4字），直接作为关键词
        if len(correct_option) <= 4:
            keywords.append(correct_option)
        else:
            # 对于长答案，提取前3个字
            keywords.append(correct_option[:3])

        # 检查关键词是否在explanation中
        found = any(kw in explanation for kw in keywords)

        if found:
            clear_explanations.append({
                'id': q_id,
                'question': question,
                'correct_option': correct_option,
                'explanation': explanation
            })
        else:
            # 可能是用不同的表述方式
            vague_explanations.append({
                'id': q_id,
                'question': question,
                'options': options,
                'correct_answer': correct_answer,
                'correct_option': correct_option,
                'explanation': explanation,
                'keywords': keywords
            })

    # 输出统计
    print(f"📊 统计结果:")
    print(f"  清晰的解析: {len(clear_explanations)} 题 ({len(clear_explanations)/len(questions)*100:.1f}%)")
    print(f"  模糊的解析: {len(vague_explanations)} 题 ({len(vague_explanations)/len(questions)*100:.1f}%)")
    print(f"  缺失的解析: {len(missing_explanations)} 题 ({len(missing_explanations)/len(questions)*100:.1f}%)")
    print()

    # 输出缺失的解析
    if missing_explanations:
        print("=" * 80)
        print(f"❌ 缺失解析的题目 ({len(missing_explanations)} 题):")
        print("=" * 80)
        for item in missing_explanations:
            print(f"\n题目ID: {item['id']}")
            print(f"问题: {item['question']}")
            print(f"正确答案: {item['correct_option']}")
            print("-" * 80)

    # 输出模糊的解析（需要人工审查）
    if vague_explanations:
        print()
        print("=" * 80)
        print(f"⚠️  需要人工审查的题目 ({len(vague_explanations)} 题):")
        print("=" * 80)
        print("这些题目的explanation中未直接包含正确答案的关键词")
        print("可能是用了不同的表述方式，需要人工确认是否准确")
        print()

        for item in vague_explanations:
            print(f"\n题目ID: {item['id']}")
            print(f"问题: {item['question']}")
            print(f"选项:")
            for idx, opt in enumerate(item['options']):
                marker = "✓" if idx == item['correct_answer'] else " "
                print(f"  [{marker}] {idx}. {opt}")
            print(f"正确答案: {item['correct_option']}")
            print(f"解析: {item['explanation']}")
            print(f"关键词: {item['keywords']}")
            print("-" * 80)

    return len(missing_explanations) == 0 and len(vague_explanations) == 0

if __name__ == '__main__':
    import sys
    success = analyze_explanations()
    sys.exit(0 if success else 1)
