class History
	attr_accessor :game_log

	def initialize
		@game_log = []
	end

	def log_move(team, origin, move, piece_type, game_state)
		@game_log << [team, origin, move, piece_type, game_state]
	end

	def print_log
		puts '[team, origin, move, piece, game status]'
		@game_log.each do |turn|
			puts turn.inspect
		end
	end



end
