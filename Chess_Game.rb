class Chess_Game
	attr_accessor :active_player

	def initialize
		@active_player = :white
		@game_board = Board.new
	end

	def get_player_move #TO DO huge ugly method. break it into more pieces
		
		# check that the piece selection is valid (on the board, piece in the spot, piece on the correct team)
		selected_piece = select_a_piece
		confirm_piece_selection
		desired_move = enter_desired_move
		confirm_legal_move(desired_move)

		if acceptable_end_location?(move_row, move_column)
			# do stuff
			puts "Move #{piece.type} to #{move_row},#{move_column}"
		else
			puts "Illegal move. Please try again."
		end

		# confirm with the player that this is the piece they want, or offer for them to select another piece
		# request the move that the player wants to make
		# check that this move is acceptable
		# update board with player move
	end

	def select_a_piece
		puts "Select one of your pieces by entering the row and the column, seperated by a space."
		choice = gets.strip
		row = choice[0].to_i
		column = choice[-1].to_i
		piece = nil
		if valid_piece_selection?(row, column)
			piece = @game_board.occupant(row, column) 
			puts "You have selected to move #{piece.type} in row#{row}, column #{column}."
		else
			puts "Invalid selection, please select again."
			select_a_piece
		end
		piece
	end

	def confirm_piece_selection
		puts "If this is correct? [y/n]"
		confirmation = gets.strip.downcase
		get_player_move unless confirmation == 'y'
	end

	def enter_desired_move
		puts "Select where to move by entering the row and column seperated by a space."
		move = gets.strip
		return [move[0], move[-1]]
	end

	def confirm_legal_move(move_arr)
		#checks if move is legal
		#if so, continue
		# if not, explain why and force another selection
	end


	def valid_piece_selection?(row, column)
		return true
	end

	def selection_is_on_board?(row, column)
		(0..7).include?(row) && (0..7).include?(column)
	end

	def selection_is_on_active_team(row, column)
		space_occupant = @game_board.occupant(row, column)
		space_occupant.team == @active_player
	end


	def acceptable_end_location?
		if move_out_of_bounds?
			puts "Illegal move: cannot move is off the board."
			return false
		elsif move_into_check?
			puts "Illegal move: you are moving into check."
			return false
		elsif own_piece_in_the_way?
			puts "Illegal move: your own piece is in the way."
			return false
		else
			return true
		end
	end

	def move_out_of_bounds?
		return false
	end

	def move_into_check?
		return false
	end

	def own_piece_in_the_way?
		return false
	end


	def game_loop
		@game_board.display_board
		get_player_move
	end

	def save_game
	end

	def load_game
	end

end
