require File.dirname(__FILE__) + '/test_helper.rb'

class TestCpre < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    assert true
  end
end

describe "a basic cpre call should return a arrya" do
  vowel_check = lambda do
    vowels = %w(a e i o u)
    lambda do |l| 
      letters, tld = [l[0..-2], l[-1]]
      min_length, max_length = lambda{
        lengths = [letters.length / 3, letters.length / 4]
        [lengths.min, lengths.max]
      }
      (min_length..max_length).include?((letters - vowels).length)
    end
  end.call

  [lambda { |l| l.join }, [%w(com net org us), *Array.new(3) { 'a'..'z' }], {lambda {}}].cpre
end