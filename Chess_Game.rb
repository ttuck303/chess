require_relative 'Board'
require_relative 'Piece'
require_relative 'Pawn'
require_relative 'King'

class Chess_Game
	attr_accessor :active_player, :game_board #board is temp for debugging

	LET_2_NUM = {'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8}
	NUM_2_LET = LET_2_NUM.invert
	DIRECTIONS = ['n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw']

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
		puts "Select a piece to move by indicating the space of the piece ('a1' thru 'h8')"
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
			piece = @game_board[choice]
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
		@game_board[move].taken if @game_board.space_occupied?(move)
		@game_board.populate_space(move, piece)
		@game_board.empty_space(origin)
	end

	def get_piece_in_space(space)
		@game_board.get_piece_in_space(space)
	end


	def on_board?(selection)
		@game_board.has_key?(selection)
	end

	def space_occupied?(selection)
		!(@game_board[selection].nil?)
	end

	def selection_is_on_active_team?(selection)
		@game_board[selection].team == @active_player
	end

	def selection_is_enemy?(selection)
		!selection_is_on_active_team?(selection)
	end

	def destination_same_as_origin?(origin, destination)
		origin == destination
	end

	def piece_on_team(piece, team)
		return piece.team == team
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
			if (x_diff == 0 && (y_diff.abs == 1 || y_diff.abs == 2) && space_occupied?(move))
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
				return true if !@game_board[space].nil?
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


	def surrounding_spaces_and_pieces(space, kings_team) # return array with space, direction, and piece
		# look in each direction
		# if the space is out of bounds, skip it
		# if the space is in bounds
			# if the space is empty > add to vacancy list
			# if the space is occupied by an enemy > add to enemy list


		enemy_team = other_team(kings_team)
		enemy_spaces = []
		vacant_spaces = []
	

		DIRECTIONS.each do |dir|
			puts
			puts "re enering the directions loop"
			resulting_space = @game_board.relative_space(space, dir)
			puts "resulting_space found = #{resulting_space}"
			puts
			if resulting_space != "Out of bounds"
				if space_occupied?(resulting_space)
					puts "#{resulting_space} space occupied..."
					piece = get_piece_in_space(resulting_space)
					puts "#{piece.type} found"
					if piece.team == enemy_team
						enemy_spaces <<  [resulting_space, dir.to_sym, piece]
					end
				else
					puts "#{resulting_space} is vacant it says"
					vacant_spaces << [resulting_space, dir.to_sym]
				end
			end
		end

		puts "returning vacancies = #{vacant_spaces.inspect}"
		puts "returning enemies = #{enemy_spaces.inspect}"
		return {:vacancies => vacant_spaces, :enemies => enemy_spaces}
	end

	def locate_king(kings_team)
		return @game_board.locate_king(kings_team)
	end

	def in_check?(kings_team)
		puts "Getting kings location..."
		kings_location = locate_king(kings_team)
		puts "Kings location found: #{kings_location}"
		puts
		puts "Getting surrounding space information...."
		surrounding_space_information = surrounding_spaces_and_pieces(kings_location, kings_team)
		puts "Completed surrounding information search."
		puts

		enemies = surrounding_space_information[:enemies]
		vacancies = surrounding_space_information[:vacancies]

		puts "Enemies = #{enemies}"
		puts "Vacancies = #{vacancies}"
		return true if !enemies.empty? && proximity_threat_check?(enemies)
		puts
		puts "Checking for lurking knights..."	
		return true if lurking_knight?(kings_location, kings_team)
		puts "Completed check for lurking knights"
		puts
		puts "Checking gaps threats..."
		#return true if !vacancies.empty? && threat_from_gaps?(kings_location, vacancies, kings_team)
		puts "Completed checking for vaccanies"
		puts "Not in check!"
		return false

	end

	def calc_adjacent_direction(origin, move) #between adjacent squares only!
		x_diff = calculate_x_difference(origin, move)
		y_diff = calculate_y_difference(origin, move)
		dir = ''
		if y_diff == 1
			dir += 'n'
		elsif y_diff == -1
			dir += 's'
		end

		if x_diff == 1
			dir += 'e'
		elsif x_diff == -1
			dir += 'w'
		end

		return dir 
	end

	def threat_from_gaps?(king_location, gaps, kings_team)
		enemy_team = other_team(kings_team)
		gaps.each do |gap|
			direction = calc_adjacent_direction(king_location, gap)
			space = gap
			until space_occupied?(space) || is_border?(space)
				if space_occupied?(space)
					piece = get_piece_in_space(space)
					if piece.team == enemy_team
						return true if ranged_enemy_threat?(piece, direction)
					end
				end
			end
		end
		return false
	end

	def ranged_enemy_threat?(piece, direction)
		if ['n', 's', 'e', 'w'].include?(direction) && [:queen, :rook].include?(piece.type)
			return true
		elsif ['ne', 'nw', 'se', 'sw'].include?(direction) && [:bishop, :queen].include?(piece.type)
			return true
		else
			return false
		end
	end

	def other_team(team)
		if team == :white
			:black
		elsif team == :black
			:white
		else
			"Error: unrecognized team"
		end
	end


	def proximity_threat_check?(enemies_packet)
		return false if enemies_packet.empty?
		enemies_packet.each do |enemy_packet|
			space = enemy_packet[0]
			direction = enemy_packet[1]
			piece = enemy_packet[2]
			if proximity_threat?(piece, direction)
				puts "#{piece.type} in space #{space} is causing threat"
				return true
			end
		end
		return false
	end

	def proximity_threat?(piece, direction)
		type = piece.type
		case type
		when :queen
			return true
		when :king
			return true
		when :rook
			return true if [:n, :s, :e, :w].include?(direction)
		when :bishop
			return true if [:ne, :nw, :se, :sw].include?(direction)
		when :pawn
			team = piece.team
			return true if (team == :white && [:se, :sw].include?(direction))
			return true if (team == :black && [:ne, :nw].include?(direction))
		when :knight
			return false
		end
	end

	def rel_space(space, direction)
		@game_board.relative_space(space, direction)
	end

	def get_knight_territory(center_space)

		north = rel_space(center_space, 'n')
		nnw = rel_space(north, 'nw')
		nne = rel_space(north, 'ne')
		nee = rel_space(rel_space(north, 'e'), 'e')
		nww = rel_space(rel_space(north, 'w'), 'w')

		south = rel_space(center_space, 's')
		ssw = rel_space(south, 'sw')
		sse = rel_space(south, 'se')
		see = rel_space(rel_space(south, 'e'), 'e')
		sww = rel_space(rel_space(south, 'w'), 'w')

		output = [nnw, nne, nee, nww, ssw, sse, see, sww]
		puts "original output = #{output}"
		output.keep_if {|item| item != "Out of bounds"}
		puts "new output = #{output}"
		return output
	end


	def lurking_knight?(king_space, king_team)
		enemy_team = other_team(king_team)
		knight_territory = get_knight_territory(king_space)
		knight_territory.each do |space|
			puts "Inspecting space #{space}"
			if space_occupied?(space)
				piece = get_piece_in_space(space)
				return true if piece.team == enemy_team && piece.type == :knight
			end
		end
		return false

	end

	def is_border?(space)
		@game_board.is_border?(space)
	end




end


g = Chess_Game.new
#g.game_loop

#g.in_check?(:white)



#checks for each type of check
# adjacent threat
	# pawn
	# rook
	# bishop
	# king
	# queen
	# not knight
# ranged threat
	# pawn
	# rook
	# bishop
	# king
	# queen
	# not knight
# knights
	# each spot



# conditions for test
	# in Chess_Game, allow accessor to board
	# in Board, block populate new board

test_board_1 = Board.new
test_board_1.populate_space(:e8, King.new('black'))
test_board_1.populate_space(:d7, Pawn.new('white'))
g.game_board = test_board_1
g.game_board.display_board
puts g.in_check?(:black)

# test 1 pawn confirmed

test_board_2 = Board.new
test_board_2.populate_space(:e8, King.new('black'))
test_board_2.populate_space(:f7, Pawn.new('white'))
g.game_board = test_board_2
g.game_board.display_board
puts g.in_check?(:black)

# test 2 pawn confirmed
puts "TEST 3"
test_board_3 = Board.new
test_board_3.populate_space(:e8, King.new('black'))
test_board_3.populate_space(:e7, Pawn.new('white'))
g.game_board = test_board_3
g.game_board.display_board
puts g.in_check?(:black)








