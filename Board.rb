require_relative 'Pawn'
require_relative 'Rook'
require_relative 'knight'
require_relative 'Bishop'
require_relative 'Queen'
require_relative 'King'


class Board
	attr_accessor :board

	def initialize
		@board = blank_board
		populate_new_board
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

	def get_column(space)
		space.to_s[0]
	end

	def get_row(space)
		space.to_s[1]
	end

	def what_to_display(input)
		input.nil? ? (return " _ ") : (return (" "+input.symbol+" "))
	end


	def display_board
		row1, row2, row3, row4, row5, row6, row7, row8 = '1 ', '2 ', '3 ', '4 ', '5 ', '6 ', '7 ' ,'8 '
		@board.each do |key, value|
			row = get_row(key).to_i
			case row
			when 1
				row1 << what_to_display(value)
			when 2
				row2 << what_to_display(value)
			when 3
				row3 << what_to_display(value)
			when 4
				row4 << what_to_display(value)
			when 5
				row5 << what_to_display(value)
			when 6
				row6 << what_to_display(value)
			when 7
				row7 << what_to_display(value)
			when 8
				row8 << what_to_display(value)
			end
		end

		puts row8, row7, row6, row5, row4, row3, row2, row1
		puts
		puts "   A  B  C  D  E  F  G  H  "
		puts "          (Columns)         "
		return nil
	end

	def occupied?(row, column) # TO DO test this function
		!@board[row][column].empty?
	end

	def occupant (row, column) # TO DO test this function
		@board[row][column][0]
	end


end