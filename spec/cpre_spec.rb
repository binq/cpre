require File.dirname(__FILE__) + '/spec_helper.rb'

describe Cpre do
  it "should be setup in Kernel" do
    respond_to?(:cpre).should be_true
  end

  it "should work for an empty call" do
    cpre.to_a.should == []
  end
  
  it "should work with two enumerables" do
    cpre(%w(a b), [1, 2]).to_a.should ==  [["a", 1], ["b", 1], ["a", 2], ["b", 2]]
  end

  it "should work with two enumerables, and a collect" do
    cpre(lambda { items[0].upcase!; "%s-%u" % items }, %w(a b), [1, 2]).to_a.sort.should ==  ["A-1", "A-2", "B-1", "B-2"]
  end

  it "should work with two enumerables, a collect and a filter" do
    filter = lambda do
      items.inject(0) { |memo, item| memo += item } == 20 && 
      items.all? { |i| i % 2 == 0 } &&
      items.inject(:prev => nil, :result => true) do |memo, i|
        memo[:prev].nil? ? {:prev => i, :result => true} :
        memo[:result] ? {:prev => i, :result => memo[:prev]+1 < i} : 
        memo 
      end[:result]
    end
    
    collect = lambda do
      items.collect { |item| item.to_s }.join('-')
    end

    cpre(collect, (0..50), (0..50), (0..50), filter).to_a.should ==  [[2, 3, 5], [3, 5, 7], [5, 7, 11], [7, 11, 13]]
    # (r = _).enum_for(:each_slice, 10).first.to_a
  end

  # it "should work with two or more enumerables in a hash"
  # it "should not be setup in Kernel if flagged"
end

# def test_base_case_should_work
#   cpre(1, 2, 3).to_a, [[1], [2], [3]]
#   assert_equal cpre([1, 2, 3]).to_a, [[1], [2], [3]]
#   assert_equal cpre(%w(a b), [1, 2]).to_a, [['a', 1], ['a', 2], 
#                                             ['b', 1], ['b', 2]]
#   assert_equal cpre(%w(a b), %w(y z)).collect { i.join }, %w(ay az by bz)
# end
# 
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
