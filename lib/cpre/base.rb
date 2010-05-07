class Cpre
  include Enumerable
  
  attr_reader :collect, :sources, :filters, :generators
  
  def initialize(*args)
    @collect, @sources, @filters = scrub_arguments do
      #If the call does not have any arguments the result will be nils.
      args.empty? ? [nil, nil, nil] :

      #If args is a Array of Enumerables it is must be @sources.
      is_all_enums?(args) ? [nil, args, nil] : 

      #if args.first is a Array of Enumerables it is must be @sources.
      is_all_enums?(args.first) ? [nil, args.first, nil] : 

      #TODO handle all the different senarios for when args.first is an array of enums
      #TODO handle all the different senarios for when args.first is a Proc (the collect)
      #TODO handle the senario for when args.first is a Array of non-enumerables (the filters)
      
      #if all else fails the result will be nils.
      [nil, nil, nil]
    end

    @generators = @sources.collect { |i| Generator.new(i) }
  end
  
  def each
    return self unless block_given?

    return if generators.any? { |generator| generator.end? }
    current_list = generators.collect { |generator| generator.next }

    loop do
      yield(current_list)

      current_list = generators.zip(current_list).inject(:finding => true, :current_list => []) { |result, pair| 
        generator, current = pair
        result.tap do
          if result[:finding]
            if generator.next?
              result[:current_list] << generator.next
              result[:finding] = false
            else
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






























