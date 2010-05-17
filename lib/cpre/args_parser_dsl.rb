class Cpre::ArgsParserDsl
  Cpre::MAIN_ARGS.each { |i| attr_accessor i }

  def initialize(options)
    @collect, @sources, @filters = Cpre::MAIN_ARGS.collect { |i| options[i.to_sym] }
  end
  
  def dsl_eval(&block)
    raise ArgumentError unless block_given?
    self.tap { self.instance_eval(&block) }
  end
  
  def set_collect(new_value)
    self.collect = new_value
  end

  def add_source(value)
    self.sources << value
  end
  
  def remove_source(value)
    self.sources.delete(value)
  end

  def add_filter(value)
    self.filters << value
  end

  def remove_filter(value)
    self.filters.delete(value)
  end
end
