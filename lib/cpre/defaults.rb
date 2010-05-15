module Cpre::Defaults
  def default_args
    Cpre::MAIN_ARGS.collect { |i| send("default_%s" % [i]) }
  end

  def default_collect
    lambda { items.length == 1 ? items.first : items }
  end

  def default_sources
    []
  end

  def default_filters
    []
  end

  def default_options
    {}
  end
end  

Cpre.class_eval do
  private
  
  extend Cpre::Defaults
end
