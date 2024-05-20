PIECES_SYMBOL = {
  'bRook' => "♜", 'wRook' => "♖",
  'bKnight' => "♞", 'wKnight' => "♘",
  'bBishop' => "♝", 'wBishop' => "♗",
  'bQueen' => '♛', 'wQueen' => "♕",
  'bKing' => "♚", 'wKing' => "♔",
  'bPawn' => "♟︎", 'wPawn' => "♙",
  'None' => "|"
}.freeze

class Piece
  attr_accessor :x, :y, :id, :col, :name

  def initialize(x, y, col, name)
    @x = x
    @y = y
    @col = col
    @name = name
  end

  def name_piece
    PIECES_SYMBOL[@name]
  end

  def move_to(x, y)
    raise NotImplementedError, 'This method should be overridden in subclasses'
  end
end

class None < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "None")
  end

  def move_to(x, y)
    true
  end
end

class Pawn < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "#{col}Pawn")
  end

  def move_to(c, d)
    direction = @col == "w" ? -1 : 1
    if @y == d
      return true if @x + direction == c
      return true if (@x + 2 * direction == c) && (@x == 1 || @x == 6)
    elsif (c - @x) == direction && (@y - d).abs == 1
      return true
    end
    false
  end
end

class Rook < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "#{col}Rook")
  end

  def move_to(c, d)
    (c - @x == 0 || d - @y == 0)
  end
end

class Knight < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "#{col}Knight")
  end

  def move_to(c, d)
    (c - @x).abs == 2 && (d - @y).abs == 1 || (c - @x).abs == 1 && (d - @y).abs == 2
  end
end

class Bishop < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "#{col}Bishop")
  end

  def move_to(c, d)
    (c - @x).abs == (d - @y).abs
  end
end

class Queen < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "#{col}Queen")
  end

  def move_to(c, d)
    (c - @x == 0 || d - @y == 0) || (c - @x).abs == (d - @y).abs
  end
end

class King < Piece
  def initialize(x, y, col, name)
    super(x, y, col, "#{col}King")
  end

  def move_to(c, d)
    (c - @x).abs <= 1 && (d - @y).abs <= 1
  end
end
