#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成题目审查报告
输出每道题的详细信息，便于人工检查答案是否正确
"""

import json
from pathlib import Path

def review_questions():
    """生成题目审查报告"""
    questions_path = Path(__file__).parent.parent / 'entry/src/main/resources/rawfile/data/questions.json'

    with open(questions_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    questions = data.get('questions', [])

    print("=" * 80)
    print("题目审查报告 - 检查答案索引是否与解析匹配")
    print("=" * 80)
    print()

    for i, q in enumerate(questions, 1):
        q_id = q.get('id', '')
        question = q.get('question', '')
        options = q.get('options', [])
        correct_answer = q.get('correct_answer')
        explanation = q.get('explanation', '')

        print(f"【题目 {i}】ID: {q_id}")
        print(f"问题: {question}")
        print(f"选项:")
        for idx, opt in enumerate(options):
            marker = "✓" if idx == correct_answer else " "
            print(f"  [{marker}] {idx}. {opt}")
        print(f"正确答案索引: {correct_answer} -> {options[correct_answer] if 0 <= correct_answer < len(options) else 'ERROR'}")
        print(f"解析: {explanation}")
        print("-" * 80)
        print()

if __name__ == '__main__':
    review_questions()
