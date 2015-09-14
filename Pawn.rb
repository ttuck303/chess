require_relative 'Piece'

class Pawn < Piece

	def initialize(team)
		super
		@type = :pawn 
		@symbol = assign_symnol
	end

	def assign_symnol
		if @team == :white
			return "\u2659"
		elsif @team == :black
			return "\u265f"
		else
			puts "Symbol error, please clarify team?"
			return nil
		end
	end

end