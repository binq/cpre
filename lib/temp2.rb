require 'generator'

# # Generator from an Enumerable object
# g = Generator.new(['A', 'B', 'C', 'Z'])
# 
# while g.next?
#   puts g.next
# end
# 
# # Generator from a block
# g = Generator.new { |g|
#   for i in 'A'..'C'
#     g.yield i
#   end
# 
#   g.yield 'Z'
# }
# 
# # The same result as above
# while g.next?
#   puts g.next
# end

puts RUBY_VERSION 

s = SyncEnumerator.new([1,2,3], ['a', 'b', 'c'])

# Yields [1, 'a'], [2, 'b'], and [3,'c']
s.each { |row| puts row.join(', ') }
