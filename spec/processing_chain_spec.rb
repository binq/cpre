require 'spec_helper'

describe "For ProcessingChain" do
  describe "the method" do
    subject do
      Object
    end

    it "should be loaded" do
      should.respond_to? :ProcessingChain
    end
  end

  describe "an empty call" do
    subject do 
      ProcessingChain()
    end

    it "should create a instance" do
      should be_an_instance_of(ProcessingChain)
    end
  end

  describe "a basic call" do
    subject do
      pc = ProcessingChain do
        add_step do |_, yielder|
          yielder.yield []
        end
        
        binary = lambda do |prev_step, yielder|
          (0..1).each do |i|
            prev_step.each do |r|
              yielder.yield r.unshift(i)
            end
          end
        end

        add_step(&binary)

        add_step(&binary)
      end

      pc.to_a
    end

    it "should create the specified array" do
      should == [[0, 0], [0, 1], [1, 0], [1, 1]]
    end
  end
end
