$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Cpre
  VERSION = '0.0.1'
end

class Array
  def cpre(args)
    args.partition { |i| }
  end
end