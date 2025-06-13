#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'json'
require 'csv'
require 'date'

class MirrorMaze
  EMPTY = '.'
  FORWARD_MIRROR = '/'
  BACKWARD_MIRROR = '\\'

  attr_reader :width, :height, :grid

  def initialize(width = 3, height = 3, grid = nil)
    @width = width
    @height = height
    @grid = grid || Array.new(height) { Array.new(width, EMPTY) }
  end

  # 隨機生成迷宮
  def self.generate(width = 3, height = 3, mirror_probability = 0.3)
    grid = Array.new(height) do
      Array.new(width) do
        rand < mirror_probability ? [FORWARD_MIRROR, BACKWARD_MIRROR].sample : EMPTY
      end
    end
    new(width, height, grid)
  end

  # 從字串解析迷宮
  def self.parse(input)
    rows = input.strip.split("\n")
    height = rows.size
    width = rows.first.size
    grid = rows.map { |row| row.chars }
    new(width, height, grid)
  end

  # 計算從指定門進入的光線路徑
  def calculate_path(entry_door)
    entry_door = entry_door - 1
    pos, dir = get_initial_position_and_direction(entry_door)
    reflections = 0
    path = []
    
    loop do
      # 檢查是否到達出口
      if pos[0] < 0 || pos[0] >= @height || pos[1] < 0 || pos[1] >= @width
        exit_door = find_exit_door(pos, dir)
        return {
          exit_door: exit_door + 1,
          reflections: reflections,
          path: path
        }
      end
      # 只在盤面內才記錄路徑
      path << [pos[0], pos[1]]
      mirror = @grid[pos[0]][pos[1]]
      if mirror != '.'
        reflections += 1
        dir = calculate_reflection(dir, mirror)
        rotate_mirror(pos[0], pos[1])
      end
      pos = get_next_room(pos, dir)
    end
  end

  # 分析所有可能的進出門組合
  def analyze_all_paths
    total_doors = 2 * (width + height)
    results = []

    (1..total_doors).each do |entry_door|
      path = calculate_path(entry_door)
      results << {
        entry_door: entry_door,
        exit_door: path[:exit_door],
        reflections: path[:reflections],
        path: path[:path]
      }
    end

    results
  end

  # 執行完整的難度分析
  def analyze_difficulty
    total_doors = 2 * (width + height)
    total_reflections = 0
    exploration_results = []
    initial_grid = deep_copy_grid

    # 對每個門進行三次探索
    (1..total_doors).each do |door|
      3.times do |attempt|
        result = calculate_path(door)
        total_reflections += result[:reflections]
        exploration_results << {
          door: door,
          attempt: attempt + 1,
          exit_door: result[:exit_door],
          reflections: result[:reflections],
          grid_state: deep_copy_grid
        }
      end
    end

    # 計算統計數據
    mirror_count = initial_grid.flatten.count { |cell| cell != EMPTY }
    mirror_percentage = (mirror_count.to_f / (width * height)) * 100

    {
      initial_config: initial_grid.map(&:join),
      room_count: width * height,
      mirror_count: mirror_count,
      mirror_percentage: mirror_percentage.round(2),
      total_reflections: total_reflections,
      exploration_results: exploration_results
    }
  end

  def print_grid(grid)
    width = grid[0].size
    height = grid.size
    total_doors = 2 * (width + height)

    # 上方門（右到左）
    print "  "
    (0...width).each do |x|
      up_door = width + height + width - x
      print " #{up_door.to_s.rjust(2)}"
    end
    puts

    # 左側、盤面、右側
    (0...height).each do |y|
      # 左側門（上到下）
      left_door = width * 2 + height + y + 1
      print "#{left_door.to_s.rjust(2)} "
      # 盤面
      (0...width).each do |x|
        print " #{grid[y][x]} "
      end
      # 右側門（下到上）
      right_door = width + height - y
      print "#{right_door.to_s.rjust(2)}"
      puts
    end

    # 下方門（左到右）
    print "  "
    (0...width).each do |x|
      print " #{(x + 1).to_s.rjust(2)}"
    end
    puts
  end

  private

  # 取得初始位置與方向向量
  def get_initial_position_and_direction(door_number)
    total_doors = 2 * (width + height)
    door_number = door_number % total_doors
    # 下方門（從左到右）
    if door_number < width
      return [[height - 1, door_number], [-1, 0]] # 往上
    # 右方門（從下到上）
    elsif door_number < width + height
      return [[height - 1 - (door_number - width), width - 1], [0, -1]] # 往左
    # 上方門（從右到左）
    elsif door_number < 2 * width + height
      return [[0, width - 1 - (door_number - width - height)], [1, 0]] # 往下
    # 左方門（從上到下）
    else
      return [[door_number - 2 * width - height, 0], [0, 1]] # 往右
    end
  end

  def get_mirror_at(pos)
    row, col = pos
    grid[row][col]
  end

  def rotate_mirror(row, col)
    current_mirror = grid[row][col]
    return if current_mirror == EMPTY
    grid[row][col] = current_mirror == FORWARD_MIRROR ? BACKWARD_MIRROR : FORWARD_MIRROR
  end

  def get_opposite_direction(direction)
    {
      'up' => 'down',
      'down' => 'up',
      'left' => 'right',
      'right' => 'left'
    }[direction]
  end

  # 計算反射後的新方向向量
  def calculate_reflection(dir, mirror_type)
    # dir: [drow, dcol]
    if mirror_type == FORWARD_MIRROR
      # / 鏡
      # 右進(0,1)→下出(-1,0)
      # 下進(-1,0)→右出(0,1)
      # 左進(0,-1)→上出(1,0)
      # 上進(1,0)→左出(0,-1)
      case dir
      when [0,1]   # 右
        [-1,0]
      when [-1,0]  # 下
        [0,1]
      when [0,-1]  # 左
        [1,0]
      when [1,0]   # 上
        [0,-1]
      end
    else
      # \ 鏡
      # 右進(0,1)→上出(1,0)
      # 上進(1,0)→右出(0,1)
      # 左進(0,-1)→下出(-1,0)
      # 下進(-1,0)→左出(0,-1)
      case dir
      when [0,1]   # 右
        [1,0]
      when [1,0]   # 上
        [0,1]
      when [0,-1]  # 左
        [-1,0]
      when [-1,0]  # 下
        [0,-1]
      end
    end
  end

  def get_next_room(pos, dir)
    # pos: [row, col], dir: [drow, dcol]
    [pos[0] + dir[0], pos[1] + dir[1]]
  end

  # 根據離開座標與方向向量判斷出口門號
  def find_exit_door(pos, dir)
    row, col = pos
    if row < 0
      # 上方門（從右到左）
      return width + height + (width - col - 1)
    elsif row >= height
      # 下方門（從左到右）
      return col
    elsif col < 0
      # 左方門（從上到下）
      return 2 * width + height + row
    elsif col >= width
      # 右方門（從下到上）
      return width + (height - row - 1)
    end
  end

  def deep_copy_grid
    grid.map(&:dup)
  end
