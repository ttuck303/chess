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
		populate_new_board
		@purgatory = clear_purgatory_hash
		@white_team = []
		@black_team = []
		@game_status = :no_restrictions
	end

	def populate_new_board #TO DO: refactor to be more concise
		for i in 'a'..'h'
			populate_space((i+'2').to_sym, Pawn.new('white'))
			populate_space((i+'7').to_sym, Pawn.new('black'))
		end
		populate_space(:a1, Rook.new('white'))
		populate_space(:b1, Knight.new('white'))
		populate_space(:c1, Bishop.new('white'))
		populate_space(:d1, Queen.new('white'))
		populate_space(:e1, King.new('white'))
		populate_space(:f1, Bishop.new('white'))
		populate_space(:g1, Knight.new('white'))
		populate_space(:h1, Rook.new('white'))

		populate_space(:a8, Rook.new('black'))
		populate_space(:b8, Knight.new('black'))
		populate_space(:c8, Bishop.new('black'))
		populate_space(:d8, Queen.new('black'))
		populate_space(:e8, King.new('black'))
		populate_space(:f8, Bishop.new('black'))
		populate_space(:g8, Knight.new('black'))
		populate_space(:h8, Rook.new('black'))
		return nil
	end

	def populate_team_tracker
		white = []
		black = []
		for letter in range ('a'..'h')
			for num in range (1..2)
				space = (letter+num.to_s).to_sym
				piece = get_piece_in_space(space)
				white << piece
			end
			for num in range (7..8)
				space = (letter+num.to_s).to_sym
				piece = get_piece_in_space(space)
				black << piece
			end
		end
		@white_team = white
		@black_team = black
		return nil
	end

	def populate_space(space, piece)
		@game_board.populate_space(space, piece)
	end

	def clear_purgatory_hash
		{:taken_piece => nil, :attacking_piece_move => nil, :attacking_piece => nil, :attacking_piece_origin => nil}
	end

	def stash_in_purgatory(origin, move, piece)
		puts "stashing in purgatory"
		@purgatory[:attacking_piece] = piece
		@purgatory[:attacking_piece_origin] = origin
		@purgatory[:attacking_piece_move] = move
		@purgatory[:taken_piece] = get_piece_in_space(move)
		puts "Purgatory = #{@purgatory.inspect}"
		return nil
	end

	def make_simple_move(origin, move, piece)
		@game_board.populate_space(move, piece)
		@game_board.empty_space(origin)
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
		[origin, move, piece] # return a piece and the legal move
	end

	def select_a_piece
		puts "#{@active_player} select a piece to move ('a1' thru 'h8')"
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
			piece = get_piece_in_space(choice)
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
	end

	def allowed_piece_movement?(origin, move, piece)
		x_diff = calculate_x_difference(origin, move)
		y_diff = calculate_y_difference(origin, move)
		piece.acceptable_move?(x_diff, y_diff)
	end

	def get_piece_in_space(space) # gets the piece or returns nil if there is none
		@game_board.get_piece_in_space(space)
	end


	def on_board?(selection)
		@game_board.on_board?(selection)
	end

	def space_occupied?(selection)
		!(@game_board[selection].nil?)
	end

	def selection_is_on_active_team?(selection)
		@game_board.board[selection].team == @active_player
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
		until @game_status == :checkmate
			@game_board.display_board
			puts "#{@active_player} you are in check!" if in_check?(@active_player)
			propose_move
			until !in_check?(@active_player)
				puts "You are still in check. Please enter a differrent move."
				restore_prev_board_state
				@game_board.display_board
				propose_move
			end
			complete_proposed_move
			switch_team
		end
	end

	def propose_move
		puts
		puts "proposing move..."
		move_info = get_player_move
		move_piece_phase_1(move_info[0], move_info[1], move_info[2])
	end

	def restore_prev_board_state # undo the move by putting pieces back where they were on the board and clearing purgatory
		origin = @purgatory[:attacking_piece_origin]
		move = @purgatory[:attacking_piece_move]
		attacking_piece = @purgatory[:attacking_piece]
		taken_piece = @purgatory[:taken_piece]

		@game_board.empty_space(move)
		@game_board.populate_space(origin, attacking_piece)
		@game_board.populate_space(move, taken_piece)
	end

	def move_piece_phase_1(origin, move, piece) # moving pieces and stashing move info in hash
		puts "Moving phase 1"
		stash_in_purgatory(origin, move, piece)
		@game_board.empty_space(move)
		@game_board.populate_space(move, piece)
		@game_board.empty_space(origin)
		puts "temporary game board being evaluated:"
		@game_board.display_board
	end


	def empty_space(space)
		@game_board.empty_space(space)
	end


	def complete_proposed_move # finalizing the move by clearing the purgatory
		@purgatory[:taken_piece].taken unless @purgatory[:taken_piece].nil?
		@purgatory[:attacking_piece].moved!
		@purgatory = clear_purgatory_hash
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
				return true if space_occupied?(space)
			end
		end
		return false
	end

	def save_game
	end

	def load_game
	end

	def game_over?
		if in_check?(@active_player)
			if checkmate?
				return true
			end
		end
		return false
	end

	def switch_team
		if @active_player == :white
			@active_player = :black
		else
			@active_player = :white
		end
	end


	def surrounding_spaces_and_pieces(space, kings_team) # return array with space, direction, and piece
		enemy_team = other_team(kings_team)
		enemy_spaces = []
		vacant_spaces = []

		DIRECTIONS.each do |dir|
			resulting_space = @game_board.relative_space(space, dir)
			if resulting_space != "Out of bounds"
				if space_occupied?(resulting_space)
					piece = get_piece_in_space(resulting_space)
					if piece.team == enemy_team
						enemy_spaces <<  [resulting_space, dir.to_sym, piece]
					end
				else
					vacant_spaces << [resulting_space, dir.to_sym]
				end
			end
		end
		return {:vacancies => vacant_spaces, :enemies => enemy_spaces}
	end

	def locate_king(kings_team)
		return @game_board.locate_king(kings_team)
	end

	def in_check?(kings_team)
		kings_location = locate_king(kings_team)
		surrounding_space_information = surrounding_spaces_and_pieces(kings_location, kings_team)
		enemies = surrounding_space_information[:enemies]
		vacancies = surrounding_space_information[:vacancies]


		return true if !enemies.empty? && proximity_threat_check?(enemies)[0]
		return true if lurking_knight?(kings_location, kings_team)[0]
		return true if !vacancies.empty? && threat_from_gaps?(kings_location, vacancies, kings_team)[0]
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

	def threat_from_gaps?(kings_location, gaps_packet, kings_team)
		enemy_team = other_team(kings_team)
		gaps_packet.each do |packet|
			gap_space = packet[0]
			direction = packet[1].to_s
			until space_occupied?(gap_space) || gap_space == "Out of bounds" #fatal bug: checking for border is not sufficient because you can travel along border
				gap_space = rel_space(gap_space, direction)
			end

			if space_occupied?(gap_space)
				piece = get_piece_in_space(gap_space)
				if piece.team == enemy_team
					return [true, piece, direction] if ranged_enemy_threat?(piece, direction)
				end
			end
		end
		return [false]
	end

	def get_threat_path(kings_location, kings_team, gaps_packet)
		gaps_packet.each do |packet|
			gap_space = packet[0]
			direction = packet[1].to_s
			until space_occupied?(gap_space) || gap_space == "Out of bounds" #fatal bug: checking for border is not sufficient because you can travel along border
				gap_space = rel_space(gap_space, direction)
			end
			if space_occupied?(gap_space)
				piece = get_piece_in_space(gap_space)
				if piece.team == enemy_team
					if ranged_enemy_threat?(piece, direction)
						return [piece, direction]
					end
				end
			end
		end
		
	end

	def ranged_enemy_threat?(piece, direction)
		if ['n', 's', 'e', 'w'].include?(direction) && [:queen, :rook].include?(piece.type)
			return [true, piece, direction]
		elsif ['ne', 'nw', 'se', 'sw'].include?(direction) && [:bishop, :queen].include?(piece.type)
			return [true, piece, direction]
		else
			return [false]
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
		return [false] if enemies_packet.empty?
		enemies_packet.each do |enemy_packet|
			space = enemy_packet[0]
			direction = enemy_packet[1]
			piece = enemy_packet[2]
			if proximity_threat?(piece, direction)
				puts "#{piece.type} in space #{space} is causing threat"
				return [true, piece, direction]
			end
		end
		return [false]
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
		output.keep_if {|item| item != "Out of bounds"}
		return output
	end


	def lurking_knight?(king_space, king_team)
		enemy_team = other_team(king_team)
		knight_territory = get_knight_territory(king_space)
		knight_territory.each do |space|
			if space_occupied?(space)
				piece = get_piece_in_space(space)
				return [true, space, piece] if piece.team == enemy_team && piece.type == :knight
			end
		end
		return [false]
	end

	def is_border?(space)
		@game_board.is_border?(space)
	end

	def checkmate?
		return false if can_move_king?
		return false if can_obstruct_threat?
		return false if can_eliminate_threat?
		return true
	end

	def can_move_king?
		kings_location = locate_king(@active_player)
		king = get_piece_in_space(kings_location)
		adjacent_vacancies = surrounding_spaces_and_pieces(kings_location, @active_player)[:vacancies]
		adjacent_vacancies.each do |move|
			temp_board = @game_board.clone()
			make_simple_move(kings_location, move, king)
			return true unless in_check?(@active_player)
		end
		return false
	end

	def can_obstruct_threat?(kings_team = @active_player, kings_location, vaccancies)
		# get the path between the threat and the king -> sub method
		path = get_threat_path(kings_location, kings_team, vacancies) if threat_from_gaps?(kings_location, vaccancies, kings_team)
		# get the active teams remaining pieces (how?) -> may need to keep track of the pieces on each team from the get-go (faster than scanning the board for remaining pieces each time)
		# for each piece, try to move to each spot on the path
			# check for legal move
				# if move completes legally, check for in check
					# if not in check, then return true
		# else return false

		return false
	end

	def can_eliminate_threat?
		return false
	end


end


g = Chess_Game.new
g.game_loop








