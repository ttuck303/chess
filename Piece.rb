class Piece
	attr_accessor :team, :type, :symbol

	def initialize(team)
		@team = team.to_sym
		@moved = false
		@alive = true
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
				return "\u265d"
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

	def acceptable_move?(origin, move)
		true
	end

	def moved!
		@moved = true
	end

	def taken
		@alive = false
	end

end