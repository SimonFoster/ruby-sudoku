#! /usr/bin/env ruby

ROWS = 
  [[ 0,  1,  2,  3,  4,  5,  6,  7,  8],
   [ 9, 10, 11, 12, 13, 14, 15, 16, 17],
   [18, 19, 20, 21, 22, 23, 24, 25, 26],
   [27, 28, 29, 30, 31, 32, 33, 34, 35],
   [36, 37, 38, 39, 40, 41, 42, 43, 44],
   [45, 46, 47, 48, 49, 50, 51, 52, 53],
   [54, 55, 56, 57, 58, 59, 60, 61, 62],
   [63, 64, 65, 66, 67, 68, 69, 70, 71],
   [72, 73, 74, 75, 76, 77, 78, 79, 80]]

COLS =
  [[ 0,  9, 18, 27, 36, 45, 54, 63, 72],
   [ 1, 10, 19, 28, 37, 46, 55, 64, 73],
   [ 2, 11, 20, 29, 38, 47, 56, 65, 74],
   [ 3, 12, 21, 30, 39, 48, 57, 66, 75],
   [ 4, 13, 22, 31, 40, 49, 58, 67, 76],
   [ 5, 14, 23, 32, 41, 50, 59, 68, 77],
   [ 6, 15, 24, 33, 42, 51, 60, 69, 78],
   [ 7, 16, 25, 34, 43, 52, 61, 70, 79],
   [ 8, 17, 26, 35, 44, 53, 62, 71, 80]]

BOXS =
  [[ 0,  1,  2,  9, 10, 11, 18, 19, 20],
   [ 3,  4,  5, 12, 13, 14, 21, 22, 23],
   [ 6,  7,  8, 15, 16, 17, 24, 25, 26],
   [27, 28, 29, 36, 37, 38, 45, 46, 47],
   [30, 31, 32, 39, 40, 41, 48, 49, 50],
   [33, 34, 35, 42, 43, 44, 51, 52, 53],
   [54, 55, 56, 63, 64, 65, 72, 73, 74],
   [57, 58, 59, 66, 67, 68, 75, 76, 77],
   [60, 61, 62, 69, 70, 71, 78, 79, 80]]

UNITS = ROWS + COLS + BOXS

class SudokuSolver

  def solve bd
    # p bd.join.tr!('0','.')
    solve_board bd or ( solve_boards only_valid_boards next_boards bd )
  end

  def solve_board bd
     ( complete? bd ) ? bd : nil
  end
  
  def solve_boards bds
    bds.map { |b| solve b }.find { |s| s }
  end

  def only_valid_boards bds
    bds.select { |b| valid? b }
  end

  def filled_cell? cell
    cell.between?(1,9)
  end

  def complete? bd
    bd.all? { |c| filled_cell? c }
  end

  def find_blank bd
    bd.index { |c| not filled_cell? c }
  end

  def next_boards bd
    blk = find_blank bd
    return [] unless blk
    (1..9).map { |i| bd.take(blk) + [i] + bd.drop(blk.succ) }
  end

  def valid? bd
    UNITS.all? { |u| valid_unit?( bd, u ) }
  end

  def valid_unit? bd, u
    no_duplicates? keep_only_filled( u.map { |p| bd[p] } )
  end

  def no_duplicates? cells
    cells == cells.uniq
  end

  def keep_only_filled cells
    cells.select { |c| filled_cell? c }
  end

end

solver = SudokuSolver.new
ARGF.each_line do |puz|
  p puz
  x = (( puz.chomp.scan /./ ).map { |c| c.to_i } )
  p ( solver.solve x ).join.tr('0','.')
end
