class Comprehend
  attr_reader :show, :lists, :filters

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
    @initialized ? self.class.new(options) : self.tap { @show, @lists, @filters, = options.values_at(:make, :given, :select) }
  end

  def show
    @show
  end

  def lists
    @lists || {}
  end

  def filters
    @filters || []
  end

  def make(*arguments, &block)
    new_show =
      case true
      when ->(_) { block_given? && block.arity.zero? }
        #use block if one is given
        block

      when ->(_) { arguments.length == 1 && arguments.first.kind_of?(Comprehend) }
        #take from comprehension if it is given
        arguments.first.show

      when ->(_) { arguments.length == 1 && arguments.first.kind_of?(Proc) && arguments.first.arity.zero? }
        #use argument if it is a proc
        arguments.first

      else
        raise ArgumentError
      end

    setup_from_options(:make => new_show, :given => lists, :select => filters)
  end
  alias_method :%, :make

  def given(*arguments, &predicate)
    new_lists = 
      case true
      when ->(_) { arguments.length == 1 && block_given? && arguments.first.respond_to?(:to_s) }
        #Merge in a new pair to the hash when a block is given
        {arguments.first.to_s => predicate}

      when ->(_) { arguments.length == 1 && arguments.first.kind_of?(Comprehend) }
        #Take lists from the parameter if it is a comprehension
        arguments.first.lists

      when ->(_) { arguments.length == 1 && arguments.first.kind_of?(Hash) && arguments.first.values.all? { |v| v.respond_to?(:each) } }
        #take the the argument if it is a Hash
        arguments.first

      when ->(_) { arguments.length == 2 && arguments.first.respond_to?(:to_s) && arguments.last.respond_to?(:each) }
        #create a pair from the parameters 
        {arguments.first.to_s => arguments.last}

      else
        raise ArgumentError, "arguments were: %p" % [arguments]
      end

    setup_from_options(:make => show, :given => lists.merge(new_lists), :select => filters)
  end
  alias_method :*, :given

  def select(*arguments, &block)
    new_filters = 
      case true
      when ->(_) { block_given? && block.arity.zero? }
        #use the block if one is given
        [block]

      when ->(_) { arguments.length == 1 && arguments.first.kind_of?(Comprehend) }
        #take filters from first para
        arguments.first.filters

      when ->(_) { arguments.all? { |x| x.kind_of?(Proc) } }
        #take all the arguments if they are Procs
        arguments

      when ->(_) { arguments.length == 1 && arguments.first.kind_of?(Array) && arguments.first.all? { |x| x.kind_of?(Proc) } }
        #take the first argument if it is a proc
        arguments.first
        
      else
        raise ArgumentError

      end

    setup_from_options(:make => show, :given => lists, :select => filters + new_filters)
  end
  alias_method :/, :select

  def processing_chain
    return [] if lists.empty?
    return @processing_chain if @processing_chain

    debug = lambda do |line, message, inspect|
      #puts "[%s] %s: %p" % [line, message, inspect]
    end.curry

    head_list_stepper = lambda do |list, _, yielder|
      debug.call(__LINE__, "top head_list_stepper", nil)
      list.each do |item|
        yielder.yield([item].tap(&debug.call(__LINE__, "yielding")))
      end
    end.curry

    rest_list_stepper = lambda do |list, previous_step, yielder|
      debug.call(__LINE__, "top rest_list_stepper", nil)
      list.each do |item|
        previous_step.each do |given|
          yielder.yield(given.unshift(item).tap(&debug.call(__LINE__, "yielding")))
        end
      end
    end.curry

    list_steppers = lambda do |steppers, list|
      steppers.push(steppers.empty? ? head_list_stepper.call(list) : rest_list_stepper.call(list))
    end

    filter_stepper = lambda do |filter, previous_step, yielder|
      debug.call(__LINE__, "top filter_stepper", nil)
      previous_step.each do |given|
        yielder.yield(given.tap(&debug.call(__LINE__, "yielding"))) if OpenStruct.new(Hash[lists.keys.zip(given)]).instance_eval(&filter)
      end
    end.curry

    simple_show_step = lambda do |previous_step, yielder|
      debug.call(__LINE__, "top show_step", nil)
      previous_step.each do |given|
        yielder.yield given.tap(&debug.call(__LINE__, "yielding"))
      end
    end

    regular_show_step = lambda do |previous_step, yielder|
      debug.call(__LINE__, "top show_step", nil)
      previous_step.each do |given|
        yielder.yield OpenStruct.new(Hash[lists.keys.zip(given)]).instance_eval(&show).tap(&debug.call(__LINE__, "yielding"))
      end
    end

    show_step = show.nil? ? simple_show_step : regular_show_step

    steps = lists.values.reverse.inject([], &list_steppers) + filters.collect(&filter_stepper) + [show_step]

    debug.call(__LINE__, "result", steps)

    @processing_chain = ProcessingChain.new(:add_steps => steps)
  end

  def method_missing(m, *args, &block)
    raise(NoMethodError, "undefined method `%s' for %s:Class" % [m, self.class]) unless (Enumerator.instance_methods(false) + Enumerable.instance_methods).include?(m)
    processing_chain.send(m, *args, &block)
  end
end
