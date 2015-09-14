require_relative 'Piece'

class Rook < Piece

	def initialize(team)
		super
		@type = :rook
		@symbol = assign_symbol(@team, @type)
	end

end
