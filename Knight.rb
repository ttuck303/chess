require_relative 'Piece'

class Knight < Piece

	def initialize(team)
		super
		@type = :knight 
		@symbol = assign_symbol(@team, @type)
	end
	
end
