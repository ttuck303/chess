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
		#confirm_piece_selection
		move = enter_desired_move
		until legal_move?(piece, origin, move)
			move = enter_desired_move
		end
		puts "Moving #{piece} from #{origin} to #{move}."
		[piece, move] # return a piece and the legal move
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
		puts "Where do you want to move?"
		choice = gets.strip.to_sym
	end

	def legal_move?(piece, origin, move)
		puts "Debug: "
		puts "Piece = #{piece}"
		puts "Origin = #{origin}"
		puts "Move = #{move}"


		if !on_board?(move)				# check that the move is on the board
			puts "The space you have selected is not on the board. Please try again."
			return false
		elsif space_occupied?(move) && selection_is_on_active_team?(move)   	# check that the desired space is not occupied by a teammate
			puts "That space is occupied by your team. Please try again."
			return false
		elsif !allowed_piece_movement?(piece, origin, move)  # check that the move abides by the piece's move rules (on an open board)
			return false
		elsif hopping_violation?(spaces_between(origin, move), piece) #hopping violation doesn't apply to knights.
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

	def allowed_piece_movement?(piece, origin, move)
		x_diff = calculate_x_difference(origin, move)
		y_diff = calculate_y_difference(origin, move)
		piece.acceptable_move?(x_diff, y_diff)
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

	def destination_same_as_origin?(origin, destination)
		origin == destination
	end

	def game_loop
		@game_board.display_board
		get_player_move
	end

	def special_case_check(piece, start, move)
		case piece
		when :pawn
			# if move differential is 1,1, check that there is an enemy in that spot
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
		puts "Letter = #{letter}"
		puts "Number = #{LET_2_NUM[letter]}"
		LET_2_NUM[letter]
	end

	def number_to_letter(number)
		puts "Number: #{number}"
		puts "Letter: #{NUM_2_LET[number]}"
		NUM_2_LET[number]
	end

	def spaces_between(origin, move) 
		o_column = origin.to_s[0] 
		o_row = origin.to_s[1]
		m_column = move.to_s[0]
		m_row = move.to_s[1]
		x_diff = calculate_x_difference(origin, move)
		y_diff = calculate_y_difference(origin, move)
		output = []
		if o_column == m_column
			puts "Case 1"
			range = Range.new(o_row.to_i, m_row.to_i)
			range.each {|num| output << (o_column+num.to_s).to_sym}
		elsif o_row == m_row
			puts "Case 2"
			o_row_conversion = letter_to_number(o_column)
			m_row_conversion = letter_to_number(m_column)
			range = Range.new(o_row_conversion, m_row_conversion)
			range.each do |num|
				let = number_to_letter(num)
				output << (let+o_row).to_sym
			end
		elsif x_diff.abs == y_diff.abs
			puts "Case 3a"
			if y_diff >0
				range = Range.new(o_row.to_i, m_row.to_i)
				puts "Range = #{range}"
				range.each_with_index do |num, idx|
					letter = number_to_letter(letter_to_number(o_column)+idx)
					puts "Letter translation is #{letter}"
					puts "Number is #{num}"
					output << (letter+num.to_s).to_sym
				end
			elsif y_diff < 0
				#mirror image
				puts "Case 3b"
				range = Range.new(m_row.to_i, o_row.to_i)
				puts "Range #{range}"
				range.each_with_index do |num, idx|
					letter = number_to_letter(letter_to_number(o_column)+idx)
					puts "Letter translation is #{letter}"
					puts "Number is #{num}"
					output << (letter+num.to_s).to_sym
				end

			end
					
		end
		puts "Output = #{output}"
		return output[1..-2] 
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

	def end_game_condition
	end


end


g = Chess_Game.new
p = Pawn.new(:white)
#g.game_loop

puts "Vertical Test:"
spaces = g.spaces_between(:a2, :a8)
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




