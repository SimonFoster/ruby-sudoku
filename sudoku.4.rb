#! /usr/bin/env ruby

require 'set'

module SudokuSolver

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
  
  PEERS = 
    [[ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 18, 19, 20, 27, 36, 45, 54, 63, 72],
     [ 0,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 18, 19, 20, 28, 37, 46, 55, 64, 73],
     [ 0,  1,  3,  4,  5,  6,  7,  8,  9, 10, 11, 18, 19, 20, 29, 38, 47, 56, 65, 74],
     [ 0,  1,  2,  4,  5,  6,  7,  8, 12, 13, 14, 21, 22, 23, 30, 39, 48, 57, 66, 75],
     [ 0,  1,  2,  3,  5,  6,  7,  8, 12, 13, 14, 21, 22, 23, 31, 40, 49, 58, 67, 76],
     [ 0,  1,  2,  3,  4,  6,  7,  8, 12, 13, 14, 21, 22, 23, 32, 41, 50, 59, 68, 77],
     [ 0,  1,  2,  3,  4,  5,  7,  8, 15, 16, 17, 24, 25, 26, 33, 42, 51, 60, 69, 78],
     [ 0,  1,  2,  3,  4,  5,  6,  8, 15, 16, 17, 24, 25, 26, 34, 43, 52, 61, 70, 79],
     [ 0,  1,  2,  3,  4,  5,  6,  7, 15, 16, 17, 24, 25, 26, 35, 44, 53, 62, 71, 80],
     [ 0,  1,  2, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 27, 36, 45, 54, 63, 72],
     [ 0,  1,  2,  9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 28, 37, 46, 55, 64, 73],
     [ 0,  1,  2,  9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 29, 38, 47, 56, 65, 74],
     [ 3,  4,  5,  9, 10, 11, 13, 14, 15, 16, 17, 21, 22, 23, 30, 39, 48, 57, 66, 75],
     [ 3,  4,  5,  9, 10, 11, 12, 14, 15, 16, 17, 21, 22, 23, 31, 40, 49, 58, 67, 76],
     [ 3,  4,  5,  9, 10, 11, 12, 13, 15, 16, 17, 21, 22, 23, 32, 41, 50, 59, 68, 77],
     [ 6,  7,  8,  9, 10, 11, 12, 13, 14, 16, 17, 24, 25, 26, 33, 42, 51, 60, 69, 78],
     [ 6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 17, 24, 25, 26, 34, 43, 52, 61, 70, 79],
     [ 6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 24, 25, 26, 35, 44, 53, 62, 71, 80],
     [ 0,  1,  2,  9, 10, 11, 19, 20, 21, 22, 23, 24, 25, 26, 27, 36, 45, 54, 63, 72],
     [ 0,  1,  2,  9, 10, 11, 18, 20, 21, 22, 23, 24, 25, 26, 28, 37, 46, 55, 64, 73],
     [ 0,  1,  2,  9, 10, 11, 18, 19, 21, 22, 23, 24, 25, 26, 29, 38, 47, 56, 65, 74],
     [ 3,  4,  5, 12, 13, 14, 18, 19, 20, 22, 23, 24, 25, 26, 30, 39, 48, 57, 66, 75],
     [ 3,  4,  5, 12, 13, 14, 18, 19, 20, 21, 23, 24, 25, 26, 31, 40, 49, 58, 67, 76],
     [ 3,  4,  5, 12, 13, 14, 18, 19, 20, 21, 22, 24, 25, 26, 32, 41, 50, 59, 68, 77],
     [ 6,  7,  8, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 33, 42, 51, 60, 69, 78],
     [ 6,  7,  8, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 34, 43, 52, 61, 70, 79],
     [ 6,  7,  8, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 35, 44, 53, 62, 71, 80],
     [ 0,  9, 18, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 45, 46, 47, 54, 63, 72],
     [ 1, 10, 19, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 45, 46, 47, 55, 64, 73],
     [ 2, 11, 20, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38, 45, 46, 47, 56, 65, 74],
     [ 3, 12, 21, 27, 28, 29, 31, 32, 33, 34, 35, 39, 40, 41, 48, 49, 50, 57, 66, 75],
     [ 4, 13, 22, 27, 28, 29, 30, 32, 33, 34, 35, 39, 40, 41, 48, 49, 50, 58, 67, 76],
     [ 5, 14, 23, 27, 28, 29, 30, 31, 33, 34, 35, 39, 40, 41, 48, 49, 50, 59, 68, 77],
     [ 6, 15, 24, 27, 28, 29, 30, 31, 32, 34, 35, 42, 43, 44, 51, 52, 53, 60, 69, 78],
     [ 7, 16, 25, 27, 28, 29, 30, 31, 32, 33, 35, 42, 43, 44, 51, 52, 53, 61, 70, 79],
     [ 8, 17, 26, 27, 28, 29, 30, 31, 32, 33, 34, 42, 43, 44, 51, 52, 53, 62, 71, 80],
     [ 0,  9, 18, 27, 28, 29, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 54, 63, 72],
     [ 1, 10, 19, 27, 28, 29, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 55, 64, 73],
     [ 2, 11, 20, 27, 28, 29, 36, 37, 39, 40, 41, 42, 43, 44, 45, 46, 47, 56, 65, 74],
     [ 3, 12, 21, 30, 31, 32, 36, 37, 38, 40, 41, 42, 43, 44, 48, 49, 50, 57, 66, 75],
     [ 4, 13, 22, 30, 31, 32, 36, 37, 38, 39, 41, 42, 43, 44, 48, 49, 50, 58, 67, 76],
     [ 5, 14, 23, 30, 31, 32, 36, 37, 38, 39, 40, 42, 43, 44, 48, 49, 50, 59, 68, 77],
     [ 6, 15, 24, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 51, 52, 53, 60, 69, 78],
     [ 7, 16, 25, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 44, 51, 52, 53, 61, 70, 79],
     [ 8, 17, 26, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 51, 52, 53, 62, 71, 80],
     [ 0,  9, 18, 27, 28, 29, 36, 37, 38, 46, 47, 48, 49, 50, 51, 52, 53, 54, 63, 72],
     [ 1, 10, 19, 27, 28, 29, 36, 37, 38, 45, 47, 48, 49, 50, 51, 52, 53, 55, 64, 73],
     [ 2, 11, 20, 27, 28, 29, 36, 37, 38, 45, 46, 48, 49, 50, 51, 52, 53, 56, 65, 74],
     [ 3, 12, 21, 30, 31, 32, 39, 40, 41, 45, 46, 47, 49, 50, 51, 52, 53, 57, 66, 75],
     [ 4, 13, 22, 30, 31, 32, 39, 40, 41, 45, 46, 47, 48, 50, 51, 52, 53, 58, 67, 76],
     [ 5, 14, 23, 30, 31, 32, 39, 40, 41, 45, 46, 47, 48, 49, 51, 52, 53, 59, 68, 77],
     [ 6, 15, 24, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 60, 69, 78],
     [ 7, 16, 25, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 61, 70, 79],
     [ 8, 17, 26, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 62, 71, 80],
     [ 0,  9, 18, 27, 36, 45, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 72, 73, 74],
     [ 1, 10, 19, 28, 37, 46, 54, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 72, 73, 74],
     [ 2, 11, 20, 29, 38, 47, 54, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 72, 73, 74],
     [ 3, 12, 21, 30, 39, 48, 54, 55, 56, 58, 59, 60, 61, 62, 66, 67, 68, 75, 76, 77],
     [ 4, 13, 22, 31, 40, 49, 54, 55, 56, 57, 59, 60, 61, 62, 66, 67, 68, 75, 76, 77],
     [ 5, 14, 23, 32, 41, 50, 54, 55, 56, 57, 58, 60, 61, 62, 66, 67, 68, 75, 76, 77],
     [ 6, 15, 24, 33, 42, 51, 54, 55, 56, 57, 58, 59, 61, 62, 69, 70, 71, 78, 79, 80],
     [ 7, 16, 25, 34, 43, 52, 54, 55, 56, 57, 58, 59, 60, 62, 69, 70, 71, 78, 79, 80],
     [ 8, 17, 26, 35, 44, 53, 54, 55, 56, 57, 58, 59, 60, 61, 69, 70, 71, 78, 79, 80],
     [ 0,  9, 18, 27, 36, 45, 54, 55, 56, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74],
     [ 1, 10, 19, 28, 37, 46, 54, 55, 56, 63, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74],
     [ 2, 11, 20, 29, 38, 47, 54, 55, 56, 63, 64, 66, 67, 68, 69, 70, 71, 72, 73, 74],
     [ 3, 12, 21, 30, 39, 48, 57, 58, 59, 63, 64, 65, 67, 68, 69, 70, 71, 75, 76, 77],
     [ 4, 13, 22, 31, 40, 49, 57, 58, 59, 63, 64, 65, 66, 68, 69, 70, 71, 75, 76, 77],
     [ 5, 14, 23, 32, 41, 50, 57, 58, 59, 63, 64, 65, 66, 67, 69, 70, 71, 75, 76, 77],
     [ 6, 15, 24, 33, 42, 51, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 78, 79, 80],
     [ 7, 16, 25, 34, 43, 52, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 71, 78, 79, 80],
     [ 8, 17, 26, 35, 44, 53, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 78, 79, 80],
     [ 0,  9, 18, 27, 36, 45, 54, 55, 56, 63, 64, 65, 73, 74, 75, 76, 77, 78, 79, 80],
     [ 1, 10, 19, 28, 37, 46, 54, 55, 56, 63, 64, 65, 72, 74, 75, 76, 77, 78, 79, 80],
     [ 2, 11, 20, 29, 38, 47, 54, 55, 56, 63, 64, 65, 72, 73, 75, 76, 77, 78, 79, 80],
     [ 3, 12, 21, 30, 39, 48, 57, 58, 59, 66, 67, 68, 72, 73, 74, 76, 77, 78, 79, 80],
     [ 4, 13, 22, 31, 40, 49, 57, 58, 59, 66, 67, 68, 72, 73, 74, 75, 77, 78, 79, 80],
     [ 5, 14, 23, 32, 41, 50, 57, 58, 59, 66, 67, 68, 72, 73, 74, 75, 76, 78, 79, 80],
     [ 6, 15, 24, 33, 42, 51, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 79, 80],
     [ 7, 16, 25, 34, 43, 52, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 80],
     [ 8, 17, 26, 35, 44, 53, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79]]

  def SudokuSolver.solve_puzzle puzzle
    bd = Array.new(81) { |i| Array (1..9) }
    81.times do |i|
      j = puzzle.scan(/./).map { |c| c.to_i }
      if j[i] != 0 then assign( bd, i, j[i] ) end
    end
    solve bd
  end

  def SudokuSolver.solve bd
    # p 'solve', bd
    solve_board bd or ( solve_boards next_boards bd )
  end
  
  def SudokuSolver.solve_board bd
     ( complete? bd ) ? bd : nil
  end
  
  def SudokuSolver.solve_boards bds
    # p 'solve_boards', bds
    return nil if bds.empty?
    solve( bds.first ) or solve_boards( bds.drop(1) )
  end

  def SudokuSolver.only_valid_boards bds
    bds.select { |b| ( not b.empty? ) and valid? b }
  end

  def SudokuSolver.complete_cell? cell
    cell.length == 1
  end

  def SudokuSolver.complete? bd
    bd.all? { |c| complete_cell? c }
  end

  def SudokuSolver.find_blank bd
    bd.index { |c| not filled_cell? c }
  end

  def SudokuSolver.copy_board bd
    bd.map { |c| c.dup }  
  end
  
  def SudokuSolver.next_boards bd
    # p 'oldbd', bd
    mrv = minimum_remaining_values bd
    # p 'mrv', mrv
    return [] unless mrv
    bd[mrv].map do |guess|
      p "#{mrv}:#{bd[mrv].inspect} guess value #{guess} for position #{mrv}" 
      newbd = copy_board bd
      assign( newbd, mrv, guess )
      # p 'newbd', newbd
      newbd
    end
  end

  def SudokuSolver.assign( bd, pos, val )
    bd[pos] = [val]
    # remove that value from all of the peers
    eliminate_from_peers( bd, pos, val )
  end
  
  def SudokuSolver.eliminate( bd, pos, val )
    # eliminate value at position
    if bd[pos].delete val
      # check the number of remaining items 
      return nil if bd[pos].empty?
      if bd[pos].length == 1
        # If there is one remaining value then
        # remove that value from all of the peers
        return unless eliminate_from_peers( bd, pos, val )
      end
      # For each unit, if a value can go in 
      # *only one* position then assign it there
      UNITS.each do |u|
        possibles = u.select { |p| bd[p].include? val }
        # p "Possibles #{possibles.inspect}"
        if possibles.length == 1
          # p "only position in #{u.inspect} for #{val} is #{possibles.first}"
          assign( bd, possibles.first, val )
        end  
      end
    end
  end

  def SudokuSolver.eliminate_from_peers( bd, pos, val )
    # Eliminate value from all peers.  If any call to 
    # eliminate returns false then stop.
    PEERS[pos].each { |p| eliminate( bd, p, bd[pos].first ) }.all?
  end
  
  def SudokuSolver.minimum_remaining_values bd
    # Return the index of the *first* cell with a minimum
    # remaining no. of values or nil if the board is complete
    return nil if complete? bd
    # p 'MRV', bd
    min_remain = bd.map { |c| c.length }.select { |l| l > 1 }.sort.first
    bd.index { |c| c.length == min_remain }
  end
  
end

ARGF.each_line do |line|
  p line
  solve = SudokuSolver.solve_puzzle line
  solve.each_slice(9) do |row|
    p row
  end
end



