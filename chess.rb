class Board
	attr_accessor :board

	def initialize
		@board = blank_board
		set_up_board
	end

	def blank_board
		board = []
		for i in 0..7
			row = []
			for j in 0..7
				row << Array.new()
			end
			board << row
		end
		board
	end


	def set_up_board
		for i in 0..7
			@board[1][i] << Piece.new('black', 'pawn')
			@board[6][i] << Piece.new('white', 'pawn')
		end
		@board[0][0] << Piece.new('black', 'rook')
		@board[0][7] << Piece.new('black', 'rook')
		@board[7][0] << Piece.new('white', 'rook')
		@board[7][7] << Piece.new('white', 'rook')

		@board[0][1] << Piece.new('black', 'knight')
		@board[0][6] << Piece.new('black', 'knight')
		@board[7][1] << Piece.new('white', 'knight')
		@board[7][6] << Piece.new('white', 'knight')

		@board[0][2] << Piece.new('black', 'bishop')
		@board[0][5] << Piece.new('black', 'bishop')
		@board[7][2] << Piece.new('white', 'bishop')
		@board[7][5] << Piece.new('white', 'bishop')

		@board[0][3] << Piece.new('black', 'queen')
		@board[0][4] << Piece.new('black', 'king')

		@board[7][3] << Piece.new('white', 'queen')
		@board[7][4] << Piece.new('white', 'king')

	end

	def display_board
		@board.each do |row|
			rowout = ''
			row.each do |space|
				space.empty? ? (rowout << " _ ") : (rowout << (" " + space[0].symbol+" "))
			end
			puts rowout
		end
		return nil
	end

	def occupied?(row, column)
		# tell us if the space is occupied
	end

	def occupant (row, column)
		# if occupied, returns the occupying piece
	end


end

class Piece
	attr_accessor :team, :type, :symbol

	def initialize(team, type)
		@type = type.to_sym
		@team = team.to_sym
		@symbol = assign_symbol(@team, @type)
	end

	def assign_symbol(team, type)
		if team == :white
			case type
			when :pawn
				return "\u2659"
			when :rook
				return "\u2656"
			when :knight
				return "\u2658"
			when :bishop
				return "\u2657"
			when :queen
				return "\u2655"
			when :king
				return "\u2654"
			end
		elsif team == :black
			case type
			when :pawn
				return "\u265f"
			when :rook
				return "\u265c"
			when :knight
				return "\u265e"
			when :bishop
				return "\u265c"
			when :queen
				return "\u265b"
			when :king
				return "\u265a"
			end
		else
			puts "Unknown symbol type error"
			return nil
		end
	end

	def move_pattern
	end

end

class Chess_Game
	def initialize
	end

	def get_player_move
	end

	def game_loop
	end

	def save_game
	end

	def load_game
	end

end


b = Board.new
puts b.display_board


