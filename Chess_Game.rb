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
		@debug = true # switches debugging print lines on or off
		@active_player = :white
		@game_board = Board.new
		#populate_new_board #commented out for debugging
		@purgatory = {}
		clear_purgatory
		@white_pieces, @black_pieces = [], []
		populate_team_tracker
		@game_status = :normal
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
		for letter in ('a'..'h')
			for num in (1..8)
				space = (letter+num.to_s).to_sym
				piece = get_piece_in_space(space)
				if !piece.nil?
					white << piece if piece.team == :white
					black << piece if piece.team == :black
				end
			end
		end
		@white_pieces = white
		@black_pieces = black
		return nil
	end

	def populate_space(space, piece)
		@game_board.populate_space(space, piece)
	end

	def clear_purgatory
		@purgatory = {:taken_piece => nil, :attacking_piece_move => nil, :attacking_piece => nil, :attacking_piece_origin => nil}
	end

	def stash_in_purgatory(origin, move, piece)
		puts "stashing in purgatory" if @debug
		@purgatory[:attacking_piece] = piece
		@purgatory[:attacking_piece_origin] = origin
		@purgatory[:attacking_piece_move] = move
		@purgatory[:taken_piece] = get_piece_in_space(move)
		puts "Purgatory = #{@purgatory.inspect}" if @debug
		return nil
	end

	def make_simple_move(origin, move, piece)
		puts "before move:" if @debug
		display_board if @debug
		puts "making simple move #{piece} from #{origin} to #{move}" if @debug
		@game_board.populate_space(move, piece)
		@game_board.empty_space(origin)
		puts "after move:" if @debug
		display_board if @debug
	end


	def select_a_piece_space
		puts "#{@active_player.capitalize} select a piece to move ('a1' thru 'h8')"
		choice = gets.strip.to_sym
	end

	def valid_piece_selection?(choice)
		if !on_board?(choice) 					# check that the space entry is legit
			puts "Selection #{choice} is not on game board. Please try again."
			return false
		elsif !space_occupied?(choice) 						# check that the space is occupied
			puts "There is no piece in the space. Please try again."
			return false
		elsif !selection_is_on_active_team?(choice) 		# check that the piece belongs to the active player's team
			puts "That's not your team!"
			return false
		else
			return true
		end
	end

	def enter_desired_move
		puts "Where do you want to move?"
		puts "Enter the space (ie 'b4')"
		puts "Enter o' to select another piece to move"
		puts "Enter 'cr' to castle right or 'cl' to castle left"
		choice = gets.strip.to_sym
	end

	def valid_move_selection?(origin, move, piece)
		puts "Entering valid_move_selection? for piece #{piece.type} #{piece.object_id} in space #{origin} to space #{move}" if @debug

		if move == :cl || move == :cr
			return valid_castle_request?(origin, move, piece)
		elsif move == :o
			return true
		elsif !on_board?(move)				# check that the move is on the board
			puts "The space you have selected is not on the board. Please try again."
			return false
		elsif space_occupied?(move) && !enemies?(piece, get_piece_in_space(move))   	# check that the desired space is not occupied by a teammate
			puts "That space is occupied by your team. Please try again."
			return false
		elsif !allowed_piece_movement?(origin, move, piece)  # check that the move abides by the piece's move rules (on an open board)
			return false
		elsif hopping_violation?(spaces_between(origin, move)[1..-2], piece) #hopping violation doesn't apply to knights.
			puts "Your #{piece.type} cannot jump other pieces. Please try again."
			return false
		elsif violates_special_cases?(origin, move, piece)
			return false
		else
			return true
		end
	end

	def valid_castle_request?(origin, move, piece)
		if piece.moved
			puts "King has already moved, cannot castle."
			return false
		end

		team = piece.team
		rook = nil
		spaces_covered = nil

		if team == :black
			if move == :cl
				rook = get_piece_in_space(:a8) if space_occupied?(:a8)
				spaces_covered = [:d8,:c8,:b8]
			elsif move == :cr
				rook = get_piece_in_space(:h8) if space_occupied?(:h8)
				spaces_covered = [:f8, :g8]
			else
				puts "Error detecting move"
			end
		elsif team == :white
			if move == :cl
				rook = get_piece_in_space(:a1) if space_occupied?(:a1)
				spaces_covered = [:d1, :c1, :b1]
			elsif move == :cr
				rook = get_piece_in_space(:h1) if space_occupied?(:h1)
				spaces_covered = [:f1, :g1]
			else
				puts "Error detecting move"
			end
		else
			puts "Error detecting team."
		end

		if rook == nil || rook.type != :rook || rook.team != team 
			puts "Invalid set up to castle in that direction"
			return false
		end

		if rook.moved
			puts "Rook has already moved"
			return false
		end

		if in_check?(team)
			puts "Cannot castle when in check."
			return false
		end
		stashed_game_state = [origin, nil, piece]
		spaces_covered.each do |space|
			stashed_game_state[1] = space
			if space_occupied?(space)
				puts "Spaces between king and rook must be unoccupied to castle."
				undo_simple_move(stashed_game_state)
				return false
			else
				make_simple_move(origin, space, piece)
				if in_check?(team)
					puts "Cannot move through check"
					undo_simple_move(stashed_game_state)
					return false
				end
				undo_simple_move(stashed_game_state)
			end
		end
		undo_simple_move(stashed_game_state)
		return true
	end

	def undo_simple_move(args)
		puts "calling undo_simple_move" if @debug
		puts "before call board: " if @debug
		display_board if @debug
		origin = args[0]
		move = args[1]
		piece = args[2]

		@game_board.populate_space(origin, piece)
		@game_board.empty_space(move)
		puts "after call board: " if @debug
		display_board if @debug
	end

	def stalemate?

	end


	def enemies?(attacking_piece, defending_piece)
		puts if @debug
		puts "entering enemies? method" if @debug
		puts "checking #{attacking_piece} with team #{attacking_piece.team}" if @debug
		puts "against #{defending_piece} with team #{defending_piece.team} " if @debug
		attacking_piece.team != defending_piece.team
	end

	def allowed_piece_movement?(origin, move, piece)
		puts "entering allowed_piece_movement? method with inputs piece = #{piece.type} #{piece.object_id} from #{origin} to #{move}" if @debug
		x_diff = calculate_x_difference(origin, move)
		y_diff = calculate_y_difference(origin, move)
		puts "calculated x_diff = #{x_diff} and y_diff #{y_diff}" if @debug
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

	def selection_is_on_active_team?(selection) #TODO squash bug: test 5 is finding check mate because its wrongly identifying the move where the king takes the queen as cannibalism
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

	def display_board
		@game_board.display_board
	end

	def move_piece_loop
		display_board
		piece_origin = select_a_piece_space
		if !valid_piece_selection?(piece_origin)
			piece_origin = select_a_piece_space until valid_piece_selection?(piece_origin)
		end
		piece_to_move = get_piece_in_space(piece_origin)
		piece_destination = enter_desired_move
		if !valid_move_selection?(piece_origin, piece_destination, piece_to_move)
			piece_destination = enter_desired_move until valid_move_selection?(piece_origin, piece_destination, piece_to_move)
		end
		move_piece_loop if piece_destination == :o #escape the current piece selection

		if piece_destination == :cl || piece_destination ==:cr
			rook = nil
			if active_player == :white
				if piece_destination == :cl 
					make_simple_move(piece_origin, :b1, piece_to_move)
					rook = get_piece_in_space(:a1)
					make_simple_move(:a1, :c1, rook)
					rook.moved!
					piece_to_move.moved!
				elsif piece_destination == :cr
					make_simple_move(piece_origin, :g1, piece_to_move)
					rook = get_piece_in_space(:h1)
					make_simple_move(:h1, :f1, rook)
					rook.moved!
					piece_to_move.moved!
				end
			elsif active_player == :black
				if piece_destination == :cl
					make_simple_move(piece_origin, :b8, piece_to_move)
					rook = get_piece_in_space(:a8)
					make_simple_move(:a8, :c8, rook)
					rook.moved!
					piece_to_move.moved!
				elsif piece_destination == :cr
					make_simple_move(piece_origin, :g8, piece_to_move)
					rook = get_piece_in_space(:h8)
					make_simple_move(:h8, :f8, rook)
					rook.moved!
					piece_to_move.moved!
				end
			end
		else
			stash_in_purgatory(piece_origin, piece_destination, piece_to_move)
			make_simple_move(piece_origin, piece_destination, piece_to_move)

			if in_check?(@active_player)
				puts "This move leaves you in check."
				restore_prev_board_state
				move_piece_loop
			else
				finalize_move
			end
		end
	end

	def game_loop
		until game_over?
			move_piece_loop
			check_pawn_promotion
			update_game_status(other_team(@active_player))
			switch_team
		end
	end

	def game_over?
		@game_status == :checkmate || @game_status == :stalemate
	end


	def restore_prev_board_state # undo the move by putting pieces back where they were on the board and clearing purgatory
		puts "entering restory previous board state method" if @debug
		puts "purgatory = #{@purgatory.inspect}" if @debug
		origin = @purgatory[:attacking_piece_origin]
		move = @purgatory[:attacking_piece_move]
		attacking_piece = @purgatory[:attacking_piece]
		taken_piece = @purgatory[:taken_piece]
		puts "game board before restoration =" if @debug
		display_board if @debug
		@game_board.empty_space(move)
		@game_board.populate_space(origin, attacking_piece)
		@game_board.populate_space(move, taken_piece)
		puts "game board after restoration" if @debug
		display_board if @debug
		clear_purgatory
	end


	def empty_space(space)
		@game_board.empty_space(space)
	end


	def finalize_move # finalizing the move by clearing the purgatory
		piece = @purgatory[:taken_piece]
		if !piece.nil?
			piece.taken
			eliminate_piece_from_match(piece)
		end
		@purgatory[:attacking_piece].moved!
		clear_purgatory
	end

	def eliminate_piece_from_match(piece)
		if @white_pieces.include?(piece)
			@white_pieces.delete(piece)
		elsif @black_pieces.include?(piece)
			@black_pieces.delete(piece)
		else
			puts "piece not found..."
		end
	end

	def add_piece_to_tracker(piece)
		if piece.team == :white 
			@white_pieces << piece
		elsif piece.team == :black 
			@black_pieces << piece 
		else
			puts "Error identifying piece's team"
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

	def spaces_between(origin, move) # need to make sure that this outputs in order of origin -> move
		o_column = origin.to_s[0] 
		o_row = origin.to_s[1].to_i
		m_column = move.to_s[0]
		m_row = move.to_s[1].to_i
		output = []

		if o_column < m_column
			output = create_spaces_list(o_column, m_column, o_row, m_row)
		else
			output = create_spaces_list(m_column, o_column, m_row, o_row)
			output.reverse!
		end

		return output
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
			#puts "inputs to relative_space method:" if @debug
			#puts "space = #{space}, direction = #{dir}" if @debug
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
		puts "locating king on team #{kings_team.inspect}" if @debug
		return @game_board.locate_king(kings_team.to_sym)
	end

	def locate_piece(piece)
		return @game_board.locate_piece(piece)
	end

	def in_check?(kings_team = @active_player)
		kings_location = locate_king(kings_team)
		puts "within in check method, looking for team #{kings_team}" if @debug
		puts "within in_check method, found king at #{kings_location}" if @debug
		surrounding_space_information = surrounding_spaces_and_pieces(kings_location, kings_team)
		enemies = surrounding_space_information[:enemies]
		vacancies = surrounding_space_information[:vacancies]
		puts "Enemies found: #{enemies.inspect}" if @debug
		puts "Vacancies found: #{vacancies.inspect}" if @debug

		puts "checking proximity_threat" if @debug
		return true if !enemies.empty? && proximity_threat_check(enemies)[0]
		puts "checking lurking knights"  if @debug
		return true if lurking_knight_check(kings_location, kings_team)[0]
		puts " checking threats from gaps"  if @debug
		return true if !vacancies.empty? && threat_from_gaps(kings_location, vacancies, kings_team)[0]
		puts "found no threats to #{kings_team}"  if @debug
		return false
	end

	def update_game_status(kings_team = @active_player)
		@game_status = :normal # ONLY FOR DEBUGGING SO WE CAN EVALUATE MID GAME SCENARIOS
		populate_team_tracker # ONLY FOR DEBUGGING SO WE CAN EVALUATE MID GAME SCENARIOS
		puts "game status = #{@game_status}" if @debug
		puts "remaining white team = #{@white_pieces.inspect}" if @debug
		puts "remaining black team = #{@black_pieces.inspect}" if @debug
		kings_location = locate_king(kings_team)
		threatening_piece = nil
		threat_space = nil
		surrounding_space_information = surrounding_spaces_and_pieces(kings_location, kings_team)
		enemies = surrounding_space_information[:enemies]
		vacancies = surrounding_space_information[:vacancies]
		knights_nearby = lurking_knight_check(kings_location, kings_team)

		if !enemies.empty?
			puts "enemies not empty"  if @debug
			temp = proximity_threat_check(enemies)
			is_proximity_threat = temp[0]
			puts "proximity threat determined to be #{is_proximity_threat}"  if @debug
			if is_proximity_threat
				threatening_piece = temp[1]
				threat_space = temp[2]
				puts "#{kings_team.capitalize} is in check!"
				@game_status = :in_check
			end
		end
		puts "evaluating vacanices"  if @debug
		if !vacancies.empty?
			puts "vacancies not empty, evaluating threat from gaps"  if @debug
			temp = threat_from_gaps(kings_location, vacancies, kings_team)
			gap_threat = temp[0]
			puts "gap threat determined to be #{gap_threat}"  if @debug
			if gap_threat
				threatening_piece = temp[1]
				threat_space = temp[2]
				puts "#{kings_team.capitalize} is in check!"
				@game_status = :in_check
			end
		end
		puts "evaluating knights nearby..."  if @debug
		if knights_nearby[0]
			puts "determined kings nearby"  if @debug
			puts "#{kings_team.capitalize} is in check!"
			@game_status = :in_check
			threatening_piece = knights_nearby[1]
			threat_space = knights_nearby[2]
		end
		
		puts "entering checkmate check" if @debug
		if @game_status == :in_check
			if !(can_move_king?(kings_team, kings_location, vacancies) || can_obstruct_or_destroy_threat?(kings_team, kings_location, threat_space))
				puts "found check m8 to be true" if @debug
				puts "#{@active_player.capitalize} puts #{kings_team} in checkmate!"
				@game_status = :checkmate
			end
		end
		puts "game status = #{@game_status}, threatening_piece = #{threatening_piece} from #{threat_space}" if @debug

		return [@game_status, threatening_piece, threat_space]
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

	def threat_from_gaps(kings_location, gaps_packet, kings_team)
		puts "Entering Threats from Gaps method" if @debug
		enemy_team = other_team(kings_team)
		puts "evaluating threats from team #{enemy_team}" if @debug
		gaps_packet.each do |packet|

			gap_space = packet[0]
			direction = packet[1].to_s
			puts "inspecting packet with #{gap_space} and #{direction}" if @debug
			until space_occupied?(gap_space) || gap_space == "Out of bounds" #fatal bug: checking for border is not sufficient because you can travel along border
				gap_space = rel_space(gap_space, direction)
			end

			if space_occupied?(gap_space)
				piece = get_piece_in_space(gap_space)
				if piece.team == enemy_team
					puts "located enemy piece #{piece} in #{gap_space}" if @debug
					puts "evaluating ranged threat with ranged_enemy_threat method" if @debug
					return [true, piece, gap_space] if ranged_enemy_threat?(piece, direction)[0]
				end
			end
		end
		return [false]
	end

	def ranged_enemy_threat?(piece, direction)
		puts "evaluating ranged enemy threat of #{piece} in direction #{direction}" if @debug
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


	def proximity_threat_check(enemies_packet)
		return [false] if enemies_packet.empty?
		enemies_packet.each do |enemy_packet|
			space = enemy_packet[0]
			direction = enemy_packet[1]
			piece = enemy_packet[2]
			if proximity_threat?(piece, direction)
				puts "#{piece.type} in space #{space} is causing threat" if @debug
				return [true, piece, space]
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


	def lurking_knight_check(kings_space, kings_team)
		enemy_team = other_team(kings_team)
		knight_territory = get_knight_territory(kings_space)
		knight_territory.each do |space|
			if space_occupied?(space)
				piece = get_piece_in_space(space)
				return [true, piece, space] if piece.team == enemy_team && piece.type == :knight
			end
		end
		return [false]
	end

	def is_border?(space)
		@game_board.is_border?(space)
	end

	def can_move_king?(kings_team, kings_location, adjacent_vacancies)
		king = get_piece_in_space(kings_location)
		puts "king var = #{king.inspect}, location = #{kings_location}" if @debug
		flag = false
		adjacent_vacancies.each do |move| # packect format is [space, direction]
			puts "move #{move.inspect}" if @debug
			stash_in_purgatory(kings_location, move[0], king)
			make_simple_move(kings_location, move[0], king)
			if !in_check?(kings_team)
				flag = true 
				restore_prev_board_state
				return flag
			end
			restore_prev_board_state
		end
		return flag
	end

	def get_teams_remaining_pieces(team = @active_player)
		if team == :white
			return @white_pieces
		elsif team == :black
			return @black_pieces
		else
			puts "Error finding active teams pieces"
			return nil
		end
	end

	def can_obstruct_or_destroy_threat?(kings_team, kings_location, threat_location)
		puts "Entering can obstruct or destroy method" if @debug

		threat_path = spaces_between(kings_location, threat_location)[1..-1] 	# get the path between the threat and the king
		puts "Threat path = #{threat_path.inspect}" if @debug
		flag = false
		get_teams_remaining_pieces(kings_team).each do |piece|
			puts "looking for piece #{piece}" if @debug
			origin = locate_piece(piece)
			puts "with origin at #{origin}" if @debug
			threat_path.each do |move|
				puts "inspecting move to  #{move}" if @debug
				if valid_move_selection?(origin, move, piece)
					puts "move determined to be valid" if @debug
					stash_in_purgatory(origin, move, piece)
					make_simple_move(origin, move, piece)
					if !in_check?(kings_team)
						puts "found way to obstruct or destroy threat!" if @debug
						flag = true
						restore_prev_board_state
						return flag
					end
					restore_prev_board_state
				end
			end
		end
		return flag
	end

	def select_pawn_promotion
		puts "Please select a piece to replace your pawn from:"
		puts "1 - Queen"
		puts "2 - Knight"
		puts "3 - Bishop"
		puts "4 - Rook"
		choice = gets.strip.to_i
		unless (1..4).include?(choice)
			puts "Please try again."
			return select_pawn_promotion
		end
		return choice
	end

	def get_entire_row(row_number)
		@game_board.get_entire_row(row_number)
	end

	def check_pawn_promotion
		row_8 = [:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8]
		row_1 = [:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1]
		row_8.each do |space|
			if space_occupied?(space) && get_piece_in_space(space).type == :pawn
				promote_pawn(space, :white)
			end
		end
		row_1.each do |space|
			if space_occupied?(space) && get_piece_in_space(space).type == :pawn
				promote_pawn(space, :black)
			end
		end
	end

	def promote_pawn(space, team)
		piece_type = select_pawn_promotion
		new_piece = nil
		case piece_type
		when 1
			new_piece = Queen.new(team)
		when 2
			new_piece = Knight.new(team)
		when 3
			new_piece = Bishop.new(team)
		when 4
			new_piece = Rook.new(team)
		end
		eliminate_piece_from_match(get_piece_in_space(space))
		populate_space(space, new_piece)
		add_piece_to_tracker(new_piece)
	end

end


g = Chess_Game.new
test_board = Board.new
test_board.populate_space(:a1, Rook.new('white'))
test_board.populate_space(:e1, King.new('white'))
test_board.populate_space(:e8, King.new('black'))
test_board.populate_space(:a8, Rook.new('black'))
g.game_board = test_board
g.game_loop













