class Cpre
  MAIN_ARGS = %w(collect sources filters)
  
  include Enumerable
  
  (MAIN_ARGS + [:generators]).each { |i| attr_reader i }

  def initialize(*args)
    parse_collect = lambda do |a, o|
      o[:collect] ? [{:collect => o.delete(:collect)}, o, a] :
      [{}, o, a] 
    end

    parse_sources = lambda do |a, o|
      o[:sources] ? [{:sources => o.delete(:sources)}, o, a] :
      is_all_enums?(a) ? [{:sources => a}, o, []] : 
      a.length == 1 && is_all_enums?(a.first) ? [{:sources => a.shift}, o, a] : 
      [{:sources => [a]}, o, []]
    end
    
    parse_filters = lambda do |a, o|
      o[:filters] ? [{:filters => o.delete(:filters)}, o, a] :
      a.last.is_a?(Proc) ? [{:filters => [a.pop]}, o, a] : 
      a.last.is_a?(Array) && a.last.all? { |i| i.is_a?(Proc) } ? [{:filters => a.pop}, o, a] : 
      [{}, o, a] 
    end
    
    parse_options = lambda do |a, o|
      a.last.is_a?(Hash) && valid_options?(a.last) ? [{}, o.merge(a.pop), a] : 
      [{}, o, a] 
    end

    @collect, @sources, @filters, @options = self.class.scrub_arguments do
      [parse_options, parse_filters, parse_collect, parse_sources].inject(:args => args, :options => {}, :result => {}) do |memo, p|
        result, memo[:options], memo[:args] = p.call(*memo.values_at(:args, :options))
        memo[:result].update(result)
        memo
      end[:result].values_at(:collect, :sources, :filters)
    end

    @generators = @sources.collect { |i| Enumerator.new(i) }
  end
  
  def accepted_by_filters?(result)
    filters.inject(true) do |memo, filter|
      memo &&= result.instance_eval(&filter)
    end
  end
  
  def each
    return self unless block_given? && generators.length > 0

    current_list = generators.collect do |generator|
      begin
        generator.next
      rescue StopIteration
        return
      end
    end

    loop do
      OpenStruct.new(:items => current_list).tap do |result|
        yield(result.instance_eval(&collect)) if accepted_by_filters?(result)
      end

      current_list = generators.zip(current_list).inject(:finding => true, :current_list => []) { |result, pair| 
        generator, current = pair
        result.tap do
          if result[:finding]
            begin
              result[:current_list] << generator.next
              result[:finding] = false
            rescue StopIteration
              return if generator == generators.last
              result[:current_list] << generator.rewind.next
            end
          else
            result[:current_list] << current
          end  
        end
      }[:current_list]
    end
  end
end


=begin
def initialize(*args)
  #Parse in arguments into instance variables: @collect need to be a proc, 
  #@sources need to be a Hash of Enumerables, and @filters need to be an
  #array of procs
  @collect, @sources, @filters = case args.length
  when 3
    #this fits perfectly with what we are looking for
    args 
  when 2
    #If the first argument is a Proc it is must be @collect, and @sources musts be the
    #next argument.
    args[0].is_a?(Proc) ? [args[0], args[1], nil] :

    #If the first argument is a Hash it is must be @sources, and @filters musts be the
    #next argument.
    args[0].is_a?(Hash) ? [nil, args[0], args[1]] : 

    #If the first argument is a Array of Enumerables it is must be @sources.  It will 
    #be turned into a Hash using array2hash() and @filters musts be the next argument.
    is_all_enums?(args[0]) ? [nil, array2hash(args[0]), args[1]] :

    #If the first argument is an Enumerable it is must be @sources.  It will 
    #be turned into a Hash using array2hash() and @filters musts be the next argument.
    is_enum?(args[0]) ? [nil, array2hash([args[0]]), args[1]] :

    #At this point all options have been exhausted and nils will be returned.
    [nil, nil, nil]
  when 1
    [nil, args.first, nil]
  else 
    [nil, nil, nil]
  end

  check_arguments
end
=end