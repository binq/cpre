require File.dirname(__FILE__) + '/spec_helper.rb'

describe Cpre do
  it "should be setup" do
    respond_to?(:cpre).should be_true
  end
  
  it "should work with two enumerables" do
    cpre(%w(a b), [1, 2]).to_a.should == [['a', 1], ['a', 2], ['b', 1], ['b', 2]]
  end
  
  # it "should work with two or more enumerables in a hash" do
  # end
end

# def test_base_case_should_work
#   assert_nothing_raised do
#     cpre
#   end
#   
#   assert_equal cpre.to_a, []
#   assert_equal cpre(1, 2, 3).to_a, [[1], [2], [3]]
#   assert_equal cpre([1, 2, 3]).to_a, [[1], [2], [3]]
#   assert_equal cpre(%w(a b), [1, 2]).to_a, [['a', 1], ['a', 2], 
#                                             ['b', 1], ['b', 2]]
#   assert_equal cpre(%w(a b), %w(y z)).collect { i.join }, %w(ay az by bz)
# end

# describe "a basic cpre call should return a arrya" do
#   vowel_check = lambda do
#     vowels = %w(a e i o u)
#     lambda do |l| 
#       letters, tld = [l[0..-2], l[-1]]
#       min_length, max_length = lambda{
#         lengths = [letters.length / 3, letters.length / 4]
#         [lengths.min, lengths.max]
#       }
#       (min_length..max_length).include?((letters - vowels).length)
#     end
#   end.call
# 
#   [lambda { |l| l.join }, [%w(com net org us), *Array.new(3) { 'a'..'z' }], {lambda {}}].cpre
# end
