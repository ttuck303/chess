require_relative 'Board'
require_relative 'Piece'
require_relative 'Pawn'

class Chess_Game
	attr_accessor :active_player

	LET_2_NUM = {'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8}
	NUM_2_LET = LET_2_NUM.invert

	def initialize
		@active_player = :white
		@game_board = Board.new
	end

	def get_player_move
		temp = select_a_piece
		piece = temp[0]
		origin = temp[1]
		move = enter_desired_move
		until legal_move?(origin, move, piece)
			move = enter_desired_move
			return get_player_move if move.to_s.downcase == 'o'
		end
		puts "Moving #{piece} from #{origin} to #{move}."
		[origin, move, piece] # return a piece and the legal move
	end

	def select_a_piece
		puts "Select a piece to move by indicating the space of the piece (e.g. 'a1' thru 'h8')"
		choice = gets.strip.to_sym
		piece = nil
	
		if !on_board?(choice) 					# check that the space entry is legit
			puts "Selection #{choice} is not on game board. Please try again."
			return select_a_piece
		elsif !space_occupied?(choice) 						# check that the space is occupied
			puts "There is no piece in the space. Please try again."
			return select_a_piece
		elsif !selection_is_on_active_team?(choice) 		# check that the piece belongs to the active player's team
			puts "That's not your team!"
			return select_a_piece
		else
			piece = @game_board.board[choice]
			puts "You have selected #{piece.type} in space #{choice.to_s}."
		end
		return [piece, choice]
	end

	def confirm_piece_selection
		puts "Is this is correct? [y/n]"
		confirmation = gets.strip.downcase
		get_player_move unless confirmation == 'y'
	end

	def enter_desired_move
		puts "Where do you want to move? (Enter o to select another piece to move)."
		choice = gets.strip.to_sym
	end

	def legal_move?(origin, move, piece)
		#puts "Debug: "
		#puts "Piece = #{piece}"
		#puts "Origin = #{origin}"
		#puts "Move = #{move}"

		if !on_board?(move)				# check that the move is on the board
			puts "The space you have selected is not on the board. Please try again."
			return false
		elsif space_occupied?(move) && selection_is_on_active_team?(move)   	# check that the desired space is not occupied by a teammate
			puts "That space is occupied by your team. Please try again."
			return false
		elsif !allowed_piece_movement?(origin, move, piece)  # check that the move abides by the piece's move rules (on an open board)
			return false
		elsif hopping_violation?(spaces_between(origin, move), piece) #hopping violation doesn't apply to knights.
			puts "Your #{piece.type} cannot jump other pieces. Please try again."
			return false
		elsif violates_special_cases?(origin, move, piece)
			return false

		else
			return true
		end
	 
		
			# check acceptable "difference" in row and column
			# check the piece is not "flying" over other pieces
			# edge cases:
				# knights can fly
				# rook / king can castle
				# pawn can move 2 on first go
				# pawn can take an opponent in a diagonal spot
				# check that the move would not move the King into check
	end

	def allowed_piece_movement?(origin, move, piece)
		x_diff = calculate_x_difference(origin, move)
		y_diff = calculate_y_difference(origin, move)
		piece.acceptable_move?(x_diff, y_diff)
	end


	def move_piece(origin, move, piece)
		# assumes that the checking logic has approved this move aleady
		@game_board.board[move].taken if @game_board.space_occupied?(move)
		@game_board.populate_space(move, piece)
		@game_board.empty_space(origin)
	end


	def on_board?(selection)
		@game_board.board.has_key?(selection)
	end

	def space_occupied?(selection)
		!@game_board.board[selection].nil?
	end

	def selection_is_on_active_team?(selection)
		@game_board.board[selection].team == @active_player
	end

	def selection_is_enemy?(selection)
		!selection_is_on_active_team
	end

	def destination_same_as_origin?(origin, destination)
		origin == destination
	end

	def game_loop
		until game_over?
			@game_board.display_board
			move_info = get_player_move
			move_piece(move_info[0], move_info[1], move_info[2])
			switch_team
		end
	end

	def space_occupied?(space)
		@game_board.space_occupied?(space)
	end

	def violates_special_cases?(origin, move, piece)
		case piece.type
		when :pawn
			x_diff = calculate_x_difference(origin, move)
			y_diff = calculate_y_difference(origin, move)

			# if move differential is 0,1, check that the space in front of the piece is not occupied
			if x_diff == 0 && y_diff.abs == 1 && space_occupied?(move)
				puts "Illegal Move: pawns cannot take pieces straight-on."
				return true

			# if move differential is 1,1, check that there is an enemy in that spot
			elsif x_diff.abs == 1 && y_diff.abs == 1 && (!space_occupied?(move) || selection_is_on_active_team?(move))
				puts "Illegal Move: pawn can only move diagonally when taking an opponent."
				return true
			end
			# if pawn moves into last space, generate new piece for that team
		end

	end

	def calculate_x_difference(space_1, space_2)
		puts "Debug"
		puts "space_1 #{space_1}"
		puts "space_2 #{space_2}"
		(letter_to_number(space_2.to_s[0]) - letter_to_number(space_1.to_s[0]))
	end

	def calculate_y_difference(space_1, space_2)
		(space_2[1].to_i - space_1[1].to_i)
	end

	def letter_to_number(letter)
		LET_2_NUM[letter]
	end

	def number_to_letter(number)
		NUM_2_LET[number]
	end

	def spaces_between(origin, move) 
		o_column = origin.to_s[0] 
		o_row = origin.to_s[1].to_i
		m_column = move.to_s[0]
		m_row = move.to_s[1].to_i
		output = []

		if o_column < m_column
			output = create_spaces_list(o_column, m_column, o_row, m_row)
		else
			output = create_spaces_list(m_column, o_column, m_row, o_row)
		end

		return output[1..-2] 
	end

	def create_spaces_list(smaller_letter, larger_letter, number_1, number_2)
		letter_range, number_range = nil, nil
		output = []

		if smaller_letter == larger_letter
			letter_range = Array.new((number_2 - number_1).abs+1, smaller_letter)
		else
			letter_range = Range.new(smaller_letter, larger_letter).to_a
		end

		if number_1 < number_2
			number_range = Range.new(number_1, number_2).to_a
		elsif number_1 == number_2
			number_range = Array.new(letter_range.size, number_1)
		else #number_1 > number_2
			number_range = Range.new(number_2, number_1).to_a.reverse!
		end

		letter_range.each_with_index do |letter, index|
			output << (letter+number_range[index].to_s).to_sym
		end

		output
	end


	def hopping_violation?(spaces, piece)
		if piece.type == :knight
			return false
		else
			spaces.each do |space|
				return true if !@game_board.board[space].nil?
			end
		end
		return false
	end


	def save_game
	end

	def load_game
	end

	def game_over?
		false
	end

	def switch_team
		if @active_player == :white
			@active_player = :black
		else
			@active_player = :white
		end
	end


end


g = Chess_Game.new
#p = Pawn.new(:white)
g.game_loop






=begin 	
#Hopping Method Tests 

puts "Vertical Test:"
spaces = g.spaces_between(:a7, :a5)
puts spaces
puts
puts g.hopping_violation?(spaces, p)
puts

puts "Horizontal Test:"
spaces2 = g.spaces_between(:a2, :h2)
puts spaces2
puts
puts g.hopping_violation?(spaces2, p)
puts 

puts "Diagonal Test:"
spaces3 = g.spaces_between(:a2, :g8)
puts spaces3
puts g.hopping_violation?(spaces3, p)

puts "Diagonal Test2:"
spaces4 = g.spaces_between(:h2, :b8)
puts spaces4
puts g.hopping_violation?(spaces4, p)

puts "Diagontal Test 3"
spaces5 = g.spaces_between(:a2, :d5)
puts spaces5
puts g.hopping_violation?(spaces5, p)

puts "Vertical Test 2"
spaces6 = g.spaces_between(:a2, :a5)
puts spaces6
puts g.hopping_violation?(spaces6, p)

puts "Horizontal Test 2"
spaces7 = g.spaces_between(:h2, :a2)
puts g.hopping_violation?(spaces7, p)

=end

=begin
#testing get spaces method

test1 = g.create_spaces_list('a', 'a', 3, 5)
test2 = g.create_spaces_list('a', 'a', 5, 3)
test3 = g.create_spaces_list('a', 'h', 2, 2)
test4 = g.create_spaces_list('a', 'd', 2, 5)
test5 = g.create_spaces_list('a', 'e', 5, 1)


puts "Test 1:"
puts test1
puts
puts "Test 2:"
puts test2
puts
puts "Test 3:"
puts test3
puts
puts "Test 4:"
puts test4
puts
puts "Test 5:"
puts test5
puts




=end




