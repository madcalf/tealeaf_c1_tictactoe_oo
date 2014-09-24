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
require 'pry'

class Player
  # include Automatable
  attr_reader :name, :marker, :board
  
  def initialize(name, marker, board)
    @name = name.capitalize
    @marker = marker
    @board = board
  end

  def choose
    begin 
      pos = gets.chomp.to_i
      is_valid_selection = self.numeric?(pos) && pos.between?(1, 9)
      if is_valid_selection
        break if board.square_empty?(pos)
      end
      puts (!is_valid_selection ? "Not a valid selection" : "Already taken. Chose another")
    end while true
    
    board.set_position(pos, self.marker)
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
end # Player

class AIPlayer < Player
  def choose
    pos = self.board.find_win_position(self.marker)
    pos = self.board.find_block_position(self.marker) if !pos
    pos = self.board.find_empty_pos if !pos
    board.set_position(pos, self.marker)
  end
end # AIPlayer
  
# board_square consists of 3 lines used to display a representation of x or o
# value is 'x', 'o' or EMPTY
# position is place on the game board. Not the array index. Passed in when created.
class BoardSquare
  SPACE2 = "  "
  SPACE5 = "     "
  EMPTY = ''
  attr_accessor :value
  attr_reader :position, :marker_pieces
  
  def initialize(pos)
    @position = pos
    @value = EMPTY
    @marker_pieces = {}
    @marker_pieces['x'] = {top: ' \ / ', mid: '  \  ', bot: ' / \ '}
    @marker_pieces['o'] = {top: '  _  ', mid: ' | | ', bot: '  —  '}
    @marker_pieces[''] =  {top: SPACE5, mid:"#{SPACE2}#{@position}#{SPACE2}", bot: SPACE5}
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
    "<BoardSquare> position=#{self.position}"
  end
end # BoardSquare

# board is an array of board_squares
class GameBoard
  TOP_LINE = " #{'_'*17} "
  BOTTOM_LINE = "|#{'_'*17}|"
  GRID_LINE = "#{'-'*5}+#{'-'*5}+#{'-'*5} "
  WIN_GROUPS =  [ [0, 1, 2], [3, 4, 5], [6, 7, 8], 
                    [0, 3, 6], [1, 4, 7], [2, 5, 8], 
                    [0, 4, 8], [2, 4, 6]
                  ]  
                  
  attr_reader :squares
  
  def initialize
    @squares = Array.new(9).collect!.with_index { |item, i| BoardSquare.new(i + 1) }
  end
  
  def set_position(pos, value)
    # puts "set_position() #{pos}, #{value}"
    self.squares[pos - 1].value = value  
  end
  
  def square_empty?(pos)
    self.squares[pos - 1].empty?
  end

  # returns a random empty square position
  def find_empty_pos
    empty_squares = squares.select { |square| square.empty? }
    # puts "empty sqares: #{empty_squares.size}"
    empty_squares.sample.position
  end

  # find consec squares w with 3 x's or o's
  # RENAME TO find_win?? or check_for_win ??
  def three_in_a_row?(marker)
    result = false
    WIN_GROUPS.each do |arr|
      result = arr.all? { |index| self.squares[index].value == marker}
      break if result
    end 
    return result
  end  
  
  def find_win_position(marker)
    group = find_group_of_two(marker, true)
    if group
      return get_empty_index(group) + 1
    end
  end
  
  def find_block_position(marker) 
    group = find_group_of_two(marker, false)
    if group
      return get_empty_index(group) + 1
    end
  end
  
  # passed a group of 3 indexes, return which index refers to an empty square
  def get_empty_index(group)
    index = group.select { |i| squares[i].empty?}[0]
  end
  
  def get_empty_position(group)
    get_empty_index + 1
  end
  
  def all_squares_occupied?
    !squares.any? { |square| square.empty?}
    # get_available_square_positions.size == 0
  end
  # def get_available_square_positions
  #   squares.collect { |square| square.empty? ? square.position : nil }.compact
  # end
  
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
  
  private

  # returns first group that contains 2 of specified marker plus an empty square
  def find_group_of_two(marker, match_marker)
    WIN_GROUPS.each do |group|
      sqrs = self.squares.values_at(*group)    # array of square objects
      values = sqrs.map { |square| square.value}  
      if values.include?(BoardSquare::EMPTY) 
        if match_marker
          selected_values = values.select { |value| value == marker}
        else
          selected_values = values.select { |value| value != marker && value != BoardSquare::EMPTY}
        end
        return group if selected_values.size == 2
      end
    end  
    # if we get here, we didn't find a group with 2 of same marker 
    # must return nil explicitly, or the entire WIN_GROUPS array gets returned!
    return nil   
  end
end # GameBoard
  
class Game
  SLEEP_TIME = 1
  BLINK_TIME = 0.25
  
  attr_accessor :player, :computer, :board, :message
 
  def initialize
    @board = GameBoard.new 
    @computer = AIPlayer.new("Computer", "o", self.board)
    @message = []
  end

  def run
    intro
    self.player = Player.new(get_player_name, 'x', self.board)
    puts "Welcome #{self.player.name}"
    draw
    
    loop do
      self.player_move
      break if self.end_game?
      self.computer_move
      break if self.end_game?
    end
    draw
    puts "Play again? [Y]es  |  [N]o"
    run if gets.chomp.downcase == "y"
  end
  
  def new_game
    self.board.clear
    draw
  end
  
  def play
    
  end
  
  def intro
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
    # puts "Your move, #{self.player.name}. Select 1 - 9"
    self.message[1] = "Your move, #{self.player.name}. Select 1 - 9"
    draw
    self.player.choose
    draw
  end
  
  def computer_move
    # puts "#{self.computer.name}'s move:"
    self.message[1] = "#{self.computer.name}'s move:"
    draw
    sleep SLEEP_TIME
    self.computer.choose
    draw
  end
    
  # see if we have a winner or all squares are taken
  def end_game?
    self.message[1] = ''
    self.message[2] = ''
    if winner?(self.player)
      self.message[2] = "#{self.player.name} wins!"
      result = true
    elsif winner?(self.computer)
      self.message[2] = "#{self.computer.name} wins!"
      result = true
    elsif self.board.all_squares_occupied?
      self.message[2] = "Tie game!"
      result = true
    end
    draw
    return result
  end
  
  def winner?(which_player)
    result = self.board.three_in_a_row?(which_player.marker)
  end
  
  def draw
    system 'clear'
    intro
    self.board.draw
    self.message.each { |item| puts "#{item}"}
  end
  
end # Game


# ==================== PROGRAM START ==================== 
system 'clear'
Game.new.run