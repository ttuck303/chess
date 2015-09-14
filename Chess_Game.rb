require_relative 'Board'
require_relative 'Piece'

class Chess_Game
	attr_accessor :active_player

	def initialize
		@active_player = :white
		@game_board = Board.new
	end

	def get_player_move

		

		# enter a move for that piece
		
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
		puts "Select a piece to move (e.g. 'a1' or 'c3')"
		choice = gets.strip.to_sym
		piece = nil
	
		if !selection_is_on_board?(choice) 					# check that the space entry is legit
			puts "Selection #{choice} is not on game board. Please try again."
			select_a_piece
		elsif !space_occupied?(choice) 						# check that the space is occupied
			puts "There is no piece in the space. Please try again."
			select_a_piece
		elsif !selection_is_on_active_team?(choice) 		# check that the piece belongs to the active player's team
			puts "That's not your team!"
			select_a_piece
		else
			piece = @game_board[choice]
			puts "You have selected #{piece.type} in space #{choice.to_s}."
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


	def selection_is_on_board?(selection)
		@game_board.has_key?(choice)
	end

	def space_occupied?(selection)
		!@game_board[selection].nil?
	end

	def selection_is_on_active_team(selection)
		@game_board[selection].team == @active_player
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


g = Chess_Game.new
g.game_loop
