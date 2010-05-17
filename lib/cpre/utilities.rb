module Cpre::Utilities
  def flatten_pair
    lambda { |memo, pair| memo << pair[0] << pair[1] }
  end
end

Cpre.class_eval do
  extend self::Utilities
  include self::Utilities
end
