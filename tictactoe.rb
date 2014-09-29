# encoding: UTF-8
# Tic Tac Toe OOP

require 'pry'

class Player
  attr_reader :name, :marker, :board
  attr_accessor :score
  
  def initialize(name, marker, board)
    @name = name.capitalize
    @marker = marker
    @board = board
    @score = 0
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
    pos = self.board.find_empty_position if !pos
    board.set_position(pos, self.marker)
  end
end # AIPlayer
  
# a BoardSquare consists of 3 lines used to display a representation of x or o
# value is 'x', 'o' or EMPTY
# position is square's number on the game board. Not the array index.
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

# board is an array of BoardSquare objects
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
  
  def reset
    self.squares.each { |square| square.value = BoardSquare::EMPTY}
  end
  
  def set_position(pos, value)
    self.squares[pos - 1].value = value  
  end
  
  def square_empty?(pos)
    self.squares[pos - 1].empty?
  end

  def find_empty_position
    empty_squares = squares.select { |square| square.empty? }
    empty_squares.sample.position
  end

  def three_in_a_row?(marker)
    WIN_GROUPS.each do |arr|
      return true if arr.all? { |index| self.squares[index].value == marker}
    end 
    return false
  end  
  
  def find_win_position(marker)
    group = find_group_of_two(marker, true)
    if group
      return get_empty_position(group)
    end
  end
  
  def find_block_position(marker) 
    group = find_group_of_two(marker, false)
    if group
      return get_empty_position(group)
    end
  end
  
  def get_empty_position(group)
    get_empty_index(group) + 1
  end
  
  def all_squares_occupied?
    squares.all? { |square| !square.empty? }
  end

  def draw
    puts "#{' '*5} #{self.squares[0].top}|#{self.squares[1].top}|#{self.squares[2].top}\n"
    puts "#{' '*5} #{self.squares[0].mid}|#{self.squares[1].mid}|#{self.squares[2].mid}\n"
    puts "#{' '*5} #{self.squares[0].bottom}|#{self.squares[1].bottom}|#{self.squares[2].bottom}\n"
    puts "#{' '*5} #{GRID_LINE}\n"
    puts "#{' '*5} #{self.squares[3].top}|#{self.squares[4].top}|#{self.squares[5].top}\n"
    puts "#{' '*5} #{self.squares[3].mid}|#{self.squares[4].mid}|#{self.squares[5].mid}\n"
    puts "#{' '*5} #{self.squares[3].bottom}|#{self.squares[4].bottom}|#{self.squares[5].bottom}\n"
    puts "#{' '*5} #{GRID_LINE}\n"
    puts "#{' '*5} #{self.squares[6].top}|#{self.squares[7].top}|#{self.squares[8].top}\n"
    puts "#{' '*5} #{self.squares[6].mid}|#{self.squares[7].mid}|#{self.squares[8].mid}\n"
    puts "#{' '*5} #{self.squares[6].bottom}|#{self.squares[7].bottom}|#{self.squares[8].bottom}\n"
  end
  
  private

  # passed a group of 3 indexes, return which index refers to an empty square
  def get_empty_index(group)
    index = group.select { |i| squares[i].empty?}[0]
  end
  
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
  attr_accessor :player, :computer, :board, :message, :total_games, :auto_play,
                :sleep_time
  
  def initialize
    @board = GameBoard.new 
    @computer = AIPlayer.new("Computer", "o", self.board)
    @message = []
    @total_games = 0
    @auto_play = false
    @sleep_time = 1
  end

  def run
    draw_title
    name = get_player_name
    system 'clear'
    draw_title
    puts "Welcome, #{name}"
    puts "Would you like to [W]atch or [P]lay ?"
    input = gets.chomp.downcase
    if input == 'w'
      puts "Ok, just sit back and watch how it's done!"
      sleep 1
      self.auto_play = true
      self.sleep_time *= 0.5
      self.player = AIPlayer.new(name, 'x', self.board)
    elsif input == 'p'
      self.player = Player.new(name, "x", self.board)
    end
    sleep self.sleep_time
    draw
    play
  end
  
  def new_game
    self.board.reset
    self.message = []
    self.total_games += 1
    draw
  end
  
  def play
    new_game
    loop do
      self.player_move
      break if self.end_game?
      self.computer_move
      break if self.end_game?
    end
    update_score
    draw
    puts "\nPlay again? [Y]es   [N]o"
    play if gets.chomp.downcase == "y"
  end
  
  def get_player_name
    puts "Please tell me your name?"
    gets.chomp.capitalize
  end
  
  def player_move
    if self.auto_play
      self.message[1] = "#{self.player.name}'s move"
    else
      self.message[1] = "Your move, #{self.player.name}. Select 1 - 9"
    end
    draw
    sleep self.sleep_time
    self.player.choose
    draw
    sleep self.sleep_time if self.auto_play
  end
  
  def computer_move
    self.message[1] = "#{self.computer.name}'s move"
    draw
    sleep self.sleep_time
    self.computer.choose
    draw
    sleep self.sleep_time if self.auto_play
  end
    
  # see if we have a winner or all squares are taken
  def end_game?
    self.message = []
    if winner?(self.player)
      self.message[2] = "#{self.player.name} wins!"
      self.player.score += 1
      result = true
    elsif winner?(self.computer)
      self.message[2] = "#{self.computer.name} wins!"
      self.computer.score += 1
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
  
  def update_score
    self.message[3] = "#{self.player.name}: #{self.player.score}   #{self.computer.name}: #{self.computer.score}   Tie: #{self.total_games - self.computer.score - self.player.score}"
  end
  
  def draw_title
    puts '----------------------------------'
    puts '          Tic Tac Toe'
    puts '----------------------------------'
  end
  
  def draw
    system 'clear'
    draw_title
    self.board.draw
    self.message.each { |item| puts "#{item}"}
  end
  
end # Game

# ==================== PROGRAM START ==================== 
system 'clear'
Game.new.run
