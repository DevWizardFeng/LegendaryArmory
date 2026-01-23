#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试选项打乱逻辑
模拟DataLoader.ets中的打乱算法，验证正确答案索引是否正确更新
"""

import json
import random
from pathlib import Path

def shuffle_options_test():
    """测试选项打乱逻辑"""
    questions_path = Path(__file__).parent.parent / 'entry/src/main/resources/rawfile/data/questions.json'

    with open(questions_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    questions = data.get('questions', [])

    print("=" * 80)
    print("选项打乱逻辑测试")
    print("=" * 80)
    print()

    issues = []

    for q in questions:
        q_id = q.get('id', '')
        options = q.get('options', [])
        correct_answer = q.get('correct_answer')
        explanation = q.get('explanation', '')

        # 保存原始正确答案文本
        original_correct_text = options[correct_answer]

        # 模拟DataLoader.ets的打乱逻辑
        # 创建带索引的选项数组
        indexed_options = [{'text': opt, 'originalIndex': i} for i, opt in enumerate(options)]

        # Fisher-Yates打��算法
        for k in range(len(indexed_options) - 1, 0, -1):
            j = random.randint(0, k)
            indexed_options[k], indexed_options[j] = indexed_options[j], indexed_options[k]

        # 提取打乱后的选项文本
        shuffled_options = [item['text'] for item in indexed_options]

        # 找到正确答案在新数组中的位置
        new_correct_index = -1
        for n, item in enumerate(indexed_options):
            if item['originalIndex'] == correct_answer:
                new_correct_index = n
                break

        # 验证：新索引指向的文本应该和原始正确答案文本相同
        if new_correct_index == -1:
            issues.append({
                'id': q_id,
                'type': 'index_not_found',
                'message': f"无法找到正确答案的新索引"
            })
        elif shuffled_options[new_correct_index] != original_correct_text:
            issues.append({
                'id': q_id,
                'type': 'text_mismatch',
                'original_index': correct_answer,
                'original_text': original_correct_text,
                'new_index': new_correct_index,
                'new_text': shuffled_options[new_correct_index],
                'message': f"打乱后的正确答案文本不匹配"
            })

    if not issues:
        print("✅ 选项打乱逻辑测试通过！")
        print()
        print("测试说明：")
        print("- 模拟了DataLoader.ets中的选项打乱算法")
        print("- 验证了正确答案索引更新的正确性")
        print("- 所有题目的正确答案文本在打乱后保持一致")
        return True

    print(f"❌ 发现 {len(issues)} 个问题：")
    print()

    for issue in issues:
        print(f"题目ID: {issue['id']}")
        print(f"问题类型: {issue['type']}")
        if issue['type'] == 'text_mismatch':
            print(f"  原始索引: {issue['original_index']} -> {issue['original_text']}")
            print(f"  新索引: {issue['new_index']} -> {issue['new_text']}")
        print(f"  描述: {issue['message']}")
        print("-" * 80)
        print()

    return False

if __name__ == '__main__':
    import sys
    # 运行多次测试，因为打乱是随机的
    print("运行10次随机测试...")
    print()
    all_passed = True
    for i in range(10):
        print(f"第 {i+1} 次测试:")
        if not shuffle_options_test():
            all_passed = False
            break
        print()

    if all_passed:
        print("=" * 80)
        print("✅ 所有测试通过！选项打乱逻辑正确。")
        print("=" * 80)

    sys.exit(0 if all_passed else 1)
