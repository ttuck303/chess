require_relative 'Pawn'

class Board
	attr_accessor :board

	def initialize
		@board = blank_board
		populate_board
	end

	def blank_board
		board = {}
		for i in Range.new('a', 'h')
			for j in Range.new(1, 8)
				board[(i+j.to_s).to_sym] = nil
			end
		end
		board
	end

	def populate_space(space, obj)
		@board[space] = obj
	end

	def idx_conversion #convert a hash key from format of @# to 
	end



	def populate_board #TO DO: refactor to be more concise
		for i in 'a'..'h'
			populate_space((i+'2').to_sym, Pawn.new('white'))
			populate_space((i+'7').to_sym, Pawn.new('black'))
		end

=begin 
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
=end

	end

	def display_board
		@board.each_with_index do |row, idx|
			rowout = idx.to_s
			row.each do |space|
				space.empty? ? (rowout << " _ ") : (rowout << (" " + space[0].symbol+" "))
			end
			puts rowout
		end
		puts "  0  1  2  3  4  5  6  7  "
		puts "        (Columns)         "
		return nil
	end

	def occupied?(row, column) # TO DO test this function
		!@board[row][column].empty?
	end

	def occupant (row, column) # TO DO test this function
		@board[row][column][0]
	end


end