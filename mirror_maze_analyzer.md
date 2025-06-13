# 鏡子迷宮分析器使用手冊

## 基本用法
```bash
ruby mirror_maze_analyzer.rb [選項]
```

## 命令列參數

| 參數 | 簡寫 | 說明 | 預設值 |
|------|------|------|--------|
| `--width` | `-w` | 設定迷宮寬度 | 3 |
| `--height` | `-h` | 設定迷宮高度 | 3 |
| `--probability` | `-p` | 設定鏡子出現機率 (0.0-1.0) | 0.3 |
| `--format` | `-f` | 設定輸出格式 (text/json) | text |
| `--iterations` | `-i` | 設定生成迷宮數量 | 1 |
| `--verbose` | `-v` | 顯示詳細輸出（包含探索結果） | 關閉 |
| `--help` | | 顯示說明文件 | |

## 使用範例

1. 生成 3x3 迷宮（預設）：
```bash
ruby mirror_maze_analyzer.rb
```

2. 生成 2x2 迷宮：
```bash
ruby mirror_maze_analyzer.rb -w 2 -h 2
```

3. 生成多個迷宮並以 JSON 格式輸出：
```bash
ruby mirror_maze_analyzer.rb -i 5 -f json
```

4. 調整鏡子出現機率：
```bash
ruby mirror_maze_analyzer.rb -p 0.5
```

5. 顯示詳細輸出：
```bash
ruby mirror_maze_analyzer.rb -v
```

6. 以 CSV 格式輸出多個迷宮：
```bash
ruby mirror_maze_analyzer.rb -w 2 -h 2 -i 3 -f csv
```

此時會產生檔名如：maze-analyzer-2x2-4-1718275200.csv，內容如下：

```
鏡子數量,鏡子佔比,總碰撞數
1,25.0%,12
3,75.0%,39
1,25.0%,12
```

- 檔名格式為 maze-analyzer-寬x高-房間數量-UNIX時間戳.csv
- 內容只包含鏡子數量、鏡子佔比、總碰撞數三欄
- 鏡子佔比欄位會自動加上 % 符號。

## 輸出說明

### 文字格式輸出（簡潔模式）
- 顯示迷宮初始配置
- 房間數量統計
- 鏡子數量及佔比
- 總咚聲數

### 文字格式輸出（詳細模式，使用 -v 選項）
- 簡潔模式的所有內容
- 每個門的探索結果
- 每次探索後的盤面狀態

### JSON 格式輸出
包含以下欄位：
- `initial_config`: 初始迷宮配置
- `room_count`: 房間數量
- `mirror_count`: 鏡子數量
- `mirror_percentage`: 鏡子佔比
- `total_reflections`: 總咚聲數
- `exploration_results`: 探索結果列表

## 注意事項
1. 鏡子出現機率範圍為 0.0 到 1.0
2. 迷宮尺寸建議不要太大，以免影響效能
3. 生成多個迷宮時，建議使用 JSON 格式輸出
4. 使用 `-v` 選項可以查看詳細的探索過程 