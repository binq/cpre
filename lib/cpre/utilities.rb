module Cpre::Utilities
  def is_all_enums?(sources)
    sources.is_a?(Array) && sources.all? { |source| is_enum?(source) }
  end

  def is_enum?(source)
    source.respond_to?(:each)
  end
end

Cpre.class_eval do
  extend self::Utilities
  include self::Utilities
end
