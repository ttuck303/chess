require_relative 'Pawn'
require_relative 'Rook'
require_relative 'knight'
require_relative 'Bishop'
require_relative 'Queen'
require_relative 'King'


class Board
	attr_accessor :board
	LET_2_NUM = {'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8}
	NUM_2_LET = LET_2_NUM.invert
	CORNERS = [:a1, :a8, :h1, :h8]
	EDGES = [:a7, :a6, :a5, :a4, :a3, :a2, :b8, :c8, :d8, :e8, :f8, :g8, :h2, :h3, :h4, :h5, :h6, :h7, :b1, :c1, :d1, :e1, :f1, :g1]
	BORDERS = CORNERS + EDGES
	DIRECTIONS = ['n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw']

	def initialize
		@board = blank_board
	end

	def on_board?(space)
		@board.has_key?(space)
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

	def space_occupied?(space)
		!@board[space].nil?
	end

	def empty_space(space)
		@board[space] = nil
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

	def get_piece_in_space(space)
		return @board[space]
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

	def surrounding_spaces(space)
		output = []
		if CORNERS.include?(space)
			#case 1: corner
		elsif EDGES.include?(space)
			#case 2: edges
		else
			#case 3: in land
		end
	end

	def left_column(column)
		column = column.to_s[0]
		return "Out of bounds" if column == 'a'
		return NUM_2_LET[(LET_2_NUM[column]-1)]
	end

	def locate_piece(piece, board = @board)
		identifier = piece.object_id
		@board.each_pair do |space, piece|
			if !piece.nil?
				if piece.object_id == identifier
					return space
				end
			end
		end
		puts "Error, cannot find piece #{piece}"
		return nil
	end

	def locate_king(team)
		@board.each_pair do |space, piece|
			if !piece.nil?
				if (piece.type == :king) && (piece.team == team)
					return space
				end
			end
		end
		return "Error: cannot find king"
	end

	def relative_space(origin, direction)
		# directions include n, ne, e, se, s, sw, w, nw

		return "Out of bounds" if origin == "Out of bounds"
		origin = origin.to_s
		column = origin[0]
		row = origin[1].to_i

		case direction
		when 'n'
			row == 8 ? (return "Out of bounds") : (return (column+(row+1).to_s).to_sym)
		when 'nw'
			if row == 8 || column == 'a'
				return "Out of bounds"
			else
				return (left_column(column) + (row+1).to_s).to_sym
			end
		when 'ne'
			if row == 8 || column == 'h'
				return "Out of bounds"
			else
				return (column.succ + (row+1).to_s).to_sym
			end
		when 'e'
			return "Out of bounds" if column == 'h'
			return (column.succ+row.to_s).to_sym
		when 'w'
			return "Out of bounds" if column == 'a'
			return (left_column(column)+row.to_s).to_sym
		when 'se'
			return "Out of bounds" if column == 'h' || row == 1
			return (column.succ + (row-1).to_s).to_sym
		when 'sw'
			return "Out of bounds" if column == 'a' || row == 1
			return (left_column(column)+(row-1).to_s).to_sym
		when 's'
			return "Out of bounds" if row == 1
			return (column + (row-1).to_s).to_sym
		else
			puts "Error: Unknown direction #{direction}."
		end
	end


	def get_surrounding_spaces(space)
		output = []
		DIRECTIONS.each do |dir|
			resulting_space = relative_space(space, dir)
			output << [resulting_space, dir.to_sym] if resulting_space != "Out of bounds"
		end
		output.sort!
	end

	def is_border?(space)
		BORDERS.include?(space)
	end


end












