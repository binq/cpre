module Cpre::Validations
  module ClassMethods
    include Cpre::Utilities
    
    #Checks to see if the values for MAIN_ARGS returned from the block are valid, otherwise it will pick default values.  
    #Works by taking the values from the block, and zipping with the default values then zipping again
    #with the validation methods.  The result with be an array with elements that look 
    #like this: [[from_block, default_value], method_name].  This result is then collected with the block
    #that will return the object or the default if the validation fails.
    def scrub_arguments
      raise ArgumentError unless block_given?
      yield.zip(default_args).zip(validation_methods).collect { |pick, meth| send(meth, pick[0]) ? pick[0] : pick[1] }
    end

    def validation_methods
      Cpre::MAIN_ARGS.collect { |i| "valid_%s?" % [i] }
    end
    
    def valid_collect?(collect)
      collect.is_a?(Proc)
    end

    alias_method :valid_sources?, :is_all_enums?

    def valid_filters?(filters)
      filters.is_a?(Array) && filters.length > 0 && filters.all? { |i| i.is_a?(Proc) }
    end

    def valid_options?(options)
      (options - Cpre::MAIN_ARGS.collect(&:to_sym) == []).tap do |result|
        raise ArgumentError unless result
      end
    end
  end
  
  module InstanceMethods
    def valid?
      Cpre::MAIN_ARGS.collect { |i| send("valid_%s?" % [i]) }
    end
  end
  
  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
      include InstanceMethods

      Cpre::MAIN_ARGS.each do |i|
        define_method("valid_%s?" % [i]) { self.class.send(send(i)) }
      end
    end
  end
end

Cpre.class_eval { include self::Validations }
