require_relative 'Piece'

class Bishop < Piece

	def initialize(team)
		super
		@type = :bishop
		@symbol = assign_symbol(@team, @type)
	end
	
end
