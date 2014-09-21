# Tic Tac Toe OOP

# Requirements
# prompt player for name
# player choses square
# check for win
# computer choses square
#   check for win opportunity
#   check for block
# check for win
# repeat until winner or no more squares
# display winner

# Nouns
# ------
# player
# computer
# game board
#  square
#  marker

# Verbs
# place marker
# choose square
# draw

module Automatable
  def choose_random(options_arr)
    options_arr.sample
  end
end # Automatable

class Player
  include Automatable
  attr_reader :name, :marker
  def initialize(name, marker)
    @name = name.capitalize
    @marker = marker
  end

  def choose()
    gets.chomp.to_i
  end
end # Player

# class AIPlayer < Player
  
# end # AIPlayer  

# board_square consists of 3 lines used to display a representation of x or o
# marker is: x, o or empty
# index is it's place on the game board. passed in when created
class BoardSquare
  SPACE2 = "  "
  SPACE5 = "     "
  EMPTY = ''
  attr_accessor :value
  attr_reader :number, :marker_pieces
  
  def initialize(num)
    @number = num
    @value = EMPTY
    @marker_pieces = {}
    @marker_pieces['x'] = {top: ' \ / ', mid: '  \  ', bot: ' / \ '}
    @marker_pieces['o'] = {top: '  _  ', mid: ' | | ', bot: '  —  '}
    @marker_pieces[''] =  {top: SPACE5, mid:"#{SPACE2}#{number}#{SPACE2}", bot: SPACE5}
    # puts "square: #{self}"
  end
  
  def empty?
    value == EMPTY  
  end
  
  def top
    self.marker_pieces[self.value][:top]
  end
    
  def mid
    self.marker_pieces[self.value][:mid]
  end
    
  def bottom
    self.marker_pieces[self.value][:bot]
  end
  
  def to_s
    "<BoardSquare> number=#{self.number}"
  end
end # BoardSquare

# board is an array of board_squares
class GameBoard
  TOP_LINE = " #{'_'*17} "
  BOTTOM_LINE = "|#{'_'*17}|"
  GRID_LINE = "#{'-'*5}+#{'-'*5}+#{'-'*5} "
  WIN_PATTERNS =  [ [0, 1, 2], [3, 4, 5], [6, 7, 8], 
                    [0, 3, 6], [1, 4, 7], [2, 5, 8], 
                    [0, 4, 8], [2, 4, 6]
                  ]  
  attr_reader :squares
  
  def initialize
    @squares = Array.new(9).collect!.with_index { |item, i| BoardSquare.new(i + 1) }
  end
  
  def set_square(index, value)
    self.squares[index].value = value
  end
  
  # def get_available_squares
  #   # returns array of squares. do we prefer indexes (0-8)? labels (1-9)?
  #   squares.select { |square| square.empty? == true }
  # end
  
  # def get_available_indexes
  #   # squares.select { |square| squares.empty? }.collect.with_index { | }
  #   squares.collect.with_index { |square, i| i if square.empty?}.compact
  # end

  # find consec squares w with 3 x's or o's
  def has_three?(marker)
    WIN_PATTERNS.each do |arr|
      arr.all? { |item| item == marker}
    end 
  end  
  
  # not really in row and don't need to be consecutive. xox, xxo, oox all
  # break this out to find the group, then get the target index??
  def find_group_of_two?(marker)
    indexes = nil # group of winning indexes
    WIN_PATTERNS.each do |arr|
      indexes = arr.select { |index| squares[index] == marker}
    end 
    # get the index that's not the marker
    if indexes.size == 2
      index = indexes.select { |item| item != marker}
    end
  end
  
  def get_available_square_nums
    squares.collect { |square| square.empty? ? square.number : nil }.compact
  end
  
  def all_squares_occupied?
    get_available_square_nums.size == 0
  end
  
  def draw
    puts "#{self.squares[0].top}|#{self.squares[1].top}|#{self.squares[2].top}\n"
    puts "#{self.squares[0].mid}|#{self.squares[1].mid}|#{self.squares[2].mid}\n"
    puts "#{self.squares[0].bottom}|#{self.squares[1].bottom}|#{self.squares[2].bottom}\n"
    puts "#{GRID_LINE}\n"
    puts "#{self.squares[3].top}|#{self.squares[4].top}|#{self.squares[5].top}\n"
    puts "#{self.squares[3].mid}|#{self.squares[4].mid}|#{self.squares[5].mid}\n"
    puts "#{self.squares[3].bottom}|#{self.squares[4].bottom}|#{self.squares[5].bottom}\n"
    puts "#{GRID_LINE}\n"
    puts "#{self.squares[6].top}|#{self.squares[7].top}|#{self.squares[8].top}\n"
    puts "#{self.squares[6].mid}|#{self.squares[7].mid}|#{self.squares[8].mid}\n"
    puts "#{self.squares[6].bottom}|#{self.squares[7].bottom}|#{self.squares[8].bottom}\n"
  end
end # GameBoard
  
class Game

  # EMPTY = "." # placeholder for empty square 
  SLEEP_TIME = 0.8
  BLINK_TIME = 0.25
  
  attr_accessor :player, :computer, :board
  
  def initialize
    # @player = Player.new(get_player_name, 'x')
    @computer = Player.new("Computer", 'o')  
    @board = GameBoard.new 
    # self.board.set_square(0, 'x')
    # self.board.set_square(4, 'x')
    # self.board.set_square(8, 'x')
  
    # puts "board: #{self.board}"
  end

  def run
    intro
    @player = Player.new(get_player_name, 'x')
    puts "Welcome #{self.player.name}"
    loop do
      sleep 1
      draw
      self.player_move
      draw
      break if self.test_end_game
      sleep 1
      self.computer_move
      draw
      break if self.test_end_game
      # break if self.game_over?
    end
  end
  
  def intro
    system 'clear'
    puts '----------------------------------'
    puts '          Tic Tac Toe'
    puts '----------------------------------'
        
  end
  
  def get_player_name
    puts "Please tell me your name?"  # may move this so this has one responsibility
    gets.chomp.capitalize
  end
  
  # gets player selection or tells player to make selection
  # draws selection? or stores it in game board state
  def player_move
    puts "Your move, #{self.player.name}. Select 1 - 9"
    
      begin 
        choice = player.choose
        break if self.numeric?(choice) && choice.between?(1, 9)
        puts "Not a valid option."
      end while true
      index = choice - 1
      board.set_square(index, self.player.marker)
  end
  
  def computer_move
    options = self.board.get_available_square_nums
    choice = self.computer.choose_random(options)
    index = choice - 1
    board.set_square(index, self.computer.marker)
  end
    
  # see if we have a winner or all squares are taken
  def test_end_game
    board.all_squares_occupied? || winner?  
  end
  
  def winner?
    false
  end
  
  def draw
    intro
    board.draw
    puts "avail nums: #{self.board.get_available_square_nums}"
  end
  
  def numeric?(str) 
    # using Float this way seems to be a popular way to do this on SO
    # anything wrong with it? 
    # is it ok to rely on an exception to set a value?
    begin 
      result = Float(str) ? true : false
    rescue
      result = false
    ensure
      return result
    end
  end
end # Game


# ==================== PROGRAM START ==================== 
system 'clear'
Game.new.run