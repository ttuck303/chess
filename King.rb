require_relative 'Piece'

class King < Piece

	def initialize(team)
		super
		@type = :king
		@symbol = assign_symbol(@team, @type)
	end
	

	def acceptable_move?(x_differential, y_differential)
		if x_differential.abs > 1 || y_differential.abs > 1
			return false
		else
			return true
		end
	end
end
