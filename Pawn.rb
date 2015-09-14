require_relative 'Piece'

class Pawn < Piece

	def initialize(team)
		super
		@type = :pawn 
		@symbol = assign_symbol(@team, @type)
		@moved = false
	end

	def acceptable_move?(x, y) #would this be an acceptable move on a blank board?
		if !correct_direction?(y)
			puts "Illegal Move: Wrong direction of travel."
			return false
		elsif y.abs > 2
			puts "Illegal Move: Too many spaces."
			return false
		elsif x.abs > 1
			puts "Illegal Move: Too much lateral movement."
			return false
		elsif (y.abs == 2) && @moved 	# if first move, allowed to go 2, otherwise just 1
			puts "Illegal Move: Can only move 2 spaces on piece's first move."
			return false
		end
	end

				
	

	def correct_direction?(y) # if white, move up; if black, move down
		if @team == :white
			return y <= 0
		elsif @team == :black
			return y >= 0
		else
			"Error."
			return nil
		end
	end
			




end