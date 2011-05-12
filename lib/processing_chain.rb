class ProcessingChain
  DESCRIPTION_TEMPLATE = "No Description"

  attr_reader :steps

  def initialize(options={}, &block)
    options.each_pair do |key, value|
      raise(ArgumentError, "Don't know what to do with: %s" % [key]) unless respond_to?(key)
      send(key, value)
    end
    self.instance_eval(&block) if block_given?
    @initialized = true
    self.instance_variables.each { |v| instance_variable_get(v).freeze }
  end

  def setup_from_options(options)
    @initialized ? self.class.new(options) : self.tap { @steps, = options.values_at(:steps) }
  end
  
  def steps
    @steps || []
  end

  def add_steps(unscrubbed_new_steps)
    raise(ArgumentError, "Steps must be a hash or array.") unless [Hash, Array].any? { |c| unscrubbed_new_steps.kind_of?(c) }
    new_steps = case(true)
                when ->(_) { unscrubbed_new_steps.kind_of?(Hash) }
                  unscrubbed_new_steps.collect { |description, step| [description, step] }
                when ->(_) { unscrubbed_new_steps.kind_of?(Array) }
                  unscrubbed_new_steps.collect { |step| [nil, step] }
                else
                  #this should not happen
                  raise TypeError
                end

    setup_from_options(:steps => scrub_descriptions(steps.to_a + new_steps))
  end

  def add_step(description=nil, &block)
    new_step = [[description, block]]

    setup_from_options(:steps => scrub_descriptions(steps.to_a + new_step))
  end

  def enumerator(_length=nil)
    length = _length ? _length : steps.length

    index = 0

    steps.values[0, length].inject(nil) do |prev_step, step|
      index += 1
      Enumerator.new(&step.curry.call(prev_step))
    end
  end

  def method_missing(m, *args, &block)
    raise(NoMethodError, "undefined method `%s' for %s:Class" % [m, self.class]) unless (Enumerator.instance_methods(false) + Enumerable.instance_methods).include?(m)
    enumerator.send(m, *args, &block)
  end

  private

  def scrub_descriptions(new_steps)
    scrubber = lambda do |(description, step), index|
      raise(ArgumentError, "for index: %u, description does not have to_s: %p" % [index, description]) if description && !description.respond_to?(:to_s)

      new_description = "%s: %s" % [index + 1, description.nil? || description.to_s == "" || description.end_with?(DESCRIPTION_TEMPLATE) ? DESCRIPTION_TEMPLATE : description]

      [new_description, step]
    end

    Hash[new_steps.enum_for(:each_with_index).collect(&scrubber)]
  end
end
