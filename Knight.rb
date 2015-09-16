require_relative 'Piece'

class Knight < Piece

	def initialize(team)
		super
		@type = :knight 
		@symbol = assign_symbol(@team, @type)
	end

	def acceptable_move?(x_differential, y_differential) 
		if x_differential.abs == 2 && y_differential.abs == 1
			return true
		elsif x_differential.abs == 1 && y_differential.abs == 2
			return true
		else
			return false
		end
	end

	
	
end
