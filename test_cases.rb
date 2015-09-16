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