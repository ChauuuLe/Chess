require_relative 'pieces'

class Board
  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8) }

    for i in (0..7)
      for j in (0..7)
        @board[i][j] = None.new(i, j, 0, "")
      end
    end

    # Pawns
    for i in (0..7)
      @board[1][i] = Pawn.new(1, i, "b", "Pawn")
      @board[6][i] = Pawn.new(6, i, "w", "Pawn")
    end

    # Knights
    @board[0][1] = Knight.new(0, 1, "b", "Knight")
    @board[0][6] = Knight.new(0, 6, "b", "Knight")
    @board[7][1] = Knight.new(7, 1, "w", "Knight")
    @board[7][6] = Knight.new(7, 6, "w", "Knight")

    # Bishops
    @board[0][2] = Bishop.new(0, 2, "b", "Bishop")
    @board[0][5] = Bishop.new(0, 5, "b", "Bishop")
    @board[7][2] = Bishop.new(7, 2, "w", "Bishop")
    @board[7][5] = Bishop.new(7, 5, "w", "Bishop")

    # Rooks
    @board[0][0] = Rook.new(0, 0, "b", "Rook")
    @board[0][7] = Rook.new(0, 7, "b", "Rook")
    @board[7][0] = Rook.new(7, 0, "w", "Rook")
    @board[7][7] = Rook.new(7, 7, "w", "Rook")

    # Queens
    @board[0][3] = Queen.new(0, 3, "b", "Queen")
    @board[7][3] = Queen.new(7, 3, "w", "Queen")

    # Kings
    @board[0][4] = King.new(0, 4, "b", "King")
    @board[7][4] = King.new(7, 4, "w", "King")
  end

  def swap(a, b)
    return b, a
  end

  def is_piece(a)
    a.to_i != 0
  end

  def show
    display_board = @board.map do |row|
      row.map { |e| e.name_piece }.join
    end.join("\n")

    puts display_board
  end

  def move(a, b, c, d)
    piece = @board[a][b]
    if valid_move?(piece, a, b, c, d)
      @board[c][d] = piece
      @board[a][b] = None.new(a, b, 0, "")
      piece.x, piece.y = c, d
    else
      puts "Illegal move. Please move again"
    end
  end

  private

  def valid_move?(piece, a, b, c, d)
    case piece
    when Rook
      move_rook(a, b, c, d)
    when Bishop
      move_bishop(a, b, c, d)
    when Queen
      move_queen(a, b, c, d)
    when Knight
      move_knight(a, b, c, d)
    when King
      move_king(a, b, c, d)
    when Pawn
      move_pawn(a, b, c, d)
    else
      false
    end
  end

  def move_rook(a, b, c, d)
    if a == c
      (([b, d].min + 1)...[b, d].max).each do |i|
        return false unless @board[a][i].is_a?(None)
      end
    elsif b == d
      (([a, c].min + 1)...[a, c].max).each do |i|
        return false unless @board[i][b].is_a?(None)
      end
    else
      return false
    end
    @board[c][d].is_a?(None) || @board[c][d].col != @board[a][b].col
  end

  def move_bishop(a, b, c, d)
    return false unless (c - a).abs == (d - b).abs

    x_step = c > a ? 1 : -1
    y_step = d > b ? 1 : -1
    steps = (c - a).abs

    (1...steps).each do |i|
      return false unless @board[a + i * x_step][b + i * y_step].is_a?(None)
    end

    @board[c][d].is_a?(None) || @board[c][d].col != @board[a][b].col
  end

  def move_knight(a, b, c, d)
    valid = (a - c).abs == 2 && (b - d).abs == 1 || (a - c).abs == 1 && (b - d).abs == 2
    valid && (@board[c][d].is_a?(None) || @board[c][d].col != @board[a][b].col)
  end

  def move_queen(a, b, c, d)
    move_rook(a, b, c, d) || move_bishop(a, b, c, d)
  end

  def move_king(a, b, c, d)
    valid = (a - c).abs <= 1 && (b - d).abs <= 1
    valid && (@board[c][d].is_a?(None) || @board[c][d].col != @board[a][b].col)
  end

  def move_pawn(a, b, c, d)
    direction = @board[a][b].col == "w" ? -1 : 1
    if b == d
      if (c - a) == direction && @board[c][d].is_a?(None)
        return true
      elsif (a == 1 && @board[a][b].col == "b" || a == 6 && @board[a][b].col == "w") &&
            (c - a) == 2 * direction && @board[c][d].is_a?(None) && @board[a + direction][b].is_a?(None)
        return true
      end
    elsif (c - a) == direction && (b - d).abs == 1 && !@board[c][d].is_a?(None) && @board[c][d].col != @board[a][b].col
      return true
    end
    false
  end

  def find_king(color)
    @board.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        return [i, j] if piece.is_a?(King) && piece.col == color
      end
    end
    nil
  end

  def in_check?(color)
    king_pos = find_king(color)
    opponent_color = color == 'w' ? 'b' : 'w'

    @board.each do |row|
      row.each do |piece|
        next if piece.col != opponent_color

        return true if valid_move?(piece, piece.x, piece.y, king_pos[0], king_pos[1])
      end
    end
    false
  end

  def valid_king_moves(color)
    king_pos = find_king(color)
    possible_moves = [
      [king_pos[0] - 1, king_pos[1] - 1], [king_pos[0] - 1, king_pos[1]], [king_pos[0] - 1, king_pos[1] + 1],
      [king_pos[0], king_pos[1] - 1],                                 [king_pos[0], king_pos[1] + 1],
      [king_pos[0] + 1, king_pos[1] - 1], [king_pos[0] + 1, king_pos[1]], [king_pos[0] + 1, king_pos[1] + 1]
    ]

    valid_moves = possible_moves.select do |move|
      next if move[0] < 0 || move[0] > 7 || move[1] < 0 || move[1] > 7
      @board[move[0]][move[1]].is_a?(None) || @board[move[0]][move[1]].col != color
    end

    valid_moves
  end

  def checkmate?(color)
    return false unless in_check?(color)

    king_moves = valid_king_moves(color)
    opponent_color = color == 'w' ? 'b' : 'w'

    king_moves.each do |move|
      safe = true
      @board.each do |row|
        row.each do |piece|
          next if piece.col != opponent_color

          if valid_move?(piece, piece.x, piece.y, move[0], move[1])
            safe = false
            break
          end
        end
        break unless safe
      end

      return false if safe
    end

    true
  end
end
