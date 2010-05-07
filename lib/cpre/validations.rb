class Cpre
  private

  #Checks to see if the values returned from the block are valid 
  #Otherwise picks the default values.  
  #It returns the three scrubbed values
  def scrub_arguments
    default = [lambda {}, [], []]
    method_names = %w(collect sources filters).collect { |i| "valid_%s?" % [i] }

    #Take the values from the block zip with the default values the zip the with the validation methods.
    #The result with be an array with elements that look like this: [[from_block, default_value], method_name]
    yield.zip(default).zip(method_names).collect { |pick, meth| send(meth, pick[0]) ? pick[0] : pick[1] }
  end
  
  def valid?
    [valid_collect?(collect), valid_sources?(sources), valid_filters?(filters)]
  end
  
  def valid_collect?(collect)
    collect.is_a?(Proc)
  end

  alias_method :valid_sources?, :is_all_enums?
  alias_method :valid_source?, :is_enum?

  def valid_filters?(filters)
    filters.is_a?(Array) && filters.length > 0 && filters.all? { |i| i.is_a?(Proc) }
  end
end
