=begin 	
#Hopping Method Tests 

#p = Pawn.new(:white)

puts "Vertical Test:"
spaces = g.spaces_between(:a7, :a5)
puts spaces
puts
puts g.hopping_violation?(spaces, p)
puts

puts "Horizontal Test:"
spaces2 = g.spaces_between(:a2, :h2)
puts spaces2
puts
puts g.hopping_violation?(spaces2, p)
puts 

puts "Diagonal Test:"
spaces3 = g.spaces_between(:a2, :g8)
puts spaces3
puts g.hopping_violation?(spaces3, p)

puts "Diagonal Test2:"
spaces4 = g.spaces_between(:h2, :b8)
puts spaces4
puts g.hopping_violation?(spaces4, p)

puts "Diagontal Test 3"
spaces5 = g.spaces_between(:a2, :d5)
puts spaces5
puts g.hopping_violation?(spaces5, p)

puts "Vertical Test 2"
spaces6 = g.spaces_between(:a2, :a5)
puts spaces6
puts g.hopping_violation?(spaces6, p)

puts "Horizontal Test 2"
spaces7 = g.spaces_between(:h2, :a2)
puts g.hopping_violation?(spaces7, p)

=end

=begin
#testing get spaces method

test1 = g.create_spaces_list('a', 'a', 3, 5)
test2 = g.create_spaces_list('a', 'a', 5, 3)
test3 = g.create_spaces_list('a', 'h', 2, 2)
test4 = g.create_spaces_list('a', 'd', 2, 5)
test5 = g.create_spaces_list('a', 'e', 5, 1)


puts "Test 1:"
puts test1
puts
puts "Test 2:"
puts test2
puts
puts "Test 3:"
puts test3
puts
puts "Test 4:"
puts test4
puts
puts "Test 5:"
puts test5
puts


=end




=begin

Testing left column method

test_board = Board.new

puts test_board.left_column('a')
puts test_board.left_column('h')
puts test_board.left_column(:a5)
puts test_board.left_column(:h8)
puts test_board.left_column(:c5)
puts test_board.left_column(:d8)


=end


	
=begin
	
Testing relative spaces method

test_board = Board.new

puts test_board.relative_space(:a1, 'n')
puts test_board.relative_space(:c5, 'n')
puts test_board.relative_space(:a6, 's')
puts test_board.relative_space(:h8, 'ne')
puts test_board.relative_space(:h8, 'sw')
puts test_board.relative_space(:b8, 'w')

=end


=begin 

Testing get surrounding spaces 


b = Board.new

test1 = b.get_surrounding_spaces(:a1)
test2 = b.get_surrounding_spaces(:f5)
test3 = b.get_surrounding_spaces(:h1)
test4 = b.get_surrounding_spaces(:g8)

puts test1
puts
puts test2
puts
puts test3
puts
puts test4

=end


=begin
	
rescue 
#Testing get surrounding spaces 


b = Board.new

test1 = b.get_surrounding_spaces(:a1)
test2 = b.get_surrounding_spaces(:f5)
test3 = b.get_surrounding_spaces(:h1)
test4 = b.get_surrounding_spaces(:g8)

puts test1
puts
puts test2
puts
puts test3
puts
puts test4


=end



=begin
	
testing in-check method

#checks for each type of check
# adjacent threat
	# pawn
	# rook
	# bishop
	# king
	# queen
	# not knight
# ranged threat
	# pawn
	# rook
	# bishop
	# king
	# queen
	# not knight
# knights
	# each spot



# conditions for test
	# in Chess_Game, allow accessor to board
	# in Board, block populate new board

test_board_1 = Board.new
test_board_1.populate_space(:e8, King.new('black'))
test_board_1.populate_space(:d7, Pawn.new('white'))
g.game_board = test_board_1
g.game_board.display_board
puts g.in_check?(:black)

# test 1 pawn confirmed

test_board_2 = Board.new
test_board_2.populate_space(:e8, King.new('black'))
test_board_2.populate_space(:f7, Pawn.new('white'))
g.game_board = test_board_2
g.game_board.display_board
puts g.in_check?(:black)

# test 2 pawn confirmed

puts "TEST 3"
test_board_3 = Board.new
test_board_3.populate_space(:e8, King.new('black'))
test_board_3.populate_space(:e7, Pawn.new('white'))
g.game_board = test_board_3
g.game_board.display_board
puts g.in_check?(:black)
#test 3 confirmed

puts "test 4"
test_board_4 = Board.new
test_board_4.populate_space(:e8, King.new('black'))
test_board_4.populate_space(:e7, Bishop.new('white'))
g.game_board = test_board_4
g.game_board.display_board
puts g.in_check?(:black)


puts "test 5"

test_board_5 = Board.new
test_board_5.populate_space(:e8, King.new('black'))
test_board_5.populate_space(:e7, Queen.new('white'))
g.game_board = test_board_5
g.game_board.display_board
puts g.in_check?(:black)

puts "test 6"

test_board_6 = Board.new
test_board_6.populate_space(:e8, King.new('black'))
test_board_6.populate_space(:e7, Rook.new('white'))
g.game_board = test_board_6
g.game_board.display_board
puts g.in_check?(:black)

puts "test 7"

test_board_7 = Board.new
test_board_7.populate_space(:e8, King.new('black'))
test_board_7.populate_space(:d7, Rook.new('white'))
g.game_board = test_board_7
g.game_board.display_board
puts g.in_check?(:black)

=end



