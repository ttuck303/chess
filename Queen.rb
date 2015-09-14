require_relative 'Piece'

class Queen < Piece

	def initialize(team)
		super
		@type = :queen
		@symbol = assign_symbol(@team, @type)
	end
	
end
