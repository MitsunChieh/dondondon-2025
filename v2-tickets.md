# 鏡子迷宮推理遊戲 v2 - 實作任務清單

## 1. 基本 M*N 盤面生成
### 任務描述
實作可自訂大小的遊戲盤面，支援 M*N 的房間配置。

### 子任務
- [ ] 建立盤面大小設定介面
  - 寬度(M)和高度(N)輸入欄位
  - 設定按鈕
  - 預設值選項（3x3, 4x4, 5x5）
- [ ] 實作盤面大小驗證
  - 最小限制（2x2）
  - 最大限制（8x8）
  - 數值有效性檢查
- [ ] 動態生成房間網格
  - 使用 CSS Grid 實現
  - 房間大小自適應
  - 保持房間間距一致

### 技術重點
- CSS Grid 動態配置
- 響應式設計
- 輸入驗證

## 2. 門的位置計算與顯示
### 任務描述
根據盤面大小自動計算並放置外門，確保門的位置和方向正確。

### 子任務
- [ ] 實作門的位置計算邏輯
  - 計算總門數（2*(M+N)）
  - 計算每個門的位置
  - 確定門的方向
- [ ] 動態生成門的 HTML 結構
  - 使用 Font Awesome 箭頭
  - 門的編號顯示
  - 選中效果
- [ ] 優化門的點擊區域
  - 確保點擊區域足夠大
  - 保持編號清晰可見

### 技術重點
- 位置計算算法
- 動態 DOM 操作
- 事件處理優化

## 3. 光線路徑計算優化
### 任務描述
調整光線路徑計算邏輯，支援不同大小的盤面。

### 子任務
- [ ] 重構光線路徑計算
  - 支援 M*N 盤面
  - 優化反射計算
  - 處理邊界情況
- [ ] 實作路徑可視化
  - 動畫效果
  - 清晰的路徑顯示
  - 反射點標記
- [ ] 優化性能
  - 減少不必要的計算
  - 優化動畫效能

### 技術重點
- 路徑計算算法
- 動畫實現
- 性能優化

## 4. 遊戲難度調整
### 任務描述
根據盤面大小自動調整遊戲難度，確保遊戲平衡性。

### 子任務
- [ ] 實作難度計算系統
  - 基於盤面大小
  - 考慮鏡子數量
  - 計算複雜度
- [ ] 調整鏡子生成邏輯
  - 動態調整出現機率
  - 確保可解性
  - 避免過於簡單或困難
- [ ] 實作步數限制
  - 根據難度調整
  - 顯示剩餘步數
  - 步數提示

### 技術重點
- 難度計算算法
- 隨機生成優化
- 遊戲平衡性

## 5. 使用者介面優化
### 任務描述
優化使用者介面，提供更好的遊戲體驗。

### 子任務
- [ ] 實作盤面大小預覽
  - 即時預覽效果
  - 大小建議
  - 難度提示
- [ ] 優化控制面板
  - 重新排列按鈕
  - 加入快捷操作
  - 提供操作提示
- [ ] 實作遊戲狀態顯示
  - 當前難度
  - 剩餘步數
  - 完成進度

### 技術重點
- UI/UX 設計
- 響應式布局
- 使用者體驗優化

## 6. 響應式設計實作
### 任務描述
確保遊戲在不同設備上都能正常運作。

### 子任務
- [ ] 實作自適應布局
  - 支援不同螢幕大小
  - 保持元素比例
  - 優化觸控操作
- [ ] 優化移動設備體驗
  - 觸控優化
  - 按鈕大小調整
  - 操作提示
- [ ] 實作縮放控制
  - 自動縮放
  - 手動縮放
  - 保持清晰度

### 技術重點
- 響應式設計
- 觸控優化
- 性能優化

## 7. 測試與平衡調整
### 任務描述
進行全面測試並調整遊戲平衡性。

### 子任務
- [ ] 實作自動測試
  - 路徑計算測試
  - 難度平衡測試
  - 性能測試
- [ ] 進行使用者測試
  - 收集反饋
  - 分析使用數據
  - 調整難度
- [ ] 優化遊戲平衡
  - 調整參數
  - 優化體驗
  - 修復問題

### 技術重點
- 測試框架
- 數據分析
- 平衡性調整

## 優先順序建議
1. 基本 M*N 盤面生成
2. 門的位置計算與顯示
3. 光線路徑計算優化
4. 遊戲難度調整
5. 使用者介面優化
6. 響應式設計實作
7. 測試與平衡調整

## 注意事項
- 每個任務完成後需要進行測試
- 保持代碼可維護性
- 注意性能優化
- 確保向下相容性
- 保持文檔更新 