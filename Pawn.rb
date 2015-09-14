require_relative 'Piece'

class Pawn < Piece

	def initialize(team)
		super
		@type = :pawn 
		@symbol = assign_symbol(@team, @type)
	end

end