end

# 解析命令列參數
options = {
  width: 3,
  height: 3,
  mirror_probability: 0.3,
  output_format: 'text',
  iterations: 1,
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "使用方式: ruby mirror_maze_analyzer.rb [選項]"

  opts.on("-w", "--width WIDTH", Integer, "設定迷宮寬度") do |w|
    options[:width] = w
  end

  opts.on("-h", "--height HEIGHT", Integer, "設定迷宮高度") do |h|
    options[:height] = h
  end

  opts.on("-p", "--probability PROB", Float, "設定鏡子出現機率 (0.0-1.0)") do |p|
    options[:mirror_probability] = p
  end

  opts.on("-f", "--format FORMAT", String, "設定輸出格式 (text/json/csv)") do |f|
    options[:output_format] = f
  end

  opts.on("-i", "--iterations ITERATIONS", Integer, "設定生成迷宮數量") do |i|
    options[:iterations] = i
  end

  opts.on("-v", "--verbose", "顯示詳細輸出") do
    options[:verbose] = true
  end

  opts.on("--help", "顯示說明文件") do
    puts opts
    exit
  end
end.parse!

# 主程式
begin
  results = []
  filename = nil
  
  options[:iterations].times do |i|
    maze = MirrorMaze.generate(
      options[:width],
      options[:height],
      options[:mirror_probability]
    )

    analysis = maze.analyze_difficulty
    results << analysis

    case options[:output_format]
    when 'json'
      puts analysis.to_json
    when 'csv'
      # 只在第一次迭代時建立檔案
      if i == 0
        room_count = analysis[:room_count]
        filename = "maze-analyzer-#{options[:width]}x#{options[:height]}-#{room_count}-#{Time.now.to_i}.csv"
        CSV.open(filename, "w") do |csv|
          csv << ["鏡子數量", "鏡子佔比", "總碰撞數"]
        end
      end
      # 追加資料
      CSV.open(filename, "a") do |csv|
        csv << [
          analysis[:mirror_count],
          "#{analysis[:mirror_percentage]}%",
          analysis[:total_reflections]
        ]
      end
    else
      puts "\n迷宮 #{i + 1}:"
      puts "\n初始配置："
      maze.print_grid(analysis[:initial_config])
      puts "\n迷宮大小：#{options[:width]}x#{options[:height]}"
      puts "房間數量：#{analysis[:room_count]}"
      puts "鏡子數量：#{analysis[:mirror_count]}"
      puts "鏡子佔比：#{analysis[:mirror_percentage]}%"
      puts "總咚聲數：#{analysis[:total_reflections]}"
      
      if options[:verbose]
        puts "\n探索結果："
        analysis[:exploration_results].each do |result|
          puts "門 #{result[:door]} 第 #{result[:attempt]} 次：出口 #{result[:exit_door]} (咚聲數: #{result[:reflections]})"
          if result[:attempt] == 3
            puts "  探索後盤面："
            maze.print_grid(result[:grid_state])
          end
        end
      end
      puts "\n" + "-" * 50
    end
  end
  
  if options[:output_format] == 'csv'
    puts "CSV 檔案已生成：#{filename}"
  end
rescue => e
  puts "錯誤：#{e.message}"
  exit 1
end 