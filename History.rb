class History
	attr_accessor :game_log

	def initialize
		@game_log = []
	end

	def log_move(team, origin, move, piece_type, game_state)
		@game_log << [team, origin, move, piece_type, game_state]
	end

	def print_log
		@game_log.each do |turn|
			puts turn
		end
	end



end
