require 'active_support'

class X1
  def initialize
    @top = nil
    @d = [[1,3,5,7,9], [2,4,6,8,10]].collect do |a| 
      callcc { |top| @top = top; rewind(a); }#.tap { |r| puts "pick init: %p"% [r] }
    end
    
    #p @d
  end

  def rewind(a)
    a.each do |i|
      callcc do |pick|
        #puts "top"
        @top.call(:array => a, :pick => pick, :value => i)
      end
    end

    @top.call(nil)
  end

  def each
    loop do
      yield @d.collect { |i| i[:value] }

      @d = @d.inject(:working => true, :result => []) do |r, i|
        r.tap do
          #p i
          new_i = r[:working] ? callcc { |top| @top = top; i[:pick].call }.tap { 
            #puts "pick next" 
          } : i

          if new_i.nil? 
            return if @d[-1] == i
            #puts "prepare for badness"
            r[:result] << callcc { |top| @top = top; rewind(i[:array]) }#.tap { puts "pick reinit" }
          else
            r[:result] << new_i
            r[:working] = false
          end
        end
      end[:result]
    end
  end
  
  def self.t
    X1.new.each { |i| p i }
  end
end
