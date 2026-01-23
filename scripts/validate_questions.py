#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
验证questions.json中的数据一致性
检查correct_answer索引是否与explanation描述匹配
"""

import json
import sys
from pathlib import Path

def validate_questions():
    """验证题目数据"""
    # 读取questions.json
    questions_path = Path(__file__).parent.parent / 'entry/src/main/resources/rawfile/data/questions.json'

    if not questions_path.exists():
        print(f"❌ 文件不存在: {questions_path}")
        return False

    with open(questions_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    questions = data.get('questions', [])
    print(f"📊 总共 {len(questions)} 道题目\n")

    issues = []

    for i, q in enumerate(questions):
        q_id = q.get('id', f'unknown_{i}')
        question = q.get('question', '')
        options = q.get('options', [])
        correct_answer = q.get('correct_answer')
        explanation = q.get('explanation', '')

        # 检查1: correct_answer是否在有效范围内
        if correct_answer is None:
            issues.append({
                'id': q_id,
                'type': 'missing_answer',
                'message': f"缺少correct_answer字段"
            })
            continue

        if not isinstance(correct_answer, int):
            issues.append({
                'id': q_id,
                'type': 'invalid_type',
                'message': f"correct_answer类型错误: {type(correct_answer)}, 值: {correct_answer}"
            })
            continue

        if correct_answer < 0 or correct_answer >= len(options):
            issues.append({
                'id': q_id,
                'type': 'out_of_range',
                'message': f"correct_answer={correct_answer} 超出选项范围 [0, {len(options)-1}]"
            })
            continue

        # 检查2: 正确答案文本是否在explanation中出现
        correct_option = options[correct_answer]

        # 简单的启发式检查：正确答案的关键词是否在解析中
        # 这不是100%准确，但可以发现明显的不一致
        if len(correct_option) >= 2:  # 至少2个字符才检查
            # 对于某些特殊情况，解析中可能用不同的表述
            # 例如："黄帝" 在解析中可能是 "黄帝所铸"
            # 所以我们只检查是否包含关键词

            # 提取关键词（去除标点符号）
            keywords = []
            if len(correct_option) <= 4:
                keywords.append(correct_option)
            else:
                # 对于较长的选项，提取前几个字作为关键词
                keywords.append(correct_option[:3])

            found = False
            for keyword in keywords:
                if keyword in explanation:
                    found = True
                    break

            if not found and explanation:  # 如果有解析但找不到关键词
                # 这可能是误报，所以我们标记为警告而不是错误
                issues.append({
                    'id': q_id,
                    'type': 'warning',
                    'question': question,
                    'options': options,
                    'correct_answer': correct_answer,
                    'correct_option': correct_option,
                    'explanation': explanation,
                    'message': f"⚠️  解析中未找到正确答案关键词"
                })

    # 输出结果
    if not issues:
        print("✅ 所有题目数据验证通过！")
        return True

    print(f"⚠️  发现 {len(issues)} 个问题:\n")

    errors = [issue for issue in issues if issue['type'] != 'warning']
    warnings = [issue for issue in issues if issue['type'] == 'warning']

    if errors:
        print(f"❌ 严重错误 ({len(errors)} 个):")
        for issue in errors:
            print(f"\n题目ID: {issue['id']}")
            print(f"  类型: {issue['type']}")
            print(f"  问题: {issue['message']}")

    if warnings:
        print(f"\n⚠️  警告 ({len(warnings)} 个):")
        for issue in warnings:
            print(f"\n题目ID: {issue['id']}")
            print(f"  题目: {issue['question']}")
            print(f"  选项: {issue['options']}")
            print(f"  正确答案索引: {issue['correct_answer']} -> {issue['correct_option']}")
            print(f"  解析: {issue['explanation']}")
            print(f"  问题: {issue['message']}")

    return len(errors) == 0

if __name__ == '__main__':
    success = validate_questions()
    sys.exit(0 if success else 1)
