require 'spec_helper'

describe "For comprehend" do
  describe "the method" do
    subject do
      Object
    end

    it "should be loaded" do
      should.respond_to? :Comprehend
    end
  end

  describe "an empty API call" do
    subject do
      Comprehend()
    end

    it "should create a instance" do
      should be_an_instance_of(Comprehend)
    end
  end

  describe "a call with given" do
    subject do
      pc = Comprehend do
        given :x => [0,1], :y => [0,1]
      end

      pc.to_a
    end

    it "should create the specified array" do
      should == [[0, 0], [0, 1], [1, 0], [1, 1]]
    end
  end

  describe "a call with make" do
    subject do
      pc = Comprehend do
        make { [x, y] }
      end

      pc.to_a
    end

    it "should create the specified array" do
      should == []
    end
  end

  describe "a call with select" do
    subject do
      pc = Comprehend do
        select { ![x, y].include?(2) }
      end

      pc.to_a
    end

    it "should create the specified array" do
      should == []
    end
  end

  describe "a call with given, make, and select" do
    subject do
      pc = Comprehend do
        given :x => [0,1,2], :y => [0,1,2]
        select { ![x, y].include?(2) }
        make { "{x: %u, y: %u}" % [x, y] }
      end

      pc.to_a
    end

    it "should create the specified array" do
      should == ["{x: 0, y: 0}", "{x: 0, y: 1}", "{x: 1, y: 0}", "{x: 1, y: 1}"]
    end
  end

  describe "a call with multiple givens" do
    subject do
      Cpre { given :x, 1..3; given :y, 1..3; }.to_a
    end

    it "should create the specified array" do
      should == [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]]
    end
  end
end
