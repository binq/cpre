module Cpre::Validations
  module ClassMethods
    #Checks to see if the values for given_args are valid, otherwise it will pick default values.  
    #Works by taking given_args, and zipping it the default values then zipping again
    #with the validation methods.  The result with be an array with elements that look 
    #like this: [[from_given_args, default_value], method_name].  This result is then collected with the block
    #that will return the given_arg or the default if the validation fails.
    def scrub_options(options)
      new_values = options.
        values_at(*Cpre::MAIN_ARGS.collect { |i| i.to_sym }). # pick[0]
        zip(default_args). # pick[1]
        zip(validation_methods). # meth
        collect { |pick, meth| send(meth, pick[0]) ? pick[0] : pick[1] }

      Hash[*Cpre::MAIN_ARGS.collect { |i| i.to_sym }.zip(new_values).inject([], &flatten_pair)].tap do |result|
        correct_names_length?(*result.values_at(:names, :sources)) 
      end
    end

    def validation_methods
      Cpre::MAIN_ARGS.collect { |i| "valid_%s?" % [i] }
    end
    
    def valid_sources?(sources)
      return false if sources.nil?
      sources.is_a?(Array) && sources.all? { |source| valid_source?(source) } or raise ArgumentError
    end

    def valid_source?(source)
      source.respond_to?(:each) || source.is_a?(Proc) or raise ArgumentError
    end

    def valid_collect?(collect)
      return false if collect.nil?
      collect.is_a?(Proc) or raise ArgumentError
    end

    def valid_filters?(filters)
      return false if filters.nil?
      filters.is_a?(Array) && filters.length > 0 && filters.all? { |i| i.is_a?(Proc) } or raise ArgumentError
    end
    
    def valid_names?(names)
      names.nil? || names.is_a?(Array) && names.all? { |i| i.is_a?(String) && i.match(/^([a-z_][a-z0-9_]+)$/) } or raise ArgumentError
    end
    
    def correct_names_length?(names, sources)
      names.nil? || names.length == sources.length or raise ArgumentError
    end
  end
  
  module InstanceMethods
    def scrub_options(options)
      self.class.scrub_options(options)
    end
    
    def valid_options?(options)
      options.keys.collect(&:to_s) - Cpre::MAIN_ARGS == []
    end
  end
  
  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
end

Cpre.class_eval { include self::Validations }
