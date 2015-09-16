require_relative 'Piece'

class Queen < Piece

	def initialize(team)
		super
		@type = :queen
		@symbol = assign_symbol(@team, @type)
	end

	def acceptable_move?(x_differential, y_differential)
		if x_differential == 0
			return true
		elsif y_differential == 0
			return true
		elsif x_differential.abs == y_differential.abs
			return true
		else
			return false
		end
	end
	
	
end
