#! /usr/bin/env ruby

BD4 = "
  2 7 4 B 9 1 B B 5
  1 B B 5 B B B 9 B
  6 B B B B 3 2 8 B
  B B 1 9 B B B B 8
  B B 5 1 B B 6 B B
  7 B B B 8 B B B 3
  4 B 2 B B B B B 9
  B B B B B B B 7 B
  8 B B 3 4 9 B B B"

BD4S = "
  2 7 4 8 9 1 3 6 5
  1 3 8 5 2 6 4 9 7
  6 5 9 4 7 3 2 8 1
  3 2 1 9 6 4 7 5 8
  9 8 5 1 3 7 6 4 2
  7 4 6 2 8 5 9 1 3
  4 6 2 7 5 8 1 3 9
  5 9 3 6 1 2 8 7 4
  8 1 7 3 4 9 5 2 6"

BD5 = "
  5 B B B B 4 B 7 B
  B 1 B B 5 B 6 B B
  B B 4 9 B B B B B
  B 9 B B B 7 5 B B
  1 8 B 2 B B B B B 
  B B B B B 6 B B B 
  B B 3 B B B B B 8
  B 6 B B 8 B B B 9
  B B 8 B 7 B B 3 1"

BD5S = "
  5 3 9 1 6 4 8 7 2
  8 1 2 7 5 3 6 9 4
  6 7 4 9 2 8 3 1 5
  2 9 6 4 1 7 5 8 3
  1 8 7 2 3 5 9 4 6
  3 4 5 8 9 6 1 2 7
  9 2 3 5 4 1 7 6 8
  7 6 1 3 8 2 4 5 9
  4 5 8 6 7 9 2 3 1"
        
BD6 = "
  B B 5 3 B B B B B 
  8 B B B B B B 2 B
  B 7 B B 1 B 5 B B 
  4 B B B B 5 3 B B
  B 1 B B 7 B B B 6
  B B 3 2 B B B 8 B
  B 6 B 5 B B B B 9
  B B 4 B B B B 3 B
  B B B B B 9 7 B B"

BD7 = "
  1 2 3 4 5 6 7 8 B 
  B B B B B B B B 2 
  B B B B B B B B 3 
  B B B B B B B B 4 
  B B B B B B B B 5
  B B B B B B B B 6
  B B B B B B B B 7
  B B B B B B B B 8
  B B B B B B B B 9"

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

require 'pp'

class SudokuSolver

  def solve bd
    solve_board bd or solve_boards only_valid_boards next_boards bd
  end

  def solve_board bd
    ( complete? bd ) ? bd : nil
  end

  def solve_boards bds
    solutions = bds.map { |b| solve b }
    solutions.detect { |s| s }
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
    blank = find_blank bd
    if blank
      (1..9).map do |i| 
        nxt = bd.dup
        nxt[blank] = i
        nxt
      end
    else
      []
    end
  end

  def valid? bd
    UNITS.all? { |u| valid_unit?( bd, u ) }
  end

  def valid_unit? bd, u
    no_duplicates? keep_only_filled( u.map { |p| bd[p] } )
  end

  def keep_only_filled cells
    cells.select { |c| filled_cell? c }
  end

  def no_duplicates? cells
    cells == cells.uniq
  end
end

def board b
  b.split.map { |i| i.to_i }
end

solver = SudokuSolver.new

bd4 = solver.solve( board( BD4 ))
p 'Solution for BD4:', bd4
p 'BD4:',  board( BD4 )
p 'BD4S:', board( BD4S )
p bd4 == board( BD4S )

bd5 = solver.solve( board( BD5 ))
p 'Solution for BD5:', bd5
p 'BD5:',  board( BD5 )
p 'BD5S:', board( BD5S )
p bd5 == board( BD5S )

p 'Solution for BD6:', solver.solve( board( BD6 ))
p 'Solution for BD7;', solver.solve( board( BD7 ))
