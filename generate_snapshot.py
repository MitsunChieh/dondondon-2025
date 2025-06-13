import os
import json
import re
from typing import Dict, List, Any

def extract_script_blocks(content: str) -> list:
    """Extract all <script>...</script> blocks from HTML."""
    return re.findall(r'<script[^>]*>([\s\S]*?)<\/script>', content, re.IGNORECASE)

def find_matching_brace(s, start):
    """Find the position of the matching closing brace for the opening brace at start."""
    depth = 0
    for i in range(start, len(s)):
        if s[i] == '{':
            depth += 1
        elif s[i] == '}':
            depth -= 1
            if depth == 0:
                return i
    return -1

def extract_classes(content: str) -> List[Dict[str, Any]]:
    """Extract class definitions and their methods from JS code (support nested braces)."""
    classes = []
    class_pattern = r'class\s+(\w+)\s*{'
    for class_match in re.finditer(class_pattern, content):
        class_name = class_match.group(1)
        body_start = class_match.end()  # position after the opening brace
        body_end = find_matching_brace(content, body_start - 1)
        if body_end == -1:
            continue
        class_body = content[body_start:body_end]
        # Extract methods (skip constructor)
        method_pattern = r'([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*{'
        methods = []
        for method_match in re.finditer(method_pattern, class_body):
            method_name = method_match.group(1)
            if method_name == 'constructor':
                continue
            params = method_match.group(2)
            method_body_start = method_match.end()
            method_body_end = find_matching_brace(class_body, method_body_start - 1)
            if method_body_end == -1:
                continue
            body = class_body[method_body_start:method_body_end]
            # 根據 method 名稱與參數生成 docstring
            docstring = generate_docstring(method_name, params)
            methods.append({
                'name': method_name,
                'params': params,
                'docstring': docstring
            })
        classes.append({
            'name': class_name,
            'methods': methods
        })
    return classes

def generate_docstring(method_name: str, params: str) -> str:
    """根據 method 名稱與參數生成 docstring。"""
    if method_name == 'initializeGame':
        return "初始化遊戲，隨機生成初始鏡子配置，並重置遊戲狀態。"
    elif method_name == 'setupEventListeners':
        return "設置所有事件監聽器，包括外門點擊、猜測格子點擊等。"
    elif method_name == 'selectDoor':
        return "選擇一個外門作為光線入口。"
    elif method_name == 'startExploration':
        return "開始探索，模擬光線從選定外門進入後的路徑。"
    elif method_name == 'simulateMovement':
        return "模擬光線從指定外門進入後的路徑，計算反射次數與出口。"
    elif method_name == 'calculateReflection':
        return "計算光線在鏡子上的反射方向。"
    elif method_name == 'findExitDoor':
        return "根據房間與方向找到對應的外門。"
    elif method_name == 'toggleGuess':
        return "切換指定房間的鏡子猜測狀態（無鏡、正斜鏡、反斜鏡）。"
    elif method_name == 'updateGuessDisplay':
        return "更新猜測區域的顯示。"
    elif method_name == 'updateHistoryDisplay':
        return "更新探索歷史記錄的顯示。"
    elif method_name == 'resetMirrors':
        return "重置鏡子配置到初始狀態。"
    elif method_name == 'submitGuess':
        return "提交猜測，檢查是否猜對所有鏡子配置。"
    elif method_name == 'revealMirrors':
        return "在主迷宮顯示正確的鏡子配置。"
    elif method_name == 'showMessage':
        return "顯示訊息，並在指定時間後自動消失。"
    else:
        return "未知功能。"

def extract_functions(content: str) -> List[Dict[str, Any]]:
    """Extract top-level function definitions from JavaScript code."""
    functions = []
    pattern = r'function\s+(\w+)\s*\(([^)]*)\)\s*{'
    for match in re.finditer(pattern, content):
        name = match.group(1)
        params = match.group(2)
        body_start = match.end()
        body_end = find_matching_brace(content, body_start - 1)
        if body_end == -1:
            continue
        body = content[body_start:body_end]
        docstring = generate_docstring(name, params)
        functions.append({
            'name': name,
            'params': params,
            'docstring': docstring
        })
    return functions

def extract_important_variables(content: str) -> List[Dict[str, Any]]:
    variables = []
    pattern = r'(?:const|let|var)\s+(\w+)\s*=\s*([^;]+);'
    for match in re.finditer(pattern, content):
        var_name = match.group(1)
        var_value = match.group(2)
        if len(var_value) < 100 and not var_value.startswith('document.'):
            variables.append({
                'name': var_name,
                'value': var_value.strip()
            })
    return variables

def scan_project(root_dir: str) -> Dict[str, Any]:
    snapshot = {
        'files': {},
        'functions': [],
        'classes': [],
        'variables': []
    }
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(('.js', '.html', '.css')):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # 專門針對 HTML 內 <script> 區塊分析
                    scripts = extract_script_blocks(content) if file.endswith('.html') else [content]
                    for script in scripts:
                        snapshot['functions'].extend(extract_functions(script))
                        snapshot['classes'].extend(extract_classes(script))
                        snapshot['variables'].extend(extract_important_variables(script))
                    snapshot['files'][file_path] = {
                        'type': file.split('.')[-1],
                        'size': len(content)
                    }
    return snapshot

def main():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    snapshot = scan_project(current_dir)
    with open('project_snapshot.json', 'w', encoding='utf-8') as f:
        json.dump(snapshot, f, ensure_ascii=False, indent=2)

if __name__ == '__main__':
    main() 