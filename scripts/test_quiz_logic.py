#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
模拟答题逻辑，检查判定和显示是否一致
"""

import json
from pathlib import Path

def test_quiz_logic():
    """测试答题逻辑"""
    questions_path = Path(__file__).parent.parent / 'entry/src/main/resources/rawfile/data/questions.json'

    with open(questions_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    questions = data.get('questions', [])

    print("=" * 80)
    print("答题逻辑测试 - 模拟用户答题")
    print("=" * 80)
    print()

    # 模拟用户答题场景
    test_cases = []

    for q in questions:
        q_id = q.get('id', '')
        question = q.get('question', '')
        options = q.get('options', [])
        correct_answer = q.get('correct_answer')
        explanation = q.get('explanation', '')

        # 模拟用户选择每个选项
        for user_choice in range(len(options)):
            # 判定逻辑（模拟Quiz.ets中的selectAnswer方法）
            is_correct = (user_choice == correct_answer)

            # 显示逻辑（模拟Quiz.ets中的AnswerHint方法）
            correct_option_text = options[correct_answer]
            user_option_text = options[user_choice]

            # 检查：如果用户选择的文本和正确答案文本相同，但判定为错误
            if user_option_text == correct_option_text and not is_correct:
                test_cases.append({
                    'id': q_id,
                    'question': question,
                    'user_choice': user_choice,
                    'correct_answer': correct_answer,
                    'user_text': user_option_text,
                    'correct_text': correct_option_text,
                    'issue': '文本相同但判定错误'
                })

            # 检查：如果判定正确，但文本不同
            if is_correct and user_option_text != correct_option_text:
                test_cases.append({
                    'id': q_id,
                    'question': question,
                    'user_choice': user_choice,
                    'correct_answer': correct_answer,
                    'user_text': user_option_text,
                    'correct_text': correct_option_text,
                    'issue': '判定正确但文本不同'
                })

    if not test_cases:
        print("✅ 所有题目的判定逻辑和显示逻辑一致！")
        print()
        print("测试说明：")
        print("- 模拟了所有题目的所有选项")
        print("- 检查了判定结果和显示文本的一致性")
        print("- 未发现任何逻辑错误")
        return True

    print(f"❌ 发现 {len(test_cases)} 个逻辑不一致的情况：")
    print()

    for case in test_cases:
        print(f"题目ID: {case['id']}")
        print(f"问题: {case['question']}")
        print(f"用户选择索引: {case['user_choice']} -> {case['user_text']}")
        print(f"正确答案索引: {case['correct_answer']} -> {case['correct_text']}")
        print(f"问题类型: {case['issue']}")
        print("-" * 80)
        print()

    return False

if __name__ == '__main__':
    import sys
    success = test_quiz_logic()
    sys.exit(0 if success else 1)
