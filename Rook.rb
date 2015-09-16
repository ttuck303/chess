require_relative 'Piece'

class Rook < Piece

	def initialize(team)
		super
		@type = :rook
		@symbol = assign_symbol(@team, @type)
	end

	def acceptable_move?(x_differential, y_differential) 	# would this be an acceptable move on a blank board?
		#case 1: moving vertically
		#case 2: moving horizontally
		if y_differential.abs > 0 && x_differential.abs > 0
			return false
		else
			return true
		end
		#case 3: castling (going to come back to this one later)
	end


end
