require_relative 'Piece'

class Bishop < Piece

	def initialize(team)
		super
		@type = :bishop
		@symbol = assign_symbol(@team, @type)
	end

	def acceptable_move?(x_differential, y_differential) # would this be an acceptable move on a blank board?
		# case 1: x_diff = y_diff
		x_differential.abs == y_differential.abs
	end
	

	
end
