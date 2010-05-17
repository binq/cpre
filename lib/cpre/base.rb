class Cpre
  MAIN_ARGS = %w(collect sources filters names)

  include Enumerable
  
  MAIN_ARGS.each { |i| attr_reader i }

  def initialize(*args, &block)
    raise ArgumentError unless args.empty? || args.length == 1 && args.first.is_a?(Hash) && valid_options?(args.first)
    options = block_given? ? update_options(scrub_options(args.first), &block) : scrub_options(args.first)
    @collect, @sources, @filters = options.values_at(*MAIN_ARGS.collect { |i| i.to_sym })
  end
  
  def accepted_by_filters?(result)
    filters.inject(true) { |memo, filter| memo &&= result.instance_eval(&filter) }
  end
  
  def each
    return self unless block_given? && sources.length > 0

    generators = sources.collect { |i| Enumerator.new(i) }

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
