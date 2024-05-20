require 'yaml'
require_relative 'lib/pieces'
require_relative 'lib/board'
require_relative 'lib/player'

PROMT = '>> '

# Menu game
MENU = <<-MENU

|--------------------|
|        Menu        |
|--------------------|
|1 |New game         |
|2 |Continue         |
|3 |Help             |
|4 |Quit             |
|--------------------|
MENU

# Help
HELP = <<-HELP
1. Rules
  - Visit https://www.chessvariants.com/d.chess/chess.html
HELP

class ChessGame 
  attr_accessor :player1, :player2, :board

  @@turn = "w"
  @@winner = nil

  def self.load_game
    return nil unless File.exist?('data/history.yml')

    YAML.load(File.read('data/history.yml'))
  end
  
  def initialize(new_game = false)
    if new_game
      puts "Enter player 1 name:"
      p1_name = gets.strip
      puts "Enter player 2 name:"
      p2_name = gets.strip
      puts "Enter name of player who wants to move first:"
      p_move = gets.strip

      if p1_name == p_move 
        @player1 = Player.new(p1_name, "w")
        @player2 = Player.new(p2_name, "b")
      else 
        @player1 = Player.new(p1_name, "b")
        @player2 = Player.new(p2_name, "w")
      end
      @board = Board.new 
    end
  end

  def save(option = 'w')
    Dir.mkdir('data') unless File.exist?('data')
    File.open('data/history.yml', option) { |f| f.write(YAML.dump(self)) }
  end

  def play
    loop do
      puts MENU
      print PROMT
      choice = gets.strip.to_i

      case choice
      when 1
        new_game
      when 2
        continue_game
      when 3
        display_help
      when 4
        quit_game
      else
        puts "Invalid option, please choose again."
      end
    end
  end

  def new_game
    initialize(true)
    game_loop
  end

  def continue_game
    game = ChessGame.load_game
    if game
      @player1, @player2, @board, @@turn, @@winner = game.player1, game.player2, game.board, @@turn, @@winner
      game_loop
    else
      puts "No saved game found."
    end
  end

  def display_help
    puts HELP
  end

  def quit_game
    puts "Thank you for playing! Goodbye."
    exit
  end

  def game_loop
    until @@winner
      @board.show
      current_player = @@turn == @player1.col ? @player1 : @player2
      puts "#{current_player.name} (#{current_player.col}), it's your turn."
      print PROMT
      input = gets.strip

      if input =~ /^[a-h][1-8]\s[a-h][1-8]$/
        from, to = input.split
        a, b = to_coords(from)
        c, d = to_coords(to)
        @board.move(a, b, c, d)
        @@turn = @@turn == "w" ? "b" : "w"
        check_winner
      elsif input.downcase == 'save'
        save
        puts "Game saved."
      elsif input.downcase == 'exit'
        save
        puts "Game saved and exited."
        break
      else
        puts "Invalid move. Please enter the move in 'e2 e4' format."
      end
    end

    puts "Congratulations, #{@@winner.name}! You win!"
  end

  private

  def to_coords(pos)
    col = pos[0].ord - 'a'.ord
    row = 8 - pos[1].to_i
    [row, col]
  end

  def check_winner
    if (@board.checkmate?) 
      winner = current_player
    end
  end
end

game = ChessGame.new
game.play
