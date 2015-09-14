require_relative 'Piece'

class King < Piece

	def initialize(team)
		super
		@type = :king
		@symbol = assign_symbol(@team, @type)
	end
	
end
